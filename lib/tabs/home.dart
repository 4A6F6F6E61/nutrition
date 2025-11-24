import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutrition/components/calorie_progress.dart';
import 'package:nutrition/components/macros_breakdown.dart';
import 'package:nutrition/components/meal_log_card.dart';
import 'package:nutrition/providers/meal_log_provider.dart';
import 'package:nutrition/sheets/add_meal.dart';
import 'package:nutrition/util.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedDate = useState(DateTime.now());
    final pageController = usePageController();
    final currentPage = useState(0);

    final prefsAsync = ref.watch(userPreferencesProvider);
    final nutritionAsync = ref.watch(
      dailyNutritionProvider(selectedDate.value),
    );
    final mealLogsAsync = ref.watch(mealLogsProvider(selectedDate.value));

    useEffect(() {
      void listener() {
        currentPage.value = pageController.page?.round() ?? 0;
      }

      pageController.addListener(listener);
      return () => pageController.removeListener(listener);
    }, [pageController]);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Date selector header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      selectedDate.value = selectedDate.value.subtract(
                        const Duration(days: 1),
                      );
                    },
                  ),
                  Text(
                    formatDate(selectedDate.value, showWeekday: true),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: selectedDate.value.isBefore(DateTime.now())
                        ? () {
                            selectedDate.value = selectedDate.value.add(
                              const Duration(days: 1),
                            );
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),

          // Carousel with progress circles
          SliverToBoxAdapter(
            child: SizedBox(
              height: 260,
              child: prefsAsync.when(
                data: (prefs) => nutritionAsync.when(
                  data: (nutrition) => Column(
                    children: [
                      Expanded(
                        child: PageView(
                          controller: pageController,
                          children: [
                            // Page 1: Calorie progress
                            CalorieProgress(
                              current: nutrition.totalCalories,
                              goal: prefs.dailyCalorieGoal.toDouble(),
                              colorScheme: colorScheme,
                            ),
                            // Page 2: Macros breakdown
                            MacrosBreakdown(
                              protein: nutrition.totalProtein,
                              proteinGoal: prefs.dailyProteinGoal,
                              carbs: nutrition.totalCarbs,
                              carbsGoal: prefs.dailyCarbGoal,
                              fat: nutrition.totalFat,
                              fatGoal: prefs.dailyFatGoal,
                              colorScheme: colorScheme,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          2,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentPage.value == index
                                  ? colorScheme.primary
                                  : colorScheme.outlineVariant,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ),

          // Section header
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'TODAY\'S MEALS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Meal logs list
          mealLogsAsync.when(
            data: (logs) => logs.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.restaurant_outlined,
                            size: 64,
                            color: colorScheme.outlineVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No meals logged today',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to log your first meal',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => MealLogCard(
                          log: logs[index],
                          date: selectedDate.value,
                        ),
                        childCount: logs.length,
                      ),
                    ),
                  ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('Error loading meals: $err')),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMealDialog(context, ref, selectedDate.value),
        icon: const Icon(Icons.add),
        label: const Text('Log Meal'),
      ),
    );
  }

  void _showAddMealDialog(BuildContext context, WidgetRef ref, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => AddMealSheet(date: date),
    );
  }
}
