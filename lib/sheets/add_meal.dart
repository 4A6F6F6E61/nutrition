import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutrition/models/recipe.dart';
import 'package:nutrition/providers/meal_log_provider.dart';
import 'package:nutrition/providers/recipe_provider.dart';
import 'package:nutrition/theme.dart';

class AddMealSheet extends HookConsumerWidget {
  const AddMealSheet({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipesProvider);
    final selectedRecipe = useState<Recipe?>(null);
    final servings = useState(1.0);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppTheme.sheetBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Log Meal',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  color: AppTheme.sheetActionBackground,
                  sizeStyle: CupertinoButtonSize.medium,
                  borderRadius: .circular(30),
                  child: const Icon(CupertinoIcons.xmark, color: AppTheme.sheetActionForeground),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          Expanded(
            child: recipesAsync.when(
              data: (recipes) => recipes.isEmpty
                  ? const Center(
                      child: Text(
                        'No recipes yet. Add one in the Recipes tab!',
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: recipes.length,
                            itemBuilder: (context, index) {
                              final recipe = recipes[index];
                              final isSelected = selectedRecipe.value?.id == recipe.id;
                              return GestureDetector(
                                onTap: () => selectedRecipe.value = recipe,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primaryColor.withOpacity(0.2)
                                        : AppTheme.cardBackground,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isSelected
                                        ? Border.all(color: AppTheme.primaryColor)
                                        : Border.all(color: AppTheme.borderColor),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              recipe.name,
                                              style: const TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (recipe.description != null) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                recipe.description!,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: AppTheme.textSecondary,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          CupertinoIcons.check_mark_circled_solid,
                                          color: AppTheme.primaryColor,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (selectedRecipe.value != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: AppTheme.cardBackground,
                              border: Border(top: BorderSide(color: AppTheme.borderColor)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Servings:',
                                      style: TextStyle(color: CupertinoColors.white, fontSize: 19),
                                    ),
                                    Row(
                                      children: [
                                        CupertinoButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: servings.value > 0.25
                                              ? () => servings.value = (servings.value - 0.25)
                                                    .clamp(0.25, 10)
                                              : null,
                                          child: Icon(
                                            CupertinoIcons.minus_circle_fill,
                                            color: servings.value > 0.25
                                                ? AppTheme.buttonPrimary
                                                : AppTheme.buttonSecondary,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 60,
                                          child: Text(
                                            servings.value.toString(),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: CupertinoColors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        CupertinoButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () => servings.value = (servings.value + 0.25)
                                              .clamp(0.25, 10),
                                          child: const Icon(
                                            CupertinoIcons.plus_circle_fill,
                                            color: AppTheme.buttonPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: CupertinoButton(
                                    color: AppTheme.buttonPrimary,
                                    onPressed: () async {
                                      await ref
                                          .read(mealLogNotifierProvider.notifier)
                                          .addMealLog(
                                            recipeId: selectedRecipe.value!.id,
                                            consumedAt: date,
                                            servingsConsumed: servings.value,
                                          );
                                      if (context.mounted) Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Log Meal',
                                      style: TextStyle(color: AppTheme.backgroundColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (err, stack) => Center(
                child: Text('Error: $err', style: const TextStyle(color: CupertinoColors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
