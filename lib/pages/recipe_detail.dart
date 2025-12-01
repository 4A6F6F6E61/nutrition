import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutrition/models/recipe.dart';
import 'package:nutrition/models/ingredient.dart';
import 'package:nutrition/providers/recipe_provider.dart';
import 'package:nutrition/providers/ingredient_provider.dart';
import 'package:nutrition/providers/meal_log_provider.dart';
import 'package:nutrition/utils/image_utils.dart';

class RecipeDetailPage extends HookConsumerWidget {
  const RecipeDetailPage({super.key, required this.recipeId});

  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeAsync = ref.watch(recipeProvider(recipeId));
    final ingredientsAsync = ref.watch(recipeIngredientsProvider(recipeId));
    final stepsAsync = ref.watch(cookingStepsProvider(recipeId));
    final allUserIngredientsAsync = ref.watch(ingredientsProvider);

    return Scaffold(
      body: recipeAsync.when(
        data: (recipe) {
          if (recipe == null) {
            return const Center(child: Text('Recipe not found'));
          }
          return _RecipeDetailContent(
            recipe: recipe,
            ingredientsAsync: ingredientsAsync,
            stepsAsync: stepsAsync,
            allIngredientsAsync: allUserIngredientsAsync,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: recipeAsync.maybeWhen(
        data: (recipe) => recipe == null
            ? null
            : FloatingActionButton.extended(
                onPressed: () => _showLogMealSheet(context, ref, recipe),
                icon: const Icon(Icons.add),
                label: const Text('Log Meal'),
              ),
        orElse: () => null,
      ),
    );
  }

  void _showLogMealSheet(BuildContext context, WidgetRef ref, Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _LogMealSheet(recipe: recipe),
    );
  }
}

class _RecipeDetailContent extends HookConsumerWidget {
  const _RecipeDetailContent({
    required this.recipe,
    required this.ingredientsAsync,
    required this.stepsAsync,
    required this.allIngredientsAsync,
  });

  final Recipe recipe;
  final AsyncValue<List<RecipeIngredient>> ingredientsAsync;
  final AsyncValue<List<CookingStep>> stepsAsync;
  final AsyncValue<List<Ingredient>> allIngredientsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Build nutrition summary once data loaded
    final nutrition = useMemoized(() {
      if (!ingredientsAsync.hasValue || !allIngredientsAsync.hasValue) {
        return _NutritionTotals.empty();
      }
      final ingredientRows = ingredientsAsync.value!;
      final userIngredients = {for (final ing in allIngredientsAsync.value!) ing.id: ing};
      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;
      double totalFiber = 0;
      double totalGrams = 0;
      for (final row in ingredientRows) {
        final base = userIngredients[row.ingredientId];
        if (base == null) continue;
        final factor = row.amountGrams / 100.0;
        totalCalories += (base.calories ?? 0) * factor;
        totalProtein += (base.protein ?? 0) * factor;
        totalCarbs += (base.carbohydrates ?? 0) * factor;
        totalFat += (base.fat ?? 0) * factor;
        totalFiber += (base.fiber ?? 0) * factor;
        totalGrams += row.amountGrams;
      }
      return _NutritionTotals(
        calories: totalCalories,
        protein: totalProtein,
        carbs: totalCarbs,
        fat: totalFat,
        fiber: totalFiber,
        servings: recipe.servings,
        totalGrams: totalGrams,
      );
    }, [ingredientsAsync, allIngredientsAsync, recipe.servings]);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 260,
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
          flexibleSpace: FlexibleSpaceBar(
            background: recipe.imagePath == null
                ? Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primaryContainer, colorScheme.secondaryContainer],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 96,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  )
                : FutureBuilder<String>(
                    future: getImageUrl(
                      ref,
                      buildImagePath(recipe.userId, 'recipes', recipe.imagePath!),
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primaryContainer,
                                colorScheme.secondaryContainer,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.restaurant,
                              size: 96,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        );
                      }
                      return Hero(
                        tag: 'recipe_image_${recipe.id}',
                        child: CachedNetworkImage(
                          imageUrl: snapshot.data!,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => Container(
                            color: colorScheme.primaryContainer,
                            child: Center(
                              child: Icon(
                                Icons.restaurant,
                                size: 96,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (recipe.description != null && recipe.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    recipe.description!,
                    style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _InfoChip(icon: Icons.restaurant_menu, label: '${recipe.servings} servings'),
                    if (recipe.prepTimeMinutes != null)
                      _InfoChip(
                        icon: Icons.cleaning_services,
                        label: '${recipe.prepTimeMinutes} prep',
                      ),
                    if (recipe.cookTimeMinutes != null)
                      _InfoChip(icon: Icons.schedule, label: '${recipe.cookTimeMinutes} cook'),
                  ],
                ),
                const SizedBox(height: 24),
                _NutritionSection(nutrition: nutrition, colorScheme: colorScheme, theme: theme),
                const SizedBox(height: 24),
                Text(
                  'INGREDIENTS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        ingredientsAsync.when(
          data: (rows) => allIngredientsAsync.when(
            data: (all) => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final row = rows[index];
                  final ing = all.firstWhere(
                    (i) => i.id == row.ingredientId,
                    orElse: () => _dummyIngredient,
                  );
                  final factor = row.amountGrams / 100.0;
                  final calories = (ing.calories ?? 0) * factor;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(ing.name),
                    subtitle: Text(
                      '${row.amountGrams.toStringAsFixed(0)} g • ${calories.toStringAsFixed(0)} kcal',
                    ),
                  );
                }, childCount: rows.length),
              ),
            ),
            loading: () =>
                const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (e, st) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
          ),
          loading: () =>
              const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
          error: (e, st) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              'STEPS',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        stepsAsync.when(
          data: (steps) => SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final step = steps[index];
                return _StepTile(step: step, index: index);
              }, childCount: steps.length),
            ),
          ),
          loading: () =>
              const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
          error: (e, st) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.primary),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _NutritionTotals {
  const _NutritionTotals({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.servings,
    required this.totalGrams,
  });
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final int servings;
  final double totalGrams;
  factory _NutritionTotals.empty() => const _NutritionTotals(
    calories: 0,
    protein: 0,
    carbs: 0,
    fat: 0,
    fiber: 0,
    servings: 1,
    totalGrams: 0,
  );
  double get caloriesPerServing => calories / servings;
  double get proteinPerServing => protein / servings;
  double get carbsPerServing => carbs / servings;
  double get fatPerServing => fat / servings;
  double get fiberPerServing => fiber / servings;
  double get _per100Factor => totalGrams > 0 ? 100 / totalGrams : 0;
  double get caloriesPer100g => calories * _per100Factor;
  double get proteinPer100g => protein * _per100Factor;
  double get carbsPer100g => carbs * _per100Factor;
  double get fatPer100g => fat * _per100Factor;
  double get fiberPer100g => fiber * _per100Factor;
}

