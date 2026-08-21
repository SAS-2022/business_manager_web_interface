import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/pdf_generators/sales_invoice_pdf.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:http/http.dart' as http;

Future<PdfDocument> generateInventoryReport({
  required String uid,
  required String companyName,
  required List<Map<String, dynamic>> items,
  required String? location,
  required List<String?> allLocations,
  required String? logoUrl,
  required AppLocalizations appLoc,
  required ResponsiveUtils responsive,
  required String? currencySymbol,
}) async {
  // Determine if RTL layout is needed
  final bool isRTL = RTLayoutHelper.isRTLRequired(appLoc);
  // Create a new PDF document
  final PdfDocument document = PdfDocument();
  //total value of all stock
  double? totalValue = 0;

  // Add a page to the document
  PdfPage page = document.pages.add();
  PdfGraphics graphics = page.graphics;

  // Load the company logo if available
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

  // Create PDF grid for the order data
  final PdfGrid grid = PdfGrid();
  grid.columns.add(count: 5);

  // Fixed (unscaled) widths — see sales_report_gen.dart's generateSalesReport
  // for why: a PDF page's physical size doesn't depend on the browser's
  // viewport, so ResponsiveUtils.scaleWidth() (built for on-screen UI
  // layout) over-inflates these on a wide desktop window and clips the
  // last column.
  if (isRTL) {
    grid.columns[4].width = 60;
    grid.columns[3].width = 110;
    grid.columns[2].width = 70;
    grid.columns[1].width = 70;
    grid.columns[0].width = 90;
  } else {
    grid.columns[0].width = 60;
    grid.columns[1].width = 110;
    grid.columns[2].width = 70;
    grid.columns[3].width = 70;
    grid.columns[4].width = 90;
  }

  // Add header row
  final PdfGridRow headerRow = grid.headers.add(1)[0];
  if (!isRTL) {
    headerRow.cells[0].value = appLoc.code;
    headerRow.cells[1].value = appLoc.productName;
    headerRow.cells[2].value = appLoc.productStock;
    headerRow.cells[3].value = appLoc.productCost;
    headerRow.cells[4].value = appLoc.totalValue;
  } else {
    headerRow.cells[4].value = appLoc.code;
    headerRow.cells[3].value = appLoc.productName;
    headerRow.cells[2].value = appLoc.productStock;
    headerRow.cells[1].value = appLoc.productCost;
    headerRow.cells[0].value = appLoc.totalValue;
  }

  // Style the header
  headerRow.style = PdfGridRowStyle(
    backgroundBrush: PdfSolidBrush(PdfColor(33, 150, 243)),
    textBrush: PdfBrushes.white,
    font:
        PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
  );

  final ByteData fontData =
      await rootBundle.load('assets/fonts/amiri/Amiri-Regular.ttf');
  final Uint8List fontBytes = fontData.buffer.asUint8List();
  final PdfFont arabicFont = PdfTrueTypeFont(fontBytes, 10);

  // Add order data rows
  for (int i = 0; i < items.length; i++) {
    final PdfGridRow row = grid.rows.add();
    double? total = 0;
    final product = items[i];

    total = product['stock'] * product['cost'];
    totalValue = totalValue! + total!;
    if (!isRTL) {
      row.cells[0].value = product['id'];
      row.cells[1].value = product['name'];
      row.cells[2].value = product['stock'].toStringAsFixed(2);
      row.cells[3].value = product['cost'].toStringAsFixed(2);
      row.cells[4].value = '$currencySymbol ${total.toStringAsFixed(2)}';
    } else {
      row.cells[4].value = product['id'];
      row.cells[3].value = product['name'];
      row.cells[2].value = product['stock'].toStringAsFixed(2);
      row.cells[1].value = product['cost'].toStringAsFixed(2);
      row.cells[0].value = '$currencySymbol ${total.toStringAsFixed(2)}';
    }

    //row.cells[0].style.font = arabicFont;

    // Alternate row colors using the loop index
    if (i % 2 == 0) {
      row.style = PdfGridRowStyle(
        backgroundBrush: PdfSolidBrush(PdfColor(245, 245, 245)),
      );
    }
  }

  // Set grid style
  grid.style = PdfGridStyle(
    cellPadding: PdfPaddings(left: 5, right: 5, top: 5, bottom: 5),
    font: PdfStandardFont(PdfFontFamily.helvetica, 10),
  );

  // Draw the report header
  final PdfFont headerFont =
      PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold);
  final PdfFont subHeaderFont = PdfStandardFont(PdfFontFamily.helvetica, 12);

  // Current y position on page
  double yPos = 40;

  // Add logo if available
  if (logoImage != null) {
    graphics.drawImage(
      logoImage,
      Rect.fromLTWH(
        page.getClientSize().width - 120,
        yPos,
        100,
        100,
      ),
    );
  }

  // Add company name and report title
  graphics.drawString(
    companyName,
    headerFont,
    bounds: Rect.fromLTWH(50, yPos, page.getClientSize().width - 100, 30),
    format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle),
  );
  yPos += 30;

  graphics.drawString(
    appLoc.inventoryReport,
    headerFont,
    bounds: Rect.fromLTWH(50, yPos, page.getClientSize().width - 100, 30),
    format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle),
  );
  yPos += 40;
  graphics.drawString(
    appLoc.storeName,
    subHeaderFont,
    bounds: Rect.fromLTWH(50, yPos, page.getClientSize().width - 100, 30),
    format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle),
  );
  graphics.drawString(
    location ?? allLocations.toString(),
    subHeaderFont,
    bounds: Rect.fromLTWH(150, yPos, page.getClientSize().width - 100, 30),
    format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle),
  );
  yPos += 40;

  // Draw the grid with proper pagination handling
  bool isComplete = false;
  int pageCount = 1;
  Rect bounds = Rect.fromLTWH(50, yPos, page.getClientSize().width - 100,
      page.getClientSize().height - yPos - 80);

  while (!isComplete && pageCount <= 10) {
    // Max 10 pages safety limit
    // Draw grid and get the result
    grid.draw(
      page: page,
      bounds: bounds,
    ) as PdfLayoutResult;

    // For Syncfusion PDF, we need to track rows manually
    int drawnRows = grid.rows.count;
    if (drawnRows < items.length) {
      // Create new page
      page = document.pages.add();
      pageCount++;
      yPos = 40;
      bounds = Rect.fromLTWH(50, yPos, page.getClientSize().width - 100,
          page.getClientSize().height - yPos - 80);

      // Add logo to new page
      if (logoImage != null) {
        graphics = page.graphics;
        graphics.drawImage(logoImage,
            Rect.fromLTWH(page.getClientSize().width - 120, yPos, 100, 100));
      }

      // Remove already drawn rows
      for (int i = 0; i < drawnRows; i++) {
        //grid.rows.removeAt(0);
      }
    } else {
      isComplete = true;
    }
  }

  // Add total value at the bottom
  final PdfPage lastPage = document.pages[document.pages.count - 1];
  graphics = lastPage.graphics;

  graphics.drawString(
    '${appLoc.totalSalesValue}: $currencySymbol${totalValue?.toStringAsFixed(2)}',
    arabicFont,
    bounds: Rect.fromLTWH(50, lastPage.getClientSize().height - 50,
        page.getClientSize().width - 100, 30),
    format: PdfStringFormat(
        lineAlignment: PdfVerticalAlignment.middle,
        alignment: PdfTextAlignment.right),
  );

  // Add page numbers
  for (int i = 0; i < document.pages.count; i++) {
    final PdfPage currentPage = document.pages[i];
    graphics = currentPage.graphics;

    graphics.drawString(
      'Page ${i + 1} of ${document.pages.count}',
      PdfStandardFont(PdfFontFamily.helvetica, 10),
      bounds: Rect.fromLTWH(50, currentPage.getClientSize().height - 30,
          currentPage.getClientSize().width - 100, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
  }

  return document;
}
