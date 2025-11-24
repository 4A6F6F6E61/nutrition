import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutrition/sheets/ingredient_picker.dart';
import 'package:nutrition/models/ingredient.dart';
import 'package:nutrition/providers/ingredient_provider.dart';
import 'package:nutrition/providers/recipe_provider.dart';
import 'package:nutrition/providers/supabase_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _IngredientEntry {
  final Ingredient ingredient;
  final double amountGrams;

  _IngredientEntry({required this.ingredient, required this.amountGrams});
}

class AddRecipeSheet extends HookConsumerWidget {
  const AddRecipeSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final servingsController = useTextEditingController(text: '4');
    final prepTimeController = useTextEditingController();
    final cookTimeController = useTextEditingController();

    final selectedIngredients = useState<List<_IngredientEntry>>([]);
    final steps = useState<List<String>>(['']);
    final selectedImage = useState<XFile?>(null);
    final isUploading = useState(false);

    final ingredientsAsync = ref.watch(ingredientsProvider);

    Future<void> submit() async {
      try {
        if (nameController.text.isEmpty) {
          throw "Please enter a recipe name";
        }

        final servings = int.tryParse(servingsController.text);
        if (servings == null || servings <= 0) {
          throw 'Please enter valid servings';
        }

        if (selectedIngredients.value.isEmpty) {
          throw 'Please add at least one ingredient';
        }

        if (steps.value.isEmpty || steps.value.every((s) => s.trim().isEmpty)) {
          throw 'Please add at least one cooking step';
        }

        isUploading.value = true;
        String? uploadedImageFileName;

        // Upload image if selected
        if (selectedImage.value != null) {
          try {
            final client = ref.read(supabaseClientProvider);
            final session = ref.read(sessionProvider).value;
            if (session != null) {
              final rawBytes = await File(selectedImage.value!.path).readAsBytes();
              final decodedImage = img.decodeImage(rawBytes);
              if (decodedImage == null) throw 'Failed to process image';
              final compressedBytes = img.encodeJpg(decodedImage, quality: 80);

              final time = DateTime.now().millisecondsSinceEpoch;

              await client.storage
                  .from('nutrition-images')
                  .uploadBinary(
                    '${session.user.id}/recipes/$time.jpg',
                    compressedBytes,
                    fileOptions: const FileOptions(contentType: 'image/jpeg'),
                  );

              uploadedImageFileName = time.toString();
            }
          } catch (e) {
            isUploading.value = false;
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
            }
            return;
          }
        }

        await ref
            .read(recipeNotifierProvider.notifier)
            .addRecipe(
              name: nameController.text,
              description: descriptionController.text.isEmpty ? null : descriptionController.text,
              servings: servings,
              prepTimeMinutes: int.tryParse(prepTimeController.text),
              cookTimeMinutes: int.tryParse(cookTimeController.text),
              imagePath: uploadedImageFileName,
              ingredients: selectedIngredients.value
                  .map(
                    (e) => {
                      'ingredient_id': e.ingredient.id,
                      'amount_grams': e.amountGrams,
                      'notes': null,
                    },
                  )
                  .toList(),
              steps: steps.value.where((s) => s.trim().isNotEmpty).toList(),
            );

        isUploading.value = false;
        if (context.mounted) context.pop();
      } on String catch (message) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
          return;
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
          return;
        }
      } finally {
        isUploading.value = false;
      }
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      snap: true,
      snapSizes: const [0.6, 0.95],
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Text('New Recipe', style: theme.textTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                children: [
                  // Basic info
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Recipe name *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  // Image upload
                  OutlinedButton.icon(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        selectedImage.value = image;
                      }
                    },
                    icon: const Icon(Icons.image),
                    label: Text(selectedImage.value == null ? 'Add Image' : 'Change Image'),
                  ),
                  if (selectedImage.value != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(selectedImage.value!.path),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: servingsController,
                          decoration: const InputDecoration(
                            labelText: 'Servings *',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: prepTimeController,
                          decoration: const InputDecoration(
                            labelText: 'Prep (min)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: cookTimeController,
                          decoration: const InputDecoration(
                            labelText: 'Cook (min)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Ingredients section
                  Row(
                    children: [
                      Text('INGREDIENTS', style: theme.textTheme.labelLarge),
                      const Spacer(),
                      FilledButton.tonalIcon(
                        onPressed: () => ingredientsAsync.whenData((ingredients) {
                          if (ingredients.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Add ingredients first in the Ingredients tab'),
                              ),
                            );
                            return;
                          }
                          _showIngredientPicker(context, ingredients, selectedIngredients);
                        }),
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (selectedIngredients.value.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'No ingredients added',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    ...selectedIngredients.value.map(
                      (entry) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(entry.ingredient.name),
                          subtitle: Text('${entry.amountGrams}g'),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              selectedIngredients.value = selectedIngredients.value
                                  .where((e) => e.ingredient.id != entry.ingredient.id)
                                  .toList();
                            },
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Steps section
                  Row(
                    children: [
                      Text('COOKING STEPS', style: theme.textTheme.labelLarge),
                      const Spacer(),
                      FilledButton.tonalIcon(
                        onPressed: () {
                          steps.value = [...steps.value, ''];
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Step'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(steps.value.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
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
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Step instruction',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                              onChanged: (value) {
                                final newSteps = [...steps.value];
                                newSteps[index] = value;
                                steps.value = newSteps;
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: steps.value.length > 1
                                ? () {
                                    steps.value = steps.value
                                        .where((s) => s != steps.value[index])
                                        .toList();
                                  }
                                : null,
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: submit,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: isUploading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Create Recipe'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showIngredientPicker(
    BuildContext context,
    List<Ingredient> ingredients,
    ValueNotifier<List<_IngredientEntry>> selected,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => IngredientPicker(
        ingredients: ingredients,
        onSelect: (ingredient, amount) {
          selected.value = [
            ...selected.value,
            _IngredientEntry(ingredient: ingredient, amountGrams: amount),
          ];
        },
      ),
    );
  }
}
