import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutrition/theme.dart';

class NavigatorScaffold extends HookConsumerWidget {
  const NavigatorScaffold({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoTabScaffold(
      key: ValueKey(shell.currentIndex),
      tabBar: CupertinoTabBar(
        activeColor: AppTheme.tabBarActive,
        inactiveColor: AppTheme.tabBarInactive,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house),
            activeIcon: Icon(CupertinoIcons.house_fill),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book),
            activeIcon: Icon(CupertinoIcons.book_fill),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_grid_2x2),
            activeIcon: Icon(CupertinoIcons.square_grid_2x2_fill),
            label: 'Ingredients',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            activeIcon: Icon(CupertinoIcons.settings_solid),
            label: 'Settings',
          ),
        ],
        currentIndex: shell.currentIndex,
        onTap: shell.goBranch,
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(builder: (context) => shell);
      },
    );
  }
}
