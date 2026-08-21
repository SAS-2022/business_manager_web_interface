import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/models/order_model.dart';
import 'package:business_manager_web_ui/src/models/purchase_model.dart';
import 'package:business_manager_web_ui/src/models/supplier_model.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/client_service.dart';
import 'package:business_manager_web_ui/src/services/supplier_service.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart' hide PdfTextElement;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

// ── Design constants ──────────────────────────────────────────────────────────
// Amber/orange accent for purchase orders
const double _kMargin = 40.0;
const double _kLogoSize = 56.0;
const double _kHeaderBgH = 110.0;
// Amber: PdfColor(230, 81, 0)
// Amber name text: PdfColor(191, 54, 12)
// Amber bg: PdfColor(255, 248, 225)

Future<PdfDocument> generatePurchaseOrderPDF({
  required UserDetails currentUser,
  required InvoiceSettings invoiceSettings,
  required PurchaseModel order,
  required String deliveryTerms,
  required String returnTerms,
  required AppLocalizations appLoc,
}) async {
  order.purchasedProducts ??= {};
  final bool isRTL = RTLayoutHelper.isRTLRequired(appLoc);
  ClientService cs = ClientService();
  final PdfDocument document = PdfDocument();
  int pageRows = 0;
  double pageTotal = 0.0, subTotal = 0.0;
  int currentPage = 0;

  final fonts = await _loadFonts();
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

  for (int i = 0; i < order.purchasedProducts!.length; i += 6) {
    currentPage++;
    PdfPage page = document.pages.add();
    PdfGraphics graphics = page.graphics;
    final double pageWidth = page.getClientSize().width;
    final double pageHeight = page.getClientSize().height;
    final double leftMargin =
        RTLayoutHelper.getLeftMargin(isRTL, pageWidth, _kMargin);
    final double rightMargin =
        RTLayoutHelper.getRightMargin(isRTL, pageWidth, _kMargin);

    if (7 + i <= order.purchasedProducts!.length) {
      pageRows = 6 + i;
    } else {
      pageRows = order.purchasedProducts!.length;
    }

    double yPos = 0;

    // ── Header: amber left accent bar + light bg ──────────────────────────
    graphics.drawRectangle(
      bounds: const Rect.fromLTWH(0, 0, 6, _kHeaderBgH),
      brush: PdfSolidBrush(PdfColor(230, 81, 0)),
    );
    graphics.drawRectangle(
      bounds: Rect.fromLTWH(6, 0, pageWidth - 6, _kHeaderBgH),
      brush: PdfSolidBrush(PdfColor(255, 248, 225)),
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

    // ── Company name ──────────────────────────────────────────────────────
    final double companyX = isRTL ? _kMargin : _kMargin + _kLogoSize + 14;
    final double companyW = pageWidth - _kMargin * 2 - _kLogoSize - 14;

    final String companyName = currentUser.companyName ?? '';
    graphics.drawString(
      companyName,
      fonts['companyName']!,
      bounds: Rect.fromLTWH(companyX, 14, companyW, 40),
      format: ArabicTextHelper.getFormatForText(companyName),
      brush: PdfSolidBrush(PdfColor(191, 54, 12)),
    );

    // ── Country · City ────────────────────────────────────────────────────
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
        bounds: Rect.fromLTWH(companyX, 54, companyW, 18),
        format: ArabicTextHelper.getFormatForText(locationLine),
        brush: PdfSolidBrush(PdfColor(66, 66, 66)),
      );
    }

    // ── Purchase order badge ──────────────────────────────────────────────
    final String poLabel = '${appLoc.purchaseOrder}  #${order.id ?? ''}';
    graphics.drawString(
      poLabel,
      fonts['invoiceBadge']!,
      bounds: Rect.fromLTWH(companyX, 74, companyW, 18),
      format: ArabicTextHelper.getFormatForText(poLabel),
      brush: PdfSolidBrush(PdfColor(230, 81, 0)),
    );

    yPos = _kHeaderBgH + 14;

    // ── Two-column meta block ─────────────────────────────────────────────
    final double colW = (pageWidth - _kMargin * 2 - 20) / 2;
    final double col1X = isRTL ? pageWidth - _kMargin - colW : _kMargin;
    final double col2X = isRTL ? _kMargin : _kMargin + colW + 20;

    final PdfGrid infoGrid = PdfGrid();
    infoGrid.columns.add(count: 2);
    infoGrid.style.cellPadding =
        PdfPaddings(left: 4, right: 4, top: 3, bottom: 3);
    infoGrid.columns[0].width = isRTL ? 65 : 70;
    infoGrid.columns[1].width = isRTL ? 75 : 80;

    _addInfoRow(infoGrid, '${appLoc.number}:', order.id ?? 'N/A', boldFont,
        regularFont, isRTL);
    _addInfoRow(
        infoGrid,
        '${appLoc.date}:',
        order.createdAt != null
            ? DateFormat('dd/MM/yyyy').format(order.createdAt!)
            : DateFormat('dd/MM/yyyy').format(DateTime.now()),
        boldFont,
        regularFont,
        isRTL);

    infoGrid.draw(
      page: page,
      bounds: Rect.fromLTWH(col1X, yPos, colW, 0),
    );

    // Right — supplier details
    double supplierY = yPos;
    graphics.drawString(
      appLoc.supplierName,
      boldFont,
      bounds: Rect.fromLTWH(col2X, supplierY, colW, 20),
      format: ArabicTextHelper.getFormatForText(appLoc.supplierName),
    );
    supplierY += 14;
    graphics.drawString(
      order.supplierName ?? '',
      regularFont,
      bounds: Rect.fromLTWH(col2X, supplierY, colW, 18),
      format: ArabicTextHelper.getFormatForText(order.supplierName ?? ''),
    );
    supplierY += 12;

    if (order.supplierId != null) {
      SupplierService ss = SupplierService();
      SupplierModel? supplier =
          await ss.futureSingleSupplier(currentUser.uid, order.supplierId);

      if (supplier.address != null && supplier.address!['street'] != null) {
        graphics.drawString(
          '${supplier.address!['street']}',
          smallFont,
          bounds: Rect.fromLTWH(col2X, supplierY, colW, 18),
          format:
              ArabicTextHelper.getFormatForText(supplier.address!['street']),
        );
        supplierY += 12;
      }

      if (invoiceSettings.clientFinancialDetails == null ||
          invoiceSettings.clientFinancialDetails == '1') {
        if (supplier.financialNumber != null &&
            supplier.financialNumber!.isNotEmpty) {
          graphics.drawString(
            '${appLoc.financialNumber}: ${supplier.financialNumber}',
            smallFont,
            bounds: Rect.fromLTWH(col2X, supplierY, colW, 18),
            format: ArabicTextHelper.getFormatForText(
                '${appLoc.financialNumber}: ${supplier.financialNumber}'),
          );
          supplierY += 12;
        }
      }

      if (invoiceSettings.clientCrNumber == null ||
          invoiceSettings.clientCrNumber == '1') {
        if (supplier.crNumber != null && supplier.crNumber!.isNotEmpty) {
          graphics.drawString(
            '${appLoc.crNumber}: ${supplier.crNumber}',
            smallFont,
            bounds: Rect.fromLTWH(col2X, supplierY, colW, 18),
            format: ArabicTextHelper.getFormatForText(
                '${appLoc.crNumber}: ${supplier.crNumber}'),
          );
          supplierY += 12;
        }
      }
    }

    // Financial details
    if (invoiceSettings.companyFinancials == null ||
        invoiceSettings.companyFinancials == '1') {
      final bool hasFinancial = currentUser.bankName != null ||
          currentUser.bankBranch != null ||
          currentUser.ibanNumber != null ||
          currentUser.otherPayment != null;

      if (hasFinancial) {
        double finY = yPos + 50;
        graphics.drawString(
          appLoc.financialDetails,
          boldFont,
          bounds: Rect.fromLTWH(col1X, finY, colW, 18),
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
              bounds: Rect.fromLTWH(col1X, finY, colW, 18),
              format: ArabicTextHelper.getFormatForText(s),
            );
            finY += 12;
          }
        }
      }
    }

    yPos = yPos + 70;

    // Rule before product table — amber
    graphics.drawLine(
      PdfPen(PdfColor(230, 81, 0), width: 1.0),
      Offset(_kMargin, yPos),
      Offset(pageWidth - _kMargin, yPos),
    );
    yPos += 10;

    // ── Product grid ──────────────────────────────────────────────────────
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

    graphics.drawLine(
      PdfPen(PdfColor(200, 200, 200), width: 0.4),
      Offset(_kMargin, yPos + 8),
      Offset(pageWidth - _kMargin, yPos + 8),
    );
    yPos += 16;

    // Terms
    yPos = await _drawTermsAndConditions(
      graphics,
      regularFont,
      yPos,
      leftMargin,
      rightMargin,
      appLoc,
      order,
      page,
      boldFont,
      returnTerms,
      deliveryTerms,
      pageWidth,
      isRTL,
    );

    // ── Footer strip — amber ──────────────────────────────────────────────
    final double footerY = pageHeight - 24;
    graphics.drawRectangle(
      bounds: Rect.fromLTWH(0, footerY, pageWidth, 24),
      brush: PdfSolidBrush(PdfColor(230, 81, 0)),
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

double calculateOrderTotal(Orders order) {
  double total = 0.0;
  if (order.orderedProducts != null) {
    order.orderedProducts!.forEach((_, product) {
      total += (product.cost)! * (product.quantity!);
    });
  }
  return total;
}

Future<Map<String, dynamic>> _productGrid(
  AppLocalizations appLoc,
  PdfDocument document,
  int rowAt,
  int pageRows,
  UserDetails currentUser,
  PdfPage page,
  PurchaseModel order,
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
  productsGrid.columns.add(count: 6);

  if (isRTL) {
    productsGrid.columns[5].width = 40;
    productsGrid.columns[4].width = 75;
    productsGrid.columns[3].width = 125;
    productsGrid.columns[2].width = 50;
    productsGrid.columns[1].width = 70;
    productsGrid.columns[0].width = 65;
  } else {
    productsGrid.columns[0].width = 40;
    productsGrid.columns[1].width = 75;
    productsGrid.columns[2].width = 125;
    productsGrid.columns[3].width = 50;
    productsGrid.columns[4].width = 70;
    productsGrid.columns[5].width = 65;
  }

  final PdfGridRow headerRow = productsGrid.headers.add(1)[0];
  headerRow.height = 22;

  List<String> headers = isRTL
      ? [
          appLoc.total,
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
  // Amber header
  headerRow.style = PdfGridRowStyle(
    backgroundBrush: PdfSolidBrush(PdfColor(230, 81, 0)),
    textBrush: PdfBrushes.white,
    font: boldFont,
  );

  if (isRTL && order.purchasedProducts != null) {
    int index = rowAt + 1;
    for (int i = rowAt; i < pageRows; i++) {
      dynamic product = order.purchasedProducts!.values.elementAt(i);
      final row = productsGrid.rows.add();
      row.height = 40;
      row.cells[5].value = index.toString();
      row.cells[4].value = product.id.toString().length > 10
          ? product.id.toString().substring(0, 10)
          : product.id.toString();
      row.cells[3].value =
          '${product.name.toString().length > 25 ? product.name.toString().substring(0, 25) : product.name}\n${product.packing ?? ''}';
      row.cells[2].value = product.quantity.toString();
      row.cells[1].value = number.format(product.cost);
      row.cells[0].value = number.format(product.cost * product.quantity);
      row.style = PdfGridRowStyle(
        font: regularFont,
        backgroundBrush: i.isEven
            ? PdfBrushes.white
            : PdfSolidBrush(PdfColor(255, 248, 235)),
        textBrush: PdfBrushes.black,
      );
      pageTotal += product.cost * product.quantity;
      index++;
    }
  } else {
    int index = rowAt + 1;
    for (int i = rowAt; i < pageRows; i++) {
      dynamic product = order.purchasedProducts!.values.elementAt(i);
      final row = productsGrid.rows.add();
      row.height = 40;
      row.cells[0].value = index.toString();
      row.cells[1].value = product.id.toString().length > 10
          ? product.id.toString().substring(0, 10)
          : product.id.toString();
      row.cells[2].value =
          '${product.name.toString().length > 25 ? product.name.toString().substring(0, 25) : product.name}\n${product.packing ?? ''}';
      row.cells[3].value = product.quantity.toString();
      row.cells[4].value = number.format(product.cost);
      row.cells[5].value = number.format(product.cost * product.quantity);
      row.style = PdfGridRowStyle(
        font: regularFont,
        backgroundBrush: i.isEven
            ? PdfBrushes.white
            : PdfSolidBrush(PdfColor(255, 248, 235)),
        textBrush: PdfBrushes.black,
      );
      pageTotal += product.cost * product.quantity;
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
  PurchaseModel order,
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
  totalsGrid.columns.add(count: 2);
  totalsGrid.columns[0].width = isRTL ? 60 : 50;
  totalsGrid.columns[1].width = isRTL ? 85 : 75;

  final int totalPages = (order.purchasedProducts!.length / 6).ceil();

  _addTotalRow(totalsGrid, '${appLoc.subtotal}:',
      '$currencyCode ${number.format(subTotal)}', regularFont, boldFont, isRTL);

  if (currentPage == totalPages) {
    // Amber total row
    final totalRow = totalsGrid.rows.add();
    totalRow.height = 22;
    totalRow.style = PdfGridRowStyle(
      backgroundBrush: PdfSolidBrush(PdfColor(230, 81, 0)),
      textBrush: PdfBrushes.white,
      font: boldFont,
    );
    if (isRTL) {
      totalRow.cells[1].value = '${appLoc.total}:';
      totalRow.cells[1].style.cellPadding =
          PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);
      totalRow.cells[0].value = '$currencyCode ${number.format(pageTotal)}';
      totalRow.cells[0].style.stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.right);
      totalRow.cells[0].style.cellPadding =
          PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);
    } else {
      totalRow.cells[0].value = '${appLoc.total}:';
      totalRow.cells[0].style.cellPadding =
          PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);
      totalRow.cells[1].value = '$currencyCode ${number.format(pageTotal)}';
      totalRow.cells[1].style.stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.right);
      totalRow.cells[1].style.cellPadding =
          PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);
    }
  }

  final double totalsX = isRTL ? leftMargin : pageWidth - rightMargin - 130;
  totalsGrid.draw(page: page, bounds: Rect.fromLTWH(totalsX, yPos, 250, 0));
  yPos += -10;
  return yPos;
}

