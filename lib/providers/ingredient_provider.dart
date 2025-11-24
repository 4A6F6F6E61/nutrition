import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutrition/models/ingredient.dart';
import 'package:nutrition/providers/supabase_providers.dart';

final ingredientsProvider = StreamProvider<List<Ingredient>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final session = ref.watch(sessionProvider).value;

  if (session == null) return Stream.value([]);

  return client
      .from('ingredients')
      .stream(primaryKey: ['id'])
      .eq('user_id', session.user.id)
      .order('name')
      .map((data) => data.map((json) => Ingredient.fromJson(json)).toList());
});

final ingredientProvider = FutureProvider.family<Ingredient?, String>((
  ref,
  id,
) async {
  final client = ref.watch(supabaseClientProvider);
  final response = await client
      .from('ingredients')
      .select()
      .eq('id', id)
      .maybeSingle();

  if (response == null) return null;
  return Ingredient.fromJson(response);
});

class IngredientNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> addIngredient({
    required String name,
    String? description,
    String? imagePath,
    double? calories,
    double? protein,
    double? carbohydrates,
    double? fat,
    double? fiber,
    double? sugar,
    double? sodium,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final client = ref.read(supabaseClientProvider);
      final session = ref.read(sessionProvider).value;

      if (session == null) throw Exception('Not authenticated');

      await client.from('ingredients').insert({
        'user_id': session.user.id,
        'name': name,
        'description': description,
        'image_path': imagePath,
        'calories': calories,
        'protein': protein,
        'carbohydrates': carbohydrates,
        'fat': fat,
        'fiber': fiber,
        'sugar': sugar,
        'sodium': sodium,
      });

      ref.invalidate(ingredientsProvider);
    });
  }

  Future<void> updateIngredient(String id, Map<String, dynamic> updates) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final client = ref.read(supabaseClientProvider);
      await client.from('ingredients').update(updates).eq('id', id);
      ref.invalidate(ingredientsProvider);
    });
  }

  Future<void> deleteIngredient(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final client = ref.read(supabaseClientProvider);
      await client.from('ingredients').delete().eq('id', id);
      ref.invalidate(ingredientsProvider);
    });
  }
}

final ingredientNotifierProvider =
    NotifierProvider<IngredientNotifier, AsyncValue<void>>(
      IngredientNotifier.new,
    );
