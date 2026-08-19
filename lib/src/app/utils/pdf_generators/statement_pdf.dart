import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/models/client_model.dart';
import 'package:business_manager_web_ui/src/models/client_statement.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

/// Generates a client statement PDF document.
///
/// Mirrors the structure of [generateQuotation]: same fonts, same RTL/Arabic
/// helpers, same header/logo layout — only the body table differs.
Future<PdfDocument> generateClientStatement({
  required UserDetails currentUser,
  required ClientDetails client,
  required List<StatementRecord> records,
  required AppLocalizations appLoc,
}) async {
  final bool isRTL = RTLayoutHelper.isRTLRequired(appLoc);
  final PdfDocument document = PdfDocument();

  // ── Fonts ──────────────────────────────────────────────────────────────────
  final fonts = await _loadFonts();
  final PdfFont headerFont = fonts['header']!;
  final PdfFont subHeaderFont = fonts['subHeader']!;
  final PdfFont regularFont = fonts['regular']!;
  final PdfFont boldFont = fonts['bold']!;

  // ── Logo ───────────────────────────────────────────────────────────────────
  PdfBitmap? logoImage;
  if (currentUser.companyLogo != null && currentUser.companyLogo!.isNotEmpty) {
    try {
      final response = await http.get(Uri.parse(currentUser.companyLogo!));
      if (response.statusCode == 200) {
        logoImage = PdfBitmap(response.bodyBytes);
      }
    } catch (e) {
      // Non-fatal: proceed without logo
    }
  }

  // ── Pagination (max 20 statement rows per page) ────────────────────────────
  const int rowsPerPage = 20;
  final int totalPages =
      records.isEmpty ? 1 : (records.length / rowsPerPage).ceil();

  double runningTotal = 0.0;
  double totalDebit = 0.0;
  double totalCredit = 0.0;

  for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
    final PdfPage page = document.pages.add();
    final PdfGraphics graphics = page.graphics;
    final double pageWidth = page.getClientSize().width;
    final double leftMargin =
        RTLayoutHelper.getLeftMargin(isRTL, pageWidth, 50);
    final double rightMargin =
        RTLayoutHelper.getRightMargin(isRTL, pageWidth, 50);

    double yPos = 35;

    // ── Page header (logo + company info + title) ──────────────────────────
    yPos = _drawStatementPageHeader(
      appLoc: appLoc,
      page: page,
      graphics: graphics,
      currentUser: currentUser,
      client: client,
      headerFont: headerFont,
      subHeaderFont: subHeaderFont,
      regularFont: regularFont,
      boldFont: boldFont,
      leftMargin: leftMargin,
      rightMargin: rightMargin,
      yPos: yPos,
      logoImage: logoImage,
      isRTL: isRTL,
      pageIndex: pageIndex,
      totalPages: totalPages,
    );

    // ── Statement rows for this page ───────────────────────────────────────
    final int startRow = pageIndex * rowsPerPage;
    final int endRow = (startRow + rowsPerPage).clamp(0, records.length);
    final List<StatementRecord> pageRecords = records.sublist(startRow, endRow);

    final result = _drawStatementGrid(
      appLoc: appLoc,
      page: page,
      pageRecords: pageRecords,
      regularFont: regularFont,
      boldFont: boldFont,
      leftMargin: leftMargin,
      rightMargin: rightMargin,
      yPos: yPos,
      isRTL: isRTL,
      runningTotalIn: runningTotal,
    );

    runningTotal = result['runningTotal'] as double;
    totalDebit += result['pageDebit'] as double;
    totalCredit += result['pageCredit'] as double;
    yPos = result['yPos'] as double;

    // ── Summary footer on the last page ───────────────────────────────────
    if (pageIndex == totalPages - 1) {
      _drawStatementSummary(
        appLoc: appLoc,
        page: page,
        graphics: graphics,
        regularFont: regularFont,
        boldFont: boldFont,
        subHeaderFont: subHeaderFont,
        leftMargin: leftMargin,
        rightMargin: rightMargin,
        totalDebit: totalDebit,
        totalCredit: totalCredit,
        netTotal: runningTotal,
        isRTL: isRTL,
        currency: currentUser.currency != null
            ? currentUser.currency!['code'] ?? ''
            : '',
      );
    }
  }

  return document;
}

