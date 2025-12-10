import 'dart:developer' as dev;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutrition/models/recipe.dart';
import 'package:nutrition/theme.dart';
import 'package:nutrition/utils/image_utils.dart';

class RecipeCard extends HookConsumerWidget {
  const RecipeCard({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = CupertinoTheme.of(context).textTheme;

    final imageUrlFuture = useMemoized(
      () => getImageUrl(ref, buildImagePath(recipe.userId, 'recipes', recipe.imagePath ?? '')),
    );
    final imageUrl = useFuture(imageUrlFuture).data;

    return GestureDetector(
      onTap: () {
        context.pushNamed('recipe_detail', pathParameters: {'id': recipe.id});
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: recipe.imagePath != null && imageUrl != null
                  ? Hero(
                      tag: 'recipe_image_${recipe.id}',
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorWidget: (_, __, error) {
                          dev.log("Error loading image: $error");
                          return Container(
                            color: AppTheme.cardBackground,
                            child: const Center(
                              child: Icon(
                                CupertinoIcons.photo,
                                size: 48,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      color: AppTheme.cardBackground,
                      child: const Center(
                        child: Icon(CupertinoIcons.photo, size: 48, color: AppTheme.textPrimary),
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
                      style: textTheme.textStyle.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.person_2_fill,
                          size: 14,
                          color: CupertinoColors.systemGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.servings} servings',
                          style: textTheme.textStyle.copyWith(
                            fontSize: 13,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                    if (recipe.prepTimeMinutes != null || recipe.cookTimeMinutes != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.time,
                            size: 14,
                            color: CupertinoColors.systemGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(recipe.prepTimeMinutes, recipe.cookTimeMinutes),
                            style: textTheme.textStyle.copyWith(
                              fontSize: 13,
                              color: CupertinoColors.systemGrey,
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
