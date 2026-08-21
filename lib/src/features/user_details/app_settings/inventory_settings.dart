import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/neumorphic_toggle.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/flush_text_field.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateInventory extends StatefulWidget {
  const CreateInventory({super.key, this.uid});
  final String? uid;

  @override
  State<CreateInventory> createState() => _CreateInventoryState();
}

class _CreateInventoryState extends State<CreateInventory> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  bool isLoading = false;
  SnackbarWidget snackbar = SnackbarWidget();
  ErrorClass errorClass = ErrorClass();
  DatabaseService db = DatabaseService();
  Future<UserDetails>? getCurrentUser;
  UserDetails currentUser = UserDetails();
  bool? changes = false;
  Map<int, TextEditingController> locations = {};
  Function? refreshCallback;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    snackbar.context = context;
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
    final GoRouterState state = GoRouterState.of(context);
    if (state.extra != null && state.extra is Function) {
      refreshCallback = state.extra as Function?;
    }
  }

  @override
  void initState() {
    if (widget.uid != null) getCurrentUser = fetchUser();
    snackbar.context = context;
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in locations.values) {
      controller.dispose();
    }
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: MyText(
            text: appLoc!.inventoryController,
            fontScale: responsive!.scaleFont(18),
            fontWeight: FontWeight.w500,
          ),
          actions: [
            if (changes != null && changes!)
              IconButton(
                icon: Icon(Icons.save_outlined,
                    size: responsive!.scaleHeight(22)),
                onPressed: () async => await saveData(),
              ),
          ],
        ),
        body: Stack(
          children: [
            _buildInventoryControlBody(),
            if (isLoading) const Center(child: AnimatedArcLoader()),
          ],
        ),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildInventoryControlBody() {
    return FutureBuilder(
      future: getCurrentUser,
      builder: (context, usershot) {
        if (usershot.hasError) {
          return Center(
            child: MyText(
                text:
                    errorClass.userNoTFoundError(e: usershot.error.toString())),
          );
        }
        if (usershot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        }

        currentUser = usershot.data ?? UserDetails();

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: responsive!.scaleWidth(16),
            vertical: responsive!.scaleHeight(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: responsive!.scaleWidth(14),
                  vertical: responsive!.scaleHeight(12),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F1FB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFB3D4F5),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: responsive!.scaleHeight(16),
                      color: const Color(0xFF185FA5),
                    ),
                    SizedBox(width: responsive!.scaleWidth(8)),
                    Expanded(
                      child: MyText(
                        text: appLoc!.inventoryIntro,
                        fontScale: responsive!.scaleFont(12),
                        softWrap: true,
                        maxLines: 4,
                        textOverflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Activate inventory toggle ─────────────────────────────
              _sectionLabel(appLoc!.inventory),
              _groupCard(children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive!.scaleWidth(14),
                    vertical: responsive!.scaleHeight(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warehouse_outlined,
                        size: responsive!.scaleHeight(18),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: responsive!.scaleWidth(12)),
                      Expanded(
                        child: MyText(
                          text: appLoc!.activateInventory,
                          fontScale: responsive!.scaleFont(13),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // NeumorphicToggle — logic unchanged
                      SizedBox(
                        width: responsive!.scaleWidth(70),
                        child: NeumorphicToggle(
                          value: currentUser.useInventory != null &&
                              currentUser.useInventory!,
                          onChanged: (value) {
                            setState(() => value == true
                                ? currentUser.useInventory = true
                                : currentUser.useInventory = false);
                            changes = true;
                            locations[1] = TextEditingController();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ]),

              // ── Stock locations (conditional) ─────────────────────────
              if (currentUser.useInventory != null &&
                  currentUser.useInventory!) ...[
                SizedBox(height: responsive!.scaleHeight(20)),
                _buildStockLocations(),
              ],

              SizedBox(height: responsive!.scaleHeight(32)),
            ],
          ),
        );
      },
    );
  }

  // ── Stock locations — logic unchanged, layout restyled ────────────────────

  Widget _buildStockLocations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _sectionLabel(appLoc!.inventoryController),
            const Spacer(),
            // Add location button — logic unchanged
            GestureDetector(
              onTap: () {
                setState(() {
                  int counter = 0;
                  if (locations.isNotEmpty) {
                    counter = locations.entries.last.key;
                  }
                  if (counter < 10) {
                    counter++;
                    locations[counter] = TextEditingController();
                    changes = true;
                  } else {
                    snackbar.content = appLoc!.inventoryLocationLimit;
                    snackbar.showSnack();
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive!.scaleWidth(10),
                  vertical: responsive!.scaleHeight(5),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      size: responsive!.scaleHeight(14),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: responsive!.scaleWidth(4)),
                    MyText(
                      text: appLoc!.add,
                      fontScale: responsive!.scaleFont(11),
                      fontWeight: FontWeight.w500,
                      fontColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Location list
        if (locations.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: locations.length,
              separatorBuilder: (_, __) => Divider(
                height: 0,
                thickness: 0.5,
                indent: responsive!.scaleWidth(14),
                color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
              ),
              itemBuilder: (context, index) {
                var element = locations.entries.elementAt(index);
                return _buildLocation(element);
              },
            ),
          ),
      ],
    );
  }

  // ── Location row — FlushTextField replacing MyTextField, logic unchanged ───

  Widget _buildLocation(MapEntry entry) {
    final controller = locations[entry.key] ?? TextEditingController();
    controller.addListener(() {
      locations[entry.key] = controller;
      changes = true;
    });

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(14),
        vertical: responsive!.scaleHeight(4),
      ),
      child: Row(
        children: [
          // Index number
          Container(
            width: responsive!.scaleWidth(28),
            height: responsive!.scaleWidth(28),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: MyText(
                text: entry.key == null ? '1' : entry.key.toString(),
                fontScale: responsive!.scaleFont(12),
                fontWeight: FontWeight.w600,
                fontColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          SizedBox(width: responsive!.scaleWidth(10)),
          // Location name field — FlushTextField, same controller + listener
          Expanded(
            child: FlushTextField(
              controller: controller,
              hintText: appLoc!.locationName,
              textCapitalization: TextCapitalization.words,
              maxLength: 40,
              fontSize: responsive!.scaleFont(13),
            ),
          ),
          SizedBox(width: responsive!.scaleWidth(8)),
          // Remove button — logic unchanged
          GestureDetector(
            onTap: () {
              setState(() {
                locations.removeWhere((key, value) => key == entry.key);
                changes = true;
              });
            },
            child: Container(
              width: responsive!.scaleWidth(28),
              height: responsive!.scaleWidth(28),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).colorScheme.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.remove_rounded,
                size: responsive!.scaleHeight(16),
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Logic — completely unchanged ───────────────────────────────────────────

  Future<UserDetails> fetchUser() async {
    UserDetails result = await db.getCurrentUser(uid: widget.uid);
    if (result.inventoryLoc != null) {
      for (var entry in result.inventoryLoc!.entries) {
        locations[entry.key] = TextEditingController(text: entry.value);
      }
    }
    return result;
  }

  Future<void> saveData() async {
    Map<int, String> inventLoc = {};
    setState(() => isLoading = true);

    if (locations.isNotEmpty &&
        currentUser.useInventory != null &&
        currentUser.useInventory!) {
      for (var loc in locations.entries) {
        inventLoc[loc.key] = loc.value.text.trim();
        if (loc.value.text.isEmpty) {
          snackbar.content = appLoc!.locationNameEmpty;
          snackbar.showSnack();
          setState(() => isLoading = false);
          return;
        }
      }
    }

    currentUser.inventoryLoc = inventLoc;
    await db.updateCurrentUser(user: currentUser);

    if (refreshCallback != null) refreshCallback!();

    if (mounted) {
      setState(() {
        isLoading = false;
        changes = false;
      });
      GoRouter.of(context).pop();
    }
  }
}
