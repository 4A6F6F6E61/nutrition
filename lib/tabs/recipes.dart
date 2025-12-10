import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutrition/sheets/add_recipe.dart';
import 'package:nutrition/components/recipe_card.dart';
import 'package:nutrition/providers/recipe_provider.dart';
import 'package:nutrition/theme.dart';

class RecipesScreen extends HookConsumerWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipesProvider);

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF000000),
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              CupertinoSliverNavigationBar(
                backgroundColor: const Color(0xFF141414),
                largeTitle: Text('Recipes', style: TextStyle(color: AppTheme.textPrimary)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        // TODO: Implement search
                      },
                      child: Icon(CupertinoIcons.search, color: AppTheme.buttonPrimary, size: 28),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (context) => const AddRecipeSheet(),
                        );
                      },
                      child: Icon(CupertinoIcons.add, color: AppTheme.buttonPrimary, size: 28),
                    ),
                  ],
                ),
              ),
              recipesAsync.when(
                data: (recipes) => recipes.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.book,
                                size: 64,
                                color: CupertinoColors.systemGrey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No recipes yet',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap + to create your first recipe',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: CupertinoColors.systemGrey2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => RecipeCard(recipe: recipes[index]),
                            childCount: recipes.length,
                          ),
                        ),
                      ),
                loading: () =>
                    const SliverFillRemaining(child: Center(child: CupertinoActivityIndicator())),
                error: (err, stack) => SliverFillRemaining(
                  child: Center(
                    child: Text('Error: $err', style: TextStyle(color: AppTheme.textPrimary)),
                  ),
                ),
              ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
