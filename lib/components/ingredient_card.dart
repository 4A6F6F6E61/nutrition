import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutrition/components/macro_chip.dart';
import 'package:nutrition/models/ingredient.dart';
import 'package:nutrition/theme.dart';
import 'package:nutrition/utils/image_utils.dart';

class IngredientCard extends HookConsumerWidget {
  const IngredientCard({super.key, required this.ingredient});

  final Ingredient ingredient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    const placeholderColor = Color(0xFFE50914);
    const muted = CupertinoColors.systemGrey;

    final imageUrlFuture = useMemoized(
      () => getImageUrl(
        ref,
        buildImagePath(ingredient.userId, 'ingredients', ingredient.imagePath ?? ''),
      ),
    );
    final imageUrl = useFuture(imageUrlFuture).data;

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to ingredient detail/edit
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3C3C3E)),
        ),
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
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.cube_box_fill,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(CupertinoIcons.cube_box_fill, color: AppTheme.textPrimary),
                  ),
            const SizedBox(width: 16),

            // Name and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ingredient.name,
                    style: textTheme.textStyle.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${ingredient.calories?.toInt() ?? 0} kcal per 100g',
                    style: textTheme.textStyle.copyWith(fontSize: 14, color: muted),
                  ),
                  if (ingredient.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      ingredient.description!,
                      style: textTheme.textStyle.copyWith(fontSize: 14, color: muted),
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
                MacroChip(
                  label: 'P',
                  value: ingredient.protein ?? 0,
                  color: CupertinoColors.systemRed,
                ),
                const SizedBox(height: 4),
                MacroChip(
                  label: 'C',
                  value: ingredient.carbohydrates ?? 0,
                  color: CupertinoColors.systemBlue,
                ),
                const SizedBox(height: 4),
                MacroChip(
                  label: 'F',
                  value: ingredient.fat ?? 0,
                  color: CupertinoColors.systemOrange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
