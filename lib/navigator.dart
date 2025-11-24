import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutrition/providers.dart';

class NavigatorScaffold extends HookConsumerWidget {
  const NavigatorScaffold({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.restaurant_menu_outlined),
      selectedIcon: Icon(Icons.restaurant_menu),
      label: 'Recipes',
    ),
    NavigationDestination(
      icon: Icon(Icons.kitchen_outlined),
      selectedIcon: Icon(Icons.kitchen),
      label: 'Ingredients',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        destinations: _destinations,
        selectedIndex: shell.currentIndex,
        onDestinationSelected: shell.goBranch,
      ),
    );
  }
}
