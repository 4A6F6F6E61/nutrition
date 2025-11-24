import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutrition/models/ingredient.dart';
import 'package:nutrition/utils/image_utils.dart';

class IngredientPicker extends StatefulHookConsumerWidget {
  const IngredientPicker({super.key, required this.ingredients, required this.onSelect});

  final List<Ingredient> ingredients;
  final void Function(Ingredient ingredient, double amount) onSelect;

  @override
  ConsumerState<IngredientPicker> createState() => _IngredientPickerSheetState();
}

class _IngredientPickerSheetState extends ConsumerState<IngredientPicker> {
  Ingredient? selectedIngredient;
  final amountController = TextEditingController(text: '100');

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final imageUrlFuture = useMemoized(
      () => getImageUrl(
        ref,
        buildImagePath(
          selectedIngredient?.userId ?? '',
          'ingredients',
          selectedIngredient?.imagePath ?? '',
        ),
      ),
    );
    final imageUrl = useFuture(imageUrlFuture).data;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      snap: true,
      snapSizes: const [0.5, 0.85],
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
                  Text('Select Ingredient', style: theme.textTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: widget.ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = widget.ingredients[index];
                  final isSelected = selectedIngredient?.id == ingredient.id;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: isSelected
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedIngredient = ingredient;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Image
                            ingredient.imagePath != null && imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, _, _) => Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.egg,
                                          color: colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.egg, color: colorScheme.onPrimaryContainer),
                                  ),
                            const SizedBox(width: 12),
                            // Name and info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ingredient.name,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${ingredient.calories?.toInt() ?? 0} kcal per 100g',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected) Icon(Icons.check_circle, color: colorScheme.primary),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (selectedIngredient != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount (grams)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          final amount = double.tryParse(amountController.text);
                          if (amount == null || amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a valid amount')),
                            );
                            return;
                          }
                          widget.onSelect(selectedIngredient!, amount);
                          Navigator.pop(context);
                        },
                        child: const Text('Add Ingredient'),
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
