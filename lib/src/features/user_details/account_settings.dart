import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/utils/components/map_snap.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/flush_text_field.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/deletion_dialog.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/ok_dialog.dart';
import 'package:business_manager_web_ui/src/app/widgets/viewer/currency_picker.dart';
import 'package:business_manager_web_ui/src/models/location_model.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/product_service.dart';
import 'package:business_manager_web_ui/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/constants/error_class.dart';
import '../../app/theme/responsive_utils.dart';
import '../../app/utils/components/snackbar_widget.dart';
import '../../services/database_service.dart';

/// Scoped like every other Settings screen so far: the "Business address"
/// section's edit link and the "Business type" section's edit link both
/// navigate to still-unbuilt screens (`MapLocationPicker` — a live
/// Google-Maps location picker, `businessType` — already stubbed from an
/// earlier stage) and are left as stub routes. Everything on this screen
/// itself is fully real: personal/company info, currency picker (new
/// `currency_picker` pubspec dependency — pure Dart/Flutter, same
/// no-platform-channel profile as `country_code_picker`), financial
/// details, company logo upload, and account deletion.
/// Company logo upload rewritten for web the same way Gallery's own
/// `_addImage()` was in Stage 5: mobile's camera/gallery choice sheet +
/// dart:io File + flutter_image_compress dance replaced with
/// `ImagePicker().pickImage(source: gallery)` + direct `Uint8List` upload
/// via `StorageService.uploadImageToStorage`. Simplified `selectedLogoImage`
/// from `dynamic` (an XFile before upload, a URL String after) to a plain
/// `String?` by uploading immediately on pick instead of deferring to save
/// time — mobile's own XFile-vs-URL branching no longer applies once the
/// upload always happens up front.
class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key, this.uid});
  final String? uid;

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  bool isLoading = false, currencyChanged = false;
  DatabaseService db = DatabaseService();
  ProductService ps = ProductService();
  StorageService ss = StorageService();
  ErrorClass errorClass = ErrorClass();
  SnackbarWidget snackbar = SnackbarWidget();
  OkDialog okDialog = OkDialog();
  DeletionDialog deletionDialog = DeletionDialog();
  final ImagePicker imagePicker = ImagePicker();
  UserDetails? currentUser = UserDetails();
  Future<UserDetails>? getCurrentUser;
  final locationNotifier = ValueNotifier<LocationModel>(LocationModel());
  LocationModel? location;
  TextEditingController companyNameController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();
  TextEditingController bankBranchController = TextEditingController();
  TextEditingController ibanController = TextEditingController();
  TextEditingController otherPaymentController = TextEditingController();
  String? selectedLogoImage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    snackbar.context = context;
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
  }

  @override
  void initState() {
    if (widget.uid != null) getCurrentUser = fetchUser();
    addListeners();
    super.initState();
  }

  @override
  void dispose() {
    locationNotifier.dispose();
    companyNameController.dispose();
    bankBranchController.dispose();
    bankNameController.dispose();
    ibanController.dispose();
    otherPaymentController.dispose();
    super.dispose();
  }

  // ── Design helpers ─────────────────────────────────────────────────────────

  Widget _sectionLabel(String text, {Widget? action}) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: responsive!.scaleHeight(10),
        top: responsive!.scaleHeight(4),
      ),
      child: Row(
        children: [
          MyText(
            text: text.toUpperCase(),
            fontScale: responsive!.scaleFont(11),
            fontWeight: FontWeight.w500,
          ),
          if (action != null) ...[const Spacer(), action],
        ],
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

  Widget _fieldRow({
    required IconData icon,
    required Widget child,
  }) {
    return Row(
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

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(14),
        vertical: responsive!.scaleHeight(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: responsive!.scaleHeight(18),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: responsive!.scaleWidth(12)),
          MyText(
            text: label,
            fontScale: responsive!.scaleFont(13),
          ),
          const Spacer(),
          MyText(
            text: value,
            fontScale: responsive!.scaleFont(13),
            fontWeight: FontWeight.w500,
            maxLines: 1,
            textOverflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: MyText(
              text: appLoc!.account,
              fontScale: responsive!.scaleFont(18),
              fontWeight: FontWeight.w500,
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.save_outlined,
                    size: responsive!.scaleHeight(22)),
                onPressed: () async => await updateCompanyData(),
              ),
            ],
          ),
          body: Stack(
            children: [
              FutureBuilder<UserDetails>(
                future: getCurrentUser,
                builder: (context, usershot) {
                  if (usershot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: responsive!.scaleWidth(48),
                              color: Theme.of(context).colorScheme.error),
                          SizedBox(height: responsive!.scaleHeight(12)),
                          MyText(
                            text: errorClass.userNoTFoundError(),
                            fontScale: responsive!.scaleFont(14),
                          ),
                        ],
                      ),
                    );
                  }
                  if (usershot.connectionState == ConnectionState.waiting) {
                    return const GradientSkeleton();
                  }
                  currentUser = usershot.data;
                  return _buildUserAccountBody();
                },
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(child: AnimatedArcLoader()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildUserAccountBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(responsive!.scaleWidth(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header card ─────────────────────────────────────────────
          _buildHeaderCard(),
          SizedBox(height: responsive!.scaleHeight(20)),

          // ── Currency ─────────────────────────────────────────────────
          _sectionLabel(appLoc!.currency),
          buildCurrencySection(),
          SizedBox(height: responsive!.scaleHeight(20)),

          // ── Business address ──────────────────────────────────────────
          _sectionLabel(
            appLoc!.businessAddress,
            action: GestureDetector(
              onTap: () async => await GoRouter.of(context).pushNamed(
                'MapLocationPicker',
                pathParameters: {'uid': widget.uid!},
                extra: locationNotifier,
              ),
              child: MyText(
                text: '${appLoc!.settings} ›',
                fontScale: responsive!.scaleFont(11),
                fontColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          buildBusinessAddress(),
          SizedBox(height: responsive!.scaleHeight(20)),

          // ── Business type ─────────────────────────────────────────────
          _sectionLabel(
            appLoc!.businessType,
            action: FutureBuilder<bool>(
              future: ps.checkIfProductsExist(widget.uid!),
              builder: (context, snapshot) {
                return GestureDetector(
                  onTap: () async {
                    final exists = snapshot.data ?? false;
                    if (exists) {
                      okDialog.showOkDialog(context, appLoc!, appLoc!.warning,
                          content: appLoc!.changingTypeNotPossible);
                    } else {
                      GoRouter.of(context).pushNamed('businessType',
                          pathParameters: {'uid': widget.uid!});
                    }
                  },
                  child: MyText(
                    text: '${appLoc!.settings} ›',
                    fontScale: responsive!.scaleFont(11),
                    fontColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ),
          buildBusinessType(),
          SizedBox(height: responsive!.scaleHeight(20)),

          // ── Company info ──────────────────────────────────────────────
          _sectionLabel(appLoc!.companyInfo),
          buildCompanyInfo(),
          SizedBox(height: responsive!.scaleHeight(20)),

          // ── Financial details ─────────────────────────────────────────
          _sectionLabel(appLoc!.financialDetails),
          buildFinancialDetails(),
          SizedBox(height: responsive!.scaleHeight(28)),

          // ── Delete account ────────────────────────────────────────────
          _deleteWidget(),
          SizedBox(height: responsive!.scaleHeight(32)),
        ],
      ),
    );
  }

  // ── Header card ────────────────────────────────────────────────────────────

  Widget _buildHeaderCard() {
    return Container(
      padding: EdgeInsets.all(responsive!.scaleWidth(14)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: responsive!.scaleWidth(50),
            height: responsive!.scaleWidth(50),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F1FB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.business_center_outlined,
              size: responsive!.scaleHeight(24),
              color: const Color(0xFF185FA5),
            ),
          ),
          SizedBox(width: responsive!.scaleWidth(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  text: currentUser?.companyName ?? appLoc!.companyName,
                  fontScale: responsive!.scaleFont(15),
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: responsive!.scaleHeight(3)),
                MyText(
                  text: [
                    currentUser?.businessType,
                    currentUser?.businessCategory,
                  ].where((e) => e != null).join(' · '),
                  fontScale: responsive!.scaleFont(12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Currency — CurrencyPicker unchanged, container restyled ───────────────

  Widget buildCurrencySection() {
    return _groupCard(children: [
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: responsive!.scaleWidth(14),
          vertical: responsive!.scaleHeight(10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.currency_exchange_outlined,
              size: responsive!.scaleHeight(18),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: responsive!.scaleWidth(12)),
            Expanded(
              child: CurrencyPicker(
                uid: widget.uid,
                currentUser: currentUser!,
                currencyChanged: (changed) {
                  currencyChanged = changed;
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  // ── Business address — StreamBuilder + MapSnapshotWidget unchanged ─────────

  Widget buildBusinessAddress() {
    return _groupCard(children: [
      StreamBuilder<UserDetails>(
        stream: db.streamCurrentUser(uid: widget.uid),
        builder: (context, usershot) {
          if (usershot.hasData) currentUser = usershot.data;

          final hasAddress = currentUser?.address != null &&
              currentUser?.address?.snapshot != null;

          if (!hasAddress) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive!.scaleWidth(14),
                vertical: responsive!.scaleHeight(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_off_outlined,
                    size: responsive!.scaleHeight(18),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: responsive!.scaleWidth(12)),
                  MyText(
                    text: appLoc!.addressNotRegistered,
                    fontScale: responsive!.scaleFont(13),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.all(responsive!.scaleWidth(12)),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _addressLine(Icons.business_outlined,
                          currentUser!.address!.addressName),
                      SizedBox(height: responsive!.scaleHeight(6)),
                      _addressLine(Icons.streetview_outlined,
                          currentUser!.address!.street),
                      SizedBox(height: responsive!.scaleHeight(6)),
                      _addressLine(Icons.location_city_outlined,
                          currentUser!.address!.province),
                      SizedBox(height: responsive!.scaleHeight(6)),
                      _addressLine(Icons.public_outlined,
                          currentUser!.address!.mapCountry),
                    ],
                  ),
                ),
                SizedBox(width: responsive!.scaleWidth(10)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: MapSnapshotWidget(
                    snapshotData: currentUser!.address!.snapshot!,
                    height: responsive!.scaleHeight(100),
                    width: responsive!.scaleWidth(90),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ]);
  }

  Widget _addressLine(IconData icon, String? text) {
    return Row(
      children: [
        Icon(icon,
            size: responsive!.scaleHeight(13),
            color: Theme.of(context).colorScheme.onSurfaceVariant),
        SizedBox(width: responsive!.scaleWidth(6)),
        Expanded(
          child: MyText(
            text: text ?? '',
            fontScale: responsive!.scaleFont(11),
            maxLines: 1,
            textOverflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ── Business type — FutureBuilder edit logic unchanged, rows restyled ──────

  Widget buildBusinessType() {
    return _groupCard(children: [
      _infoRow(
        icon: Icons.work_outline_rounded,
        label: appLoc!.businessType,
        value: currentUser?.businessType ?? '',
      ),
      _infoRow(
        icon: Icons.category_outlined,
        label: appLoc!.businessCategory,
        value: currentUser?.businessCategory ?? '',
      ),
    ]);
  }

  // ── Company info — FlushTextField + logo section ───────────────────────────

  Widget buildCompanyInfo() {
    return _groupCard(children: [
      // Company name
      _fieldRow(
        icon: Icons.business_outlined,
        child: FlushTextField(
          controller: companyNameController,
          hintText: appLoc!.companyName,
          textCapitalization: TextCapitalization.words,
          fontSize: responsive!.scaleFont(13),
        ),
      ),

      // Logo
      Padding(
        padding: EdgeInsets.all(responsive!.scaleWidth(14)),
        child: Column(
          children: [
            GestureDetector(
              onLongPress: _removeImage,
              onTap: _addImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: responsive!.scaleWidth(110),
                height: responsive!.scaleWidth(110),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selectedLogoImage != null
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dividerColor.withValues(alpha: 0.4),
                    width: selectedLogoImage != null ? 1.5 : 0.5,
                    style: selectedLogoImage != null
                        ? BorderStyle.solid
                        : BorderStyle.solid,
                  ),
                ),
                child: selectedLogoImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: responsive!.scaleHeight(28),
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(height: responsive!.scaleHeight(6)),
                          MyText(
                            text: appLoc!.companyLogo,
                            fontScale: responsive!.scaleFont(11),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.network(
                          selectedLogoImage!,
                          fit: BoxFit.cover,
                          width: responsive!.scaleWidth(110),
                          height: responsive!.scaleWidth(110),
                        ),
                      ),
              ),
            ),
            if (selectedLogoImage != null) ...[
              SizedBox(height: responsive!.scaleHeight(8)),
              MyText(
                text: appLoc!.longPressToRemove,
                fontScale: responsive!.scaleFont(11),
              ),
            ],
          ],
        ),
      ),
    ]);
  }

  // ── Financial details — FlushTextField in grouped card ─────────────────────

  Widget buildFinancialDetails() {
    return _groupCard(children: [
      _fieldRow(
        icon: Icons.account_balance_outlined,
        child: FlushTextField(
          controller: bankNameController,
          hintText: appLoc!.bankName,
          textCapitalization: TextCapitalization.words,
          fontSize: responsive!.scaleFont(13),
        ),
      ),
      _fieldRow(
        icon: Icons.account_tree_outlined,
        child: FlushTextField(
          controller: bankBranchController,
          hintText: appLoc!.bankBranch,
          textCapitalization: TextCapitalization.words,
          fontSize: responsive!.scaleFont(13),
        ),
      ),
      _fieldRow(
        icon: Icons.tag_outlined,
        child: FlushTextField(
          controller: ibanController,
          hintText: appLoc!.ibanNumber,
          textCapitalization: TextCapitalization.characters,
          fontSize: responsive!.scaleFont(13),
        ),
      ),
      _fieldRow(
        icon: Icons.more_horiz_outlined,
        child: FlushTextField(
          controller: otherPaymentController,
          hintText: appLoc!.otherPayment,
          textCapitalization: TextCapitalization.words,
          fontSize: responsive!.scaleFont(13),
        ),
      ),
    ]);
  }

  // ── Delete account — outlined error button ─────────────────────────────────

  Widget _deleteWidget() {
    return GestureDetector(
      onTap: () async {
        var result =
            await deletionDialog.showAccountDeletionDialog(context, appLoc!);
        if (result) await _startDeletionProcess();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: responsive!.scaleHeight(14)),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.error,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline_rounded,
              size: responsive!.scaleHeight(16),
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(width: responsive!.scaleWidth(6)),
            MyText(
              text: appLoc!.deleteAccount,
              fontScale: responsive!.scaleFont(14),
              fontWeight: FontWeight.w500,
              fontColor: Theme.of(context).colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }

  // ── All logic — completely unchanged ──────────────────────────────────────

  void addListeners() {
    locationNotifier.addListener(() {
      location = locationNotifier.value;
      if (location != null &&
          location!.name != null &&
          location!.addressName != null &&
          location!.lat != null &&
          location!.lng != null) {
        updateUserData();
      }
    });
    bankNameController.addListener(() {
      if (bankNameController.text.isNotEmpty) {
        currentUser!.bankName = bankNameController.text.trim();
      } else {
        currentUser!.bankName = null;
      }
    });
    bankBranchController.addListener(() {
      if (bankBranchController.text.isNotEmpty) {
        currentUser!.bankBranch = bankBranchController.text.trim();
      } else {
        currentUser!.bankBranch = null;
      }
    });
    ibanController.addListener(() {
      if (ibanController.text.isNotEmpty) {
        currentUser!.ibanNumber = ibanController.text.trim();
      } else {
        currentUser!.ibanNumber = null;
      }
    });
    otherPaymentController.addListener(() {
      if (otherPaymentController.text.isNotEmpty) {
        currentUser!.otherPayment = otherPaymentController.text.trim();
      } else {
        currentUser!.otherPayment = null;
      }
    });
    setState(() {});
  }

  Future<UserDetails> fetchUser() async {
    var result = await db.getCurrentUser(uid: widget.uid);
    if (result.companyLogo != null) selectedLogoImage = result.companyLogo;
    if (result.companyName != null) {
      companyNameController.text = result.companyName!;
    }
    if (result.bankName != null) bankNameController.text = result.bankName!;
    if (result.bankBranch != null) {
      bankBranchController.text = result.bankBranch!;
    }
    if (result.ibanNumber != null) ibanController.text = result.ibanNumber!;
    if (result.otherPayment != null) {
      otherPaymentController.text = result.otherPayment!;
    }
    return result;
  }

  Future<void> updateUserData() async {
    if (location == null) {
      snackbar.content = appLoc!.noLocationSelected;
      snackbar.showSnack();
      return;
    }
    UserDetails currentUser = await db.getCurrentUser(uid: widget.uid);
    if (currentUser.uid != null) {
      currentUser.address = location;
      await db.updateCurrentUser(user: currentUser);
    }
  }

  Future<void> updateCompanyData() async {
    if (companyNameController.text.isEmpty) {
      snackbar.content = appLoc!.companyNameEmpty;
      snackbar.showSnack();
      return;
    }
    if (selectedLogoImage == null) {
      snackbar.content = appLoc!.companyLogoMissing;
      snackbar.showSnack();
      return;
    }
    setState(() => isLoading = true);
    if (currentUser!.uid != null) {
      currentUser?.companyName = companyNameController.text.trim();
      currentUser?.companyLogo = selectedLogoImage;
      var result = await db.updateCurrentUser(user: currentUser);
      if (result == 'success') {
        snackbar.content = appLoc!.dataSaveSuccessfully;
        snackbar.showSnack();
      } else {
        snackbar.content = appLoc!.failedToSaveData;
        snackbar.showSnack();
      }
    }
    setState(() => isLoading = false);
  }

  // Mobile picks camera-vs-gallery via a bottom sheet, then platform-branches
  // on dart:io Platform.isIOS/isAndroid for the actual picker call — none of
  // that applies on web. This goes straight to the browser's file picker
  // (image_picker's web implementation) and uploads bytes directly instead
  // of wrapping a dart:io File, matching the pattern used by the Gallery
  // screen's own _addImage().
  Future<void> _addImage() async {
    XFile? picked;
    try {
      picked = await imagePicker.pickImage(source: ImageSource.gallery);
    } catch (error) {
      snackbar.content = error.toString();
      snackbar.showSnack();
      return;
    }
    if (picked == null) {
      snackbar.content = appLoc!.imageNotSelected;
      snackbar.showSnack();
      return;
    }
    setState(() => isLoading = true);
    try {
      final bytes = await picked.readAsBytes();
      final url = await ss.uploadImageToStorage(
        bytes: bytes,
        fileName: picked.name,
        folderName: '${widget.uid}/logo',
      );
      if (url.isEmpty) {
        snackbar.content = appLoc!.failedToUploadImage;
        snackbar.showSnack();
      } else {
        selectedLogoImage = url;
      }
    } catch (error) {
      snackbar.content = error.toString();
      snackbar.showSnack();
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _removeImage() async {
    if (selectedLogoImage != null) {
      var delete = await deletionDialog.showDeletionDialog(context, appLoc!);
      if (delete) {
        setState(() => isLoading = true);
        await ss.deleteItemFromStorage(
            url: selectedLogoImage, uid: widget.uid, folder: 'logo');
        selectedLogoImage = null;
        if (currentUser != null && currentUser!.companyLogo != null) {
          currentUser!.companyLogo = null;
          var result = await db.updateCurrentUser(user: currentUser);
          if (result == 'success') {
            snackbar.content = appLoc!.imageRemovedSuccessfully;
            snackbar.showSnack();
          } else {
            snackbar.content = appLoc!.failedToRemoveImage;
            snackbar.showSnack();
          }
        }
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _startDeletionProcess() async {
    setState(() => isLoading = true);
    try {
      await db.scheduleAccountDeletion();
      snackbar.content = appLoc!.accountDeletionSuccess;
      snackbar.showSnack();
    } catch (e) {
      snackbar.content = errorClass.accountDeletionFailed(e.toString());
      snackbar.showSnack();
    } finally {
      setState(() => isLoading = false);
    }
  }
}
