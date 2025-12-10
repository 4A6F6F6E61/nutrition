import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutrition/sheets/add_ingredient.dart';
import 'package:nutrition/components/ingredient_card.dart';
import 'package:nutrition/providers/ingredient_provider.dart';
import 'package:nutrition/theme.dart';

class IngredientsScreen extends HookConsumerWidget {
  const IngredientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredientsAsync = ref.watch(ingredientsProvider);

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF000000),
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              CupertinoSliverNavigationBar(
                backgroundColor: const Color(0xFF141414),
                largeTitle: const Text(
                  'Ingredients',
                  style: TextStyle(color: CupertinoColors.white),
                ),
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
                          builder: (context) => const AddIngredientSheet(),
                        );
                      },
                      child: Icon(CupertinoIcons.add, color: AppTheme.buttonPrimary, size: 28),
                    ),
                  ],
                ),
              ),
              ingredientsAsync.when(
                data: (ingredients) => ingredients.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.square_grid_2x2,
                                size: 64,
                                color: CupertinoColors.systemGrey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No ingredients yet',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap + to add your first ingredient',
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
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => IngredientCard(ingredient: ingredients[index]),
                            childCount: ingredients.length,
                          ),
                        ),
                      ),
                loading: () =>
                    const SliverFillRemaining(child: Center(child: CupertinoActivityIndicator())),
                error: (err, stack) => SliverFillRemaining(
                  child: Center(
                    child: Text('Error: $err', style: TextStyle(color: CupertinoColors.white)),
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
