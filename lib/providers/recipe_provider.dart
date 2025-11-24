import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutrition/models/recipe.dart';
import 'package:nutrition/providers/supabase_providers.dart';

final recipesProvider = StreamProvider<List<Recipe>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final session = ref.watch(sessionProvider).value;

  if (session == null) return Stream.value([]);

  return client
      .from('recipes')
      .stream(primaryKey: ['id'])
      .eq('user_id', session.user.id)
      .order('created_at', ascending: false)
      .map((data) => data.map((json) => Recipe.fromJson(json)).toList());
});

final recipeProvider = FutureProvider.family<Recipe?, String>((ref, id) async {
  final client = ref.watch(supabaseClientProvider);
  final response = await client
      .from('recipes')
      .select()
      .eq('id', id)
      .maybeSingle();

  if (response == null) return null;
  return Recipe.fromJson(response);
});

final recipeIngredientsProvider =
    FutureProvider.family<List<RecipeIngredient>, String>((
      ref,
      recipeId,
    ) async {
      final client = ref.watch(supabaseClientProvider);
      final response = await client
          .from('recipe_ingredients')
          .select()
          .eq('recipe_id', recipeId);

      return response.map((json) => RecipeIngredient.fromJson(json)).toList();
    });

final cookingStepsProvider = FutureProvider.family<List<CookingStep>, String>((
  ref,
  recipeId,
) async {
  final client = ref.watch(supabaseClientProvider);
  final response = await client
      .from('cooking_steps')
      .select()
      .eq('recipe_id', recipeId)
      .order('step_number');

  return response.map((json) => CookingStep.fromJson(json)).toList();
});

class RecipeNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<String> addRecipe({
    required String name,
    String? description,
    String? imagePath,
    required int servings,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    required List<Map<String, dynamic>> ingredients,
    required List<String> steps,
  }) async {
    state = const AsyncValue.loading();
    String recipeId = '';

    state = await AsyncValue.guard(() async {
      final client = ref.read(supabaseClientProvider);
      final session = ref.read(sessionProvider).value;

      if (session == null) throw Exception('Not authenticated');

      // Insert recipe
      final recipeResponse = await client
          .from('recipes')
          .insert({
            'user_id': session.user.id,
            'name': name,
            'description': description,
            'image_path': imagePath,
            'servings': servings,
            'prep_time_minutes': prepTimeMinutes,
            'cook_time_minutes': cookTimeMinutes,
          })
          .select()
          .single();

      recipeId = recipeResponse['id'] as String;

      // Insert ingredients
      if (ingredients.isNotEmpty) {
        final ingredientInserts = ingredients
            .map(
              (ing) => {
                'recipe_id': recipeId,
                'ingredient_id': ing['ingredient_id'],
                'amount_grams': ing['amount_grams'],
                'notes': ing['notes'],
              },
            )
            .toList();
        await client.from('recipe_ingredients').insert(ingredientInserts);
      }

      // Insert steps
      if (steps.isNotEmpty) {
        final stepInserts = steps
            .asMap()
            .entries
            .map(
              (entry) => {
                'recipe_id': recipeId,
                'step_number': entry.key + 1,
                'instruction': entry.value,
              },
            )
            .toList();
        await client.from('cooking_steps').insert(stepInserts);
      }

      ref.invalidate(recipesProvider);
    });

    return recipeId;
  }

  Future<void> deleteRecipe(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final client = ref.read(supabaseClientProvider);
      await client.from('recipes').delete().eq('id', id);
      ref.invalidate(recipesProvider);
    });
  }
}

final recipeNotifierProvider =
    NotifierProvider<RecipeNotifier, AsyncValue<void>>(RecipeNotifier.new);
