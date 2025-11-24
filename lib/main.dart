import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutrition/router.dart';
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

    return MaterialApp.router(
      title: 'Nutrition',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.red, brightness: .dark),
        useMaterial3: true,
        sliderTheme: const SliderThemeData(year2023: false),
      ),
      routerConfig: router,
    );
  }
}