Future<double> _drawTermsAndConditions(
  PdfGraphics graphics,
  PdfFont regularFont,
  double yPos,
  double leftMargin,
  double rightMargin,
  AppLocalizations appLoc,
  PurchaseModel order,
  PdfPage page,
  PdfFont boldFont,
  String? returnTerms,
  String? deliveryTerms,
  double pageWidth,
  bool isRTL,
) async {
  double termsX = isRTL ? pageWidth - leftMargin - 220 : leftMargin;

  if (order.paymentTerms != null) {
    graphics.drawString(appLoc.paymentTerms, boldFont,
        bounds: Rect.fromLTWH(termsX, yPos, pageWidth * 0.5, 20),
        format: ArabicTextHelper.getFormatForText(appLoc.paymentTerms));
    yPos += 18;
    graphics.drawString(order.paymentTerms ?? 'N/A', regularFont,
        bounds: Rect.fromLTWH(termsX, yPos, pageWidth * 0.5, 20),
        format: ArabicTextHelper.getFormatForText(order.paymentTerms ?? 'N/A'));
    yPos += 24;
  }

  if (deliveryTerms != null && deliveryTerms.isNotEmpty) {
    graphics.drawString('${appLoc.deliveryTerms}:', boldFont,
        bounds: Rect.fromLTWH(termsX, yPos, pageWidth * 0.5, 20),
        format: ArabicTextHelper.getFormatForText(appLoc.deliveryTerms));
    yPos += 18;
    graphics.drawString(deliveryTerms, regularFont,
        bounds: Rect.fromLTWH(termsX, yPos, pageWidth * 0.5, 20),
        format: ArabicTextHelper.getFormatForText(deliveryTerms));
    yPos += 24;
  }

  if (returnTerms != null && returnTerms.isNotEmpty) {
    graphics.drawString('${appLoc.returns}:', boldFont,
        bounds: Rect.fromLTWH(termsX, yPos, pageWidth * 0.5, 20),
        format: ArabicTextHelper.getFormatForText(appLoc.returns));
    yPos += 18;
    graphics.drawString(returnTerms, regularFont,
        bounds: Rect.fromLTWH(termsX, yPos, pageWidth * 0.5, 20),
        format: ArabicTextHelper.getFormatForText(returnTerms));
    yPos += 24;
  }

  return yPos;
}

