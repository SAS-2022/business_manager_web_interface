import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/models/client_model.dart';
import 'package:business_manager_web_ui/src/models/order_model.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/client_service.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart' hide PdfTextElement;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sfpdf;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

// ── Design constants ──────────────────────────────────────────────────────────
const double _kMargin = 40.0;
const double _kLogoSize = 56.0;
const double _kHeaderBgH = 100.0;

Future<PdfDocument> generateSalesInvoice({
  required UserDetails currentUser,
  required InvoiceSettings invoiceSettings,
  required Orders order,
  required String termsAndConditions,
  required AppLocalizations appLoc,
}) async {
  final bool isRTL = RTLayoutHelper.isRTLRequired(appLoc);
  // Guards every `order.orderedProducts!` below at once — in practice this
  // is only ever called for an order that passed OrderAddEdit's "at least
  // one product" validation, but a defensive fallback is cheap here.
  order.orderedProducts ??= {};
  ClientService cs = ClientService();
  final PdfDocument document = PdfDocument();
  int pageRows = 0;
  double pageTotal = 0.0, subTotal = 0.0;
  int currentPage = 0;

  final fonts = await _loadFonts();
  final PdfFont subHeaderFont = fonts['subHeader']!;
  final PdfFont regularFont = fonts['regular']!;
  final PdfFont boldFont = fonts['bold']!;
  final PdfFont smallFont = fonts['small']!;

  // Load logo once
  PdfBitmap? logoImage;
  if (currentUser.companyLogo != null && currentUser.companyLogo!.isNotEmpty) {
    try {
      final response = await http.get(Uri.parse(currentUser.companyLogo!));
      if (response.statusCode == 200) {
        logoImage = PdfBitmap(response.bodyBytes);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  for (int i = 0; i < order.orderedProducts!.length; i += 6) {
    currentPage++;
    PdfPage page = document.pages.add();
    PdfGraphics graphics = page.graphics;
    final double pageWidth = page.getClientSize().width;
    final double pageHeight = page.getClientSize().height;
    final double leftMargin =
        RTLayoutHelper.getLeftMargin(isRTL, pageWidth, _kMargin);
    final double rightMargin =
        RTLayoutHelper.getRightMargin(isRTL, pageWidth, _kMargin);

    if (7 + i <= order.orderedProducts!.length) {
      pageRows = 6 + i;
    } else {
      pageRows = order.orderedProducts!.length;
    }

    double yPos = 0;

    // ── Header: accent bar + white bg + logo + company name ─────────────────
    // Left green accent bar
    graphics.drawRectangle(
      bounds: const Rect.fromLTWH(0, 0, 6, _kHeaderBgH),
      brush: PdfSolidBrush(PdfColor(46, 125, 50)),
    );
    // Light background
    graphics.drawRectangle(
      bounds: Rect.fromLTWH(6, 0, pageWidth - 6, _kHeaderBgH),
      brush: PdfSolidBrush(PdfColor(250, 250, 250)),
    );

    // ── Logo ──────────────────────────────────────────────────────────────
    if (logoImage != null) {
      final double logoX = isRTL ? pageWidth - _kMargin - _kLogoSize : _kMargin;
      graphics.drawImage(
        logoImage,
        Rect.fromLTWH(
            logoX, (_kHeaderBgH - _kLogoSize) / 2, _kLogoSize, _kLogoSize),
      );
    }

    // ── Company name (large, bold) ─────────────────────────────────────────
    final double companyX = isRTL ? _kMargin : _kMargin + _kLogoSize + 14;
    final double companyW = pageWidth - _kMargin * 2 - _kLogoSize - 14;

    final String companyName = currentUser.companyName ?? '';
    graphics.drawString(
      companyName,
      fonts['companyName']!,
      bounds: Rect.fromLTWH(companyX, 14, companyW, 55),
      format: ArabicTextHelper.getFormatForText(companyName),
      brush: PdfSolidBrush(PdfColor(27, 94, 32)),
    );

    // ── Country · City only under the name ───────────────────────────────
    final StringBuffer sbLocation = StringBuffer();
    if (currentUser.address?.mapCountry != null) {
      sbLocation.write('${currentUser.address!.mapCountry}');
    }
    if (currentUser.address?.province != null) {
      sbLocation.write('  ·  ${currentUser.address!.province}');
    }
    final String locationLine = sbLocation.toString();

    if (locationLine.isNotEmpty) {
      graphics.drawString(
        locationLine,
        fonts['contact']!,
        bounds: Rect.fromLTWH(companyX, 54, companyW, 35),
        format: ArabicTextHelper.getFormatForText(locationLine),
        brush: PdfSolidBrush(PdfColor(66, 66, 66)),
      );
    }

    // ── Invoice number badge ──────────────────────────────────────────────
    final String invoiceLabel = '${appLoc.invoice}  #${order.uid ?? ''}';
    graphics.drawString(
      invoiceLabel,
      fonts['invoiceBadge']!,
      bounds: Rect.fromLTWH(companyX, 74, companyW, 18),
      format: ArabicTextHelper.getFormatForText(invoiceLabel),
      brush: PdfSolidBrush(PdfColor(46, 125, 50)),
    );

    yPos = _kHeaderBgH + 14;

    // ── Two-column meta block ─────────────────────────────────────────────
    // Left col: Invoice number + date  |  Right col: Client details

    final double colW = (pageWidth - _kMargin * 2 - 20) / 2;
    final double col1X = isRTL ? pageWidth - _kMargin - colW : _kMargin;
    final double col2X = isRTL ? _kMargin : _kMargin + colW + 20;

    // Left — invoice meta grid
    final PdfGrid infoGrid = PdfGrid();
    infoGrid.columns.add(count: 2);
    infoGrid.style.cellPadding =
        PdfPaddings(left: 4, right: 4, top: 3, bottom: 3);
    infoGrid.columns[0].width = isRTL ? 65 : 70;
    infoGrid.columns[1].width = isRTL ? 75 : 80;

    _addInfoRow(infoGrid, '${appLoc.number}:', order.uid ?? 'N/A', boldFont,
        regularFont, isRTL);
    _addInfoRow(
        infoGrid,
        '${appLoc.date}:',
        order.orderedAt != null
            ? DateFormat('dd/MM/yyyy').format(order.orderedAt!)
            : DateFormat('dd/MM/yyyy').format(DateTime.now()),
        boldFont,
        regularFont,
        isRTL);

    infoGrid.draw(
      page: page,
      bounds: Rect.fromLTWH(col1X, yPos, colW, 0),
    );

    // Right — client details
    double clientY = yPos;
    graphics.drawString(
      appLoc.clientDetails,
      boldFont,
      bounds: Rect.fromLTWH(col2X, clientY, colW, 20),
      format: ArabicTextHelper.getFormatForText(appLoc.clientDetails),
    );
    clientY += 14;
    graphics.drawString(
      order.clientName ?? '',
      regularFont,
      bounds: Rect.fromLTWH(col2X, clientY, colW, 20),
      format: ArabicTextHelper.getFormatForText(order.clientName ?? ''),
    );
    clientY += 12;

    if (order.clientId != null) {
      ClientDetails? client =
          await cs.futureSingleClient(currentUser.uid, order.clientId);

      if (client.address != null && client.address!['street'] != null) {
        graphics.drawString(
          '${client.address!['street']}',
          smallFont,
          bounds: Rect.fromLTWH(col2X, clientY, colW, 20),
          format: ArabicTextHelper.getFormatForText(client.address!['street']),
        );
        clientY += 12;
      }

      if (invoiceSettings.clientFinancialDetails == null ||
          invoiceSettings.clientFinancialDetails == '1') {
        if (client.financialNumber != null &&
            client.financialNumber!.isNotEmpty) {
          graphics.drawString(
            '${appLoc.financialNumber}: ${client.financialNumber}',
            smallFont,
            bounds: Rect.fromLTWH(col2X, clientY, colW, 20),
            format: ArabicTextHelper.getFormatForText(
                '${appLoc.financialNumber}: ${client.financialNumber}'),
          );
          clientY += 12;
        }
      }

      if (invoiceSettings.clientCrNumber == null ||
          invoiceSettings.clientCrNumber == '1') {
        if (client.crNumber != null && client.crNumber!.isNotEmpty) {
          graphics.drawString(
            '${appLoc.crNumber}: ${client.crNumber}',
            smallFont,
            bounds: Rect.fromLTWH(col2X, clientY, colW, 20),
            format: ArabicTextHelper.getFormatForText(
                '${appLoc.crNumber}: ${client.crNumber}'),
          );
          clientY += 12;
        }
      }
    }

    // Financial details — right of client, same block if space allows
    if (invoiceSettings.companyFinancials == null ||
        invoiceSettings.companyFinancials == '1') {
      final bool hasFinancial = currentUser.bankName != null ||
          currentUser.bankBranch != null ||
          currentUser.ibanNumber != null ||
          currentUser.otherPayment != null;

      if (hasFinancial) {
        // Draw below invoice meta on left col
        double finY = yPos + 50;
        graphics.drawString(
          appLoc.financialDetails,
          boldFont,
          bounds: Rect.fromLTWH(col1X, finY, colW, 20),
          format: ArabicTextHelper.getFormatForText(appLoc.financialDetails),
        );
        finY += 13;
        for (final s in [
          currentUser.bankName,
          currentUser.bankBranch,
          currentUser.ibanNumber,
          currentUser.otherPayment,
        ]) {
          if (s != null && s.isNotEmpty) {
            graphics.drawString(
              s,
              smallFont,
              bounds: Rect.fromLTWH(col1X, finY, colW, 20),
              format: ArabicTextHelper.getFormatForText(s),
            );
            finY += 12;
          }
        }
      }
    }

    // Push yPos below whichever column is taller
    yPos = yPos + 70;

    // Thin rule before product table
    graphics.drawLine(
      PdfPen(PdfColor(46, 125, 50), width: 1.0),
      Offset(_kMargin, yPos),
      Offset(pageWidth - _kMargin, yPos),
    );
    yPos += 10;

    // ── Product grid — logic completely unchanged ──────────────────────────
    Map<String, dynamic> result = await _productGrid(
      appLoc,
      document,
      i,
      pageRows,
      currentUser,
      page,
      order,
      regularFont,
      boldFont,
      leftMargin,
      rightMargin,
      yPos,
      currentUser.currency != null
          ? currentUser.currency!['code'] ?? '\$'
          : '\$',
      logoImage,
      cs,
      isRTL,
    );
    yPos = result['yPos'] as double;
    page = result['page'] as PdfPage;
    graphics = result['graphics'] as PdfGraphics;
    pageTotal += result['pageTotal'];
    subTotal = result['pageTotal'];

    // Thin rule before totals
    graphics.drawLine(
      PdfPen(PdfColor(200, 200, 200), width: 0.4),
      Offset(_kMargin, yPos - 12),
      Offset(pageWidth - _kMargin, yPos - 12),
    );

    yPos = await _totalSection(
      appLoc,
      page,
      currentPage,
      order,
      yPos,
      currentUser.currency != null
          ? currentUser.currency!['code'] ?? '\$'
          : '\$',
      leftMargin,
      rightMargin,
      subTotal,
      pageTotal,
      regularFont,
      boldFont,
      isRTL,
    );

    // Thin rule after totals
    graphics.drawLine(
      PdfPen(PdfColor(200, 200, 200), width: 0.4),
      Offset(_kMargin, yPos + 8),
      Offset(pageWidth - _kMargin, yPos + 8),
    );
    yPos += 16;

    // ── Scheduled delivery — logic unchanged ──────────────────────────────
    yPos = await _schedueledDelivery(
        graphics,
        subHeaderFont,
        boldFont,
        order,
        page,
        appLoc,
        yPos,
        leftMargin,
        invoiceSettings,
        regularFont,
        pageWidth,
        isRTL);

    // ── Terms and conditions — logic unchanged ─────────────────────────────
    if (termsAndConditions.isNotEmpty && order.paymentTerms != null) {
      yPos = await _drawTermsAndConditions(
          graphics,
          termsAndConditions,
          subHeaderFont,
          regularFont,
          yPos,
          leftMargin,
          rightMargin,
          appLoc,
          order,
          page,
          boldFont,
          invoiceSettings,
          pageWidth,
          isRTL);
    }

    // ── Footer strip ──────────────────────────────────────────────────────
    final double footerY = pageHeight - 24;
    graphics.drawRectangle(
      bounds: Rect.fromLTWH(0, footerY, pageWidth, 24),
      brush: PdfSolidBrush(PdfColor(46, 125, 50)),
    );
    graphics.drawString(
      _buildFooterText(currentUser, currentPage, appLoc),
      fonts['smallWhite']!,
      bounds:
          Rect.fromLTWH(_kMargin, footerY + 5, pageWidth - _kMargin * 2, 16),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
      brush: PdfBrushes.white,
    );
  }

  return document;
}

// ── All helper functions — logic completely unchanged, only
//    _drawPageHeader removed (inlined above). Everything else identical. ──────

// ── Footer text helper ─────────────────────────────────────────────────────────
String _buildFooterText(UserDetails user, int page, AppLocalizations appLoc) {
  final parts = <String>['Page $page'];
  if (user.companyName != null) parts.add(user.companyName!);
  if (user.emailAddress != null) parts.add(user.emailAddress!);
  if (user.phoneNumber != null) {
    final code = user.phoneNumber!['code'] ?? '';
    final num = user.phoneNumber!['number'] ?? '';
    if (code.isNotEmpty || num.isNotEmpty) parts.add('$code $num'.trim());
  }
  return parts.join('  ·  ');
}

void _addInfoRow(PdfGrid grid, String label, String value, PdfFont boldFont,
    PdfFont regularFont, bool isRTL) {
  final row = grid.rows.add();
  row.height = 20;
  if (isRTL) {
    row.cells[1].value = label;
    row.cells[1].style.font = boldFont;
    if (ArabicTextHelper.isArabic(label)) {
      row.cells[1].style.stringFormat = ArabicTextHelper.arabicGridTextFormat;
    }
    row.cells[0].value = value;
    row.cells[0].style.font = regularFont;
    if (ArabicTextHelper.isArabic(value)) {
      row.cells[0].style.stringFormat = ArabicTextHelper.arabicGridTextFormat;
    }
  } else {
    row.cells[0].value = label;
    row.cells[0].style.font = boldFont;
    if (ArabicTextHelper.isArabic(label)) {
      row.cells[0].style.stringFormat = ArabicTextHelper.arabicGridTextFormat;
    }
    row.cells[1].value = value;
    row.cells[1].style.font = regularFont;
    if (ArabicTextHelper.isArabic(value)) {
      row.cells[1].style.stringFormat = ArabicTextHelper.arabicGridTextFormat;
    }
  }
}

void _addTotalRow(PdfGrid grid, String label, String value, PdfFont regularFont,
    PdfFont boldFont, bool isRtl,
    {bool isBold = false}) {
  final row = grid.rows.add();
  row.height = 20;
  if (isRtl) {
    row.cells[1].value = label;
    row.cells[1].style.font = isBold ? regularFont : boldFont;
    row.cells[1].style.cellPadding =
        PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);
    if (ArabicTextHelper.isArabic(label)) {
      row.cells[1].style.stringFormat = ArabicTextHelper.arabicGridTextFormat;
    }
    row.cells[0].value = value;
    row.cells[0].style.font = !isBold ? regularFont : boldFont;
    row.cells[0].style.stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.right,
      textDirection: ArabicTextHelper.isArabic(value)
          ? PdfTextDirection.rightToLeft
          : PdfTextDirection.leftToRight,
    );
    row.cells[0].style.cellPadding =
        PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);
  } else {
    row.cells[0].value = label;
    row.cells[0].style.font = !isBold ? regularFont : boldFont;
    row.cells[0].style.cellPadding =
        PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);
    if (ArabicTextHelper.isArabic(label)) {
      row.cells[0].style.stringFormat = ArabicTextHelper.arabicGridTextFormat;
    }
    row.cells[1].value = value;
    row.cells[1].style.font = !isBold ? regularFont : boldFont;
    row.cells[1].style.stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.right,
      textDirection: ArabicTextHelper.isArabic(value)
          ? PdfTextDirection.rightToLeft
          : PdfTextDirection.leftToRight,
    );
    row.cells[1].style.cellPadding =
        PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);
  }
}

