import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/models/product_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:business_manager_web_ui/src/services/product_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ProductContentScreen extends StatefulWidget {
  const ProductContentScreen({super.key, this.uid});
  final String? uid;

  @override
  State<ProductContentScreen> createState() => _ProductContentScreenState();
}

class _ProductContentScreenState extends State<ProductContentScreen> {
  AppLocalizations? appLoc;
  ResponsiveUtils? responsive;
  ProductService ps = ProductService();
  DatabaseService db = DatabaseService();
  ErrorClass errorClass = ErrorClass();
  bool isLoading = false;
  final number = NumberFormat("#,##0.00", "en_US");

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
  }

  @override
  Widget build(BuildContext context) {
    return _buildProductAnalysisContent();
  }

  Widget _buildProductAnalysisContent() {
    return StreamBuilder<List<OrderProducts>>(
      stream: ps.streamProductRecords(userId: widget.uid),
      builder: (context, recordsnap) {
        if (recordsnap.hasError) {
          return Center(
            child: MyText(
                text:
                    errorClass.failedToGetRecords(recordsnap.error.toString())),
          );
        } else if (recordsnap.connectionState == ConnectionState.waiting) {
          return Center(
            child: LinearProgressIndicator(
              color:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
              minHeight: responsive!.scaleHeight(2),
            ),
          );
        } else if (recordsnap.hasData && recordsnap.data!.isNotEmpty) {
          final aggregatedRecords = aggregateProductsWeighted(recordsnap.data!);
          return _buildRecordDetails(aggregatedRecords);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildRecordDetails(List<OrderProducts> records) {
    final displayCount = records.length > 5 ? 5 : records.length;
    final maxQuantity = records.isNotEmpty
        ? records
            .take(displayCount)
            .map((r) => r.quantity ?? 0)
            .reduce((a, b) => a > b ? a : b)
        : 1.0;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.2),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          MyText(
            text: appLoc!.topProducts.toUpperCase(),
            fontScale: responsive!.scaleFont(11),
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 10),

          // Product rows
          ...List.generate(displayCount, (index) {
            final record = records[index];
            return FutureBuilder(
              future: ps.futureSingleProduct(
                  userId: widget.uid, productId: record.id),
              builder: (context, productshot) {
                if (productshot.hasError || !productshot.hasData) {
                  return const SizedBox.shrink();
                }
                if (productshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(
                      color: Theme.of(context).colorScheme.surface,
                      minHeight: responsive!.scaleHeight(2),
                    ),
                  );
                }
                return _productRow(
                  product: productshot.data!,
                  record: record,
                  rank: index + 1,
                  maxQuantity: maxQuantity,
                  isLast: index == displayCount - 1,
                );
              },
            );
          }),

          // View more
          if (records.length > 5) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => GoRouter.of(context).pushNamed(
                'topProductsScreen',
                pathParameters: {'uid': widget.uid!},
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyText(
                    text: appLoc!.viewMore,
                    fontScale: responsive!.scaleFont(12),
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    Icons.arrow_forward,
                    size: responsive!.scaleHeight(13),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _productRow({
    required Product product,
    required OrderProducts record,
    required int rank,
    required double maxQuantity,
    required bool isLast,
  }) {
    final ratio = maxQuantity > 0 ? (record.quantity ?? 0) / maxQuantity : 0.0;
    final totalRevenue = (record.quantity ?? 0) * (record.price ?? 0);

    return GestureDetector(
      onTap: () => GoRouter.of(context).pushNamed(
        'editProduct',
        pathParameters: {'uid': widget.uid!, 'productId': product.id!},
      ),
      child: Container(
        decoration: BoxDecoration(
          border: !isLast
              ? Border(
                  bottom: BorderSide(
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.25),
                    width: 0.5,
                  ),
                )
              : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image with rank badge overlay
            _buildImageWithRank(product, rank),
            const SizedBox(width: 12),

            // Name + meta + bar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    text: product.name.length > 22
                        ? '${product.name.substring(0, 22)}...'
                        : product.name,
                    fontScale: responsive!.scaleFont(13),
                    fontWeight: FontWeight.w500,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  MyText(
                    text:
                        '${appLoc!.averagePrice}: ${number.format(record.price)}',
                    fontScale: responsive!.scaleFont(11),
                  ),
                  const SizedBox(height: 5),
                  // Relative bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 4,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      color: Colors.blue.withValues(alpha: 0.4 + 0.6 * ratio),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Qty pill + revenue
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Blue qty pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: MyText(
                    text:
                        '${number.format(record.quantity)} ${appLoc!.soldQuantity}',
                    fontScale: responsive!.scaleFont(10),
                    fontWeight: FontWeight.w500,
                    fontColor: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 3),
                // Revenue total
                MyText(
                  text: number.format(totalRevenue),
                  fontScale: responsive!.scaleFont(11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWithRank(Product product, int rank) {
    // Rank badge colors
    Color badgeBg;
    Color badgeText;
    if (rank == 1) {
      badgeBg = Colors.amber.shade200;
      badgeText = Colors.amber.shade900;
    } else if (rank == 2) {
      badgeBg = Colors.grey.shade300;
      badgeText = Colors.grey.shade800;
    } else if (rank == 3) {
      badgeBg = Colors.orange.shade200;
      badgeText = Colors.orange.shade900;
    } else {
      badgeBg = Theme.of(context).colorScheme.surfaceContainerHighest;
      badgeText = Theme.of(context).colorScheme.onSurfaceVariant;
    }

    final imgSize = responsive!.deviceType == 1
        ? responsive!.scaleWidth(56)
        : responsive!.scaleWidth(48);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Image box
        Container(
          width: imgSize,
          height: imgSize,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
              width: 0.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: product.images != null && product.images!.isNotEmpty
              ? FutureBuilder(
                  future: ps.futureSingleImage(
                    userId: widget.uid!,
                    imageId: product.images!.entries.elementAt(0).value!,
                  ),
                  builder: (context, imageshot) {
                    if (imageshot.connectionState == ConnectionState.waiting) {
                      return _shimmerBox();
                    }
                    if (imageshot.hasData) {
                      return CachedNetworkImage(
                        imageUrl: imageshot.data!.imageUrl!,
                        cacheManager: CacheManager(
                          Config(
                            'customCacheKey',
                            stalePeriod: const Duration(days: 7),
                            maxNrOfCacheObjects: 100,
                          ),
                        ),
                        placeholder: (_, __) => _shimmerBox(),
                        errorWidget: (_, __, ___) => const Icon(
                            Icons.image_not_supported_outlined,
                            size: 20),
                        fit: BoxFit.cover,
                      );
                    }
                    return Image.asset(
                      'assets/images/placeholder.png',
                      fit: BoxFit.cover,
                    );
                  },
                )
              : const Icon(Icons.inventory_2_outlined, size: 22),
        ),

        // Rank badge
        Positioned(
          top: -5,
          left: -5,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: badgeBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: MyText(
              text: '$rank',
              fontScale: responsive!.scaleFont(9),
              fontWeight: FontWeight.w500,
              fontColor: badgeText,
            ),
          ),
        ),
      ],
    );
  }

  // avoids using GradientSkeleton inside a constrained box.
  Widget _shimmerBox() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, _) {
        return Container(
          color: (Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade700
                  : Colors.grey.shade300)
              .withValues(alpha: value),
        );
      },
      onEnd: () => setState(() {}), // retriggers the animation
    );
  }

  // ─── Data logic (unchanged) ───────────────────────────────────────────────

  List<OrderProducts> aggregateProductsWeighted(List<OrderProducts> records) {
    final Map<String, OrderProducts> aggregatedMap = {};
    final Map<String, double> totalValueMap = {};
    final Map<String, double> totalQuantityMap = {};

    for (var record in records) {
      if (record.id == null) continue;

      final productId = record.id!;
      final quantity = record.quantity ?? 0;
      final price = record.price ?? 0;

      if (aggregatedMap.containsKey(productId)) {
        totalValueMap[productId] =
            totalValueMap[productId]! + (price * quantity);
        totalQuantityMap[productId] = totalQuantityMap[productId]! + quantity;

        aggregatedMap[productId] = OrderProducts(
          id: productId,
          userId: aggregatedMap[productId]!.userId,
          name: aggregatedMap[productId]!.name,
          originalPrice: aggregatedMap[productId]!.originalPrice,
          price: totalValueMap[productId]! / totalQuantityMap[productId]!,
          quantity: totalQuantityMap[productId],
          discount: aggregatedMap[productId]!.discount,
          packing: aggregatedMap[productId]!.packing,
        );
      } else {
        totalValueMap[productId] = price * quantity;
        totalQuantityMap[productId] = quantity;

        aggregatedMap[productId] = OrderProducts(
          id: productId,
          userId: record.userId,
          name: record.name,
          originalPrice: record.originalPrice,
          price: price,
          quantity: quantity,
          discount: record.discount,
          packing: record.packing,
        );
      }
    }

    return aggregatedMap.values.toList()
      ..sort((a, b) => (b.quantity ?? 0).compareTo(a.quantity ?? 0));
  }
}

extension DoublePrecision on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}
