import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/models/product_model.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart' show UserDetails;
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:business_manager_web_ui/src/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ProductRecords extends StatefulWidget {
  const ProductRecords({super.key, this.uid, this.productId});
  final String? uid;
  final String? productId;

  @override
  State<ProductRecords> createState() => _ProductRecordsState();
}

class _ProductRecordsState extends State<ProductRecords> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  bool isLoading = false;
  DatabaseService db = DatabaseService();
  ProductService ps = ProductService();
  ErrorClass errorClass = ErrorClass();
  SnackbarWidget snackbar = SnackbarWidget();
  UserDetails currentUser = UserDetails();
  Future<UserDetails>? getCurrentUser;
  Future<List<OrderProducts>>? getProductRecords;
  List<OrderProducts> records = [];
  final number = NumberFormat("#,##0.00", "en_US");

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    snackbar.context = context;
    responsive = ResponsiveUtils(context);
    appLoc = AppLocalizations.of(context);
  }

  @override
  void initState() {
    if (widget.uid != null) getCurrentUser = fetchUser();
    if (widget.productId != null) getProductRecords = fetchProduct();
    super.initState();
  }

  // ── Logic unchanged ────────────────────────────────────────────────────────

  Future<UserDetails> fetchUser() async => db.getCurrentUser(uid: widget.uid);

  Future<List<OrderProducts>> fetchProduct() async =>
      ps.futureSingleProductRecord(
          userId: widget.uid, productId: widget.productId);

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
            text: appLoc!.productRecords,
            fontScale: responsive!.scaleFont(18),
            fontWeight: FontWeight.w500,
          ),
        ),
        body: _buildProductRecord(),
      ),
    );
  }

  Widget _buildProductRecord() {
    return FutureBuilder<List<OrderProducts>>(
      future: getProductRecords,
      builder: (context, productsnap) {
        if (productsnap.hasError) {
          return Center(
            child: MyText(
              text: errorClass.productRecordNotFound(
                  e: productsnap.error.toString()),
              align: TextAlign.center,
            ),
          );
        }
        if (productsnap.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        }

        if (productsnap.data != null) records = productsnap.data!;

        if (records.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: responsive!.scaleHeight(48),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(height: responsive!.scaleHeight(12)),
                MyText(
                  text: appLoc!.noItemRecordFound,
                  fontScale: responsive!.scaleFont(14),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // ── Summary bar ────────────────────────────────────────────────
            _buildSummaryBar(),

            // ── Column headers ─────────────────────────────────────────────
            _buildHeaders(),

            // ── Records list ───────────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive!.scaleWidth(16),
                  vertical: responsive!.scaleHeight(8),
                ),
                itemCount: records.length,
                itemBuilder: (context, index) => _buildRecordRow(index),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Summary bar ────────────────────────────────────────────────────────────

  Widget _buildSummaryBar() {
    final totalQty =
        records.fold<double>(0, (sum, r) => sum + (r.quantity ?? 0));
    final totalRevenue = records.fold<double>(
        0, (sum, r) => sum + ((r.price ?? 0) * (r.quantity ?? 0)));

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(16),
        vertical: responsive!.scaleHeight(12),
      ),
      child: Row(
        children: [
          _summaryChip(
            icon: Icons.receipt_outlined,
            label: appLoc!.totalOrders,
            value: records.length.toString(),
          ),
          SizedBox(width: responsive!.scaleWidth(10)),
          _summaryChip(
            icon: Icons.shopping_cart_outlined,
            label: appLoc!.quantity,
            value: number.format(totalQty),
          ),
          SizedBox(width: responsive!.scaleWidth(10)),
          _summaryChip(
            icon: Icons.monetization_on_outlined,
            label: appLoc!.totalValue,
            value: number.format(totalRevenue),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsive!.scaleWidth(10),
          vertical: responsive!.scaleHeight(10),
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: responsive!.scaleHeight(14),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: responsive!.scaleHeight(4)),
            MyText(
              text: value,
              fontScale: responsive!.scaleFont(13),
              fontWeight: FontWeight.w500,
            ),
            MyText(
              text: label,
              fontScale: responsive!.scaleFont(10),
            ),
          ],
        ),
      ),
    );
  }

  // ── Column headers ─────────────────────────────────────────────────────────

  Widget _buildHeaders() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: responsive!.scaleWidth(16)),
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(14),
        vertical: responsive!.scaleHeight(8),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: MyText(
              text: appLoc!.orderId.toUpperCase(),
              fontScale: responsive!.scaleFont(10),
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            flex: 2,
            child: MyText(
              text: appLoc!.price.toUpperCase(),
              fontScale: responsive!.scaleFont(10),
              fontWeight: FontWeight.w500,
              align: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: MyText(
              text: appLoc!.quantity.toUpperCase(),
              fontScale: responsive!.scaleFont(10),
              fontWeight: FontWeight.w500,
              align: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: MyText(
              text: appLoc!.discount.toUpperCase(),
              fontScale: responsive!.scaleFont(10),
              fontWeight: FontWeight.w500,
              align: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // ── Record row ─────────────────────────────────────────────────────────────

  Widget _buildRecordRow(int index) {
    final record = records[index];
    final hasDiscount = record.discount != null && record.discount! > 0;

    return GestureDetector(
      onTap: () {
        if (widget.uid == null || record.id == null) return;
        GoRouter.of(context).pushNamed('editOrder', pathParameters: {
          'uid': widget.uid!,
          'orderId': record.id!,
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: responsive!.scaleHeight(8)),
        padding: EdgeInsets.symmetric(
          horizontal: responsive!.scaleWidth(14),
          vertical: responsive!.scaleHeight(12),
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Order ID
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Icon(
                    Icons.chevron_right,
                    size: responsive!.scaleHeight(14),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: responsive!.scaleWidth(4)),
                  Flexible(
                    child: MyText(
                      text: record.id?.toString() ?? '—',
                      fontScale: responsive!.scaleFont(12),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Price
            Expanded(
              flex: 2,
              child: MyText(
                text: number.format(record.price ?? 0),
                fontScale: responsive!.scaleFont(12),
                align: TextAlign.right,
              ),
            ),
            // Quantity
            Expanded(
              flex: 2,
              child: MyText(
                text: number.format(record.quantity ?? 0),
                fontScale: responsive!.scaleFont(12),
                align: TextAlign.right,
              ),
            ),
            // Discount
            Expanded(
              flex: 2,
              child: hasDiscount
                  ? Container(
                      margin: EdgeInsets.only(left: responsive!.scaleWidth(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: MyText(
                        text: '${number.format(record.discount)}%',
                        fontScale: responsive!.scaleFont(11),
                        fontWeight: FontWeight.w500,
                        fontColor: Colors.orange.shade800,
                        align: TextAlign.center,
                      ),
                    )
                  : MyText(
                      text: '—',
                      fontScale: responsive!.scaleFont(12),
                      align: TextAlign.right,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
