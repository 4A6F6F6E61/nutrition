import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:nutrition/providers/ingredient_provider.dart';
import 'package:nutrition/providers/supabase_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _CupertinoTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String placeholder;
  final int maxLines;
  final TextInputType keyboardType;

  const _CupertinoTextField({
    this.controller,
    required this.placeholder,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
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
    );
  }
}

class AddIngredientSheet extends HookConsumerWidget {
  const AddIngredientSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      'Add Ingredient',
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
                _CupertinoTextField(controller: nameController, placeholder: 'Ingredient name *'),
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
                Container(height: 1, color: const Color(0xFF3C3C3E)),
                const SizedBox(height: 16),

                const Text(
                  'NUTRITION (per 100g)',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFE50914),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // Calories
                _CupertinoTextField(
                  controller: caloriesController,
                  placeholder: 'Calories (kcal) *',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),

                // Macros row 1
                Row(
                  children: [
                    Expanded(
                      child: _CupertinoTextField(
                        controller: proteinController,
                        placeholder: 'Protein (g) *',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CupertinoTextField(
                        controller: carbsController,
                        placeholder: 'Carbs (g) *',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CupertinoTextField(
                        controller: fatController,
                        placeholder: 'Fat (g) *',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Macros row 2
                Row(
                  children: [
                    Expanded(
                      child: _CupertinoTextField(
                        controller: fiberController,
                        placeholder: 'Fiber (g)',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CupertinoTextField(
                        controller: sugarController,
                        placeholder: 'Sugar (g)',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CupertinoTextField(
                        controller: sodiumController,
                        placeholder: 'Sodium (mg)',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: const Color(0xFFE50914),
                    onPressed: isUploading.value
                        ? null
                        : () async {
                            // Validation
                            if (nameController.text.isEmpty) {
                              showCupertinoDialog(
                                context: context,
                                builder: (context) => CupertinoAlertDialog(
                                  title: const Text('Error'),
                                  content: const Text('Please enter an ingredient name'),
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

                            final calories = double.tryParse(caloriesController.text);
                            final protein = double.tryParse(proteinController.text);
                            final carbs = double.tryParse(carbsController.text);
                            final fat = double.tryParse(fatController.text);

                            if (calories == null ||
                                protein == null ||
                                carbs == null ||
                                fat == null) {
                              showCupertinoDialog(
                                context: context,
                                builder: (context) => CupertinoAlertDialog(
                                  title: const Text('Error'),
                                  content: const Text(
                                    'Please fill in all required nutrition fields',
                                  ),
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

                            isUploading.value = true;
                            String? uploadedImageFileName;

                            // Upload image if selected
                            if (selectedImage.value != null) {
                              try {
                                final client = ref.read(supabaseClientProvider);
                                final session = ref.read(sessionProvider).value;
                                if (session != null) {
                                  final rawBytes = await File(
                                    selectedImage.value!.path,
                                  ).readAsBytes();
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
                    child: isUploading.value
                        ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                        : const Text('Add Ingredient'),
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
}
