import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutrition/models/meal_log.dart';
import 'package:nutrition/providers/meal_log_provider.dart';
import 'package:nutrition/providers/recipe_provider.dart';
import 'package:nutrition/theme.dart';
import 'package:nutrition/util.dart';
import 'package:nutrition/utils/image_utils.dart';

class MealLogCard extends HookConsumerWidget {
  const MealLogCard({super.key, required this.log, required this.date});

  final MealLog log;
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = CupertinoTheme.of(context);
    final recipeAsync = ref.watch(recipeProvider(log.recipeId));

    return recipeAsync.when(
      data: (recipe) {
        if (recipe == null) {
          return const SizedBox();
        }
        return Row(
          children: [
            recipe.imagePath != null
                ? FutureBuilder<String>(
                    future: getImageUrl(
                      ref,
                      buildImagePath(recipe.userId, 'recipes', recipe.imagePath ?? ''),
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: snapshot.data!,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) => Container(
                              width: 64,
                              height: 64,
                              color: AppTheme.sheetActionBackground,
                              child: Icon(
                                CupertinoIcons.square_fill,
                                color: AppTheme.sheetActionForeground,
                              ),
                            ),
                          ),
                        );
                      }
                      return Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppTheme.sheetActionBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: snapshot.connectionState == ConnectionState.waiting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CupertinoActivityIndicator(radius: 8),
                              )
                            : Icon(
                                CupertinoIcons.square_fill,
                                color: AppTheme.sheetActionForeground,
                              ),
                      );
                    },
                  )
                : Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.sheetActionBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(CupertinoIcons.square_fill, color: AppTheme.sheetActionForeground),
                  ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  recipe.name,
                  style: theme.textTheme.textStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${log.servingsConsumed} serving${log.servingsConsumed != 1 ? 's' : ''} | ${formatTime(log.consumedAt)}',
                  style: theme.textTheme.textStyle.copyWith(color: AppTheme.textSecondary),
                ),
              ],
            ),
            Spacer(),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.delete, color: AppTheme.buttonPrimary, size: 24),
              onPressed: () async {
                final confirm = await showCupertinoDialog<bool>(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('Delete meal log'),
                    content: const Text('Are you sure you want to remove this meal?'),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      CupertinoDialogAction(
                        isDestructiveAction: true,
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref.read(mealLogNotifierProvider.notifier).deleteMealLog(log.id, date);
                }
              },
            ),
          ],
        );
      },
      loading: () => const SizedBox(child: CupertinoActivityIndicator(radius: 8)),
      error: (err, stack) => SizedBox(child: Text('Error: $err')),
    );
  }
}