// ── Page header ───────────────────────────────────────────────────────────────

double _drawStatementPageHeader({
  required AppLocalizations appLoc,
  required PdfPage page,
  required PdfGraphics graphics,
  required UserDetails currentUser,
  required ClientDetails client,
  required PdfFont headerFont,
  required PdfFont subHeaderFont,
  required PdfFont regularFont,
  required PdfFont boldFont,
  required double leftMargin,
  required double rightMargin,
  required double yPos,
  required PdfBitmap? logoImage,
  required bool isRTL,
  required int pageIndex,
  required int totalPages,
}) {
  final double pageWidth = page.getClientSize().width;

  // Logo
  if (logoImage != null) {
    final double logoX = isRTL ? leftMargin : pageWidth - 120;
    graphics.drawImage(logoImage, Rect.fromLTWH(logoX, yPos, 100, 100));
  }

  // Company info (left / right depending on RTL)
  final double companyInfoX = isRTL ? pageWidth - leftMargin - 70 : leftMargin;

  graphics.drawString(
    currentUser.companyName!,
    headerFont,
    bounds: Rect.fromLTWH(companyInfoX, yPos, 300, 50),
    format: ArabicTextHelper.getFormatForText(currentUser.companyName!),
  );
  yPos += 25;

  if (currentUser.address != null) {
    final addressText =
        '${currentUser.address!.mapCountry ?? 'N/A'} - ${currentUser.address!.province ?? 'N/A'}';
    graphics.drawString(
      addressText,
      regularFont,
      bounds: Rect.fromLTWH(companyInfoX, yPos, 300, 20),
      format: ArabicTextHelper.getFormatForText(addressText),
    );
    yPos += 15;
  }

  final contactText =
      '${currentUser.emailAddress ?? 'N/A'} | ${currentUser.phoneNumber != null ? '${currentUser.phoneNumber!['code']} ${currentUser.phoneNumber!['number']}' : 'N/A'}';
  graphics.drawString(
    contactText,
    regularFont,
    bounds: Rect.fromLTWH(companyInfoX, yPos, 300, 20),
    format: ArabicTextHelper.getFormatForText(contactText),
  );
  yPos += 20;

  // Statement title
  final double titleX = isRTL ? pageWidth - leftMargin - 400 : leftMargin;
  graphics.drawString(
    appLoc.clientStatement,
    subHeaderFont,
    bounds: Rect.fromLTWH(titleX, isRTL ? yPos - 30 : yPos, 200, 30),
    format: ArabicTextHelper.getFormatForText(appLoc.clientStatement),
  );
  yPos += 20;

  // Metadata grid: date generated + page number
  final PdfGrid infoGrid = PdfGrid();
  infoGrid.columns.add(count: 2);
  infoGrid.style.cellPadding =
      PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);
  infoGrid.columns[0].width = isRTL ? 70 : 80;
  infoGrid.columns[1].width = isRTL ? 80 : 90;

  _addInfoRow(
    infoGrid,
    '${appLoc.date}:',
    DateFormat('dd/MM/yyyy').format(DateTime.now()),
    boldFont,
    regularFont,
    isRTL,
  );
  _addInfoRow(
    infoGrid,
    'Page:',
    '${pageIndex + 1} / $totalPages',
    boldFont,
    regularFont,
    isRTL,
  );

  final double infoGridX = isRTL ? pageWidth - rightMargin - 110 : leftMargin;
  final infoResult = infoGrid.draw(
    page: page,
    bounds: Rect.fromLTWH(infoGridX, yPos, 200, 0),
  );
  yPos += (infoResult?.bounds.height ?? 0) + 7;

  // Client details block
  final double clientX = isRTL ? pageWidth - leftMargin : leftMargin;
  graphics.drawString(
    appLoc.clientDetails,
    boldFont,
    bounds: Rect.fromLTWH(isRTL ? clientX - 160 : clientX, yPos, 150, 30),
    format: ArabicTextHelper.getFormatForText(appLoc.clientDetails),
  );
  yPos += 15;

  final String clientName =
      client.companyName ?? '${client.firstName} ${client.lastName}';
  graphics.drawString(
    clientName,
    regularFont,
    bounds: Rect.fromLTWH(clientX, yPos, 200, 20),
    format: ArabicTextHelper.getFormatForText(clientName),
  );
  yPos += 15;

  if (client.address != null && client.address!['street'] != null) {
    final street = client.address!['street'] as String;
    graphics.drawString(
      street,
      regularFont,
      bounds: Rect.fromLTWH(clientX, yPos, 200, 15),
      format: ArabicTextHelper.getFormatForText(street),
    );
    yPos += 15;
  }

  yPos += 10;

  // Horizontal separator under header
  graphics.drawLine(
    PdfPen(PdfColor(33, 150, 243), width: 1.5),
    Offset(leftMargin, yPos),
    Offset(pageWidth - rightMargin, yPos),
  );
  yPos += 10;

  return yPos;
}