double calculateOrderTotal(Orders order, {double deliveryCharges = 0.0}) {
  double total = 0.0;
  if (order.orderedProducts != null) {
    order.orderedProducts!.forEach((_, product) {
      total += (product.price)! * (product.quantity!);
    });
  }
  if (deliveryCharges > -1) total += deliveryCharges;
  return total;
}

Future<Map<String, dynamic>> _productGrid(
  AppLocalizations appLoc,
  PdfDocument document,
  int rowAt,
  int pageRows,
  UserDetails currentUser,
  PdfPage page,
  Orders order,
  PdfFont regularFont,
  PdfFont boldFont,
  double leftMargin,
  double rightMargin,
  double yPos,
  String currencyCode,
  PdfBitmap? logoImage,
  ClientService cs,
  bool isRTL,
) async {
  final double pageWidth = page.getClientSize().width;
  double pageTotal = 0.0;
  final number = NumberFormat("#,##0.00", "en_US");
  final availableHeight = page.getClientSize().height - yPos - 60;
  final PdfGrid productsGrid = PdfGrid();
  productsGrid.columns.add(count: 8);

  if (isRTL) {
    productsGrid.columns[7].width = 30;
    productsGrid.columns[6].width = 40;
    productsGrid.columns[5].width = 100;
    productsGrid.columns[4].width = 40;
    productsGrid.columns[3].width = 57;
    productsGrid.columns[2].width = 45;
    productsGrid.columns[1].width = 57;
    productsGrid.columns[0].width = 70;
  } else {
    productsGrid.columns[0].width = 30;
    productsGrid.columns[1].width = 40;
    productsGrid.columns[2].width = 100;
    productsGrid.columns[3].width = 40;
    productsGrid.columns[4].width = 57;
    productsGrid.columns[5].width = 45;
    productsGrid.columns[6].width = 57;
    productsGrid.columns[7].width = 70;
  }

  final PdfGridRow headerRow = productsGrid.headers.add(1)[0];
  headerRow.height = 22;

  List<String> headers = isRTL
      ? [
          appLoc.total,
          appLoc.discountedPrice,
          appLoc.discount,
          appLoc.price,
          appLoc.quantity,
          appLoc.productName,
          appLoc.id,
          appLoc.ref
        ]
      : [
          appLoc.ref,
          appLoc.id,
          appLoc.productName,
          appLoc.quantity,
          appLoc.price,
          appLoc.discount,
          appLoc.discountedPrice,
          appLoc.total
        ];

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
  // Green header
  headerRow.style = PdfGridRowStyle(
    backgroundBrush: PdfSolidBrush(PdfColor(46, 125, 50)),
    textBrush: PdfBrushes.white,
    font: boldFont,
  );

  if (order.orderedProducts != null) {
    int index = rowAt + 1;
    for (int i = rowAt; i < pageRows; i++) {
      dynamic product = order.orderedProducts!.values.elementAt(i);
      final row = productsGrid.rows.add();
      row.height = 40;

      List<dynamic> cellValues = [
        index.toString(),
        product.id.toString().length > 10
            ? product.id.toString().substring(0, 10)
            : product.id.toString(),
        product.name.length > 35
            ? '${product.name.toString().substring(0, 34)}\n${product.packing ?? ''}'
            : '${product.name}\n${product.packing ?? ''}',
        product.quantity.toString(),
        product.price > product.originalPrice
            ? number.format(product.price)
            : number.format(product.originalPrice),
        '%${product.discount ?? 0.00}',
        number.format(product.price),
        number.format(product.price * product.quantity),
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

      // Alternating rows
      row.style = PdfGridRowStyle(
        font: regularFont,
        backgroundBrush: i.isEven
            ? PdfBrushes.white
            : PdfSolidBrush(PdfColor(245, 248, 255)),
        textBrush: PdfBrushes.black,
      );

      pageTotal += product.price * product.quantity;
      index++;
    }
  }

  productsGrid.style = PdfGridStyle(
    cellPadding: PdfPaddings(left: 5, right: 5, top: 5, bottom: 5),
    font: regularFont,
  );

  final double gridWidth = pageWidth - leftMargin - rightMargin;
  final double gridX = isRTL ? rightMargin : leftMargin;

  final productsResult = productsGrid.draw(
    page: page,
    bounds: Rect.fromLTWH(gridX, yPos, gridWidth, availableHeight),
  );

  yPos += productsResult!.bounds.height + 12;
  return {
    'yPos': yPos,
    'page': page,
    'document': document,
    'graphics': page.graphics,
    'pageTotal': pageTotal,
  };
}

Future<double> _totalSection(
  AppLocalizations appLoc,
  PdfPage page,
  int currentPage,
  Orders order,
  double yPos,
  String currencyCode,
  double leftMargin,
  double rightMargin,
  double subTotal,
  double pageTotal,
  PdfFont regularFont,
  PdfFont boldFont,
  bool isRTL,
) async {
  final double pageWidth = page.getClientSize().width;
  final PdfGrid totalsGrid = PdfGrid();
  final number = NumberFormat("#,##0.00", "en_US");
  int totalPages = 0;

  totalsGrid.columns.add(count: 2);
  totalsGrid.columns[0].width = isRTL ? 60 : 50;
  totalsGrid.columns[1].width = isRTL ? 85 : 75;

  totalPages = (order.orderedProducts!.length / 6).ceil();

  _addTotalRow(totalsGrid, '${appLoc.subtotal}:',
      '$currencyCode ${number.format(subTotal)}', regularFont, boldFont, isRTL);

  if (order.taxAmount != null && order.taxAmount! > 0) {
    _addTotalRow(
        totalsGrid,
        '${appLoc.salesTax}:',
        '$currencyCode ${number.format(order.taxAmount)}',
        regularFont,
        boldFont,
        isRTL);
  }

  if (currentPage == totalPages) {
    double totalAmount = 0.0;
    if (order.deliveryFees != null && order.deliveryFees! > 0) {
      _addTotalRow(
        totalsGrid,
        '${appLoc.delivery}:',
        '$currencyCode ${number.format(order.deliveryFees ?? 0)}',
        regularFont,
        boldFont,
        isRTL,
      );
      totalAmount += order.deliveryFees!;
    }
    totalAmount += (order.taxAmount ?? 0) + pageTotal;

    // Highlight total row with background
    final totalRow = totalsGrid.rows.add();
    totalRow.height = 22;
    totalRow.style = PdfGridRowStyle(
      backgroundBrush: PdfSolidBrush(PdfColor(46, 125, 50)),
      textBrush: PdfBrushes.white,
      font: boldFont,
    );
    if (isRTL) {
      totalRow.cells[1].value = '${appLoc.total}:';
      totalRow.cells[1].style.cellPadding =
          PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);
      totalRow.cells[0].value = '$currencyCode ${number.format(totalAmount)}';
      totalRow.cells[0].style.stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.right);
      totalRow.cells[0].style.cellPadding =
          PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);
    } else {
      totalRow.cells[0].value = '${appLoc.total}:';
      totalRow.cells[0].style.cellPadding =
          PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);
      totalRow.cells[1].value = '$currencyCode ${number.format(totalAmount)}';
      totalRow.cells[1].style.stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.right);
      totalRow.cells[1].style.cellPadding =
          PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);
    }
  }

  final double totalsX = isRTL ? leftMargin : pageWidth - rightMargin - 120;
  totalsGrid.draw(
    page: page,
    bounds: Rect.fromLTWH(totalsX, yPos, 250, 0),
  );
  yPos += -10;
  return yPos;
}

