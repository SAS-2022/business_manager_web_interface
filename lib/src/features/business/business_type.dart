import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text_field.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/auth_service.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/responsive_utils.dart';
import '../../app/widgets/buttons/skeleton_loading.dart';

class BusinessType extends StatefulWidget {
  const BusinessType({super.key, this.uid});
  final String? uid;

  @override
  State<BusinessType> createState() => _BusinessTypeState();
}

class _BusinessTypeState extends State<BusinessType> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  AuthService as = AuthService();
  bool isLoading = false, isUpdate = false, controllerInitialized = false;
  Future<UserDetails>? getCurrentUser;
  UserDetails currentUser = UserDetails();
  final DatabaseService db = DatabaseService();
  final ErrorClass errorClass = ErrorClass();
  final SnackbarWidget snackbarWidget = SnackbarWidget();
  TextEditingController otherController = TextEditingController();
  bool termsChecked = false, showingTerms = false;

  // Cached type list so we don't re-fetch on every setState
  List<String> _cachedTypes = [];

  @override
  void initState() {
    getCurrentUser = fetchUser();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
    snackbarWidget.context = context;
  }

  @override
  void dispose() {
    otherController.dispose();
    super.dispose();
  }

  // ── Icon mapping — add entries here when new types are added to Firestore ──
  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'trading':
        return Icons.storefront_outlined;
      case 'manufacturing':
        return Icons.precision_manufacturing_outlined;
      case 'service':
        return Icons.build_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  IconData _iconForCategory(String category) {
    final c = category.toLowerCase();
    if (c.contains('fashion') || c.contains('apparel') || c.contains('cloth')) {
      return Icons.checkroom_outlined;
    } else if (c.contains('electronic') || c.contains('tech')) {
      return Icons.devices_outlined;
    } else if (c.contains('food') ||
        c.contains('beverage') ||
        c.contains('restaurant')) {
      return Icons.restaurant_outlined;
    } else if (c.contains('home') || c.contains('furniture')) {
      return Icons.chair_outlined;
    } else if (c.contains('health') || c.contains('medical')) {
      return Icons.health_and_safety_outlined;
    } else if (c.contains('auto') ||
        c.contains('car') ||
        c.contains('vehicle')) {
      return Icons.directions_car_outlined;
    } else if (c.contains('construction') || c.contains('building')) {
      return Icons.construction_outlined;
    } else if (c.contains('beauty') || c.contains('cosmetic')) {
      return Icons.face_outlined;
    } else if (c.contains('education') || c.contains('training')) {
      return Icons.school_outlined;
    } else if (c.contains('it') || c.contains('software')) {
      return Icons.code_outlined;
    } else if (c.contains('other')) {
      return Icons.more_horiz;
    }
    return Icons.label_outline;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          actions: [
            GestureDetector(
              onTap: () async {
                await as.signOut();
                // ignore: use_build_context_synchronously
                GoRouter.of(context).pushReplacementNamed('/');
              },
              child: Padding(
                padding: responsive!.responsivePaddingRight,
                child: MyText(
                  text: appLoc!.signOut,
                  fontScale: responsive!.scaleFont(13),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            _buildBody(),
            if (isUpdate) const Center(child: AnimatedArcLoader()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<UserDetails>(
      future: getCurrentUser,
      builder: (context, usershot) {
        if (usershot.hasError) {
          return Center(
            child: MyText(text: errorClass.userNoTFoundError()),
          );
        }
        if (usershot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        }
        if (!usershot.hasData) return const SizedBox.shrink();

        currentUser = usershot.data!;

        if (!controllerInitialized && currentUser.otherCategory != null) {
          otherController.text = currentUser.otherCategory!;
          controllerInitialized = true;
        }

        // Terms check — unchanged logic
        if (!termsChecked &&
            (currentUser.termsAccepted == null ||
                currentUser.termsAccepted == false)) {
          termsChecked = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!showingTerms) {
              showingTerms = true;
              GoRouter.of(context).pushNamed('termsPage', pathParameters: {
                'uid': currentUser.uid!
              }).then((_) => showingTerms = false);
            }
          });
        }

        return SingleChildScrollView(
          padding: responsive!.responsivePaddingM,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Step header ───────────────────────────────────────────────
              _buildHeader(),
              SizedBox(height: responsive!.scaleHeight(24)),

              // ── Business type grid ────────────────────────────────────────
              _buildSectionLabel(appLoc!.businessType),
              SizedBox(height: responsive!.scaleHeight(10)),
              _buildTypeGrid(),
              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Category list (shows after type selected) ─────────────────
              if (currentUser.businessType != null) ...[
                Divider(
                  height: 0,
                  thickness: 0.5,
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                ),
                SizedBox(height: responsive!.scaleHeight(20)),
                _buildSectionLabel(appLoc!.businessCategoryDes),
                SizedBox(height: responsive!.scaleHeight(10)),
                _buildCategoryList(),
                SizedBox(height: responsive!.scaleHeight(12)),
              ],

              // ── Other text field ──────────────────────────────────────────
              if (currentUser.businessCategory != null &&
                  currentUser.businessCategory!.toLowerCase() == 'other') ...[
                MyTextField(
                  controller: otherController,
                  hintText: appLoc!.businessCategory,
                  fontSize: responsive!.scaleFont(14),
                ),
                SizedBox(height: responsive!.scaleHeight(12)),
              ],

              // ── Continue button ───────────────────────────────────────────
              SizedBox(height: responsive!.scaleHeight(8)),
              GestureDetector(
                onTap: updateUser,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      vertical: responsive!.scaleHeight(15)),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: MyText(
                      text: appLoc!.continueLabel,
                      fontScale: responsive!.scaleFont(15),
                      fontWeight: FontWeight.w500,
                      fontColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: responsive!.scaleHeight(24)),
            ],
          ),
        );
      },
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: MyText(
            text: appLoc!.stepOneOfTwo,
            fontScale: responsive!.scaleFont(11),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: responsive!.scaleHeight(10)),
        MyText(
          text: appLoc!.businessTypeDes,
          fontScale: responsive!.scaleFont(18),
          fontWeight: FontWeight.w500,
          softWrap: true,
          maxLines: 3,
        ),
        SizedBox(height: responsive!.scaleHeight(4)),
        MyText(
          text: appLoc!
              .businessTypeSubDes, // add to l10n: "This helps us personalise your experience."
          fontScale: responsive!.scaleFont(13),
        ),
      ],
    );
  }

  // ── Section label ──────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String text) {
    return MyText(
      text: text.toUpperCase(),
      fontScale: responsive!.scaleFont(11),
      fontWeight: FontWeight.w500,
    );
  }

  // ── Business type 2×2 card grid ────────────────────────────────────────────

  Widget _buildTypeGrid() {
    return FutureBuilder<List<String>>(
      future: db.futureBusinessType(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: MyText(text: errorClass.businessTypeMissing()));
        }
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: LinearProgressIndicator());
        }
        if (!snap.hasData || snap.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        _cachedTypes = snap.data!;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
          ),
          itemCount: _cachedTypes.length,
          itemBuilder: (context, i) {
            final type = _cachedTypes[i];
            final isSelected = currentUser.businessType == type;

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (currentUser.businessType != type) {
                    currentUser.businessCategory = null;
                    otherController.clear();
                  }
                  currentUser.businessType = type;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.08)
                      : Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.3),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dividerColor.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 0.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      _iconForType(type),
                      size: responsive!.scaleHeight(22),
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          text: type,
                          fontScale: responsive!.scaleFont(13),
                          fontWeight: FontWeight.w500,
                          fontColor: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Category row list ──────────────────────────────────────────────────────

  Widget _buildCategoryList() {
    return FutureBuilder<List<String>>(
      future: db.futureBusinessCategory(currentUser.businessType ?? ''),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
              child: MyText(text: errorClass.businessCategoryMissing()));
        }
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: LinearProgressIndicator());
        }
        if (!snap.hasData || snap.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final categories = snap.data!;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: categories.asMap().entries.map((entry) {
              final i = entry.key;
              final cat = entry.value;
              final isSelected = currentUser.businessCategory == cat;
              final isLast = i == categories.length - 1;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    currentUser.businessCategory = cat;
                    if (cat.toLowerCase() != 'other') {
                      currentUser.otherCategory = null;
                      otherController.clear();
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.06)
                        : Colors.transparent,
                    border: !isLast
                        ? Border(
                            bottom: BorderSide(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: 0.25),
                              width: 0.5,
                            ),
                          )
                        : null,
                    borderRadius: isLast
                        ? const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          )
                        : i == 0
                            ? const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              )
                            : null,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive!.scaleWidth(14),
                    vertical: responsive!.scaleHeight(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _iconForCategory(cat),
                        size: responsive!.scaleHeight(18),
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: responsive!.scaleWidth(12)),
                      Expanded(
                        child: MyText(
                          text: cat,
                          fontScale: responsive!.scaleFont(13),
                          fontColor: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                      ),
                      // Radio circle
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .dividerColor
                                    .withValues(alpha: 0.5),
                            width: isSelected ? 0 : 0.5,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 12,
                                color: Theme.of(context).colorScheme.onPrimary,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // ── Logic (unchanged) ──────────────────────────────────────────────────────

  Future<UserDetails> fetchUser() async {
    if (widget.uid != null) {
      var result = await db.getCurrentUser(uid: widget.uid);
      if (result.businessCategory == 'others') {
        otherController.text = result.otherCategory.toString();
      }
      return result;
    } else {
      return UserDetails();
    }
  }

  Future<void> updateUser() async {
    if (termsChecked) {
      currentUser.termsAccepted = true;
    }
    if (currentUser.businessType == null) {
      snackbarWidget.content = appLoc!.missingType;
      snackbarWidget.showSnack();
      return;
    }
    if (currentUser.businessCategory == null) {
      snackbarWidget.content = appLoc!.missingCategory;
      snackbarWidget.showSnack();
      return;
    }
    if (currentUser.businessCategory != null &&
        currentUser.businessCategory!.isNotEmpty &&
        currentUser.businessCategory!.toLowerCase() == 'other') {
      if (otherController.text.isEmpty) {
        snackbarWidget.content = appLoc!.fillManualCategory;
        snackbarWidget.showSnack();
        return;
      }
    }
    if (otherController.text.isNotEmpty) {
      currentUser.otherCategory = otherController.text;
    }

    setState(() => isUpdate = true);
    await db.updateCurrentUser(user: currentUser);

    if (mounted) {
      setState(() => isUpdate = false);
      if (currentUser.currency != null && currentUser.address != null) {
        GoRouter.of(context).pop();
      } else {
        GoRouter.of(context).pushNamed('currencyLocation',
            pathParameters: {'uid': currentUser.uid!});
      }
    }
  }
}
