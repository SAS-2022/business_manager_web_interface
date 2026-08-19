import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/providers/providers.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/regular_button.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/features/home/product_content.dart';
import 'package:business_manager_web_ui/src/features/home/sales_statistics.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/responsive_utils.dart';

/// Stage 11 scope: real Home dashboard (top products, sales statistics).
/// Dropped vs. mobile: local push-notification init (`notification_service`,
/// no web equivalent), app-store rating-prompt tracking (`rating_provider`,
/// mobile-store-only), and the AI "business content" news card
/// (`business_content.dart`, `ai_service.dart`/`OpenAIDataService`,
/// `createNewsCard()`) — that last one was already dead code on mobile
/// itself (defined but never inserted into the widget tree), so this isn't
/// a feature cut, just not porting unused code.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.uid});
  final String? uid;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  bool isLoading = false;
  DatabaseService db = DatabaseService();
  ErrorClass errorClass = ErrorClass();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  UserDetails? currentUser = UserDetails();
  String? error;

  @override
  void initState() {
    if (widget.uid != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(userProvider(widget.uid));
        _updateUserLastActive();
      });
    }
    snackbarWidget.context = context;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid && widget.uid != null) {
      ref.invalidate(userProvider(widget.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userAsync = ref.watch(userProvider(widget.uid));
    return userAsync.when(
      loading: () => const Center(
        child: GradientSkeleton(
          hasAppBar: true,
          hasBottomNavigation: true,
          itemCount: 6,
        ),
      ),
      error: (error, stackTrace) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyText(
                text: errorClass.userNoTFoundError(e: error.toString()),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _refreshData,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
      data: (user) {
        currentUser = user;
        return _buildHomeScreen(user);
      },
    );
  }

  Future<void> _updateUserLastActive() async {
    if (widget.uid != null) {
      try {
        await db.updateUserLastActive(widget.uid!);
      } catch (e) {
        debugPrint('Error updating last active: $e');
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() => isLoading = true);
    final refreshUser = ref.read(userRefreshProvider);
    try {
      await refreshUser(widget.uid!);
      if (mounted) {
        snackbarWidget.content = appLoc!.dataRefereshedSuccessfully;
        snackbarWidget.showSnack();
      }
    } catch (e) {
      if (mounted) {
        snackbarWidget.content = appLoc!.dataFailedToRefresh;
        snackbarWidget.showSnack();
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget _buildHomeScreen(UserDetails? user) {
    return isLoading
        ? const GradientSkeleton()
        : SingleChildScrollView(
            child: Padding(
              padding: responsive!.responsivePaddingHor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  user!.termsAccepted == null || user.termsAccepted == false
                      ? _buildTermsAndConditions()
                      : const SizedBox.shrink(),
                  ProductContentScreen(
                    uid: widget.uid,
                  ),
                  SalesStatisticsScreen(
                    uid: widget.uid,
                    currencySymbol:
                        user.currency != null ? user.currency!['symbol'] : '\$',
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildTermsAndConditions() {
    return Center(
      child: Padding(
        padding: responsive!.responsivePaddingVer,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(10),
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
          child: Padding(
            padding: responsive!.responsivePaddingM,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MyText(
                  text: appLoc!.needToAgreeToTerms,
                  fontScale: responsive!.scaleFont(13),
                ),
                SizedBox(height: responsive!.scaleHeight(10)),
                GestureDetector(
                  onTap: () {
                    GoRouter.of(context).pushNamed('termsPage',
                        pathParameters: {'uid': widget.uid!});
                  },
                  child: RegulartButton(
                    text: appLoc!.termsOfUse,
                    fontSize: responsive!.scaleFont(12),
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.5),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
