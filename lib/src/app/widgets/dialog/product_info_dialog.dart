import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text_field.dart';
import 'package:business_manager_web_ui/src/models/product_model.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProductInfoDialog {
  Future<String?> show(
    BuildContext context,
    ResponsiveUtils? responsive,
    AppLocalizations appLoc,
    String inventoryLoc,
    OrderProducts orderProduct,
    Function(OrderProducts updatedProduct) onSave,
    UserDetails currentUser,
    bool? purchase,
  ) {
    // ── All logic variables — completely unchanged ──────────────────────────
    bool? useInventory = false,
        isApplyingDiscount = false,
        isUpdatingPrice = false,
        isUpdatingQuantity = false;

    if (currentUser.isSubscribed != null &&
        currentUser.isSubscribed! &&
        currentUser.useInventory != null &&
        currentUser.useInventory!) {
      useInventory = true;
    }
    ProductService ps = ProductService();
    SnackbarWidget snackbarWidget = SnackbarWidget();
    snackbarWidget.context = context;
    double? newItemValue = purchase! ? orderProduct.cost : orderProduct.price;
    TextEditingController quantityController = TextEditingController(
      text: orderProduct.quantity.toString(),
    );
    TextEditingController discountController = TextEditingController(
      text: orderProduct.discount != null
          ? orderProduct.discount.toString()
          : '0',
    );
    TextEditingController priceController = TextEditingController(
      text: purchase
          ? orderProduct.cost.toString()
          : orderProduct.price.toString(),
    );

    // ── All listener logic — completely unchanged ───────────────────────────
    void safeCalculateValue() {
      final quantityText = quantityController.text.trim();
      final priceText = priceController.text.trim();
      final quantity = double.tryParse(quantityText);
      final price = double.tryParse(priceText);
      final discount = double.tryParse(discountController.text);

      if (quantity != null && price != null) {
        newItemValue = quantity * price;
      } else if (quantity != null && price == null) {
        final originalPrice = purchase
            ? orderProduct.cost ?? 0
            : orderProduct.price ?? 0;
        newItemValue = quantity * originalPrice;
      } else if (discount == null || discount == 0.0) {
        final originalPrice = purchase
            ? orderProduct.cost ?? 0
            : orderProduct.price ?? 0;
        newItemValue = (quantity ?? 0) * originalPrice;
      } else if (price != null && quantity == null) {
        newItemValue = price;
      }
    }

    quantityController.addListener(() async {
      if (isUpdatingQuantity!) return;
      if (quantityController.text.isEmpty || quantityController.text == ' ') {
        safeCalculateValue();
        return;
      }
      final quantity = double.tryParse(quantityController.text);
      if (quantity == null) {
        isUpdatingQuantity = true;
        quantityController.text = '1';
        Future.delayed(Duration.zero, () {
          isUpdatingQuantity = false;
        });
        safeCalculateValue();
        return;
      }
      if (quantity <= 0) {
        isUpdatingQuantity = true;
        quantityController.text = '1';
        Future.delayed(Duration.zero, () {
          isUpdatingQuantity = false;
        });
      }
      if (useInventory! &&
          inventoryLoc.isNotEmpty &&
          orderProduct.storeLocation!.contains(inventoryLoc) &&
          !purchase) {
        try {
          if (currentUser.businessType == 'trading') {
            final result = await checkIfInventoryIsAvailable(
              currentUser.uid!,
              orderProduct.id!,
              quantityController.text,
              inventoryLoc,
            );
            final totalStock = await checkInventoryTotalTrading(
              currentUser.uid!,
              orderProduct.id!,
              inventoryLoc,
            );
            if (!result) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(appLoc.insufficientInventory),
                    elevation: 4,
                    duration: const Duration(seconds: 4),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              });
              isUpdatingQuantity = true;
              quantityController.text = '$totalStock';
              Future.delayed(Duration.zero, () {
                isUpdatingQuantity = false;
              });
              safeCalculateValue();
              return;
            }
          } else if (currentUser.businessType == 'manufacturing') {
            Product product = await ps.futureSingleProduct(
              userId: currentUser.uid,
              productId: orderProduct.id,
            );
            var stock = await checkRawMaterialStock(
              product,
              currentUser,
              orderProduct,
              quantityController.text,
              appLoc,
            );
            if (stock['stock'] != null && stock['stock']! < 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(appLoc.insufficientInventory),
                    elevation: 4,
                    duration: const Duration(seconds: 4),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              });
              isUpdatingQuantity = true;
              quantityController.text = '1';
              Future.delayed(Duration.zero, () {
                isUpdatingQuantity = false;
              });
              safeCalculateValue();
              return;
            }
          } else {
            return;
          }
        } catch (e) {
          debugPrint('Inventory check error: $e');
        }
      }
      safeCalculateValue();
    });

    discountController.addListener(() {
      double? basePrice;
      if (isApplyingDiscount!) return;
      if (discountController.text.isEmpty) {
        basePrice = purchase ? orderProduct.cost! : orderProduct.originalPrice!;
        priceController.text = basePrice.toStringAsFixed(2);
      }
      if (discountController.text.isNotEmpty &&
          priceController.text.isNotEmpty) {
        double discountValue = double.tryParse(discountController.text) ?? 0.0;
        if (discountValue == orderProduct.discount) return;
        if ((discountValue - orderProduct.discount!).abs() < 0.001) return;
        if (discountValue < 0) {
          discountController.text = '0';
          discountValue = 0.0;
        } else if (discountValue > 100) {
          discountController.text = '100';
          discountValue = 100.0;
        }
        double basePrice = purchase ? orderProduct.cost! : orderProduct.price!;
        double newPrice = basePrice - (discountValue * basePrice / 100);
        priceController.text = newPrice.toStringAsFixed(2);
        isApplyingDiscount = true;
        Future.delayed(Duration.zero, () {
          isApplyingDiscount = false;
        });
        newItemValue =
            double.tryParse(quantityController.text)! *
            double.tryParse(priceController.text)!;
      }
    });

    priceController.addListener(() {
      if (isUpdatingPrice!) return;
      if (priceController.text.isNotEmpty) {
        if (priceController.text == '0' ||
            (purchase ? orderProduct.cost == 0 : orderProduct.price == 0)) {
          isUpdatingPrice = true;
          isUpdatingPrice = false;
        }
        newItemValue =
            double.tryParse(quantityController.text)! *
            double.tryParse(priceController.text)!;
      }
    });

    // ── showModalBottomSheet — only visual changes inside ──────────────────
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      elevation: 1,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void updateItemValue() {
              final quantity = double.tryParse(quantityController.text) ?? 0;
              final price = double.tryParse(priceController.text) ?? 0;
              if (context.mounted) {
                setState(() {
                  newItemValue = quantity * price;
                });
              }
            }

            quantityController.addListener(updateItemValue);
            discountController.addListener(updateItemValue);
            priceController.addListener(updateItemValue);

            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Drag handle ──────────────────────────────────
                        Container(
                          width: 36,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        // ── Header: name / total / save ──────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: MyText(
                                text: orderProduct.name!.length > 22
                                    ? '${orderProduct.name!.substring(0, 22)}…'
                                    : orderProduct.name!,
                                fontScale: responsive!.scaleFont(15),
                                fontWeight: FontWeight.w600,
                                softWrap: true,
                              ),
                            ),
                            SizedBox(width: responsive.scaleWidth(8)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                MyText(
                                  text: appLoc.total,
                                  fontScale: responsive.scaleFont(11),
                                ),
                                MyText(
                                  text: (newItemValue ?? 0).toStringAsFixed(2),
                                  fontScale: responsive.scaleFont(14),
                                  fontWeight: FontWeight.w600,
                                ),
                                // Inventory stock display — logic unchanged
                                if (useInventory != null && useInventory)
                                  FutureBuilder<double>(
                                    future:
                                        currentUser.businessType == 'trading'
                                        ? checkInventoryTotalTrading(
                                            currentUser.uid!,
                                            orderProduct.id!,
                                            inventoryLoc,
                                          )
                                        : checkInventoryTotalManufacuturing(
                                            currentUser,
                                            appLoc,
                                            orderProduct,
                                            inventoryLoc,
                                          ),
                                    builder: (context, totalshot) {
                                      if (totalshot.hasData) {
                                        return MyText(
                                          text:
                                              '${appLoc.inventory}: ${totalshot.data!.toStringAsFixed(2)}',
                                          fontScale: responsive.scaleFont(10),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                              ],
                            ),
                            SizedBox(width: responsive.scaleWidth(10)),
                            // Save button — same onPressed logic, restyled
                            GestureDetector(
                              onTap: () {
                                if (quantityController.text.isEmpty) {
                                  snackbarWidget.content =
                                      appLoc.quantityCannotBeEmpty;
                                  snackbarWidget.showSnack();
                                }
                                if (priceController.text.isEmpty) {
                                  snackbarWidget.content =
                                      appLoc.priceCannotBeEmpty;
                                  snackbarWidget.showSnack();
                                }
                                OrderProducts newProduct = orderProduct;
                                if (purchase) {
                                  onSave(
                                    newProduct.copyWith(
                                      quantity: double.tryParse(
                                        quantityController.text,
                                      ),
                                      cost: double.tryParse(
                                        priceController.text,
                                      ),
                                      discount: double.tryParse(
                                        discountController.text,
                                      ),
                                    ),
                                  );
                                } else {
                                  onSave(
                                    newProduct.copyWith(
                                      quantity: double.tryParse(
                                        quantityController.text,
                                      ),
                                      price: double.tryParse(
                                        priceController.text,
                                      ),
                                      discount: double.tryParse(
                                        discountController.text,
                                      ),
                                    ),
                                  );
                                }
                                GoRouter.of(context).pop();
                              },
                              child: Container(
                                width: responsive.scaleWidth(36),
                                height: responsive.scaleHeight(36),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.save_outlined,
                                  size: responsive.scaleHeight(18),
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: responsive.scaleHeight(14),
                          ),
                          child: Divider(
                            height: 0,
                            thickness: 0.5,
                            color: Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: 0.3),
                          ),
                        ),

                        // ── Quantity row ─────────────────────────────────
                        _fieldRow(
                          responsive: responsive,
                          label: appLoc.itemQuantity,
                          field: MyTextField(
                            controller: quantityController,
                            fontSize: responsive.scaleFont(14),
                            isNumberKeyboard: true,
                          ),
                        ),

                        SizedBox(height: responsive.scaleHeight(10)),

                        // ── Price / Cost row ─────────────────────────────
                        _fieldRow(
                          responsive: responsive,
                          label: purchase ? appLoc.cost : appLoc.price,
                          trailing: GestureDetector(
                            onTap: () {
                              setState(() {
                                priceController.text = orderProduct
                                    .originalPrice
                                    .toString();
                                discountController.text = '0.0';
                              });
                            },
                            child: Container(
                              width: responsive.scaleWidth(26),
                              height: responsive.scaleHeight(26),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.restore,
                                size: responsive.scaleHeight(14),
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          field: MyTextField(
                            controller: priceController,
                            fontSize: responsive.scaleFont(14),
                            isNumberKeyboard: true,
                          ),
                        ),

                        // ── Discount row (non-purchase only) ─────────────
                        if (!purchase) ...[
                          SizedBox(height: responsive.scaleHeight(10)),
                          _fieldRow(
                            responsive: responsive,
                            label: appLoc.discount,
                            field: MyTextField(
                              controller: discountController,
                              fontSize: responsive.scaleFont(14),
                              isNumberKeyboard: true,
                              suffix: '%',
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // ── Field row helper — label left, optional trailing icon, input right ─────
  Widget _fieldRow({
    required ResponsiveUtils responsive,
    required String label,
    required Widget field,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              Text(label, style: TextStyle(fontSize: responsive.scaleFont(14))),
              if (trailing != null) ...[
                SizedBox(width: responsive.scaleWidth(6)),
                trailing,
              ],
            ],
          ),
        ),
        SizedBox(
          height: responsive.scaleHeight(44),
          width: responsive.scaleWidth(130),
          child: field,
        ),
      ],
    );
  }

  // ── All logic methods — completely unchanged ───────────────────────────────

  Future<bool> checkIfInventoryIsAvailable(
    String uid,
    String productId,
    String quantity,
    String location,
  ) async {
    ProductService ps = ProductService();
    Product product = await ps.futureSingleProduct(
      userId: uid,
      productId: productId,
    );
    if (product.inventory != null &&
        product.inventory!.containsKey(location) &&
        product.inventory![location] != null) {
      if (product.inventory![location]! < double.tryParse(quantity)!) {
        return false;
      } else {
        return true;
      }
    }
    return true;
  }

  Future<double> checkInventoryTotalTrading(
    String uid,
    String productId,
    String location,
  ) async {
    try {
      ProductService ps = ProductService();
      Product product = await ps.futureSingleProduct(
        userId: uid,
        productId: productId,
      );
      if (product.inventory != null &&
          product.inventory!.containsKey(location) &&
          product.inventory![location] != null) {
        return product.inventory![location];
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  Future<double> checkInventoryTotalManufacuturing(
    UserDetails user,
    AppLocalizations appLoc,
    OrderProducts orderProduct,
    String storeLocation,
  ) async {
    try {
      ProductService ps = ProductService();
      double leastStock = -1;
      Product product = await ps.futureSingleProduct(
        userId: user.uid,
        productId: orderProduct.id,
      );
      if (product.receipeId != null && product.receipeId!.isNotEmpty) {
        var receipe = await ps.futureSingleReceipe(
          userId: user.uid!,
          receipeId: product.receipeId!,
        );
        if (receipe.ingredients != null && receipe.ingredients!.isNotEmpty) {
          for (var ingredient in receipe.ingredients!) {
            var rawItem = await ps.futureSingleRawItem(
              userId: user.uid!,
              rawItemId: ingredient.uid!,
            );
            if (rawItem.inventory != null && rawItem.inventory!.isNotEmpty) {
              double availableStock = rawItem.inventory![storeLocation] ?? 0;
              double ingredientQtyPerUnit = ingredient.quantity ?? 1.0;
              if (ingredient.unit?.toLowerCase() !=
                  rawItem.unit?.toLowerCase()) {
                var convertedRate =
                    rawItem.conversion![ingredient.unit?.toLowerCase()]?.rate;
                if (convertedRate != null && convertedRate != 0) {
                  ingredientQtyPerUnit = ingredientQtyPerUnit / convertedRate;
                }
              }
              // Now always calculate — whether units matched or not
              final itemConvertedStock = ingredientQtyPerUnit > 0
                  ? availableStock / ingredientQtyPerUnit
                  : 0.0;

              if (leastStock < 0 || leastStock > itemConvertedStock) {
                leastStock = itemConvertedStock;
              }
            }
          }
        }
      }
      return leastStock;
    } catch (e) {
      return 0;
    }
  }

  // Future<Map<String, double>> checkRawMaterialStock(
  //   Product product,
  //   UserDetails user,
  //   OrderProducts order,
  //   String quantity,
  //   AppLocalizations appLoc,
  // ) async {
  //   ProductService ps = ProductService();
  //   double stock = -1;
  //   double leastStock = -1;
  //   Map<String, double> requiredMaterials = {};
  //   if (product.receipeId != null && product.receipeId!.isNotEmpty) {
  //     var receipe = await ps.futureSingleReceipe(
  //         userId: user.uid!, receipeId: product.receipeId!);
  //     if (receipe.ingredients != null && receipe.ingredients!.isNotEmpty) {
  //       for (var ingredient in receipe.ingredients!) {
  //         var rawItem = await ps.futureSingleRawItem(
  //             userId: user.uid!, rawItemId: ingredient.uid!);
  //         if (rawItem.inventory != null &&
  //             rawItem.inventory!.isNotEmpty &&
  //             rawItem.inventory!.containsKey(order.storeLocation)) {
  //           double availableStock =
  //               rawItem.inventory![order.storeLocation] ?? 0;
  //           if (ingredient.unit?.toLowerCase() != rawItem.unit?.toLowerCase()) {
  //             var convertedRate =
  //                 rawItem.conversion![ingredient.unit?.toLowerCase()]?.rate;
  //             var originalRate = ingredient.quantity! / convertedRate!;
  //             ingredient.quantity = originalRate;
  //           }
  //           if (quantity.isEmpty || quantity == '0') quantity = '1';
  //           double requiredQuantity =
  //               ingredient.quantity! * double.parse(quantity);
  //           double remainingStock = 0;
  //           if (leastStock < 0 || leastStock < availableStock) {
  //             leastStock = availableStock;
  //           }
  //           if (availableStock - requiredQuantity >= 0) {
  //             remainingStock = availableStock - requiredQuantity;
  //           } else {
  //             remainingStock = -1;
  //           }
  //           requiredMaterials[ingredient.name!] = remainingStock;
  //           print('the stock needed: ${requiredMaterials[ingredient.name!]}');
  //         } else {
  //           stock = -1;
  //         }
  //       }
  //     }
  //   }
  //   if (requiredMaterials.containsValue(-1)) {
  //     requiredMaterials.keys.firstWhere((k) => requiredMaterials[k] == -1);
  //     stock = -1;
  //   } else {
  //     stock = 1;
  //   }
  //   print('the stock: $stock - Least: $leastStock');
  //   return {'stock': stock, 'least': leastStock};
  // }
  Future<Map<String, double>> checkRawMaterialStock(
    Product product,
    UserDetails user,
    OrderProducts order,
    String quantity,
    AppLocalizations appLoc,
  ) async {
    ProductService ps = ProductService();
    double stock = -1;
    double leastStock = -1;
    bool ingredientMissingFromLocation = false; // tracks Bug 4 separately
    Map<String, double> requiredMaterials = {};

    if (product.receipeId != null && product.receipeId!.isNotEmpty) {
      var receipe = await ps.futureSingleReceipe(
        userId: user.uid!,
        receipeId: product.receipeId!,
      );

      if (receipe.ingredients != null && receipe.ingredients!.isNotEmpty) {
        if (quantity.isEmpty || quantity == '0') quantity = '1';
        final parsedQty = double.parse(quantity);

        for (var ingredient in receipe.ingredients!) {
          var rawItem = await ps.futureSingleRawItem(
            userId: user.uid!,
            rawItemId: ingredient.uid!,
          );

          if (rawItem.inventory != null &&
              rawItem.inventory!.isNotEmpty &&
              rawItem.inventory!.containsKey(order.storeLocation)) {
            double availableStock =
                rawItem.inventory![order.storeLocation] ?? 0;

            // Unit conversion — your original logic, variable kept local
            double ingredientQtyPerUnit = ingredient.quantity ?? 1.0;
            if (ingredient.unit?.toLowerCase() != rawItem.unit?.toLowerCase()) {
              var convertedRate =
                  rawItem.conversion![ingredient.unit?.toLowerCase()]?.rate;
              if (convertedRate != null && convertedRate != 0) {
                var originalRate = ingredientQtyPerUnit / convertedRate;
                ingredientQtyPerUnit = originalRate;
              }
            }

            double requiredQuantity = ingredientQtyPerUnit * parsedQty;
            double remainingStock = 0;

            // leastStock = how many product units can be made from this ingredient
            final maxUnitsFromThisIngredient =
                availableStock / ingredientQtyPerUnit;
            if (leastStock < 0 || maxUnitsFromThisIngredient < leastStock) {
              leastStock = maxUnitsFromThisIngredient;
            }

            if (availableStock - requiredQuantity >= 0) {
              remainingStock = availableStock - requiredQuantity;
            } else {
              remainingStock = -1;
            }

            requiredMaterials[ingredient.name!] = remainingStock;
          } else {
            // ingredient not found in this location — flag it, don't just set stock
            ingredientMissingFromLocation = true;
            requiredMaterials[ingredient.name ?? 'unknown'] = -1;
          }
        }
      }
    }

    // Final verdict — shortfall OR missing ingredient both mean stock = -1
    if (requiredMaterials.containsValue(-1) || ingredientMissingFromLocation) {
      stock = -1;
    } else {
      stock = 1;
    }
    return {'stock': stock, 'least': leastStock};
  }
}
