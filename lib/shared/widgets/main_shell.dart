import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNav(),
    );
  }
}

class _BottomNav extends StatelessWidget {
  static const _items = [
    (icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard', path: '/dashboard'),
    (icon: Icons.account_tree_outlined, activeIcon: Icons.account_tree, label: 'Worktree', path: '/worktree'),
    (icon: Icons.people_outline, activeIcon: Icons.people, label: 'Clients', path: '/clients'),
    (icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'Ledger', path: '/transactions'),
    (icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Reports', path: '/reports'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _items.indexWhere((item) => location.startsWith(item.path));

    return NavigationBar(
      selectedIndex: currentIndex < 0 ? 0 : currentIndex,
      onDestinationSelected: (i) => context.go(_items[i].path),
      destinations: _items
          .map((item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.activeIcon),
                label: item.label,
              ))
          .toList(),
    );
  }
}
