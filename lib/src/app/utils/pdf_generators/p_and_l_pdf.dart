import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

// Add this method to your _PlSummaryState class
Future<PdfDocument> generatePandLPdfFile({
  required UserDetails currentUser,
  required AppLocalizations appLoc,
  required Map<String, dynamic> records,
  Map<String, Map<String, dynamic>>? selectedOptions,
  required String startDate,
  required String endDate,
}) async {
  // Create a new PDF document
  final PdfDocument document = PdfDocument();

  // Add a page
  final PdfPage page = document.pages.add();

  // Get page size
  final Size pageSize = page.getClientSize();

  // Create PDF graphics and font
  final PdfGraphics graphics = page.graphics;
  final PdfFont headerFont = PdfStandardFont(PdfFontFamily.helvetica, 20);
  final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 16);
  final PdfFont normalFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
  final PdfFont boldFont =
      PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold);
  final PdfFont smallFont = PdfStandardFont(PdfFontFamily.helvetica, 10);

  // Current Y position for drawing
  double yPos = 0;

  // Add header
  graphics.drawString(
    appLoc.pandLStatement,
    headerFont,
    bounds: Rect.fromLTWH(0, yPos, pageSize.width, 30),
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  );
  yPos += 40;

  // Add Company Name
  graphics.drawString(
    '${appLoc.company}: ${currentUser.companyName}',
    boldFont,
    bounds: Rect.fromLTWH(0, yPos, pageSize.width, 17),
    format: PdfStringFormat(alignment: PdfTextAlignment.left),
  );
  // Add period information
  graphics.drawString(
    '${appLoc.period}: ${_getFormattedDate(startDate)} - ${_getFormattedDate(endDate)}',
    normalFont,
    bounds: Rect.fromLTWH(0, yPos, pageSize.width, 15),
    format: PdfStringFormat(alignment: PdfTextAlignment.right),
  );
  yPos += 20;

  // Add currency information
  graphics.drawString(
    '${appLoc.currency}: ${currentUser.currency?['symbol'] ?? '\$'} ${currentUser.currency?['code'] ?? 'USD'}',
    normalFont,
    bounds: Rect.fromLTWH(0, yPos, pageSize.width, 15),
    format: PdfStringFormat(alignment: PdfTextAlignment.right),
  );
  yPos += 30;

  // Profit & Loss Statement Section
  graphics.drawString(
    appLoc.plSummary,
    titleFont,
    bounds: Rect.fromLTWH(0, yPos, pageSize.width, 20),
  );
  yPos += 25;

  // Draw P&L table
  yPos = _drawPandLTable(page, graphics, yPos, normalFont, smallFont, appLoc,
      currentUser, records);
  yPos += 20;

  // Detailed Breakdown Section
  graphics.drawString(
    appLoc.detailedBreakDown,
    titleFont,
    bounds: Rect.fromLTWH(0, yPos, pageSize.width, 20),
  );
  yPos += 25;

  // Operating Expenses Detail
  yPos = _drawOperatingExpensesDetail(
      page, graphics, yPos, normalFont, appLoc, currentUser, selectedOptions!);
  yPos += 15;

  // Non-Operating Detail
  yPos = _drawNonOperatingDetail(
      page, graphics, yPos, normalFont, appLoc, currentUser, selectedOptions);
  yPos += 20;

  // Key Metrics Section
  graphics.drawString(
    appLoc.keyFinancialMetrics,
    titleFont,
    bounds: Rect.fromLTWH(0, yPos, pageSize.width, 20),
  );
  yPos += 25;

  _drawKeyMetrics(
      page, graphics, yPos, normalFont, appLoc, currentUser, records);

  return document;
}

String? _getFormattedDate(String date) {
  //will return a date Range
  return DateFormat('MMM yyyy').format(DateTime.parse(date));
}

