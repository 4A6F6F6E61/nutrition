import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutrition/models/meal_log.dart';
import 'package:nutrition/providers/meal_log_provider.dart';
import 'package:nutrition/providers/recipe_provider.dart';
import 'package:nutrition/util.dart';
import 'package:nutrition/utils/image_utils.dart';

class MealLogCard extends HookConsumerWidget {
  const MealLogCard({super.key, required this.log, required this.date});

  final MealLog log;
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final recipeAsync = ref.watch(recipeProvider(log.recipeId));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      child: recipeAsync.when(
        data: (recipe) {
          if (recipe == null) {
            return const ListTile(title: Text('Recipe not found'));
          }
          return ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: recipe.imagePath != null
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
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) => Container(
                              width: 56,
                              height: 56,
                              color: colorScheme.primaryContainer,
                              child: Icon(Icons.restaurant, color: colorScheme.onPrimaryContainer),
                            ),
                          ),
                        );
                      }

                      return Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: snapshot.connectionState == ConnectionState.waiting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(Icons.restaurant, color: colorScheme.onPrimaryContainer),
                      );
                    },
                  )
                : Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.restaurant, color: colorScheme.onPrimaryContainer),
                  ),
            title: Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${log.servingsConsumed} serving${log.servingsConsumed != 1 ? 's' : ''}'),
                Text(
                  formatTime(log.consumedAt),
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete meal log'),
                    content: const Text('Are you sure you want to remove this meal?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
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
          );
        },
        loading: () =>
            const ListTile(leading: CircularProgressIndicator(), title: Text('Loading...')),
        error: (err, stack) => ListTile(title: Text('Error: $err')),
      ),
    );
  }
}
