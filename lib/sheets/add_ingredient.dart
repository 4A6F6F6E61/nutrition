import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:nutrition/providers/ingredient_provider.dart';
import 'package:nutrition/providers/supabase_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddIngredientSheet extends HookConsumerWidget {
  const AddIngredientSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final caloriesController = useTextEditingController();
    final proteinController = useTextEditingController();
    final carbsController = useTextEditingController();
    final fatController = useTextEditingController();
    final fiberController = useTextEditingController();
    final sugarController = useTextEditingController();
    final sodiumController = useTextEditingController();
    final selectedImage = useState<XFile?>(null);
    final isUploading = useState(false);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      snap: true,
      snapSizes: const [0.6, 0.9],
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
                  Text('Add Ingredient', style: theme.textTheme.titleLarge),
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
                      labelText: 'Ingredient name *',
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

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  Text(
                    'NUTRITION (per 100g)',
                    style: theme.textTheme.labelLarge?.copyWith(color: colorScheme.primary),
                  ),
                  const SizedBox(height: 16),

                  // Calories
                  TextField(
                    controller: caloriesController,
                    decoration: const InputDecoration(
                      labelText: 'Calories (kcal) *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  ),
                  const SizedBox(height: 16),

                  // Macros row 1
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: proteinController,
                          decoration: const InputDecoration(
                            labelText: 'Protein (g) *',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: carbsController,
                          decoration: const InputDecoration(
                            labelText: 'Carbs (g) *',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: fatController,
                          decoration: const InputDecoration(
                            labelText: 'Fat (g) *',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Macros row 2
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: fiberController,
                          decoration: const InputDecoration(
                            labelText: 'Fiber (g)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: sugarController,
                          decoration: const InputDecoration(
                            labelText: 'Sugar (g)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: sodiumController,
                          decoration: const InputDecoration(
                            labelText: 'Sodium (mg)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        // Validation
                        if (nameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter an ingredient name')),
                          );
                          return;
                        }

                        final calories = double.tryParse(caloriesController.text);
                        final protein = double.tryParse(proteinController.text);
                        final carbs = double.tryParse(carbsController.text);
                        final fat = double.tryParse(fatController.text);

                        if (calories == null || protein == null || carbs == null || fat == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in all required nutrition fields'),
                            ),
                          );
                          return;
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
                                    '${session.user.id}/ingredients/$time.jpg',
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
                            .read(ingredientNotifierProvider.notifier)
                            .addIngredient(
                              name: nameController.text,
                              description: descriptionController.text.isEmpty
                                  ? null
                                  : descriptionController.text,
                              imagePath: uploadedImageFileName,
                              calories: calories,
                              protein: protein,
                              carbohydrates: carbs,
                              fat: fat,
                              fiber: double.tryParse(fiberController.text),
                              sugar: double.tryParse(sugarController.text),
                              sodium: double.tryParse(sodiumController.text),
                            );

                        isUploading.value = false;
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: isUploading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Add Ingredient'),
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
}
