import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/cupertino.dart';
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
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('Error'),
                  content: Text('Failed to upload image: $e'),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
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
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Error'),
              content: Text(message),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          return;
        }
      } catch (e) {
        if (context.mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Error'),
              content: Text('Error: $e'),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          return;
        }
      } finally {
        isUploading.value = false;
      }
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        children: [
          // Header with handle bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const SizedBox(width: 16),
                    const Text(
                      'New Recipe',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                    const Spacer(),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: const Icon(
                        CupertinoIcons.xmark_circle_fill,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Basic info
                _CupertinoTextField(controller: nameController, placeholder: 'Recipe name *'),
                const SizedBox(height: 12),
                _CupertinoTextField(
                  controller: descriptionController,
                  placeholder: 'Description',
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Image upload
                CupertinoButton(
                  color: const Color(0xFF2C2C2E),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      selectedImage.value = image;
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.photo, size: 20),
                      const SizedBox(width: 8),
                      Text(selectedImage.value == null ? 'Add Image' : 'Change Image'),
                    ],
                  ),
                ),
                if (selectedImage.value != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(selectedImage.value!.path),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Servings, prep time, cook time
                Row(
                  children: [
                    Expanded(
                      child: _CupertinoTextField(
                        controller: servingsController,
                        placeholder: 'Servings *',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CupertinoTextField(
                        controller: prepTimeController,
                        placeholder: 'Prep (min)',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CupertinoTextField(
                        controller: cookTimeController,
                        placeholder: 'Cook (min)',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Container(height: 1, color: const Color(0xFF3C3C3E)),
                const SizedBox(height: 16),

                // Ingredients section
                Row(
                  children: [
                    const Text(
                      'INGREDIENTS',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFFE50914),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      color: const Color(0xFFE50914),
                      child: const Row(
                        children: [
                          Icon(CupertinoIcons.plus, size: 18),
                          SizedBox(width: 4),
                          Text('Add', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      onPressed: () => ingredientsAsync.whenData((ingredients) {
                        if (ingredients.isEmpty) {
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: const Text('No ingredients'),
                              content: const Text('Add ingredients first in the Ingredients tab'),
                              actions: [
                                CupertinoDialogAction(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          return;
                        }
                        _showIngredientPicker(context, ingredients, selectedIngredients);
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (selectedIngredients.value.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    child: const Center(
                      child: Text(
                        'No ingredients added',
                        style: TextStyle(color: CupertinoColors.systemGrey),
                      ),
                    ),
                  )
                else
                  ...selectedIngredients.value.map(
                    (entry) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.ingredient.name,
                                  style: const TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${entry.amountGrams}g',
                                  style: const TextStyle(
                                    color: CupertinoColors.systemGrey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              selectedIngredients.value = selectedIngredients.value
                                  .where((e) => e.ingredient.id != entry.ingredient.id)
                                  .toList();
                            },
                            child: const Icon(
                              CupertinoIcons.xmark_circle_fill,
                              color: Color(0xFFE50914),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
                Container(height: 1, color: const Color(0xFF3C3C3E)),
                const SizedBox(height: 16),

                // Steps section
                Row(
                  children: [
                    const Text(
                      'COOKING STEPS',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFFE50914),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      color: const Color(0xFFE50914),
                      child: const Row(
                        children: [
                          Icon(CupertinoIcons.plus, size: 18),
                          SizedBox(width: 4),
                          Text('Add Step', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      onPressed: () {
                        steps.value = [...steps.value, ''];
                      },
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
                          decoration: const BoxDecoration(
                            color: Color(0xFFE50914),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CupertinoTextField(
                            placeholder: 'Step instruction',
                            maxLines: 2,
                            onChanged: (value) {
                              final newSteps = [...steps.value];
                              newSteps[index] = value;
                              steps.value = newSteps;
                            },
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: steps.value.length > 1
                              ? () {
                                  steps.value = steps.value
                                      .where((s) => s != steps.value[index])
                                      .toList();
                                }
                              : null,
                          child: Icon(
                            CupertinoIcons.xmark_circle_fill,
                            color: steps.value.length > 1
                                ? const Color(0xFFE50914)
                                : CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: const Color(0xFFE50914),
                    onPressed: isUploading.value ? null : submit,
                    child: isUploading.value
                        ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                        : const Text('Create Recipe'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showIngredientPicker(
    BuildContext context,
    List<Ingredient> ingredients,
    ValueNotifier<List<_IngredientEntry>> selected,
  ) {
    showCupertinoModalPopup(
      context: context,
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

class _CupertinoTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String placeholder;
  final int maxLines;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const _CupertinoTextField({
    this.controller,
    required this.placeholder,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(8),
      ),
      style: const TextStyle(color: CupertinoColors.white),
      placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey),
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }
}
