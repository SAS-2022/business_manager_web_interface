import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/constants/dimensions.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/features/landing/login_popup.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The public marketing landing page — what an unauthenticated visitor sees
/// at '/' (swapped in by Wrapper._buildInitialPage() in place of the old
/// bare logo + login/register button panel). Sign-in itself now happens in
/// a popup (login_popup.dart) anchored under the header's Login button
/// rather than a full page, so a visitor never leaves the marketing content
/// to authenticate.
///
/// Copy on this page (headline, feature blurbs, pricing-card text) is
/// deliberately plain English literals rather than AppLocalizations keys —
/// unlike the rest of this app, which is fully localized. This page's
/// content is expected to change repeatedly as the design is iterated on;
/// once the copy settles, it should be ported into the ARB files across all
/// 5 languages like everything else. Structural strings that already existed
/// (login/register/appTitle/contactUs) still use appLoc as normal.
///
/// No real product screenshots exist yet for this app, so the hero/about
/// illustrations are abstract mock-dashboard graphics built from plain
/// Flutter shapes rather than fabricated/stock imagery — swap in real
/// screenshots once available.
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _pricingKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  bool _isAnnual = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    responsive = ResponsiveUtils(context);
    appLoc = AppLocalizations.of(context);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isDesktop => MediaQuery.of(context).size.width >= 1024;
  bool get _isTablet =>
      MediaQuery.of(context).size.width >= 700 &&
      MediaQuery.of(context).size.width < 1024;

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    _hero(),
                    _sectionWrap(key: _featuresKey, child: _features()),
                    _sectionWrap(key: _aboutKey, child: _about()),
                    _sectionWrap(key: _pricingKey, child: _pricing()),
                    _ctaBanner(),
                    _footer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A plain wrapper so GlobalKeys used for scroll-to-anchor don't have to
  // sit on the section widget itself (which may return a Padding/Container
  // whose own key semantics we'd rather not entangle with).
  Widget _sectionWrap({required GlobalKey key, required Widget child}) {
    return KeyedSubtree(key: key, child: child);
  }

  Widget _centered({
    required Widget child,
    double maxWidth = AppDimensions.maxCatalogWidth,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────

  Widget _header() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
            width: 0.5,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: _isDesktop ? 40 : responsive!.scaleWidth(16),
        vertical: 14,
      ),
      child: _centered(
        maxWidth: 1280,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  const SizedBox(width: 10),
                  MyText(
                    text: appLoc!.appTitle,
                    fontScale: responsive!.scaleFont(18),
                    fontWeight: FontWeight.w700,
                  ),
                ],
              ),
            ),
            if (_isDesktop || _isTablet) ...[
              const SizedBox(width: 40),
              _navLink('Features', () => _scrollTo(_featuresKey)),
              const SizedBox(width: 28),
              _navLink('About', () => _scrollTo(_aboutKey)),
              const SizedBox(width: 28),
              _navLink('Pricing', () => _scrollTo(_pricingKey)),
            ],
            const Spacer(),
            GestureDetector(
              onTap: () => showLoginPopup(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: MyText(
                  text: appLoc!.login,
                  fontScale: responsive!.scaleFont(14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => GoRouter.of(context).pushNamed('register'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: MyText(
                  text: 'Get Started',
                  fontScale: responsive!.scaleFont(13),
                  fontWeight: FontWeight.w500,
                  fontColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navLink(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: MyText(
        text: label,
        fontScale: responsive!.scaleFont(14),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // ── Hero ───────────────────────────────────────────────────────────────

  Widget _hero() {
    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: MyText(
            text: 'RUN YOUR BUSINESS FROM ANYWHERE',
            fontScale: responsive!.scaleFont(11),
            fontWeight: FontWeight.w600,
            fontColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 20),
        MyText(
          text: 'The all-in-one workspace to run your business',
          fontScale: responsive!.scaleFont(_isDesktop ? 40 : 28),
          fontWeight: FontWeight.w700,
          softWrap: true,
          optimalSizeEnabled: false,
        ),
        const SizedBox(height: 16),
        MyText(
          text:
              'Orders, quotes, purchases, inventory, and financial reports — '
              'all in one place. Built for retail, manufacturing, and '
              'service businesses of any size.',
          fontScale: responsive!.scaleFont(15),
          softWrap: true,
          optimalSizeEnabled: false,
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            GestureDetector(
              onTap: () => GoRouter.of(context).pushNamed('register'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: MyText(
                  text: 'Get Started Free',
                  fontScale: responsive!.scaleFont(15),
                  fontWeight: FontWeight.w500,
                  fontColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => showLoginPopup(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.4),
                  ),
                ),
                child: MyText(
                  text: appLoc!.login,
                  fontScale: responsive!.scaleFont(15),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );

    final illustration = _HeroIllustration(isDesktop: _isDesktop);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _isDesktop ? 40 : responsive!.scaleWidth(16),
        vertical: _isDesktop ? 72 : 40,
      ),
      child: _centered(
        maxWidth: 1280,
        child: _isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 5, child: textColumn),
                  const SizedBox(width: 56),
                  Expanded(flex: 4, child: illustration),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textColumn,
                  const SizedBox(height: 40),
                  illustration,
                ],
              ),
      ),
    );
  }

  // ── Features ───────────────────────────────────────────────────────────

  static const _features_ = [
    (
      Icons.shopping_cart_outlined,
      'Sales, Orders & Quotes',
      'Create orders and quotes, schedule deliveries, and turn quotes into '
          'orders in a click.',
    ),
    (
      Icons.inventory_2_outlined,
      'Inventory Management',
      'Track stock across multiple locations and stop overselling — updated '
          'automatically as you buy and sell.',
    ),
    (
      Icons.local_shipping_outlined,
      'Purchases & Suppliers',
      'Manage purchase orders and supplier relationships, and keep product '
          'cost accurate automatically.',
    ),
    (
      Icons.science_outlined,
      'Manufacturing & Recipes',
      'Plan raw materials, cost recipes, and track production for '
          'manufacturing businesses.',
    ),
    (
      Icons.bar_chart_outlined,
      'Financial Reports',
      'Sales, profit & loss, and inventory reports whenever you need them — '
          'no spreadsheets required.',
    ),
    (
      Icons.pie_chart_outline_rounded,
      'Capital & Expenses',
      'Keep track of business assets and running costs alongside everything '
          'else.',
    ),
    (
      Icons.people_outline_rounded,
      'Client Management',
      'Store client details, statements, and payment history in one '
          'searchable place.',
    ),
    (
      Icons.storefront_outlined,
      'Built For Any Business',
      'Purpose-built flows for trading, manufacturing, and service '
          'businesses alike.',
    ),
  ];

  Widget _features() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _isDesktop ? 40 : responsive!.scaleWidth(16),
        vertical: 56,
      ),
      child: _centered(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _sectionHeading(
              eyebrow: 'FEATURES',
              title: 'Everything your business needs',
              subtitle:
                  'One workspace instead of five different tools stitched '
                  'together.',
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: _features_
                  .map(
                    (f) => _featureCard(
                      icon: f.$1,
                      title: f.$2,
                      description: f.$3,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 14),
          MyText(
            text: title,
            fontScale: responsive!.scaleFont(15),
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 6),
          MyText(
            text: description,
            fontScale: responsive!.scaleFont(13),
            softWrap: true,
            optimalSizeEnabled: false,
          ),
        ],
      ),
    );
  }

  // ── About ──────────────────────────────────────────────────────────────

  static const _aboutHighlights = [
    (
      Icons.sync_rounded,
      'Real-Time Sync',
      'Every change on web reaches your mobile app instantly, and back.',
    ),
    (
      Icons.translate_rounded,
      'Multi-Currency & Language',
      'Work in your own currency and language — five languages supported.',
    ),
    (
      Icons.cloud_done_outlined,
      'Secure Cloud Backups',
      'Your data lives safely in the cloud, backed up automatically.',
    ),
  ];

  Widget _about() {
    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _sectionHeading(
          eyebrow: 'ABOUT COSTERA',
          title: 'The business manager that grows with you',
          subtitle: null,
          alignment: CrossAxisAlignment.start,
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 20),
        MyText(
          text:
              'CostEra started as a mobile app for small business owners who '
              'needed something better than spreadsheets and paper receipts. '
              'The web version brings the same tools to your desktop: manage '
              'orders and quotes, track inventory across locations, generate '
              'invoices, and see real financial reports — all synced with '
              'your mobile app in real time.',
          fontScale: responsive!.scaleFont(15),
          softWrap: true,
          optimalSizeEnabled: false,
        ),
        const SizedBox(height: 16),
        MyText(
          text:
              'Whether you run a retail shop, a manufacturing workshop, or a '
              'service business, CostEra adapts its tools to how you '
              'actually work — right down to which fields and reports you '
              'see, based on the type of business you run.',
          fontScale: responsive!.scaleFont(15),
          softWrap: true,
          optimalSizeEnabled: false,
        ),
        const SizedBox(height: 16),
        MyText(
          text:
              'No installs, no updates to wait for — sign in from any '
              'browser and pick up exactly where you left off on your '
              'phone, with the same data, the same day.',
          fontScale: responsive!.scaleFont(15),
          softWrap: true,
          optimalSizeEnabled: false,
        ),
        const SizedBox(height: 28),
        ..._aboutHighlights.map(
          (h) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    h.$1,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        text: h.$2,
                        fontScale: responsive!.scaleFont(15),
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: 3),
                      MyText(
                        text: h.$3,
                        fontScale: responsive!.scaleFont(13),
                        softWrap: true,
                        optimalSizeEnabled: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    final illustrationColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AboutIllustration(),
        const SizedBox(height: 20),
        _AboutStatsIllustration(),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _isDesktop ? 40 : responsive!.scaleWidth(16),
        vertical: 56,
      ),
      child: _centered(
        child: _isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: illustrationColumn),
                  const SizedBox(width: 56),
                  Expanded(flex: 5, child: textColumn),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  illustrationColumn,
                  const SizedBox(height: 32),
                  textColumn,
                ],
              ),
      ),
    );
  }

  // ── Pricing / comparison ───────────────────────────────────────────────

  Widget _pricing() {
    return Container(
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      padding: EdgeInsets.symmetric(
        horizontal: _isDesktop ? 40 : responsive!.scaleWidth(16),
        vertical: 56,
      ),
      child: _centered(
        child: Column(
          children: [
            _sectionHeading(
              eyebrow: 'PRICING',
              title: 'Simple, transparent pricing',
              subtitle: 'Start free. Upgrade when you need more.',
            ),
            const SizedBox(height: 28),
            Center(child: _billingToggle()),
            const SizedBox(height: 28),
            Flex(
              direction: _isDesktop || _isTablet
                  ? Axis.horizontal
                  : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _pricingCard(isPremium: false)),
                SizedBox(
                  width: _isDesktop || _isTablet ? 24 : 0,
                  height: _isDesktop || _isTablet ? 0 : 24,
                ),
                Expanded(child: _pricingCard(isPremium: true)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // A sliding pill toggle (on/off style) between Monthly and Annual billing
  // — swapped in for the earlier AnimatedRadioButton, which renders as a
  // pair of radio circles rather than a toggle and doesn't fit this
  // pricing-switch pattern.
  Widget _billingToggle() {
    const width = 260.0;
    const height = 46.0;
    return GestureDetector(
      onTap: () => setState(() => _isAnnual = !_isAnnual),
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(height / 2),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              alignment: _isAnnual
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular((height - 8) / 2),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: MyText(
                      text: 'Monthly',
                      fontScale: responsive!.scaleFont(13),
                      fontWeight: FontWeight.w600,
                      optimalSizeEnabled: false,
                      fontColor: !_isAnnual
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: MyText(
                      text: 'Annual',
                      fontScale: responsive!.scaleFont(13),
                      fontWeight: FontWeight.w600,
                      optimalSizeEnabled: false,
                      fontColor: _isAnnual
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const _freeFeatures = [
    'Up to 9 products',
    'Up to 19 orders',
    'Client management',
    'Payment tracking',
  ];

  static const _premiumFeatures = [
    'Everything in Free',
    'Unlimited products & orders',
    'Quotes',
    'Suppliers & purchase orders',
    'Inventory across all locations',
    'Manufacturing & recipe costing',
    'Sales, profit & inventory reports',
    'Capital & expenses tracking',
    'Order & quote margin insights',
    'Priority support',
  ];

  // The premium card's own accent shifts between the two billing periods —
  // primary (black/white per theme) for Annual, the theme's blue/teal
  // secondaryFixed for Monthly — animated on toggle purely as a bit of
  // visual interest, not meaningful state; Annual stays the one that also
  // carries the POPULAR badge.
  Color _premiumCardColor(BuildContext context) => _isAnnual
      ? Theme.of(context).colorScheme.primary
      : Theme.of(context).colorScheme.secondaryFixed;

  Widget _pricingCard({required bool isPremium}) {
    final premiumColor = _premiumCardColor(context);
    // Computed from the actual premium color rather than colorScheme.onPrimary
    // — onPrimary is tuned to contrast against colorScheme.primary
    // specifically, but the premium card's background now also switches to
    // secondaryFixed for Monthly, which onPrimary isn't guaranteed to read
    // well against (especially in dark mode). Estimating brightness keeps
    // the text legible against whichever of the two colors is showing.
    final onPremium =
        ThemeData.estimateBrightnessForColor(premiumColor) == Brightness.dark
        ? Colors.white
        : Colors.black;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isPremium
            ? premiumColor
            : Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPremium
              ? Colors.transparent
              : Theme.of(context).dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MyText(
                text: isPremium ? 'Premium' : 'Free',
                fontScale: responsive!.scaleFont(18),
                fontWeight: FontWeight.w700,
                fontColor: isPremium ? onPremium : null,
              ),
              if (isPremium && _isAnnual) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: onPremium,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: MyText(
                    text: 'POPULAR',
                    fontScale: responsive!.scaleFont(9),
                    fontWeight: FontWeight.w700,
                    fontColor: premiumColor,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MyText(
                text: isPremium ? (_isAnnual ? '\$98.90' : '\$14.99') : '\$0',
                fontScale: responsive!.scaleFont(32),
                fontWeight: FontWeight.w700,
                fontColor: isPremium ? onPremium : null,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: MyText(
                  text: isPremium
                      ? (_isAnnual ? '/year' : '/month')
                      : '/forever',
                  fontScale: responsive!.scaleFont(13),
                  fontColor: isPremium
                      ? onPremium.withValues(alpha: 0.8)
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (isPremium)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: MyText(
                text: _isAnnual
                    ? '≈ \$8.24/mo — save ~45% vs. monthly'
                    : 'or \$98.90/year — save ~45%',
                fontScale: responsive!.scaleFont(12),
                fontColor: onPremium.withValues(alpha: 0.8),
              ),
            ),
          const SizedBox(height: 22),
          ...(isPremium ? _premiumFeatures : _freeFeatures).map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: isPremium
                        ? onPremium
                        : Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MyText(
                      text: f,
                      fontScale: responsive!.scaleFont(13),
                      softWrap: true,
                      optimalSizeEnabled: false,
                      fontColor: isPremium ? onPremium : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => GoRouter.of(context).pushNamed('register'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isPremium
                    ? onPremium
                    : Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: MyText(
                  text: isPremium ? 'Get Premium' : 'Get Started',
                  fontScale: responsive!.scaleFont(14),
                  fontWeight: FontWeight.w500,
                  fontColor: isPremium
                      ? premiumColor
                      : Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── CTA banner ─────────────────────────────────────────────────────────

  Widget _ctaBanner() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _isDesktop ? 40 : responsive!.scaleWidth(16),
        vertical: 64,
      ),
      child: _centered(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 44),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              MyText(
                text: 'Ready to run your business better?',
                fontScale: responsive!.scaleFont(_isDesktop ? 26 : 20),
                fontWeight: FontWeight.w700,
                fontColor: Theme.of(context).colorScheme.onPrimary,
                align: TextAlign.center,
              ),
              const SizedBox(height: 10),
              MyText(
                text: 'Create your free account — no card required.',
                fontScale: responsive!.scaleFont(14),
                fontColor: Theme.of(
                  context,
                ).colorScheme.onPrimary.withValues(alpha: 0.85),
                align: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => GoRouter.of(context).pushNamed('register'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: MyText(
                    text: 'Get Started Free',
                    fontScale: responsive!.scaleFont(15),
                    fontWeight: FontWeight.w600,
                    fontColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────

  Widget _footer() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: _isDesktop ? 40 : responsive!.scaleWidth(16),
        vertical: 28,
      ),
      child: _centered(
        maxWidth: 1280,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 12,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                const SizedBox(width: 8),
                MyText(
                  text:
                      '© ${DateTime.now().year} ${appLoc!.appTitle}. All rights reserved.',
                  fontScale: responsive!.scaleFont(12),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => GoRouter.of(context).pushNamed('contactUs'),
              child: MyText(
                text: appLoc!.contactUs,
                fontScale: responsive!.scaleFont(12),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shared heading block ───────────────────────────────────────────────

  Widget _sectionHeading({
    required String eyebrow,
    required String title,
    String? subtitle,
    CrossAxisAlignment alignment = CrossAxisAlignment.center,
    TextAlign textAlign = TextAlign.center,
  }) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        MyText(
          text: eyebrow,
          fontScale: responsive!.scaleFont(12),
          fontWeight: FontWeight.w600,
          fontColor: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        MyText(
          text: title,
          fontScale: responsive!.scaleFont(_isDesktop ? 28 : 22),
          fontWeight: FontWeight.w700,
          align: textAlign,
          softWrap: true,
          optimalSizeEnabled: false,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          MyText(
            text: subtitle,
            fontScale: responsive!.scaleFont(14),
            align: textAlign,
            softWrap: true,
            optimalSizeEnabled: false,
          ),
        ],
      ],
    );
  }
}

// ── Abstract hero illustration — a mock "dashboard" card built from plain
// shapes (no real product screenshot exists yet). Purely decorative. ──────

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration({required this.isDesktop});
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      height: isDesktop ? 340 : 240,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _dot(Colors.redAccent),
              const SizedBox(width: 6),
              _dot(Colors.orangeAccent),
              const SizedBox(width: 6),
              _dot(Colors.greenAccent),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 3, child: _barsCard(primary)),
                const SizedBox(width: 14),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(child: _statCard(primary, '128', 'Orders')),
                      const SizedBox(height: 14),
                      Expanded(child: _statCard(primary, '\$24.8k', 'Revenue')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  Widget _barsCard(Color primary) {
    final heights = [0.4, 0.65, 0.5, 0.9, 0.7, 1.0];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: heights
            .map(
              (h) => Flexible(
                child: FractionallySizedBox(
                  heightFactor: h,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.15 + h * 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _statCard(Color primary, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
        ],
      ),
    );
  }
}

// ── Abstract "about" illustration — a mock list of order rows. ────────────

class _AboutIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final rows = [
      ('Order #1042', '\$240.00', true),
      ('Order #1041', '\$85.50', true),
      ('Purchase #88', '\$1,120.00', false),
      ('Order #1040', '\$62.00', true),
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: rows
            .map(
              (r) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: r.$3 ? primary : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        r.$1,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      r.$2,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Second "about" illustration — a small stats snapshot mock, so the
// section reads as two images rather than one. ────────────────────────────

class _AboutStatsIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.insights_rounded, size: 16, color: primary),
              const SizedBox(width: 6),
              const Text(
                'This Month',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _statTile(primary, '342', 'Products Sold')),
              const SizedBox(width: 12),
              Expanded(child: _statTile(primary, '\$186', 'Avg. Order')),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up_rounded, size: 16, color: primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Gross margin up 6% vs. last month',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statTile(Color primary, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