Future<double> _drawTermsAndConditions(
    PdfGraphics graphics,
    String termsAndConditions,
    PdfFont subHeaderFont,
    PdfFont regularFont,
    double yPos,
    double leftMargin,
    double rightMargin,
    AppLocalizations appLoc,
    Orders order,
    PdfPage page,
    PdfFont boldFont,
    InvoiceSettings invoiceSettings,
    double pageWidth,
    bool isRTL) async {
  double termsX = isRTL ? pageWidth - leftMargin - 220 : leftMargin;

  if (invoiceSettings.paymentTerms != null ||
      invoiceSettings.paymentTerms == '1') {
    graphics.drawString(
      appLoc.paymentTerms,
      subHeaderFont,
      bounds: Rect.fromLTWH(termsX, yPos, pageWidth * 0.5, 100),
      format: ArabicTextHelper.getFormatForText(appLoc.paymentTerms),
    );
    yPos += 15;
    graphics.drawString(
      order.paymentTerms ?? 'N/A',
      regularFont,
      bounds: Rect.fromLTWH(termsX, yPos,
          page.getClientSize().width - leftMargin - rightMargin, 15),
      format: ArabicTextHelper.getFormatForText(order.paymentTerms ?? 'N/A'),
    );
    yPos += 30;
  }

  if (invoiceSettings.deliveryTerms != null ||
      invoiceSettings.deliveryTerms == '1') {
    graphics.drawString(
      '${appLoc.termsandConditions}:',
      subHeaderFont,
      bounds: Rect.fromLTWH(termsX, yPos, pageWidth * 0.5, 100),
      format: ArabicTextHelper.getFormatForText(appLoc.termsandConditions),
    );
    yPos += 15;
    final sfpdf.PdfTextElement termsElement = sfpdf.PdfTextElement(
      text: termsAndConditions,
      font: regularFont,
      format: ArabicTextHelper.getFormatForText(termsAndConditions),
    );
    final double maxTermsHeight = page.getClientSize().height - yPos - 50;
    final double termsElementX =
        regularFont.measureString(termsAndConditions).width;
    termsElement.draw(
      page: page,
      bounds: Rect.fromLTWH(
        isRTL ? termsX - termsElementX - 100 : termsX,
        yPos,
        page.getClientSize().width - leftMargin - rightMargin,
        maxTermsHeight,
      ),
    );
  }

  return yPos;
}

