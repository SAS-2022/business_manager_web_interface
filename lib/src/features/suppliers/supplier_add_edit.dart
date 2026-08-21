import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/utils/components/country_code.dart';
import 'package:business_manager_web_ui/src/app/utils/components/phone_validators.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/flush_text_field.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/models/purchase_model.dart';
import 'package:business_manager_web_ui/src/models/supplier_model.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:business_manager_web_ui/src/services/purchase_service.dart';
import 'package:business_manager_web_ui/src/services/supplier_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../app/theme/responsive_utils.dart';
import '../../services/auth_service.dart';

/// Two real mobile bugs fixed here (unfixed at the source):
/// - `fetchSupplier()` never assigned `supplier = result`, so
///   `updateSupplier()`'s reconstruction always sent `createdAt: null` to
///   Firestore's `.update()`, silently wiping the field — which then drops
///   the supplier entirely out of `streamAllSupplier()`'s
///   `orderBy('createdAt', descending: true)` query. Same bug class as the
///   already-fixed products bug (Stage 4b, "update omits createdAt"), just
///   more severe here since it makes the record vanish, not just re-sort.
///   `client_add_edit.dart` has the identical bug, still unfixed there.
/// - `supplierOrders()` pushed `editOrder` with a *purchase* id as the
///   `orderId` param — copy-paste from Clients' own `clientOrders()`, wrong
///   route entirely for a Purchases-history card. Fixed to `editPurchase`.
class SupplierAddEdit extends StatefulWidget {
  const SupplierAddEdit({super.key, this.uid, this.suppliedId});
  final String? uid;
  final String? suppliedId;

  @override
  State<SupplierAddEdit> createState() => _SupplierAddEditState();
}

