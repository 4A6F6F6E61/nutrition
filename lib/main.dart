import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutrition/providers/theme_provider.dart';
import 'package:nutrition/router.dart';
import 'package:nutrition/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  await Supabase.initialize(url: dotenv.env['SUPABASE_URL']!, anonKey: dotenv.env['SUPABASE_KEY']!);

  runApp(const ProviderScope(child: NutritionApp()));
}

class NutritionApp extends HookConsumerWidget {
  const NutritionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeColor = ref.watch(themeProvider);
    final theme = useMemoized(() => generateTheme(themeColor: themeColor), [themeColor]);

    return CupertinoApp.router(
      title: 'Nutrition',
      theme: theme,
      routerConfig: router,
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      builder: (context, child) {
        // Add fake safe area padding on desktop platforms
        if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
          final existingMediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: existingMediaQuery.copyWith(
              viewPadding: existingMediaQuery.viewPadding.copyWith(top: 44.0, bottom: 34.0),
              padding: existingMediaQuery.padding.copyWith(top: 44.0, bottom: 34.0),
            ),
            child: child ?? const SizedBox(),
          );
        }
        return child ?? const SizedBox();
      },
    );
  }
}