Future<double> _schedueledDelivery(
    PdfGraphics graphics,
    PdfFont subHeaderFont,
    PdfFont boldFont,
    Orders order,
    PdfPage page,
    AppLocalizations appLoc,
    double yPos,
    double leftMargin,
    InvoiceSettings invoiceSettings,
    PdfFont regularFont,
    double pageWidth,
    bool isRTL) async {
  double scheduleGridX = isRTL ? pageWidth - leftMargin - 220 : leftMargin;
  if (invoiceSettings.schedueledDate == null ||
      invoiceSettings.schedueledDate == '0') {
    return yPos;
  }
  if (order.scheduledDate != null || order.scheduledAt != null) {
    graphics.drawString(
      appLoc.scheduledOrder,
      subHeaderFont,
      bounds: Rect.fromLTWH(scheduleGridX, yPos, pageWidth * 0.5, 100),
      format: ArabicTextHelper.getFormatForText(appLoc.scheduledOrder),
    );
    yPos += 18;
    final PdfGrid scheduleGrid = PdfGrid();
    scheduleGrid.columns.add(count: 2);
    scheduleGrid.columns[0].width = isRTL ? 80 : 100;
    scheduleGrid.columns[1].width = isRTL ? 80 : 80;
    scheduleGrid.style.cellPadding =
        PdfPaddings(left: 5, right: 5, top: 4, bottom: 4);
    String scheduledDate = '', scheduledTime = '';
    if (order.scheduledDate != null) {
      scheduledDate += DateFormat('dd/MM/yyyy').format(order.scheduledDate!);
    }
    if (order.scheduledAt != null) {
      if (scheduledDate.isNotEmpty) scheduledDate += ' ';
      final theTime = DateTime(
        order.scheduledDate?.year ?? DateTime.now().year,
        order.scheduledDate?.month ?? DateTime.now().month,
        order.scheduledDate?.day ?? DateTime.now().day,
        order.scheduledAt!.hour,
        order.scheduledAt!.minute,
      );
      scheduledTime = DateFormat('hh:mm a').format(theTime);
    }
    _addInfoRow(scheduleGrid, '${appLoc.scheduledDate}:', scheduledDate,
        boldFont, regularFont, isRTL);
    _addInfoRow(scheduleGrid, '${appLoc.scheduledTime}:', scheduledTime,
        boldFont, regularFont, isRTL);
    scheduleGrid.draw(
      page: page,
      bounds: Rect.fromLTWH(
          scheduleGridX, yPos, isRTL ? pageWidth * 0.55 : pageWidth * 0.65, 0),
    );
    yPos += 45;
  }
  return yPos;
}