// ── Statement grid ────────────────────────────────────────────────────────────

Map<String, dynamic> _drawStatementGrid({
  required AppLocalizations appLoc,
  required PdfPage page,
  required List<StatementRecord> pageRecords,
  required PdfFont regularFont,
  required PdfFont boldFont,
  required double leftMargin,
  required double rightMargin,
  required double yPos,
  required bool isRTL,
  required double runningTotalIn,
}) {
  final double pageWidth = page.getClientSize().width;
  final double availableHeight = page.getClientSize().height - yPos - 80;
  final NumberFormat number = NumberFormat("#,##0.00", "en_US");

  double runningTotal = runningTotalIn;
  double pageDebit = 0.0;
  double pageCredit = 0.0;

  final PdfGrid grid = PdfGrid();
  // Columns: Date | Record ID | Debit | Credit | Balance
  grid.columns.add(count: 5);

  // Column widths — totals ~440 which fits nicely within margins
  if (isRTL) {
    grid.columns[4].width = 80; // Date  (rightmost in RTL = first logical)
    grid.columns[3].width = 100; // Record ID
    grid.columns[2].width = 80; // Debit
    grid.columns[1].width = 80; // Credit
    grid.columns[0].width = 80; // Balance (leftmost in RTL = last logical)
  } else {
    grid.columns[0].width = 80; // Date
    grid.columns[1].width = 100; // Record ID
    grid.columns[2].width = 80; // Debit
    grid.columns[3].width = 80; // Credit
    grid.columns[4].width = 80; // Balance
  }

  // Header row
  final PdfGridRow headerRow = grid.headers.add(1)[0];
  headerRow.height = 25;

  final List<String> ltrHeaders = [
    appLoc.date,
    'Record ID',
    'Debit',
    'Credit',
    'Balance',
  ];

  final List<String> headers =
      isRTL ? ltrHeaders.reversed.toList() : ltrHeaders;

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
  headerRow.style = PdfGridRowStyle(
    backgroundBrush: PdfSolidBrush(PdfColor(33, 150, 243)),
    textBrush: PdfBrushes.white,
    font: boldFont,
  );

  // Data rows
  for (final record in pageRecords) {
    final bool isDebit = record.type == 'debit';
    final double value = record.value ?? 0.0;

    if (isDebit) {
      runningTotal -= value;
      pageDebit += value;
    } else {
      runningTotal += value;
      pageCredit += value;
    }

    final String dateText = record.entryDate != null
        ? DateFormat('dd/MM/yyyy').format(record.entryDate!)
        : '-';
    final String recordId = record.uid ?? '-';
    final String debitText = isDebit ? number.format(value) : '-';
    final String creditText = !isDebit ? number.format(value) : '-';
    final String balanceText = number.format(runningTotal);

    // LTR logical order
    final List<String> cellValues = [
      dateText,
      recordId,
      debitText,
      creditText,
      balanceText,
    ];

    final PdfGridRow row = grid.rows.add();
    row.height = 22;

    for (int j = 0; j < cellValues.length; j++) {
      final int cellIndex = isRTL ? (cellValues.length - 1 - j) : j;
      final String cellValue = cellValues[j];
      row.cells[cellIndex].value = cellValue;

      // Numeric columns right-aligned
      final bool isNumericCol = j >= 2;
      row.cells[cellIndex].style.stringFormat = PdfStringFormat(
        alignment: isNumericCol
            ? PdfTextAlignment.right
            : (isRTL ? PdfTextAlignment.right : PdfTextAlignment.left),
        textDirection: ArabicTextHelper.isArabic(cellValue)
            ? PdfTextDirection.rightToLeft
            : PdfTextDirection.leftToRight,
      );

      // Colour debit red, credit green, balance conditional
      if (j == 2 && cellValue != '-') {
        row.cells[cellIndex].style.textBrush =
            PdfSolidBrush(PdfColor(211, 47, 47));
      } else if (j == 3 && cellValue != '-') {
        row.cells[cellIndex].style.textBrush =
            PdfSolidBrush(PdfColor(56, 142, 60));
      } else if (j == 4) {
        row.cells[cellIndex].style.textBrush = runningTotal >= 0
            ? PdfSolidBrush(PdfColor(56, 142, 60))
            : PdfSolidBrush(PdfColor(211, 47, 47));
      }
    }
  }

  grid.style = PdfGridStyle(
    cellPadding: PdfPaddings(left: 5, right: 5, top: 4, bottom: 4),
    font: regularFont,
  );

  final double gridWidth = pageWidth - leftMargin - rightMargin;
  final double gridX = isRTL ? rightMargin : leftMargin;

  final result = grid.draw(
    page: page,
    bounds: Rect.fromLTWH(gridX, yPos, gridWidth, availableHeight),
  );

  yPos += (result?.bounds.height ?? 0) + 15;

  return {
    'yPos': yPos,
    'runningTotal': runningTotal,
    'pageDebit': pageDebit,
    'pageCredit': pageCredit,
  };
}

