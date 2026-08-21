import 'dart:typed_data';

import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/animations/progress_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/utils/components/url_launcher_func.dart';
import 'package:business_manager_web_ui/src/app/utils/pdf_generators/inventory_report_pdf.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/models/product_model.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:business_manager_web_ui/src/services/order_service.dart';
import 'package:business_manager_web_ui/src/services/product_service.dart';
import 'package:business_manager_web_ui/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InventoryReportVariables extends StatefulWidget {
  const InventoryReportVariables({super.key, this.uid});
  final String? uid;

  @override
  State<InventoryReportVariables> createState() =>
      _InventoryReportVariablesState();
}

class _InventoryReportVariablesState extends State<InventoryReportVariables> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  bool isLoading = false;
  DatabaseService db = DatabaseService();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  OrderService os = OrderService();
  ErrorClass errorClass = ErrorClass();
  ProductService ps = ProductService();
  StorageService ss = StorageService();
  UrlLauncherFunc urlLaunch = UrlLauncherFunc();
  UserDetails currentUser = UserDetails();
  int? start, end;
  Future<UserDetails>? getCurrentUser;
  String? selectedLocation;
  List<Product> products = [];
  List<RawItem> rawItems = [];
  List<String> locations = [];
  DateTimeRange? selectedRange;
  final number = NumberFormat("#,##0.00", "en_US");

  @override
  void initState() {
    if (widget.uid != null) getCurrentUser = fetchUser();
    snackbarWidget.context = context;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
    snackbarWidget.context = context;
  }

  // ── Design helpers ─────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: responsive!.scaleHeight(10),
        top: responsive!.scaleHeight(4),
      ),
      child: MyText(
        text: text.toUpperCase(),
        fontScale: responsive!.scaleFont(11),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _groupCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final isLast = entry.key == children.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast)
                Divider(
                  height: 0,
                  thickness: 0.5,
                  indent: responsive!.scaleWidth(14),
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: MyText(
            text: appLoc!.inventoryReport,
            fontScale: responsive!.scaleFont(18),
            fontWeight: FontWeight.w500,
          ),
          actions: [
            IconButton(
              onPressed: () async => await generateAndSaveReport(),
              icon: Icon(Icons.picture_as_pdf_outlined,
                  size: responsive!.scaleHeight(22)),
              tooltip: appLoc!.generate,
            ),
          ],
        ),
        body: Stack(
          children: [
            _buildInventoryReportBody(),
            if (isLoading)
              StreamBuilder<double>(
                stream: Stream.periodic(
                  const Duration(milliseconds: 100),
                  (_) => ProgressManager.progress,
                ),
                builder: (context, progressshot) {
                  final progress = progressshot.data ?? 0.0;
                  return Center(
                    child: AnimatedArcLoader(
                      progress: progress,
                      size: 150,
                      fontSize: responsive!.scaleFont(15),
                      color: Colors.blueAccent,
                      showPercentage: true,
                      onTimeout: () {
                        setState(() => isLoading = false);
                        ProgressManager.stopLoading();
                        snackbarWidget.content = appLoc!.operationTimedOut;
                        snackbarWidget.showSnack();
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildInventoryReportBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(responsive!.scaleWidth(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Location selector ───────────────────────────────────────
          _sectionLabel(appLoc!.selectLocation),
          _groupCard(children: [
            // Info hint
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive!.scaleWidth(14),
                vertical: responsive!.scaleHeight(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: responsive!.scaleHeight(15),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: responsive!.scaleWidth(8)),
                  Expanded(
                    child: MyText(
                      text: appLoc!.keepEmptyForAllLocations,
                      fontScale: responsive!.scaleFont(11),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
            // Dropdown — logic unchanged, border removed
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive!.scaleWidth(4),
                vertical: responsive!.scaleHeight(2),
              ),
              child: getInventoryLocations(context),
            ),
          ]),

          SizedBox(height: responsive!.scaleHeight(20)),

          // ── Inventory table ─────────────────────────────────────────
          _sectionLabel(appLoc!.summary),
          currentUser.businessType == 'trading'
              ? showSummaryTradingCompany()
              : showSummaryManufacturingCompany(),

          SizedBox(height: responsive!.scaleHeight(32)),
        ],
      ),
    );
  }

  // ── Location dropdown — logic unchanged, decoration restyled ──────────────

  Widget getInventoryLocations(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: selectedLocation,
      hint: Padding(
        padding: EdgeInsets.symmetric(horizontal: responsive!.scaleWidth(10)),
        child: MyText(
          text: appLoc!.storeName,
          fontScale: responsive!.scaleFont(13),
        ),
      ),
      decoration: InputDecoration(
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(
          horizontal: responsive!.scaleWidth(10),
          vertical: responsive!.scaleHeight(12),
        ),
      ),
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      dropdownColor: Theme.of(context).scaffoldBackgroundColor,
      items: currentUser.inventoryLoc?.entries
          .map<DropdownMenuItem<String>>((data) {
        return DropdownMenuItem<String>(
          value: data.value,
          child: MyText(
            text: data.value.toString(),
            fontScale: responsive!.scaleFont(13),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() => selectedLocation = newValue!);
      },
    );
  }

  // ── Trading summary — logic unchanged, table header + rows restyled ────────

  Widget showSummaryTradingCompany() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive!.scaleWidth(14),
            vertical: responsive!.scaleHeight(8),
          ),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Row(
            children: [
              _headerCell(appLoc!.code, 0.15),
              _headerCell(appLoc!.productName, 0.28),
              _headerCell(appLoc!.productStock, 0.17),
              _headerCell(appLoc!.cost, 0.15),
              _headerCell(appLoc!.total, 0.15),
            ],
          ),
        ),
        // Data rows — FutureBuilder + logic unchanged
        FutureBuilder<List<Product>>(
          future: getInventoryProduct(selectedLocation),
          builder: (context, productshot) {
            if (productshot.hasError) {
              return Center(
                child: MyText(
                    text: errorClass.productNotFound(
                        e: productshot.error.toString())),
              );
            }
            if (productshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: responsive!.screenHeight * 0.4,
                child: const Center(child: GradientSkeleton()),
              );
            }
            products = productshot.data!;
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                separatorBuilder: (_, __) => Divider(
                  height: 0,
                  thickness: 0.5,
                  indent: responsive!.scaleWidth(14),
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                ),
                itemBuilder: (context, index) {
                  double totalValue = 0, totalStock = 0;
                  if (selectedLocation == null) {
                    for (var loc in locations) {
                      totalValue = products[index].inventory?[loc] *
                          products[index].cost;
                      totalStock = totalStock + products[index].inventory?[loc];
                    }
                  } else {
                    totalValue = products[index].inventory?[selectedLocation] *
                        products[index].cost;
                    totalStock = products[index].inventory?[selectedLocation];
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive!.scaleWidth(14),
                      vertical: responsive!.scaleHeight(8),
                    ),
                    child: Row(
                      children: [
                        _dataCell(products[index].id.toString(), 0.15),
                        _dataCell(
                            products[index].name.length < 18
                                ? products[index].name
                                : products[index].name.substring(0, 18),
                            0.28),
                        _dataCell(totalStock.toString(), 0.17),
                        _dataCell('${products[index].cost}', 0.15),
                        _dataCell(totalValue.toStringAsFixed(2), 0.15),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Manufacturing summary — logic unchanged, same table treatment ──────────

  Widget showSummaryManufacturingCompany() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive!.scaleWidth(14),
            vertical: responsive!.scaleHeight(8),
          ),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Row(
            children: [
              _headerCell(appLoc!.productName, 0.35),
              _headerCell(appLoc!.productStock, 0.17),
              _headerCell(appLoc!.cost, 0.20),
              _headerCell(appLoc!.total, 0.20),
            ],
          ),
        ),
        // Data rows — FutureBuilder + logic unchanged
        FutureBuilder<List<RawItem>>(
          future: getInventoryRawItems(selectedLocation),
          builder: (context, rawitemshot) {
            if (rawitemshot.hasError) {
              return Center(
                child: MyText(
                    text: errorClass.productNotFound(
                        e: rawitemshot.error.toString())),
              );
            }
            if (rawitemshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: responsive!.screenHeight * 0.4,
                child: const Center(child: GradientSkeleton()),
              );
            }
            rawItems = rawitemshot.data!;
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rawItems.length,
                separatorBuilder: (_, __) => Divider(
                  height: 0,
                  thickness: 0.5,
                  indent: responsive!.scaleWidth(14),
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                ),
                itemBuilder: (context, index) {
                  double totalValue = 0, totalStock = 0;
                  if (selectedLocation == null) {
                    for (var loc in locations) {
                      if (rawItems[index].inventory?[loc] != null) {
                        totalValue = rawItems[index].inventory?[loc] *
                            rawItems[index].cost;
                        totalStock =
                            totalStock + rawItems[index].inventory?[loc];
                      }
                    }
                  } else {
                    if (rawItems.isNotEmpty) {
                      totalValue =
                          rawItems[index].inventory?[selectedLocation] *
                              rawItems[index].cost;
                      totalStock = rawItems[index].inventory?[selectedLocation];
                    }
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive!.scaleWidth(14),
                      vertical: responsive!.scaleHeight(8),
                    ),
                    child: Row(
                      children: [
                        _dataCell(
                            rawItems[index].name != null &&
                                    rawItems[index].name!.length > 20
                                ? rawItems[index].name!.substring(0, 20)
                                : rawItems[index].name ?? '',
                            0.35),
                        _dataCell(totalStock.toString(), 0.17),
                        _dataCell('${rawItems[index].cost}', 0.20),
                        _dataCell(totalValue.toStringAsFixed(2), 0.20),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Table cell helpers ─────────────────────────────────────────────────────

  Widget _headerCell(String text, double widthFraction) {
    return SizedBox(
      width: (responsive!.screenWidth * 0.9) * widthFraction,
      child: MyText(
        text: text,
        fontScale: responsive!.scaleFont(11),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _dataCell(String text, double widthFraction) {
    return SizedBox(
      width: (responsive!.screenWidth * 0.90) * widthFraction,
      child: MyText(
        text: text,
        fontScale: responsive!.scaleFont(11),
        maxLines: 1,
        textOverflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ── Logic — completely unchanged (except PDF save/open, see below) ────────

  Future<UserDetails> fetchUser() async {
    UserDetails user = await db.getCurrentUser(uid: widget.uid);
    setState(() => currentUser = user);
    return user;
  }

  Future<List<Product>> getInventoryProduct(String? selectedLocation) async {
    var result = await ps.futureAllProductInStore(
        userId: widget.uid, storeName: selectedLocation);
    if (selectedLocation == null) {
      for (var element in result) {
        element.inventory?.forEach((key, value) {
          if (!locations.contains(key)) locations.add(key);
        });
      }
    }
    return result;
  }

  Future<List<RawItem>> getInventoryRawItems(String? selectedLocation) async {
    var result = await ps.futureAllRawItems(
        userId: widget.uid, storeName: selectedLocation);
    if (selectedLocation == null) {
      for (var element in result) {
        element.inventory?.forEach((key, value) {
          if (!locations.contains(key)) locations.add(key);
        });
      }
    }
    return result;
  }

  Future<void> generateAndSaveReport() async {
    String? currency;
    try {
      final userData = await db.getCurrentUser(uid: widget.uid);
      if (userData.companyName == null || userData.companyName!.isEmpty) {
        snackbarWidget.content = appLoc!.companyNameEmpty;
        snackbarWidget.showSnack();
        return;
      }
      if (userData.companyLogo == null || userData.companyLogo!.isEmpty) {
        snackbarWidget.content = appLoc!.companyLogoMissing;
        snackbarWidget.showSnack();
        return;
      }
      setState(() => isLoading = true);
      ProgressManager.startLoading(
        onTimeout: () {
          if (mounted) {
            setState(() => isLoading = false);
            snackbarWidget.content = appLoc!.operationTimedOut;
            snackbarWidget.showSnack();
          }
        },
        timeoutDuration: const Duration(seconds: 30),
      );
      List<Map<String, dynamic>> items = [];
      if (currentUser.businessType == 'trading') {
        for (var item in products) {
          double stock = 0;
          if (selectedLocation != null) {
            stock = item.inventory?[selectedLocation];
          } else {
            if (locations.isEmpty) continue;
            for (var loc in locations) {
              stock = stock + item.inventory?[loc];
            }
          }
          items.add({
            'id': item.id,
            'name': item.name,
            'stock': stock,
            'cost': item.cost,
          });
        }
      } else {
        for (var item in rawItems) {
          double stock = 0;
          if (selectedLocation != null) {
            stock = item.inventory?[selectedLocation];
          } else {
            if (locations.isEmpty) continue;
            for (var loc in locations) {
              stock = stock + item.inventory?[loc];
            }
          }
          items.add({
            'id': item.uid!.substring(0, 5),
            'name': item.name,
            'stock': stock,
            'cost': item.cost,
          });
        }
      }
      currency = userData.currency!['code'];
      final pdfDocument = await generateInventoryReport(
          uid: widget.uid!,
          companyName: userData.companyName!,
          items: items,
          location: selectedLocation,
          allLocations: locations,
          logoUrl: userData.companyLogo,
          appLoc: appLoc!,
          responsive: responsive!,
          currencySymbol: currency ?? '\$');
      // Web-native save/open — replaces mobile's SaveFiles.savePdf +
      // OpenAppFile.open temp-file dance (same pattern as sales_report.dart).
      final bytes = Uint8List.fromList(await pdfDocument.save());
      pdfDocument.dispose();
      final fileName =
          'Inventory_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
      final url = await ss.uploadPdfToStorage(
        bytes: bytes,
        fileName: fileName,
        folderName: '${widget.uid}-inventory_reports',
      );
      ProgressManager.completeLoading();
      await urlLaunch.launchUrlWidget(url);
      snackbarWidget.content = appLoc!.reportGenSuccess;
      snackbarWidget.showSnack();
      if (mounted) setState(() => isLoading = false);
    } catch (e) {
      ProgressManager.stopLoading();
      snackbarWidget.content = appLoc!.reportGenFailed;
      snackbarWidget.showSnack();
      if (mounted) setState(() => isLoading = false);
    }
  }
}