// ── Font loading ───────────────────────────────────────────────────────────────

Future<Map<String, PdfFont>> _loadFonts() async {
  try {
    final ByteData fontData =
        await rootBundle.load('assets/fonts/amiri/Amiri-Regular.ttf');
    final List<int> fontBytes = fontData.buffer.asUint8List();

    return {
      'header': PdfTrueTypeFont(fontBytes, 16, style: PdfFontStyle.bold),
      'headerWhite': PdfTrueTypeFont(fontBytes, 13, style: PdfFontStyle.bold),
      'companyName': PdfTrueTypeFont(fontBytes, 20, style: PdfFontStyle.bold),
      'contact': PdfTrueTypeFont(fontBytes, 8),
      'invoiceBadge': PdfTrueTypeFont(fontBytes, 8, style: PdfFontStyle.bold),
      'subHeader': PdfTrueTypeFont(fontBytes, 10, style: PdfFontStyle.bold),
      'regular': PdfTrueTypeFont(fontBytes, 8),
      'bold': PdfTrueTypeFont(fontBytes, 9, style: PdfFontStyle.bold),
      'small': PdfTrueTypeFont(fontBytes, 7),
      'smallWhite': PdfTrueTypeFont(fontBytes, 7),
    };
  } catch (e) {
    return {
      'header': PdfStandardFont(PdfFontFamily.timesRoman, 16,
          style: PdfFontStyle.bold),
      'headerWhite': PdfStandardFont(PdfFontFamily.timesRoman, 13,
          style: PdfFontStyle.bold),
      'companyName': PdfStandardFont(PdfFontFamily.timesRoman, 20,
          style: PdfFontStyle.bold),
      'contact': PdfStandardFont(PdfFontFamily.timesRoman, 8),
      'invoiceBadge': PdfStandardFont(PdfFontFamily.timesRoman, 8,
          style: PdfFontStyle.bold),
      'subHeader': PdfStandardFont(PdfFontFamily.timesRoman, 10,
          style: PdfFontStyle.bold),
      'regular': PdfStandardFont(PdfFontFamily.timesRoman, 8),
      'bold': PdfStandardFont(PdfFontFamily.timesRoman, 9,
          style: PdfFontStyle.bold),
      'small': PdfStandardFont(PdfFontFamily.timesRoman, 7),
      'smallWhite': PdfStandardFont(PdfFontFamily.timesRoman, 7),
    };
  }
}