// ── Summary section (last page only) ─────────────────────────────────────────
// Drawn as a full-width horizontal bar pinned to the page bottom.

void _drawStatementSummary({
  required AppLocalizations appLoc,
  required PdfPage page,
  required PdfGraphics graphics,
  required PdfFont regularFont,
  required PdfFont boldFont,
  required PdfFont subHeaderFont,
  required double leftMargin,
  required double rightMargin,
  required double totalDebit,
  required double totalCredit,
  required double netTotal,
  required bool isRTL,
  required String currency,
}) {
  final NumberFormat number = NumberFormat("#,##0.00", "en_US");
  final double pageWidth = page.getClientSize().width;
  final double pageHeight = page.getClientSize().height;

  // Pin the bar 50 pts from the bottom
  const double barHeight = 55.0;
  const double bottomPad = 50.0;
  final double barY = pageHeight - bottomPad - barHeight;
  final double barX = leftMargin;
  final double barWidth = pageWidth - leftMargin - rightMargin;

  // ── Background fill ────────────────────────────────────────────────────────
  graphics.drawRectangle(
    brush: PdfSolidBrush(PdfColor(33, 150, 243)),
    bounds: Rect.fromLTWH(barX, barY, barWidth, barHeight),
  );

  // ── Three equal columns inside the bar ────────────────────────────────────
  final double colWidth = barWidth / 3;
  const double labelY = 8.0; // offset inside bar for label text
  const double valueY = 26.0; // offset inside bar for value text

  final List<Map<String, dynamic>> columns = isRTL
      ? [
          {
            'label': 'Net Balance',
            'value': '$currency ${number.format(netTotal)}',
            'isNet': true,
          },
          {
            'label': 'Total Credit',
            'value': '$currency ${number.format(totalCredit)}',
            'isNet': false,
          },
          {
            'label': 'Total Debit',
            'value': '$currency ${number.format(totalDebit)}',
            'isNet': false,
          },
        ]
      : [
          {
            'label': 'Total Debit',
            'value': '$currency ${number.format(totalDebit)}',
            'isNet': false,
          },
          {
            'label': 'Total Credit',
            'value': '$currency ${number.format(totalCredit)}',
            'isNet': false,
          },
          {
            'label': 'Net Balance',
            'value': '$currency ${number.format(netTotal)}',
            'isNet': true,
          },
        ];

  for (int i = 0; i < columns.length; i++) {
    final double colX = barX + i * colWidth;
    final bool isNet = columns[i]['isNet'] as bool;
    final String label = columns[i]['label'] as String;
    final String value = columns[i]['value'] as String;

    // Vertical divider between columns (skip before first)
    if (i > 0) {
      graphics.drawLine(
        PdfPen(PdfColor(255, 255, 255, 100), width: 0.8),
        Offset(colX, barY + 6),
        Offset(colX, barY + barHeight - 6),
      );
    }

    // Label (small, white, centered)
    graphics.drawString(
      label,
      PdfStandardFont(PdfFontFamily.timesRoman, 7),
      brush: PdfBrushes.white,
      bounds: Rect.fromLTWH(colX + 6, barY + labelY, colWidth - 12, 12),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        textDirection: ArabicTextHelper.isArabic(label)
            ? PdfTextDirection.rightToLeft
            : PdfTextDirection.leftToRight,
      ),
    );

    // Value (bold, white for normal / yellow highlight for net)
    graphics.drawString(
      value,
      PdfStandardFont(PdfFontFamily.timesRoman, 9, style: PdfFontStyle.bold),
      brush: isNet
          ? PdfSolidBrush(PdfColor(255, 245, 157)) // soft yellow for net
          : PdfBrushes.white,
      bounds: Rect.fromLTWH(colX + 6, barY + valueY, colWidth - 12, 14),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        textDirection: ArabicTextHelper.isArabic(value)
            ? PdfTextDirection.rightToLeft
            : PdfTextDirection.leftToRight,
      ),
    );
  }

  // ── Thin top accent line ───────────────────────────────────────────────────
  graphics.drawLine(
    PdfPen(PdfColor(21, 101, 192), width: 2),
    Offset(barX, barY),
    Offset(barX + barWidth, barY),
  );
}

