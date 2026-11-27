import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FoodSaverImageService {
  FoodSaverImageService._();

  static final FoodSaverImageService instance = FoodSaverImageService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  static const String bucketName = 'savebite-food-images';

  Future<String> uploadFoodImage({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Please sign in before uploading food images.');
    }

    final safeFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';

    final path = '${user.uid}/$safeFileName';

    await _supabase.storage
        .from(bucketName)
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: false),
        );

    return _supabase.storage.from(bucketName).getPublicUrl(path);
  }
}
