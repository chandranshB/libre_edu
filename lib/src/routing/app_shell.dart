import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/offline')) return 1;
    return 0; // Default to Home
  }

  void _onItemTapped(int index, BuildContext context) {
    if (index == 0) {
      context.go('/');
    } else if (index == 1) {
      context.go('/offline');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final isWideScreen = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      body: Row(
        children: [
          if (isWideScreen)
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (idx) => _onItemTapped(idx, context),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Icon(Icons.school, size: 32, color: Theme.of(context).colorScheme.primary),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Courses'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.download_for_offline_outlined),
                  selectedIcon: Icon(Icons.download_for_offline),
                  label: Text('Offline'),
                ),
              ],
            ),
          if (isWideScreen)
            const VerticalDivider(thickness: 1, width: 1),
          // Main content
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: isWideScreen
          ? null
          : NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (idx) => _onItemTapped(idx, context),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Courses',
                ),
                NavigationDestination(
                  icon: Icon(Icons.download_for_offline_outlined),
                  selectedIcon: Icon(Icons.download_for_offline),
                  label: 'Offline',
                ),
              ],
            ),
    );
  }
}
