import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrition/login.dart';
import 'package:nutrition/navigator.dart';
import 'package:nutrition/providers/supabase_providers.dart';
import 'package:nutrition/tabs/home.dart';
import 'package:nutrition/tabs/ingredients.dart';
import 'package:nutrition/tabs/recipes.dart';
import 'package:nutrition/tabs/settings.dart';
import 'package:nutrition/pages/recipe_detail.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(sessionProvider);
  final authStream = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: RouterRefreshStream(authStream),
    routes: [
      GoRoute(path: '/login', name: 'login', builder: (context, state) => const LoginScreen()),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => NavigatorScaffold(shell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', name: 'home', builder: (context, state) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/recipes',
                name: 'recipes',
                builder: (context, state) => const RecipesScreen(),
                routes: [
                  GoRoute(
                    path: '/:id',
                    name: 'recipe_detail',
                    builder: (context, state) =>
                        RecipeDetailPage(recipeId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ingredients',
                name: 'ingredients',
                builder: (context, state) => const IngredientsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final session = authState.asData?.value;
      final loggingIn = state.matchedLocation == '/login';

      if (session == null) {
        return loggingIn ? null : '/login';
      }

      if (loggingIn) {
        return '/home';
      }

      return null;
    },
  );
});

class RouterRefreshStream extends ChangeNotifier {
  RouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
