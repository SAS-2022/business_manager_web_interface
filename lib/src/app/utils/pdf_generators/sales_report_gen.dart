import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/constants/app_constants.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/pdf_generators/sales_invoice_pdf.dart';
import 'package:business_manager_web_ui/src/models/order_model.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Product {
  final String? id;
  final String? name;
  final double? price;
  final int? quantity;

  Product({this.id, this.name, this.price, this.quantity});
}

Future<PdfDocument> generateSalesReport({
  required String uid,
  required int startDate,
  required int endDate,
  required String companyName,
  required String? logoUrl,
  required List<Orders> orders,
  required AppLocalizations appLoc,
  required ResponsiveUtils responsive,
  required String? currencySymbol,
}) async {
  // ── All logic unchanged ────────────────────────────────────────────────────
  final bool isRTL = RTLayoutHelper.isRTLRequired(appLoc);
  final fonts = await _loadFonts();
  final PdfFont headerFont = fonts['header']!;
  final PdfFont subHeaderFont = fonts['subHeader']!;
  final PdfFont regularFont = fonts['regular']!;
  final PdfFont boldFont = fonts['bold']!;

  final PdfDocument document = PdfDocument();
  ConstantStrings constStrings = ConstantStrings();
  Map<String, Orders> cancelledOrder = {}, activeOrder = {};

  double calculateOrderTotal(Orders order) {
    if (order.orderedProducts == null || order.orderedProducts!.isEmpty) {
      return 0.0;
    }
    return order.orderedProducts!.values.fold(0.0, (sum, product) {
      if (order.status == constStrings.cancel) {
        cancelledOrder[order.uid!] = order;
        return sum;
      }
      final price = product.price;
      final quantity = product.quantity;
      activeOrder[order.uid!] = order;
      return sum + (price! * quantity!);
    });
  }

  PdfPage page = document.pages.add();
  PdfGraphics graphics = page.graphics;
  final double pageWidth = page.getClientSize().width;
  final double pageHeight = page.getClientSize().height;

  // Load logo — unchanged
  PdfBitmap? logoImage;
  if (logoUrl != null && logoUrl.isNotEmpty) {
    try {
      final response = await http.get(Uri.parse(logoUrl));
      if (response.statusCode == 200) {
        logoImage = PdfBitmap(response.bodyBytes);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  final dateFormat = DateFormat('dd MMM yyyy');
  final startFormatted =
      dateFormat.format(DateTime.fromMillisecondsSinceEpoch(startDate));
  final endFormatted =
      dateFormat.format(DateTime.fromMillisecondsSinceEpoch(endDate));

  double totalValue =
      orders.fold(0, (sum, order) => sum + calculateOrderTotal(order));

  // ── Grid setup — logic unchanged, visual tweaks only ──────────────────────

  final PdfGrid grid = PdfGrid();
  grid.columns.add(count: 6);
  final PdfGridRow headerRow = grid.headers.add(1)[0];
  List<String> headers = [];

  // Fixed (unscaled) widths — a PDF page has a fixed physical size
  // regardless of the browser's viewport, so ResponsiveUtils.scaleWidth()
  // (clamped for on-screen UI layout up to a 480px reference) is the wrong
  // scale here: on a typical wide desktop viewport it inflates these
  // widths ~28% past mobile's near-1:1 scaling (screen width ≈ the 375px
  // baseWidth), pushing the column total past the page's usable width and
  // clipping the last column. Raw values match mobile's real-world output.
  if (isRTL) {
    grid.columns[0].width = 50;
    grid.columns[1].width = 80;
    grid.columns[2].width = 50;
    grid.columns[3].width = 100;
    grid.columns[4].width = 60;
    grid.columns[5].width = 60;
  } else {
    grid.columns[0].width = 60;
    grid.columns[1].width = 60;
    grid.columns[2].width = 100;
    grid.columns[3].width = 50;
    grid.columns[4].width = 80;
    grid.columns[5].width = 50;
  }

  if (!isRTL) {
    headers = [
      appLoc.date,
      appLoc.invoiceNumber,
      appLoc.clientName,
      appLoc.productCount,
      appLoc.totalValue,
      appLoc.status,
    ];
  } else {
    headers = [
      appLoc.status,
      appLoc.totalValue,
      appLoc.productCount,
      appLoc.clientName,
      appLoc.invoiceNumber,
      appLoc.date,
    ];
  }

  for (int i = 0; i < headers.length; i++) {
    headerRow.cells[i].value = headers[i];
    headerRow.cells[i].style.font = boldFont;
    headerRow.cells[i].style.stringFormat =
        RTLayoutHelper.getTextFormat(isRTL, headers[i]);
    if (ArabicTextHelper.isArabic(headers[i])) {
      headerRow.cells[i].style.stringFormat =
          ArabicTextHelper.arabicGridTextFormat;
    }
  }

  // Header style — darker, more professional blue
  headerRow.style = PdfGridRowStyle(
    backgroundBrush: PdfSolidBrush(PdfColor(21, 101, 192)), // #1565C0
    textBrush: PdfBrushes.white,
    font: boldFont,
  );

  for (int i = 0; i < orders.length; i++) {
    final PdfGridRow row = grid.rows.add();
    final order = orders[i];

    List<dynamic> cellValues = [
      dateFormat.format(order.scheduledDate ?? order.orderedAt!),
      order.uid ?? 'N/A',
      order.clientName ?? 'N/A',
      order.orderedProducts?.length.toString() ?? '0',
      '$currencySymbol${calculateOrderTotal(order).toStringAsFixed(2)}',
      order.status == constStrings.cancel ? appLoc.cancelled : appLoc.active,
    ];

    for (int j = 0; j < cellValues.length; j++) {
      int cellIndex = isRTL ? (cellValues.length - 1 - j) : j;
      row.cells[cellIndex].value = cellValues[j];
      final cellValue = cellValues[j].toString();
      row.cells[cellIndex].style.stringFormat =
          RTLayoutHelper.getTextFormat(isRTL, cellValue);
      if (j == 2 && ArabicTextHelper.isArabic(cellValue)) {
        row.cells[cellIndex].style.stringFormat =
            ArabicTextHelper.arabicGridTextFormat;
      }
    }

    if (order.status == constStrings.cancel) {
      // Softer cancelled row — light red tint instead of solid indianRed
      row.style = PdfGridRowStyle(
        font: regularFont,
        backgroundBrush: PdfSolidBrush(PdfColor(255, 235, 238)),
        textBrush: PdfSolidBrush(PdfColor(183, 28, 28)),
      );
    } else {
      // Alternating rows — white / very light grey
      final bg =
          i.isEven ? PdfBrushes.white : PdfSolidBrush(PdfColor(245, 248, 255));
      row.style = PdfGridRowStyle(
        font: regularFont,
        backgroundBrush: bg,
        textBrush: PdfBrushes.black,
      );
    }
  }

  grid.style = PdfGridStyle(
    cellPadding: PdfPaddings(left: 6, right: 6, top: 6, bottom: 6),
    font: PdfStandardFont(PdfFontFamily.helvetica, 10),
  );

  // ── Page layout — tighter header, no fixed-bottom footer ──────────────────

  const double margin = 50.0;
  const double logoSize = 56.0;
  double yPos = margin;

  // ── Header block ──────────────────────────────────────────────────────────

  // Logo — left side, square crop
  if (logoImage != null) {
    final double logoX = isRTL ? pageWidth - margin - logoSize : margin;
    graphics.drawImage(
      logoImage,
      Rect.fromLTWH(logoX, yPos, logoSize, logoSize),
    );
  }

  // Company name — right of logo (or left for RTL)
  final double textX = isRTL ? margin : margin + logoSize + 14;
  final double textW = pageWidth - margin * 2 - logoSize - 14;

  graphics.drawString(
    companyName,
    headerFont,
    bounds: Rect.fromLTWH(textX, yPos, textW, 28),
    format: ArabicTextHelper.getFormatForText(companyName),
  );
  yPos += 28;

  // "Sales Report" subtitle
  graphics.drawString(
    appLoc.salesReport,
    subHeaderFont,
    bounds: Rect.fromLTWH(textX, yPos, textW, 20),
    format: ArabicTextHelper.getFormatForText(appLoc.salesReport),
  );
  yPos += 20;

  // Date range
  final String dateRangeText =
      '${appLoc.from} $startFormatted  ${appLoc.to}  $endFormatted';
  graphics.drawString(
    dateRangeText,
    fonts['small']!,
    bounds: Rect.fromLTWH(textX, yPos, textW, 16),
    format: ArabicTextHelper.getFormatForText(appLoc.date),
  );

  // Align yPos to bottom of logo block + gap
  yPos = margin + logoSize + 16;

  // Thin rule under header
  graphics.drawLine(
    PdfPen(PdfColor(21, 101, 192), width: 0.8),
    Offset(margin, yPos),
    Offset(pageWidth - margin, yPos),
  );
  yPos += 10;

  // ── Summary chips (total orders / active / cancelled) ─────────────────────

  final int totalOrders = orders.length;
  final int cancelledCount = cancelledOrder.length;
  final int activeCount = activeOrder.length;

  _drawChip(graphics, fonts['small']!, '${appLoc.totalOrders}: $totalOrders',
      margin, yPos,
      bg: PdfColor(227, 242, 253), textColor: PdfColor(13, 71, 161));
  _drawChip(graphics, fonts['small']!, '${appLoc.active}: $activeCount',
      margin + 120, yPos,
      bg: PdfColor(232, 245, 233), textColor: PdfColor(27, 94, 32));
  if (cancelledCount > 0) {
    _drawChip(graphics, fonts['small']!, '${appLoc.cancelled}: $cancelledCount',
        margin + 240, yPos,
        bg: PdfColor(255, 235, 238), textColor: PdfColor(183, 28, 28));
  }
  yPos += 28;

  // Thin rule
  graphics.drawLine(
    PdfPen(PdfColor(200, 200, 200), width: 0.4),
    Offset(margin, yPos),
    Offset(pageWidth - margin, yPos),
  );
  yPos += 10;

  // ── Draw grid — logic completely unchanged ─────────────────────────────────

  bool isComplete = false;
  int pageCount = 1;
  Rect bounds = Rect.fromLTWH(
      margin, yPos, pageWidth - margin * 2, pageHeight - yPos - 60);

  PdfLayoutResult? gridResult;

  while (!isComplete && pageCount <= 10) {
    gridResult = grid.draw(
      page: page,
      bounds: bounds,
    ) as PdfLayoutResult;

    int drawnRows = grid.rows.count;
    if (drawnRows < orders.length) {
      page = document.pages.add();
      pageCount++;
      yPos = margin;
      bounds = Rect.fromLTWH(
          margin, yPos, pageWidth - margin * 2, pageHeight - yPos - 60);

      if (logoImage != null) {
        graphics = page.graphics;
        graphics.drawImage(
          logoImage,
          Rect.fromLTWH(
              pageWidth - margin - logoSize, margin, logoSize, logoSize),
        );
      }
      for (int i = 0; i < drawnRows; i++) {}
    } else {
      isComplete = true;
    }
  }

  // ── Footer — placed immediately after grid, not pinned to page bottom ──────

  final PdfPage lastPage = document.pages[document.pages.count - 1];
  graphics = lastPage.graphics;

  // Calculate where grid ended
  double footerY =
      gridResult != null ? gridResult.bounds.bottom + 16 : pageHeight - 80;

  // Thin rule above footer
  graphics.drawLine(
    PdfPen(PdfColor(21, 101, 192), width: 0.6),
    Offset(margin, footerY),
    Offset(pageWidth - margin, footerY),
  );
  footerY += 10;

  // Total sales value — left
  graphics.drawString(
    '${appLoc.totalSalesValue}:  $currencySymbol${totalValue.toStringAsFixed(2)}',
    fonts['footerBold']!,
    bounds: Rect.fromLTWH(margin, footerY, pageWidth * 0.6, 20),
    format: ArabicTextHelper.getFormatForText(appLoc.invoice),
  );

  // Page numbers on every page
  for (int i = 0; i < document.pages.count; i++) {
    final PdfPage currentPage = document.pages[i];
    final pg = currentPage.graphics;
    pg.drawString(
      'Page ${i + 1} of ${document.pages.count}',
      fonts['small']!,
      bounds: Rect.fromLTWH(
        pageWidth - margin - 80,
        currentPage.getClientSize().height - 30,
        80,
        20,
      ),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );
  }

  return document;
}

// ── Chip helper ────────────────────────────────────────────────────────────────

void _drawChip(
  PdfGraphics graphics,
  PdfFont font,
  String text,
  double x,
  double y, {
  required PdfColor bg,
  required PdfColor textColor,
}) {
  const double h = 18, w = 110;
  graphics.drawRectangle(
    bounds: Rect.fromLTWH(x, y, w, h),
    pen: PdfPen(bg),
    brush: PdfSolidBrush(bg),
  );
  graphics.drawString(
    text,
    font,
    bounds: Rect.fromLTWH(x + 6, y + 3, w - 8, h - 4),
    brush: PdfSolidBrush(textColor),
    format: PdfStringFormat(alignment: PdfTextAlignment.left),
  );
}

// ── Font loading — unchanged ───────────────────────────────────────────────────

Future<Map<String, PdfFont>> _loadFonts() async {
  try {
    final ByteData fontData =
        await rootBundle.load('assets/fonts/amiri/Amiri-Regular.ttf');
    final List<int> fontBytes = fontData.buffer.asUint8List();

    return {
      'header': PdfTrueTypeFont(fontBytes, 16, style: PdfFontStyle.bold),
      'subHeader': PdfTrueTypeFont(fontBytes, 11, style: PdfFontStyle.bold),
      'regular': PdfTrueTypeFont(fontBytes, 8),
      'bold': PdfTrueTypeFont(fontBytes, 9, style: PdfFontStyle.bold),
      'small': PdfTrueTypeFont(fontBytes, 7),
      'footerBold': PdfTrueTypeFont(fontBytes, 9, style: PdfFontStyle.bold),
    };
  } catch (e) {
    return {
      'header': PdfStandardFont(PdfFontFamily.timesRoman, 16,
          style: PdfFontStyle.bold),
      'subHeader': PdfStandardFont(PdfFontFamily.timesRoman, 11,
          style: PdfFontStyle.bold),
      'regular': PdfStandardFont(PdfFontFamily.timesRoman, 8),
      'bold': PdfStandardFont(PdfFontFamily.timesRoman, 9,
          style: PdfFontStyle.bold),
      'small': PdfStandardFont(PdfFontFamily.timesRoman, 7),
      'footerBold': PdfStandardFont(PdfFontFamily.timesRoman, 9,
          style: PdfFontStyle.bold),
    };
  }
}
