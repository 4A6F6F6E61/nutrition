import 'dart:developer' as dev;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutrition/providers/supabase_providers.dart';

/// Constructs the full Supabase storage URL from an image path
/// Path format: {userId}/recipes/{filename} or {userId}/ingredients/{filename}
Future<String> getImageUrl(WidgetRef ref, String imagePath) async {
  final client = ref.read(supabaseClientProvider);
  return await client.storage.from('nutrition-images').createSignedUrl(imagePath, 60);
}

/// Constructs the full path for storing an image
/// Returns: {userId}/{category}/{filename}
String buildImagePath(String userId, String category, String filename) {
  final path = '$userId/$category/$filename.jpg';
  dev.log("Built image path: $path");
  return path;
}