class _NutritionSection extends HookWidget {
  const _NutritionSection({
    required this.nutrition,
    required this.colorScheme,
    required this.theme,
  });
  final _NutritionTotals nutrition;
  final ColorScheme colorScheme;
  final ThemeData theme;
  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialIndex: 0, initialLength: 3);
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: tabController,
            labelColor: colorScheme.onSurface,
            indicatorColor: colorScheme.primary,
            tabs: const [
              Tab(text: 'Per Serving'),
              Tab(text: 'Total'),
              Tab(text: 'Per 100g'),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 140,
              child: TabBarView(
                controller: tabController,
                children: [
                  _NutritionView(
                    title: 'Nutrition (per serving)',
                    colorScheme: colorScheme,
                    theme: theme,
                    calories: nutrition.caloriesPerServing,
                    protein: nutrition.proteinPerServing,
                    carbs: nutrition.carbsPerServing,
                    fat: nutrition.fatPerServing,
                    fiber: nutrition.fiberPerServing,
                  ),
                  _NutritionView(
                    title: 'Total (whole recipe)',
                    colorScheme: colorScheme,
                    theme: theme,
                    calories: nutrition.calories,
                    protein: nutrition.protein,
                    carbs: nutrition.carbs,
                    fat: nutrition.fat,
                    fiber: nutrition.fiber,
                  ),
                  _NutritionView(
                    title: 'Nutrition (per 100g)',
                    colorScheme: colorScheme,
                    theme: theme,
                    calories: nutrition.caloriesPer100g,
                    protein: nutrition.proteinPer100g,
                    carbs: nutrition.carbsPer100g,
                    fat: nutrition.fatPer100g,
                    fiber: nutrition.fiberPer100g,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _nutriTile(String label, double value, {required String suffix, required Color color}) {
  return SizedBox(
    width: 110,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text('${value.toStringAsFixed(0)} $suffix'),
          ],
        ),
      ],
    ),
  );
}

class _NutritionView extends StatelessWidget {
  const _NutritionView({
    required this.title,
    required this.colorScheme,
    required this.theme,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });
  final String title;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            _nutriTile('Calories', calories, suffix: 'kcal', color: colorScheme.primary),
            _nutriTile('Protein', protein, suffix: 'g', color: Colors.red),
            _nutriTile('Carbs', carbs, suffix: 'g', color: Colors.blue),
            _nutriTile('Fat', fat, suffix: 'g', color: Colors.orange),
            _nutriTile('Fiber', fiber, suffix: 'g', color: Colors.green),
          ],
        ),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.step, required this.index});
  final CookingStep step;
  final int index;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: colorScheme.primaryContainer, shape: BoxShape.circle),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.instruction, style: theme.textTheme.bodyLarge),
                if (step.durationMinutes != null) ...[
                  const SizedBox(height: 4),
                  Text('${step.durationMinutes} min', style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogMealSheet extends HookConsumerWidget {
  const _LogMealSheet({required this.recipe});
  final Recipe recipe;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servings = useState<double>(1);
    final date = DateTime.now();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      snap: true,
      snapSizes: const [0.5, 0.8],
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Log Meal', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(recipe.name, style: theme.textTheme.titleMedium),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('Servings:'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: servings.value > 0.25
                      ? () => servings.value = (servings.value - 0.25).clamp(0.25, 20)
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
                  onPressed: () => servings.value = (servings.value + 0.25).clamp(0.25, 20),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  await ref
                      .read(mealLogNotifierProvider.notifier)
                      .addMealLog(
                        recipeId: recipe.id,
                        consumedAt: date,
                        servingsConsumed: servings.value,
                      );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Log Meal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _dummyIngredient = Ingredient(
  id: '',
  userId: '',
  name: 'Unknown',
  description: null,
  imagePath: null,
  calories: 0,
  protein: 0,
  carbohydrates: 0,
  fat: 0,
  fiber: 0,
  sugar: 0,
  sodium: 0,
  createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
);
