import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authStateChangesProvider = Provider<Stream<AuthState>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

final sessionProvider = StreamProvider<Session?>((ref) {
  return ref.watch(authStateChangesProvider).map((event) => event.session);
});
