import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _ShellDestination {
  const _ShellDestination({
    required this.routeName,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final String routeName;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Persistent navigation shell for the four main tabs (Home/Orders/
/// Products/Settings). Mobile handles these as an in-app PageView with no
/// URL per tab; web gets a real route per tab instead (bookmarkable, back
/// button works) — a NavigationRail at >=600px width (Material's own
/// rail/bottom-nav breakpoint), a BottomNavigationBar below that.
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
          selectedIcon: Icons.home,
          label: appLoc?.home ?? 'Home',
        ),
        _ShellDestination(
          routeName: 'orders',
          icon: Icons.calendar_month_outlined,
          selectedIcon: Icons.calendar_month,
          label: appLoc?.orders ?? 'Orders',
        ),
        _ShellDestination(
          routeName: 'products',
          icon: Icons.inventory_2_outlined,
          selectedIcon: Icons.inventory_2,
          label: appLoc?.product ?? 'Items',
        ),
        _ShellDestination(
          routeName: 'settings',
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings,
          label: appLoc?.menu ?? 'Menu',
        ),
      ];

  int _currentIndex(String location) {
    if (location.startsWith('/orders')) return 1;
    if (location.startsWith('/products')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  void _onSelect(BuildContext context, List<_ShellDestination> destinations, int index) {
    if (index == _currentIndex(location)) return;
    context.goNamed(destinations[index].routeName, pathParameters: {'uid': uid});
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
            Image.asset('assets/images/logo.png', height: 28),
            const SizedBox(width: 8),
            Text(appLoc?.appTitle ?? 'CostEra'),
          ],
        ),
      ),
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: (i) => _onSelect(context, destinations, i),
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
          if (isWide) const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: currentIndex,
              onTap: (i) => _onSelect(context, destinations, i),
              items: [
                for (final d in destinations)
                  BottomNavigationBarItem(
                    icon: Icon(d.icon),
                    activeIcon: Icon(d.selectedIcon),
                    label: d.label,
                  ),
              ],
            ),
    );
  }
}
