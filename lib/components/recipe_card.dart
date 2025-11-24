import 'dart:developer' as dev;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutrition/models/recipe.dart';
import 'package:nutrition/utils/image_utils.dart';

class RecipeCard extends HookConsumerWidget {
  const RecipeCard({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final imageUrlFuture = useMemoized(
      () => getImageUrl(ref, buildImagePath(recipe.userId, 'recipes', recipe.imagePath ?? '')),
    );
    final imageUrl = useFuture(imageUrlFuture).data;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to recipe detail
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: recipe.imagePath != null && imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorWidget: (_, _, error) {
                        dev.log("Error loading image: $error");
                        return Container(
                          color: colorScheme.primaryContainer,
                          child: Center(
                            child: Icon(Icons.restaurant, size: 48, color: Colors.amber),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: colorScheme.primaryContainer,
                      child: Center(
                        child: Icon(
                          Icons.restaurant,
                          size: 48,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.restaurant_menu, size: 14, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.servings} servings',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (recipe.prepTimeMinutes != null || recipe.cookTimeMinutes != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 14, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(recipe.prepTimeMinutes, recipe.cookTimeMinutes),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int? prep, int? cook) {
    final total = (prep ?? 0) + (cook ?? 0);
    if (total == 0) return 'Quick';
    if (total < 60) return '${total}m';
    final hours = total ~/ 60;
    final mins = total % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }
}