// ── Shared helpers (same as in quotation_pdf.dart) ───────────────────────────

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

Future<Map<String, PdfFont>> _loadFonts() async {
  try {
    final ByteData fontData =
        await rootBundle.load('assets/fonts/amiri/Amiri-Regular.ttf');
    final List<int> fontBytes = fontData.buffer.asUint8List();
    return {
      'header': PdfTrueTypeFont(fontBytes, 18, style: PdfFontStyle.bold),
      'subHeader': PdfTrueTypeFont(fontBytes, 14, style: PdfFontStyle.bold),
      'regular': PdfTrueTypeFont(fontBytes, 7),
      'bold': PdfTrueTypeFont(fontBytes, 8, style: PdfFontStyle.bold),
    };
  } catch (_) {
    return {
      'header': PdfStandardFont(PdfFontFamily.timesRoman, 18,
          style: PdfFontStyle.bold),
      'subHeader': PdfStandardFont(PdfFontFamily.timesRoman, 12,
          style: PdfFontStyle.bold),
      'regular': PdfStandardFont(PdfFontFamily.timesRoman, 8),
      'bold': PdfStandardFont(PdfFontFamily.timesRoman, 8,
          style: PdfFontStyle.bold),
    };
  }
}

// ── Text / layout helpers (identical to those in quotation_pdf.dart) ──────────

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

  static double getLeftMargin(bool isRTL, double pageWidth, double margin) =>
      isRTL ? margin : 50;

  static double getRightMargin(bool isRTL, double pageWidth, double margin) =>
      isRTL ? margin : 50;

  static PdfStringFormat getTextFormat(bool isRTL, String text) =>
      PdfStringFormat(
        alignment: isRTL ? PdfTextAlignment.right : PdfTextAlignment.left,
        textDirection:
            isRTL ? PdfTextDirection.rightToLeft : PdfTextDirection.leftToRight,
      );
}
