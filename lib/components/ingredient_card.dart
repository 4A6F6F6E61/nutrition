import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutrition/components/macro_chip.dart';
import 'package:nutrition/models/ingredient.dart';
import 'package:nutrition/utils/image_utils.dart';

class IngredientCard extends HookConsumerWidget {
  const IngredientCard({super.key, required this.ingredient});

  final Ingredient ingredient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final imageUrlFuture = useMemoized(
      () => getImageUrl(
        ref,
        buildImagePath(ingredient.userId, 'ingredients', ingredient.imagePath ?? ''),
      ),
    );
    final imageUrl = useFuture(imageUrlFuture).data;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to ingredient detail/edit
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image
              ingredient.imagePath != null && imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.egg, color: colorScheme.onPrimaryContainer),
                        ),
                      ),
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.egg, color: colorScheme.onPrimaryContainer),
                    ),
              const SizedBox(width: 16),

              // Name and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ingredient.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${ingredient.calories?.toInt() ?? 0} kcal per 100g',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (ingredient.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        ingredient.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Macro summary
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MacroChip(label: 'P', value: ingredient.protein ?? 0, color: Colors.red),
                  const SizedBox(height: 4),
                  MacroChip(label: 'C', value: ingredient.carbohydrates ?? 0, color: Colors.blue),
                  const SizedBox(height: 4),
                  MacroChip(label: 'F', value: ingredient.fat ?? 0, color: Colors.orange),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
