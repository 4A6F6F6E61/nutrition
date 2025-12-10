import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ColorScheme;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutrition/components/calorie_progress.dart';
import 'package:nutrition/components/macros_breakdown.dart';
import 'package:nutrition/components/meal_log_card.dart';
import 'package:nutrition/providers/meal_log_provider.dart';
import 'package:nutrition/sheets/add_meal.dart';
import 'package:nutrition/theme.dart';
import 'package:nutrition/util.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = useState(DateTime.now());
    final pageController = usePageController();
    final currentPage = useState(0);

    // Create a ColorScheme for components that still need it
    final colorScheme = ColorScheme.dark(
      primary: const Color(0xFFE50914),
      surfaceContainerHighest: const Color(0xFF2C2C2E),
      onSurfaceVariant: CupertinoColors.systemGrey.color,
    );

    final prefsAsync = ref.watch(userPreferencesProvider);
    final nutritionAsync = ref.watch(dailyNutritionProvider(selectedDate.value));
    final mealLogsAsync = ref.watch(mealLogsProvider(selectedDate.value));

    useEffect(() {
      void listener() {
        currentPage.value = pageController.page?.round() ?? 0;
      }

      pageController.addListener(listener);
      return () => pageController.removeListener(listener);
    }, [pageController]);

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF000000),
      child: CustomScrollView(
        slivers: [
          // Navigation bar with title and add button
          CupertinoSliverNavigationBar(
            backgroundColor: const Color(0xFF141414),
            largeTitle: const Text('Home'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showAddMealDialog(context, ref, selectedDate.value),
              child: const Icon(CupertinoIcons.add, color: AppTheme.buttonPrimary, size: 28),
            ),
          ),

          // Date selector
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      selectedDate.value = selectedDate.value.subtract(const Duration(days: 1));
                    },
                    child: const Icon(CupertinoIcons.chevron_left, color: CupertinoColors.white),
                  ),
                  Text(
                    formatDate(selectedDate.value, showWeekday: true),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: selectedDate.value.isBefore(DateTime.now())
                        ? () {
                            selectedDate.value = selectedDate.value.add(const Duration(days: 1));
                          }
                        : null,
                    child: Icon(
                      CupertinoIcons.chevron_right,
                      color: selectedDate.value.isBefore(DateTime.now())
                          ? CupertinoColors.white
                          : CupertinoColors.systemGrey,
                    ),
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
                                  ? const Color(0xFFE50914)
                                  : CupertinoColors.systemGrey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                  loading: () => const Center(child: CupertinoActivityIndicator()),
                  error: (err, stack) => Center(
                    child: Text('Error: $err', style: TextStyle(color: CupertinoColors.white)),
                  ),
                ),
                loading: () => const Center(child: CupertinoActivityIndicator()),
                error: (err, stack) => Center(
                  child: Text('Error: $err', style: TextStyle(color: CupertinoColors.white)),
                ),
              ),
            ),
          ),

          // Section header
          SliverPadding(
            padding: .all(16),
            sliver: SliverToBoxAdapter(child: Text('TODAY\'S MEALS')),
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
                            CupertinoIcons.square_list,
                            size: 64,
                            color: CupertinoColors.systemGrey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No meals logged today',
                            style: const TextStyle(fontSize: 18, color: CupertinoColors.systemGrey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to log your first meal',
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final bottomPadding = index == logs.length - 1 ? 0.0 : 12.0;
                        return Padding(
                          padding: EdgeInsets.only(bottom: bottomPadding),
                          child: MealLogCard(log: logs[index], date: selectedDate.value),
                        );
                      }, childCount: logs.length),
                    ),
                  ),
            loading: () =>
                const SliverFillRemaining(child: Center(child: CupertinoActivityIndicator())),
            error: (err, stack) => SliverFillRemaining(
              child: Center(
                child: Text(
                  'Error loading meals: $err',
                  style: TextStyle(color: CupertinoColors.white),
                ),
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }

  void _showAddMealDialog(BuildContext context, WidgetRef ref, DateTime date) {
    showCupertinoSheet(
      context: context,
      builder: (context) => AddMealSheet(date: date),
    );
  }
}