double _drawPandLTable(
    PdfPage page,
    PdfGraphics graphics,
    double yPos,
    PdfFont normalFont,
    PdfFont smallFont,
    AppLocalizations appLoc,
    UserDetails currentUser,
    Map<String, dynamic> records) {
  final number = NumberFormat("#,##0.00", "en_US");
  final Size pageSize = page.getClientSize();
  final double columnWidth = pageSize.width / 2;
  final currencySymbol = currentUser.currency?['symbol'] ?? '\$';

  // Table data
  final List<Map<String, dynamic>> tableData = [
    {
      'label': 'Total Revenue',
      'value': records['totalSales'],
      'isHeader': true,
      'isPositive': true
    },
    {
      'label': 'Total Cost',
      'value': records['totalCost'],
      'isHeader': true,
      'isPositive': true
    },
    {'label': '', 'value': null, 'isDivider': true},
    {
      'label': 'Gross Profit',
      'value': records['grossProfit'],
      'isHeader': true,
      'isPositive': records['grossProfit'] >= 0
    },
    {
      'label': 'Operating Expenses',
      'value': records['totalOperatingExpenses'],
      'isPositive': false
    },
    {
      'label': 'Operating Income',
      'value': records['operatingIncome'],
      'isPositive': records['operatingIncome'] >= 0
    },
    {'label': '', 'value': null, 'isDivider': true},
    {
      'label': 'Non-Operating Income/Expense',
      'value': records['totalNonOperating'],
      'isPositive': records['totalNonOperating'] >= 0
    },
    {'label': '', 'value': null, 'isDivider': true},
    {
      'label': 'Earnings Before Tax',
      'value': records['EBIT'],
      'isHeader': true,
      'isPositive': records['EBIT'] >= 0
    },
    {
      'label': 'Income Tax',
      'value': records['EBIT'] * (records['incomeTaxRate'] / 100),
      'isPositive': false
    },
    {
      'label': 'Sales Tax',
      'value': records['EBIT'] * (records['salesTaxRate'] / 100),
      'isPositive': false
    },
    {
      'label': 'State Tax',
      'value': records['EBIT'] * (records['stateTaxRate'] / 100),
      'isPositive': false
    },
    {
      'label': 'Government Tax',
      'value': records['EBIT'] * (records['governmentTaxRate'] / 100),
      'isPositive': false
    },
    {'label': '', 'value': null, 'isDivider': true},
    {
      'label': 'Net Income',
      'value': records['netIncome'],
      'isHeader': true,
      'isTotal': true,
      'isPositive': records['netIncome'] >= 0
    },
  ];

  for (var row in tableData) {
    if (row['isDivider'] == true) {
      // Draw divider line
      graphics.drawLine(
        PdfPen(PdfColor(200, 200, 200)),
        Offset(0, yPos + 2),
        Offset(pageSize.width, yPos + 2),
      );
      yPos += 10;
      continue;
    }

    final String label = row['label'];
    final double? value = row['value'];
    final bool isHeader = row['isHeader'] ?? false;
    final bool isTotal = row['isTotal'] ?? false;
    final bool isPositive = row['isPositive'] ?? true;

    final PdfFont font = isHeader || isTotal
        ? PdfStandardFont(PdfFontFamily.helvetica, isTotal ? 14 : 12,
            style: PdfFontStyle.bold)
        : normalFont;

    // Draw label
    graphics.drawString(
      label,
      font,
      bounds: Rect.fromLTWH(0, yPos, columnWidth, 20),
    );

    // Draw value
    if (value != null) {
      final String valueText =
          '${value >= 0 && isPositive ? '' : '-'}$currencySymbol${number.format(value.abs())}';
      graphics.drawString(
        valueText,
        font,
        bounds: Rect.fromLTWH(columnWidth, yPos, columnWidth - 10, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
      );
    }

    yPos += 20;

    // Add extra space after headers and before totals
    if (isHeader || isTotal) {
      yPos += 5;
    }
  }

  return yPos;
}

double _drawOperatingExpensesDetail(
    PdfPage page,
    PdfGraphics graphics,
    double yPos,
    PdfFont font,
    AppLocalizations appLoc,
    UserDetails currentUser,
    Map<String, Map<String, dynamic>> selectedOptions) {
  final Size pageSize = page.getClientSize();
  final currencySymbol = currentUser.currency?['symbol'] ?? '\$';
  final number = NumberFormat("#,##0.00", "en_US");
  final operatingExpenses = selectedOptions['Operating Expenses'];
  if (operatingExpenses == null || operatingExpenses['subOptions'] == null) {
    return yPos;
  }

  graphics.drawString(
    '${appLoc.operatingExpenses}:',
    PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
    bounds: Rect.fromLTWH(0, yPos, pageSize.width, 20),
  );
  yPos += 20;

  final subOptions = operatingExpenses['subOptions'] as Map<String, dynamic>;
  final selectedSubOptions =
      subOptions.entries.where((entry) => entry.value['selected'] == true);

  for (var entry in selectedSubOptions) {
    graphics.drawString(
      '• ${entry.key}',
      font,
      bounds: Rect.fromLTWH(20, yPos, pageSize.width / 2, 15),
    );

    graphics.drawString(
      '$currencySymbol${number.format(entry.value['value'])}',
      font,
      bounds:
          Rect.fromLTWH(pageSize.width / 2, yPos, pageSize.width / 2 - 10, 15),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );

    yPos += 15;
  }

  return yPos;
}

double _drawNonOperatingDetail(
    PdfPage page,
    PdfGraphics graphics,
    double yPos,
    PdfFont font,
    AppLocalizations appLoc,
    UserDetails currentUser,
    Map<String, Map<String, dynamic>> selectedOptions) {
  final Size pageSize = page.getClientSize();
  final currencySymbol = currentUser.currency?['symbol'] ?? '\$';

  final interestExpense = selectedOptions['Interest Expense']?['value'] ?? 0.0;
  final foreignExchange =
      selectedOptions['Foreign Exchange Gain/Loss']?['value'] ?? 0.0;
  final investmentIncome =
      selectedOptions['Investment Income']?['value'] ?? 0.0;

  graphics.drawString(
    '${appLoc.nonOperatingItems}:',
    PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
    bounds: Rect.fromLTWH(0, yPos, pageSize.width, 20),
  );
  yPos += 20;

  if (investmentIncome > 0) {
    _drawDetailRow(graphics, font, appLoc.investmentIncome, investmentIncome,
        currencySymbol, yPos, pageSize);
    yPos += 15;
  }

  if (interestExpense > 0) {
    _drawDetailRow(graphics, font, appLoc.interestExpense, -interestExpense,
        currencySymbol, yPos, pageSize,
        isNegative: true);
    yPos += 15;
  }

  if (foreignExchange != 0) {
    _drawDetailRow(graphics, font, appLoc.foreignExchange, foreignExchange,
        currencySymbol, yPos, pageSize,
        isNegative: foreignExchange < 0);
    yPos += 15;
  }

  return yPos;
}

void _drawDetailRow(PdfGraphics graphics, PdfFont font, String label,
    double value, String currencySymbol, double yPos, Size pageSize,
    {bool isNegative = false}) {
  final number = NumberFormat("#,##0.00", "en_US");
  graphics.drawString(
    '• $label',
    font,
    bounds: Rect.fromLTWH(20, yPos, pageSize.width / 2, 15),
  );

  graphics.drawString(
    '${isNegative ? '-' : ''}$currencySymbol${number.format(value.abs())}',
    font,
    bounds:
        Rect.fromLTWH(pageSize.width / 2, yPos, pageSize.width / 2 - 10, 15),
    format: PdfStringFormat(alignment: PdfTextAlignment.right),
  );
}

void _drawKeyMetrics(
    PdfPage page,
    PdfGraphics graphics,
    double yPos,
    PdfFont font,
    AppLocalizations appLoc,
    UserDetails currentUser,
    Map<String, dynamic> records) {
  final number = NumberFormat("#,##0.00", "en_US");
  final Size pageSize = page.getClientSize();
  final currencySymbol = currentUser.currency?['symbol'] ?? '\$';

  final grossProfitMargin = records['totalRevenue'] > 0
      ? (records['grossProfit'] / records['totalRevenue']) * 100
      : 0;
  final operatingMargin = records['totalRevenue'] > 0
      ? (records['operatingIncome'] / records['totalRevenue']) * 100
      : 0;
  final netProfitMargin = records['totalRevenue'] > 0
      ? (records['netIncome'] / records['totalRevenue']) * 100
      : 0;
  final cogsPercentage = records['totalRevenue'] > 0
      ? (records['totalCost'] / records['totalRevenue']) * 100
      : 0;

  final List<Map<String, String>> metrics = [
    {
      'label': appLoc.grossProfitMargin,
      'value': '${grossProfitMargin.toStringAsFixed(1)}%'
    },
    {
      'label': appLoc.operatingMargin,
      'value': '${operatingMargin.toStringAsFixed(1)}%'
    },
    {
      'label': appLoc.netProfitMargin,
      'value': '${netProfitMargin.toStringAsFixed(1)}%'
    },
    {
      'label': appLoc.percentageCogs,
      'value': '${cogsPercentage.toStringAsFixed(1)}%'
    },
    {
      'label': appLoc.totalRevenue,
      'value': '$currencySymbol${number.format(records['totalRevenue'])}'
    },
    {
      'label': appLoc.netIncome,
      'value': '$currencySymbol${number.format(records['netIncome'])}'
    },
  ];

  for (var metric in metrics) {
    graphics.drawString(
      metric['label']!,
      font,
      bounds: Rect.fromLTWH(0, yPos, pageSize.width / 2, 15),
    );

    graphics.drawString(
      metric['value']!,
      font,
      bounds:
          Rect.fromLTWH(pageSize.width / 2, yPos, pageSize.width / 2 - 10, 15),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );

    yPos += 15;
  }
}