Future<Map<String, PdfFont>> _loadFonts() async {
  try {
    final ByteData fontData =
        await rootBundle.load('assets/fonts/amiri/Amiri-Regular.ttf');
    final List<int> fontBytes = fontData.buffer.asUint8List();
    return {
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

  static PdfStringFormat getFormatForText(String text) =>
      isArabic(text) ? arabicTextFormat : PdfStringFormat();
}

class RTLayoutHelper {
  static bool isRTLRequired(AppLocalizations appLoc) =>
      appLoc.localeName.contains('ar') || _isRTLText(appLoc.invoice);

  static bool _isRTLText(String text) {
    final arabicRegex = RegExp(
        r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]');
    return arabicRegex.hasMatch(text);
  }

  static double getLeftMargin(bool isRTL, double pageWidth, double m) =>
      isRTL ? m : 40;
  static double getRightMargin(bool isRTL, double pageWidth, double m) =>
      isRTL ? m : 40;

  static Rect getTextBounds(bool isRTL, double x, double y, double w, double h,
          double pageWidth) =>
      isRTL
          ? Rect.fromLTWH(pageWidth - x - w, y, w, h)
          : Rect.fromLTWH(x, y, w, h);

  static PdfStringFormat getTextFormat(bool isRTL, String text) =>
      PdfStringFormat(
        alignment: isRTL ? PdfTextAlignment.right : PdfTextAlignment.left,
        textDirection:
            isRTL ? PdfTextDirection.rightToLeft : PdfTextDirection.leftToRight,
      );
}
