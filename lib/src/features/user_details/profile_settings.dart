import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/utils/components/phone_validators.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/warning_dialog.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/animations/loading_animation.dart';
import '../../app/constants/error_class.dart';
import '../../app/theme/responsive_utils.dart';
import '../../app/utils/components/country_code.dart';
import '../../app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/flush_text_field.dart';

import '../../services/database_service.dart';

/// Dropped `buildBusinessAddress()`/`buildBusinessType()`/`_buildInfoRow()` —
/// unreferenced anywhere in mobile's own build tree (its own source labels
/// them "unused widgets retained so nothing referencing them breaks", but
/// nothing does reference them). Also dropped the unused `ProductService ps`
/// field for the same reason.
class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key, this.uid});
  final String? uid;

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  bool isLoading = false, currencyChanged = false;
  DatabaseService db = DatabaseService();
  ErrorClass errorClass = ErrorClass();
  SnackbarWidget snackbar = SnackbarWidget();
  WarningDialog warningDialog = WarningDialog();
  UserDetails? currentUser = UserDetails();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  Future<UserDetails>? getCurrentUser;
  String? phoneCode, phoneCountry;
  int phoneLength = 10;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    snackbar.context = context;
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
  }

  @override
  void initState() {
    getCurrentUser = fetchUser();
    super.initState();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: MyText(
              text: appLoc!.profile,
              fontScale: responsive!.scaleFont(18),
              fontWeight: FontWeight.w500,
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.save_outlined,
                    size: responsive!.scaleHeight(22)),
                onPressed: () async => await updateUser(),
              ),
            ],
          ),
          body: Stack(
            children: [
              _buildUserAccountBody(),
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
    return FutureBuilder<UserDetails>(
      future: getCurrentUser,
      builder: (context, usershot) {
        if (usershot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: responsive!.scaleWidth(48),
                  color: Theme.of(context).colorScheme.error,
                ),
                SizedBox(height: responsive!.scaleHeight(12)),
                MyText(
                  text: errorClass.userNoTFoundError(),
                  fontScale: responsive!.scaleFont(14),
                  fontColor: Theme.of(context).colorScheme.error,
                ),
              ],
            ),
          );
        }
        if (usershot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        }
        currentUser = usershot.data;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(responsive!.scaleWidth(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile header ──────────────────────────────────────
              _buildProfileHeader(),
              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Personal info ───────────────────────────────────────
              _sectionLabel(appLoc!.personalInformation),
              _buildPersonalInfoSection(),
              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Contact info ────────────────────────────────────────
              _sectionLabel(appLoc!.contactInformation),
              _buildContactInfoSection(),
              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Account info ────────────────────────────────────────
              _sectionLabel(appLoc!.accountInformation),
              _buildAccountInfoSection(),
              SizedBox(height: responsive!.scaleHeight(32)),
            ],
          ),
        );
      },
    );
  }

  // ── Profile header — avatar + name + email ─────────────────────────────────

  Widget _buildProfileHeader() {
    final fullName =
        '${firstNameController.text} ${lastNameController.text}'.trim();
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
            width: responsive!.scaleWidth(52),
            height: responsive!.scaleWidth(52),
            decoration: const BoxDecoration(
              color: Color(0xFFE6F1FB),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline_rounded,
              size: responsive!.scaleHeight(26),
              color: const Color(0xFF185FA5),
            ),
          ),
          SizedBox(width: responsive!.scaleWidth(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  text: fullName.isNotEmpty ? fullName : appLoc!.profile,
                  fontScale: responsive!.scaleFont(16),
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: responsive!.scaleHeight(3)),
                MyText(
                  text: currentUser?.emailAddress ?? '',
                  fontScale: responsive!.scaleFont(12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Personal info — first name + last name ─────────────────────────────────

  Widget _buildPersonalInfoSection() {
    return _groupCard(children: [
      Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: responsive!.scaleWidth(14)),
            child: Icon(
              Icons.badge_outlined,
              size: responsive!.scaleHeight(18),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: FlushTextField(
              controller: firstNameController,
              hintText: appLoc!.firstName,
              textCapitalization: TextCapitalization.words,
              fontSize: responsive!.scaleFont(13),
            ),
          ),
        ],
      ),
      Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: responsive!.scaleWidth(14)),
            child: Icon(
              Icons.badge_outlined,
              size: responsive!.scaleHeight(18),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: FlushTextField(
              controller: lastNameController,
              hintText: appLoc!.lastName,
              textCapitalization: TextCapitalization.words,
              fontSize: responsive!.scaleFont(13),
            ),
          ),
        ],
      ),
    ]);
  }

  // ── Contact info — phone with country code ─────────────────────────────────

  Widget _buildContactInfoSection() {
    return _groupCard(children: [
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: responsive!.scaleWidth(14),
          vertical: responsive!.scaleHeight(6),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.phone_outlined,
              size: responsive!.scaleHeight(18),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: responsive!.scaleWidth(10)),
            // CountryCodePhone — completely unchanged
            SizedBox(
              width: responsive!.screenWidth * 0.25,
              child: CountryCodePhone(
                initialCode: phoneCountry,
                onSelected: (code, country) {
                  if (code.isNotEmpty) {
                    phoneCode = code;
                    phoneCountry = country;
                    phoneLength = PhoneValidators.getPhoneNumberLength(
                        phoneCountry ?? 'US');
                    setState(() => phoneNumberController.clear());
                  }
                },
              ),
            ),
            SizedBox(width: responsive!.scaleWidth(8)),
            Expanded(
              child: FlushTextField(
                controller: phoneNumberController,
                hintText: appLoc!.phoneNumber,
                keyboardType: TextInputType.number,
                fontSize: responsive!.scaleFont(13),
                maxLength: phoneLength,
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  // ── Account info — read-only email + verified badge ────────────────────────

  Widget _buildAccountInfoSection() {
    return _groupCard(children: [
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: responsive!.scaleWidth(14),
          vertical: responsive!.scaleHeight(14),
        ),
        child: Row(
          children: [
            Icon(
              Icons.mail_outline_rounded,
              size: responsive!.scaleHeight(18),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: responsive!.scaleWidth(12)),
            Expanded(
              child: MyText(
                text: currentUser!.emailAddress ?? '',
                fontScale: responsive!.scaleFont(13),
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3DE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: MyText(
                text: 'Verified',
                fontScale: responsive!.scaleFont(10),
                fontWeight: FontWeight.w500,
                fontColor: const Color(0xFF27500A),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  // ── All logic — completely unchanged ──────────────────────────────────────

  Future<UserDetails> fetchUser() async {
    var result = await db.getCurrentUser(uid: widget.uid);
    firstNameController.text = result.firstName ?? '';
    lastNameController.text = result.lastName ?? '';
    phoneCountry =
        result.phoneNumber != null ? result.phoneNumber!['country'] : null;
    phoneCode = result.phoneNumber != null ? result.phoneNumber!['code'] : null;
    phoneNumberController.text =
        result.phoneNumber != null ? result.phoneNumber!['number'] ?? '' : '';
    emailController.text = result.emailAddress ?? '';
    return result;
  }

  Future<void> updateUser() async {
    if (firstNameController.text.isEmpty) {
      snackbar.content = appLoc!.firstNameRequired;
      snackbar.showSnack();
      return;
    }
    if (lastNameController.text.isEmpty) {
      snackbar.content = appLoc!.lastNameRequired;
      snackbar.showSnack();
      return;
    }
    if (currentUser == null) {
      snackbar.content = appLoc!.connectionError;
      snackbar.showSnack();
      return;
    }
    currentUser!.firstName = firstNameController.text.trim();
    currentUser!.lastName = lastNameController.text.trim();
    currentUser!.phoneNumber = {
      'country': phoneCountry ?? 'US',
      'code': phoneCode ?? '+1',
      'number': phoneNumberController.text,
    };
    setState(() => isLoading = true);
    await db.updateCurrentUser(user: currentUser);
    if (mounted) {
      setState(() => isLoading = false);
      snackbar.content = appLoc!.profileUpdatedSuccessfully;
      snackbar.showSnack();
      GoRouter.of(context).pop();
    }
  }
}
