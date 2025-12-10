import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutrition/providers/supabase_providers.dart';
import 'package:nutrition/providers/theme_provider.dart';
import 'package:nutrition/theme.dart';
import 'package:nutrition/util.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(supabaseClientProvider);
    final sessionAsync = ref.watch(sessionProvider);

    Future<void> signOut() async {
      await client.auth.signOut();
      if (!context.mounted) return;
      // Show toast/snackbar equivalent
    }

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF000000),
      child: sessionAsync.when(
        data: (session) {
          final user = session?.user;
          final email = user?.email ?? 'Unknown';
          final userId = user?.id ?? '';
          final createdAt = user?.createdAt != null
              ? DateTime.parse(user!.createdAt).toLocal()
              : null;

          return CustomScrollView(
            slivers: [
              // Account header
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: const Alignment(-0.95, 1.0),
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.45),
                        AppTheme.backgroundColor,
                        AppTheme.backgroundColor,
                      ],
                      stops: const [0.1, 1.0, 1.0],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryColor.withAlpha(200),
                            ),
                            child: const Icon(
                              CupertinoIcons.person_fill,
                              size: 32,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Account',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary.withAlpha(190),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  email,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (createdAt != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Member since ${formatDate(createdAt)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Settings list
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: CupertinoListSection.insetGrouped(
                    header: const Text(
                      'Preferences',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    children: [
                      CupertinoListTile(
                        leading: const Icon(CupertinoIcons.bell, color: AppTheme.textPrimary),
                        title: const Text(
                          'Notifications',
                          style: TextStyle(color: AppTheme.textPrimary),
                        ),
                        subtitle: const Text(
                          'Manage notification settings',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                        trailing: const Icon(CupertinoIcons.forward, color: AppTheme.textSecondary),
                        onTap: () {
                          // TODO: Implement
                        },
                      ),
                      CupertinoListTile(
                        leading: const Icon(CupertinoIcons.paintbrush, color: AppTheme.textPrimary),
                        title: const Text(
                          'Theme Color',
                          style: TextStyle(color: AppTheme.textPrimary),
                        ),
                        subtitle: Text(
                          AppThemeColor.values
                              .firstWhere(
                                (t) => t.color == ref.watch(themeProvider),
                                orElse: () => AppThemeColor.netflixRed,
                              )
                              .label,
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                        trailing: const Icon(CupertinoIcons.forward, color: AppTheme.textSecondary),
                        onTap: () {
                          _showThemeSelector(context, ref);
                        },
                      ),
                      CupertinoListTile(
                        leading: const Icon(CupertinoIcons.chart_bar, color: AppTheme.textPrimary),
                        title: const Text(
                          'Dietary preferences',
                          style: TextStyle(color: AppTheme.textPrimary),
                        ),
                        subtitle: const Text(
                          'Set your dietary goals',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                        trailing: const Icon(CupertinoIcons.forward, color: AppTheme.textSecondary),
                        onTap: () {
                          // TODO: Implement
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: CupertinoListSection.insetGrouped(
                    header: const Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 19,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    children: [
                      CupertinoListTile(
                        leading: const Icon(CupertinoIcons.person, color: AppTheme.textPrimary),
                        title: const Text('Profile', style: TextStyle(color: AppTheme.textPrimary)),
                        subtitle: const Text(
                          'Edit your profile information',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                        trailing: const Icon(CupertinoIcons.forward, color: AppTheme.textSecondary),
                        onTap: () {
                          // TODO: Implement
                        },
                      ),
                      CupertinoListTile(
                        leading: const Icon(CupertinoIcons.lock, color: AppTheme.textPrimary),
                        title: const Text(
                          'Privacy & Security',
                          style: TextStyle(color: AppTheme.textPrimary),
                        ),
                        subtitle: const Text(
                          'Manage your account security',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                        trailing: const Icon(CupertinoIcons.forward, color: AppTheme.textSecondary),
                        onTap: () {
                          // TODO: Implement
                        },
                      ),
                      CupertinoListTile(
                        leading: const Icon(
                          CupertinoIcons.square_arrow_right,
                          color: AppTheme.primaryColor,
                        ),
                        title: const Text(
                          'Sign out',
                          style: TextStyle(color: AppTheme.primaryColor),
                        ),
                        onTap: () async {
                          final confirm = await showCupertinoDialog<bool>(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: const Text('Sign out'),
                              content: const Text('Are you sure you want to sign out?'),
                              actions: [
                                CupertinoDialogAction(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                CupertinoDialogAction(
                                  isDestructiveAction: true,
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Sign out'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await signOut();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: CupertinoListSection.insetGrouped(
                    header: const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 19,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    children: [
                      CupertinoListTile(
                        leading: const Icon(CupertinoIcons.info, color: AppTheme.textPrimary),
                        title: const Text('About', style: TextStyle(color: AppTheme.textPrimary)),
                        subtitle: const Text(
                          'Version 1.0.0',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                        trailing: const Icon(CupertinoIcons.forward, color: AppTheme.textSecondary),
                        onTap: () {
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: const Text('Nutrition'),
                              content: const Text('Version 1.0.0\n\nA nutrition tracking app'),
                              actions: [
                                CupertinoDialogAction(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      CupertinoListTile(
                        leading: const Icon(CupertinoIcons.doc_text, color: AppTheme.textPrimary),
                        title: const Text(
                          'Terms & Privacy',
                          style: TextStyle(color: AppTheme.textPrimary),
                        ),
                        trailing: const Icon(CupertinoIcons.forward, color: AppTheme.textSecondary),
                        onTap: () {
                          // TODO: Implement
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // User ID for debugging
              if (userId.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'User ID: ${userId.substring(0, 8)}...',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          );
        },
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error loading account: $error',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
        ),
      ),
    );
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 400,
        decoration: const BoxDecoration(
          color: AppTheme.sheetBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Choose Theme Color',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: AppThemeColor.values.length,
                  itemBuilder: (context, index) {
                    final themeColor = AppThemeColor.values[index];
                    final isSelected = ref.watch(themeProvider) == themeColor.color;
                    return GestureDetector(
                      onTap: () {
                        ref.read(themeProvider.notifier).setTheme(themeColor);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: themeColor.color,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: AppTheme.textPrimary, width: 3)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isSelected)
                              const Icon(
                                CupertinoIcons.check_mark,
                                color: AppTheme.textPrimary,
                                size: 24,
                              ),
                            const SizedBox(height: 4),
                            Text(
                              themeColor.label,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