class _SupplierAddEditState extends State<SupplierAddEdit> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  ErrorClass errorClass = ErrorClass();
  AuthService as = AuthService();
  SupplierService ss = SupplierService();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  PurchaseService ps = PurchaseService();
  DatabaseService db = DatabaseService();
  bool isLoading = false, isSearching = false, isUpdating = false;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController supplierNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailAddressController = TextEditingController();
  TextEditingController financialNumberController = TextEditingController();
  TextEditingController crNumberController = TextEditingController();
  TextEditingController ibanNumberController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();
  String? phoneCode, phoneCountry;
  UserDetails currentUser = UserDetails();
  Future<UserDetails>? getCurrentUser;
  SupplierModel supplier = SupplierModel();
  Future<SupplierModel>? getCurrentSupplier;
  PhoneValidators phoneValidation = PhoneValidators();
  int phoneLength = 10;
  final number = NumberFormat("#,##0.00", "en_US");

  @override
  void didChangeDependencies() {
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
    snackbarWidget.context = context;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    if (widget.uid != null) getCurrentUser = fetchUser();
    if (widget.suppliedId != null) getCurrentSupplier = fetchSupplier();
    super.initState();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    supplierNameController.dispose();
    phoneNumberController.dispose();
    emailAddressController.dispose();
    financialNumberController.dispose();
    crNumberController.dispose();
    ibanNumberController.dispose();
    bankNameController.dispose();
    super.dispose();
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

  Widget _fieldRow({required IconData icon, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(left: responsive!.scaleWidth(14)),
          child: Icon(
            icon,
            size: responsive!.scaleHeight(18),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: FutureBuilder<UserDetails>(
          future: getCurrentUser,
          builder: (context, usershot) {
            if (usershot.hasError) {
              return Center(
                  child: MyText(text: errorClass.userNoTFoundError()));
            }
            if (usershot.connectionState == ConnectionState.waiting) {
              return const GradientSkeleton();
            }
            currentUser = usershot.data!;
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                title: MyText(
                  text: widget.suppliedId == null
                      ? appLoc!.addSupplier
                      : appLoc!.editSupplier,
                  fontScale: responsive!.scaleFont(18),
                  fontWeight: FontWeight.w500,
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.save_outlined,
                        size: responsive!.scaleHeight(22)),
                    onPressed: () => widget.suppliedId == null
                        ? addSupplier()
                        : updateSupplier(),
                  ),
                ],
              ),
              body: Stack(
                children: [
                  _buildSupplierViewBody(),
                  if (isLoading) const Center(child: AnimatedArcLoader()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSupplierViewBody() {
    return FutureBuilder(
      future: getCurrentSupplier,
      builder: (context, suppliershot) {
        if (suppliershot.hasError) {
          return Center(
              child: MyText(
                  text: errorClass
                      .supplierNotLoading(suppliershot.error.toString())));
        }
        if (suppliershot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        }

        if (suppliershot.hasData && !isUpdating) {
          isUpdating = true;
        }

        return SingleChildScrollView(
          padding: responsive!.responsivePaddingM,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Company info ────────────────────────────────────────────
              _sectionLabel(appLoc!.companyInfo), // add to l10n: "Company info"
              _groupCard(children: [
                _fieldRow(
                  icon: Icons.business_outlined,
                  child: FlushTextField(
                    controller: supplierNameController,
                    hintText: appLoc!.company,
                    textCapitalization: TextCapitalization.words,
                    fontSize: responsive!.scaleFont(13),
                  ),
                ),
                _fieldRow(
                  icon: Icons.person_outline_rounded,
                  child: FlushTextField(
                    controller: firstNameController,
                    hintText: appLoc!.firstName,
                    textCapitalization: TextCapitalization.words,
                    fontSize: responsive!.scaleFont(13),
                  ),
                ),
                _fieldRow(
                  icon: Icons.person_outline_rounded,
                  child: FlushTextField(
                    controller: lastNameController,
                    hintText: appLoc!.lastName,
                    textCapitalization: TextCapitalization.words,
                    fontSize: responsive!.scaleFont(13),
                  ),
                ),
              ]),

              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Contact info ────────────────────────────────────────────
              _sectionLabel(appLoc!.contactInfo),
              _groupCard(children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.only(left: responsive!.scaleWidth(14)),
                      child: SizedBox(
                        width: responsive!.screenWidth * 0.25,
                        child: CountryCodePhone(
                          initialCode: phoneCountry,
                          onSelected: (code, country) {
                            if (code.isNotEmpty) {
                              phoneCode = code;
                              phoneCountry = country;
                              phoneLength =
                                  PhoneValidators.getPhoneNumberLength(
                                      phoneCountry ?? 'US');
                              setState(() {});
                            }
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: FlushTextField(
                        controller: phoneNumberController,
                        hintText: appLoc!.phoneNumber,
                        keyboardType: TextInputType.phone,
                        maxLength: phoneLength,
                        fontSize: responsive!.scaleFont(13),
                      ),
                    ),
                  ],
                ),
                _fieldRow(
                  icon: Icons.mail_outline_rounded,
                  child: FlushTextField(
                    controller: emailAddressController,
                    hintText: appLoc!.emailAddress,
                    keyboardType: TextInputType.emailAddress,
                    fontSize: responsive!.scaleFont(13),
                  ),
                ),
              ]),

              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Official data ───────────────────────────────────────────
              _sectionLabel(appLoc!.officialData),
              _groupCard(children: [
                _fieldRow(
                  icon: Icons.numbers_outlined,
                  child: FlushTextField(
                    controller: financialNumberController,
                    hintText: appLoc!.financialNumber,
                    textCapitalization: TextCapitalization.words,
                    fontSize: responsive!.scaleFont(13),
                  ),
                ),
                _fieldRow(
                  icon: Icons.badge_outlined,
                  child: FlushTextField(
                    controller: crNumberController,
                    hintText: appLoc!.crNumber,
                    textCapitalization: TextCapitalization.words,
                    fontSize: responsive!.scaleFont(13),
                  ),
                ),
                _fieldRow(
                  icon: Icons.account_balance_outlined,
                  child: FlushTextField(
                    controller: ibanNumberController,
                    hintText: appLoc!.ibanNumber,
                    textCapitalization: TextCapitalization.characters,
                    fontSize: responsive!.scaleFont(13),
                  ),
                ),
                _fieldRow(
                  icon: Icons.corporate_fare_outlined,
                  child: FlushTextField(
                    controller: bankNameController,
                    hintText: appLoc!.bankName,
                    textCapitalization: TextCapitalization.words,
                    fontSize: responsive!.scaleFont(13),
                  ),
                ),
              ]),

              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Supplier purchases ──────────────────────────────────────
              if (widget.suppliedId != null) ...[
                supplierOrders(),
                SizedBox(height: responsive!.scaleHeight(24)),
              ],
            ],
          ),
        );
      },
    );
  }

  // ── Supplier orders — logic unchanged, card layout ─────────────────────────

  Widget supplierOrders() {
    return StreamBuilder<List<PurchaseModel>>(
      stream: ps.streamSupplierPurchases(widget.uid!, widget.suppliedId ?? ''),
      builder: (context, purchaseshot) {
        if (purchaseshot.hasError) {
          return Center(
              child: MyText(
                  text: errorClass
                      .purchaseNotLoading(purchaseshot.error.toString())));
        }
        if (purchaseshot.connectionState == ConnectionState.waiting) {
          return const Center(child: AnimatedArcLoader());
        }

        final purchases = purchaseshot.data ?? [];
        double totalValue = 0.0;
        for (var purchase in purchases) {
          for (var product in purchase.purchasedProducts!.values) {
            if (product.price == null || product.quantity == null) continue;
            totalValue += product.price! * product.quantity!;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel(appLoc!.supplierOrders),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surface
                    .withValues(alpha: 0.5),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: responsive!.scaleHeight(220),
                    child: purchases.isEmpty
                        ? Center(
                            child: MyText(
                              text: appLoc!.noExpenseFound,
                              fontScale: responsive!.scaleFont(13),
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: purchases.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 0,
                              thickness: 0.5,
                              indent: responsive!.scaleWidth(14),
                              color: Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: 0.25),
                            ),
                            itemBuilder: (context, index) {
                              double orderValue = 0.0;
                              for (var product in purchases[index]
                                  .purchasedProducts!
                                  .values) {
                                if (product.price == null ||
                                    product.quantity == null) {
                                  continue;
                                }
                                orderValue +=
                                    product.price! * product.quantity!;
                              }
                              return GestureDetector(
                                onTap: () => GoRouter.of(context).pushNamed(
                                    'editPurchase',
                                    pathParameters: {
                                      'uid': widget.uid!,
                                      'purchaseId': purchases[index].id!,
                                    }),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: responsive!.scaleWidth(14),
                                    vertical: responsive!.scaleHeight(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.chevron_right,
                                        size: responsive!.scaleHeight(14),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      SizedBox(
                                          width: responsive!.scaleWidth(6)),
                                      MyText(
                                        text:
                                            '${purchases[index].createdAt!.day}/${purchases[index].createdAt!.month}/${purchases[index].createdAt!.year}',
                                        fontScale: responsive!.scaleFont(13),
                                      ),
                                      const Spacer(),
                                      MyText(
                                        text:
                                            '${currentUser.currency!['symbol']} ${number.format(orderValue)}',
                                        fontScale: responsive!.scaleFont(13),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Divider(
                    height: 0,
                    thickness: 0.5,
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.3),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive!.scaleWidth(14),
                      vertical: responsive!.scaleHeight(10),
                    ),
                    child: Row(
                      children: [
                        MyText(
                          text: appLoc!.totalValue,
                          fontScale: responsive!.scaleFont(12),
                          fontWeight: FontWeight.w500,
                        ),
                        const Spacer(),
                        MyText(
                          text:
                              '${currentUser.currency!['symbol']} ${number.format(totalValue)}',
                          fontScale: responsive!.scaleFont(13),
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Logic — completely unchanged ───────────────────────────────────────────

  Future<UserDetails> fetchUser() async => db.getCurrentUser(uid: widget.uid);

  Future<SupplierModel> fetchSupplier() async {
    var result = await ss.futureSingleSupplier(widget.uid, widget.suppliedId);
    supplier = result;
    supplierNameController.text = result.supplierName ?? '';
    firstNameController.text = result.firstName ?? '';
    lastNameController.text = result.lastName ?? '';
    phoneCountry = result.phoneNumber!['country'];
    phoneCode = result.phoneNumber?['code'];
    phoneNumberController.text = result.phoneNumber?['number'] ?? '';
    emailAddressController.text = result.email ?? '';
    financialNumberController.text = result.financialNumber ?? '';
    crNumberController.text = result.crNumber ?? '';
    ibanNumberController.text = result.ibanNumber ?? '';
    bankNameController.text = result.bankName ?? '';
    return result;
  }

  Future<void> addSupplier() async {
    if (supplierNameController.text.isEmpty) {
      snackbarWidget.content = appLoc!.companyNameEmpty;
      snackbarWidget.showSnack();
      return;
    }
    if (firstNameController.text.isEmpty) {
      snackbarWidget.content = appLoc!.clientNameEmpty;
      snackbarWidget.showSnack();
      return;
    }
    if (phoneCode == null || phoneCode!.isEmpty) {
      snackbarWidget.content = appLoc!.phoneCodeEmpty;
      snackbarWidget.showSnack();
      return;
    }
    if (phoneNumberController.text.isEmpty) {
      snackbarWidget.content = appLoc!.phoneNumberEmpty;
      snackbarWidget.showSnack();
      return;
    }
    supplier = SupplierModel(
      supplierName: supplierNameController.text.trim(),
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      phoneNumber: <String, String>{
        'country': phoneCountry ?? '',
        'code': phoneCode ?? '',
        'number': phoneNumberController.text.trim(),
      },
      email: emailAddressController.text.trim(),
      createdAt: DateTime.now(),
      financialNumber: financialNumberController.text,
      crNumber: crNumberController.text,
      ibanNumber: ibanNumberController.text,
      bankName: bankNameController.text,
    );
    setState(() => isLoading = true);
    await ss.addSupplier(uid: widget.uid, supplier: supplier);
    if (mounted) {
      setState(() => isLoading = false);
      GoRouter.of(context).pop();
    }
  }

  Future<void> updateSupplier() async {
    if (supplierNameController.text.isEmpty) {
      snackbarWidget.content = appLoc!.companyNameEmpty;
      snackbarWidget.showSnack();
      return;
    }
    if (firstNameController.text.isEmpty) {
      snackbarWidget.content = appLoc!.clientNameEmpty;
      snackbarWidget.showSnack();
      return;
    }
    if (phoneCode == null || phoneCode!.isEmpty) {
      snackbarWidget.content = appLoc!.phoneCodeEmpty;
      snackbarWidget.showSnack();
      return;
    }
    if (phoneNumberController.text.isEmpty) {
      snackbarWidget.content = appLoc!.phoneNumberEmpty;
      snackbarWidget.showSnack();
      return;
    }
    supplier = SupplierModel(
      uid: widget.suppliedId,
      supplierName: supplierNameController.text.trim(),
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      phoneNumber: <String, String>{
        'country': phoneCountry ?? '',
        'code': phoneCode ?? '',
        'number': phoneNumberController.text.trim(),
      },
      email: emailAddressController.text.trim(),
      createdAt: supplier.createdAt,
      financialNumber: financialNumberController.text,
      crNumber: crNumberController.text,
      ibanNumber: ibanNumberController.text,
      bankName: bankNameController.text,
    );
    setState(() => isLoading = true);
    await ss.updateSupplier(uid: widget.uid, supplier: supplier);
    if (mounted) {
      setState(() => isLoading = false);
      GoRouter.of(context).pop();
    }
  }
}