// ── Text helpers — completely unchanged ───────────────────────────────────────

class ArabicTextHelper {
  static PdfStringFormat get arabicTextFormat => PdfStringFormat(
        alignment: PdfTextAlignment.right,
        textDirection: PdfTextDirection.rightToLeft,
        lineAlignment: PdfVerticalAlignment.top,
        wordWrap: PdfWordWrapType.word,
      );

  static PdfStringFormat get arabicGridTextFormat => PdfStringFormat(
        alignment: PdfTextAlignment.right,
        textDirection: PdfTextDirection.rightToLeft,
        lineAlignment: PdfVerticalAlignment.top,
      );

  static bool isArabic(String text) {
    if (text.isEmpty) return false;
    final arabicRegex = RegExp(
        r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]');
    return arabicRegex.hasMatch(text);
  }

  static PdfStringFormat getFormatForText(String text) {
    return isArabic(text) ? arabicTextFormat : PdfStringFormat();
  }
}

class RTLayoutHelper {
  static bool isRTLRequired(AppLocalizations appLoc) {
    return appLoc.localeName.contains('ar') || _isRTLText(appLoc.invoice);
  }

  static bool _isRTLText(String text) {
    final arabicRegex = RegExp(
        r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]');
    return arabicRegex.hasMatch(text);
  }

  static double getLeftMargin(
      bool isRTL, double pageWidth, double rightMargin) {
    return isRTL ? rightMargin : 40;
  }

  static double getRightMargin(
      bool isRTL, double pageWidth, double leftMargin) {
    return isRTL ? leftMargin : 40;
  }

  static Rect getTextBounds(bool isRTL, double x, double y, double width,
      double height, double pageWidth) {
    if (isRTL) return Rect.fromLTWH(pageWidth - x - width, y, width, height);
    return Rect.fromLTWH(x, y, width, height);
  }

  static PdfStringFormat getTextFormat(bool isRTL, String text) {
    return PdfStringFormat(
      alignment: isRTL ? PdfTextAlignment.right : PdfTextAlignment.left,
      textDirection:
          isRTL ? PdfTextDirection.rightToLeft : PdfTextDirection.leftToRight,
    );
  }
}
