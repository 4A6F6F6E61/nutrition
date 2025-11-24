import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutrition/providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nutrition/main.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late _MockSupabaseClient client;
  late _MockGoTrueClient auth;

  setUp(() {
    client = _MockSupabaseClient();
    auth = _MockGoTrueClient();
    when(() => client.auth).thenReturn(auth);
    when(() => auth.signOut()).thenAnswer((_) async {});
  });

  testWidgets('Shows login screen when signed out', (tester) async {
    final authStateStream = Stream<AuthState>.value(
      AuthState(AuthChangeEvent.signedOut, null),
    ).asBroadcastStream();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseClientProvider.overrideWithValue(client),
          authStateChangesProvider.overrideWithValue(authStateStream),
        ],
        child: const NutritionApp(),
      ),
    );

    await tester.pump();

    expect(find.text('Sign in to continue'), findsOneWidget);
  });
}
