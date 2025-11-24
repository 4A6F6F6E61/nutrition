import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutrition/models/recipe.dart';
import 'package:nutrition/providers/meal_log_provider.dart';
import 'package:nutrition/providers/recipe_provider.dart';

class AddMealSheet extends HookConsumerWidget {
  const AddMealSheet({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recipesAsync = ref.watch(recipesProvider);
    final selectedRecipe = useState<Recipe?>(null);
    final servings = useState(1.0);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Log Meal', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            recipesAsync.when(
              data: (recipes) => Expanded(
                child: recipes.isEmpty
                    ? const Center(
                        child: Text(
                          'No recipes yet. Add one in the Recipes tab!',
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: recipes.length,
                              itemBuilder: (context, index) {
                                final recipe = recipes[index];
                                final isSelected =
                                    selectedRecipe.value?.id == recipe.id;
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  color: isSelected
                                      ? theme.colorScheme.primaryContainer
                                      : theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                  child: ListTile(
                                    title: Text(recipe.name),
                                    subtitle: recipe.description != null
                                        ? Text(
                                            recipe.description!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : null,
                                    trailing: isSelected
                                        ? const Icon(Icons.check_circle)
                                        : null,
                                    onTap: () => selectedRecipe.value = recipe,
                                  ),
                                );
                              },
                            ),
                          ),
                          if (selectedRecipe.value != null) ...[
                            const Divider(),
                            Row(
                              children: [
                                const Text('Servings:'),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: servings.value > 0.25
                                      ? () => servings.value =
                                            (servings.value - 0.25).clamp(
                                              0.25,
                                              10,
                                            )
                                      : null,
                                ),
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    servings.value.toString(),
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => servings.value =
                                      (servings.value + 0.25).clamp(0.25, 10),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
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
                                child: const Text('Log Meal'),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
              loading: () => const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) =>
                  Expanded(child: Center(child: Text('Error: $err'))),
            ),
          ],
        ),
      ),
    );
  }
}
