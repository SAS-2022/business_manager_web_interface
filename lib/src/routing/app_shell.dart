import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _ShellDestination {
  const _ShellDestination({
    required this.routeName,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.iconBg,
    required this.iconColor,
  });

  final String routeName;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  // Same colored-chip language used for every menu row elsewhere in the
  // app (settings_screen.dart, app_settings.dart, ...) — reused here
  // rather than invented fresh, and reusing the same color per concept
  // (orders is green in both places, etc.) rather than picking arbitrarily.
  final Color iconBg;
  final Color iconColor;
}

/// Persistent navigation shell for the four main tabs (Home/Orders/
/// Products/Settings). Mobile handles these as an in-app PageView with no
/// URL per tab; web gets a real route per tab instead (bookmarkable, back
/// button works) — a custom-styled rail at >=600px width (Material's own
/// rail/bottom-nav breakpoint), a matching custom bottom bar below that.
///
/// Both were originally stock NavigationRail/BottomNavigationBar widgets —
/// functional, but visually flat (plain gray icons, a bare pill behind the
/// selected item, no color) next to the rest of the app's colored-icon-chip
/// menu rows. Rebuilt from scratch here to match that language instead.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.uid,
    required this.location,
    required this.child,
  });

  final String uid;
  final String location;
  final Widget child;

  static const _railBreakpoint = 600.0;

  List<_ShellDestination> _destinations(AppLocalizations? appLoc) => [
    _ShellDestination(
      routeName: 'homeId',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: appLoc?.home ?? 'Home',
      iconBg: const Color(0xFFE6F1FB),
      iconColor: const Color(0xFF185FA5),
    ),
    _ShellDestination(
      routeName: 'orders',
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month_rounded,
      label: appLoc?.orders ?? 'Orders',
      iconBg: const Color(0xFFEAF3DE),
      iconColor: const Color(0xFF3B6D11),
    ),
    _ShellDestination(
      routeName: 'products',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2_rounded,
      label: appLoc?.product ?? 'Items',
      iconBg: const Color(0xFFFAEEDA),
      iconColor: const Color(0xFF854F0B),
    ),
    _ShellDestination(
      routeName: 'settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      label: appLoc?.menu ?? 'Menu',
      iconBg: const Color(0xFFEEEDFE),
      iconColor: const Color(0xFF534AB7),
    ),
  ];

  int _currentIndex(String location) {
    if (location.startsWith('/orders')) return 1;
    if (location.startsWith('/products')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  void _onSelect(
    BuildContext context,
    List<_ShellDestination> destinations,
    int index,
  ) {
    if (index == _currentIndex(location)) return;
    context.goNamed(
      destinations[index].routeName,
      pathParameters: {'uid': uid},
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    final destinations = _destinations(appLoc);
    final currentIndex = _currentIndex(location);
    final isWide = MediaQuery.of(context).size.width >= _railBreakpoint;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // filterQuality: the 512×512 source logo gets downscaled ~18x
            // here — Flutter's default FilterQuality.low (fast bilinear)
            // visibly softens/aliases a shrink that aggressive; .high uses
            // a proper mipmapped downsample instead.
            Image.asset(
              'assets/images/logo.png',
              height: 28,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(width: 8),
            Text(appLoc?.appTitle ?? 'CostEra'),
          ],
        ),
      ),
      body: Row(
        children: [
          if (isWide)
            _SideRail(
              destinations: destinations,
              currentIndex: currentIndex,
              onSelect: (i) => _onSelect(context, destinations, i),
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : _BottomBar(
              destinations: destinations,
              currentIndex: currentIndex,
              onSelect: (i) => _onSelect(context, destinations, i),
            ),
    );
  }
}

// ── Wide layout: a vertical sidebar ─────────────────────────────────────

class _SideRail extends StatelessWidget {
  const _SideRail({
    required this.destinations,
    required this.currentIndex,
    required this.onSelect,
  });

  final List<_ShellDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          for (var i = 0; i < destinations.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: _RailTile(
                destination: destinations[i],
                selected: i == currentIndex,
                onTap: () => onSelect(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _RailTile extends StatelessWidget {
  const _RailTile({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _ShellDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: 52,
              height: 44,
              decoration: BoxDecoration(
                color: selected ? destination.iconBg : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                selected ? destination.selectedIcon : destination.icon,
                size: 22,
                color: selected
                    ? destination.iconColor
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              destination.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? destination.iconColor
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Narrow layout: a bottom bar, same visual language ───────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.destinations,
    required this.currentIndex,
    required this.onSelect,
  });

  final List<_ShellDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var i = 0; i < destinations.length; i++)
              Expanded(
                child: InkWell(
                  onTap: () => onSelect(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          width: 48,
                          height: 32,
                          decoration: BoxDecoration(
                            color: i == currentIndex
                                ? destinations[i].iconBg
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            i == currentIndex
                                ? destinations[i].selectedIcon
                                : destinations[i].icon,
                            size: 20,
                            color: i == currentIndex
                                ? destinations[i].iconColor
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          destinations[i].label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: i == currentIndex
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: i == currentIndex
                                ? destinations[i].iconColor
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
