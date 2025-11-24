import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutrition/models/meal_log.dart';
import 'package:nutrition/providers/supabase_providers.dart';

final mealLogsProvider = StreamProvider.family<List<MealLog>, DateTime>((
  ref,
  date,
) {
  final client = ref.watch(supabaseClientProvider);
  final session = ref.watch(sessionProvider).value;

  if (session == null) return Stream.value([]);

  final startOfDay = DateTime(date.year, date.month, date.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  return client
      .from('meal_logs')
      .stream(primaryKey: ['id'])
      .eq('user_id', session.user.id)
      .order('consumed_at', ascending: false)
      .map((data) {
        // Filter by date range in memory since stream doesn't support .gte/.lt
        return data.map((json) => MealLog.fromJson(json)).where((log) {
          return log.consumedAt.isAfter(
                startOfDay.subtract(const Duration(seconds: 1)),
              ) &&
              log.consumedAt.isBefore(endOfDay);
        }).toList();
      });
});

final dailyNutritionProvider = FutureProvider.family<DailyNutrition, DateTime>((
  ref,
  date,
) async {
  final client = ref.watch(supabaseClientProvider);
  final session = ref.watch(sessionProvider).value;

  if (session == null)
    return const DailyNutrition(
      totalCalories: 0,
      totalProtein: 0,
      totalCarbs: 0,
      totalFat: 0,
    );

  final response = await client
      .from('daily_nutrition')
      .select()
      .eq('user_id', session.user.id)
      .eq('log_date', date.toIso8601String().split('T')[0])
      .maybeSingle();

  if (response == null) {
    return const DailyNutrition(
      totalCalories: 0,
      totalProtein: 0,
      totalCarbs: 0,
      totalFat: 0,
    );
  }

  return DailyNutrition.fromJson(response);
});

final userPreferencesProvider = FutureProvider<UserPreferences>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final session = ref.watch(sessionProvider).value;

  if (session == null) {
    return const UserPreferences(
      userId: '',
      dailyCalorieGoal: 2000,
      dailyProteinGoal: 50,
      dailyCarbGoal: 250,
      dailyFatGoal: 70,
    );
  }

  final response = await client
      .from('user_preferences')
      .select()
      .eq('user_id', session.user.id)
      .maybeSingle();

  if (response == null) {
    // Create default preferences
    await client.from('user_preferences').insert({
      'user_id': session.user.id,
      'daily_calorie_goal': 2000,
      'daily_protein_goal': 50,
      'daily_carb_goal': 250,
      'daily_fat_goal': 70,
    });

    return const UserPreferences(
      userId: '',
      dailyCalorieGoal: 2000,
      dailyProteinGoal: 50,
      dailyCarbGoal: 250,
      dailyFatGoal: 70,
    );
  }

  return UserPreferences.fromJson(response);
});

class MealLogNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> addMealLog({
    required String recipeId,
    required DateTime consumedAt,
    required double servingsConsumed,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final client = ref.read(supabaseClientProvider);
      final session = ref.read(sessionProvider).value;

      if (session == null) throw Exception('Not authenticated');

      await client.from('meal_logs').insert({
        'user_id': session.user.id,
        'recipe_id': recipeId,
        'consumed_at': consumedAt.toIso8601String(),
        'servings_consumed': servingsConsumed,
        'notes': notes,
      });

      final date = DateTime(consumedAt.year, consumedAt.month, consumedAt.day);
      ref.invalidate(mealLogsProvider(date));
      ref.invalidate(dailyNutritionProvider(date));
    });
  }

  Future<void> deleteMealLog(String id, DateTime date) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final client = ref.read(supabaseClientProvider);
      await client.from('meal_logs').delete().eq('id', id);

      ref.invalidate(mealLogsProvider(date));
      ref.invalidate(dailyNutritionProvider(date));
    });
  }
}

final mealLogNotifierProvider =
    NotifierProvider<MealLogNotifier, AsyncValue<void>>(MealLogNotifier.new);
