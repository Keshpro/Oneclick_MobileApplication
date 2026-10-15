import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

class SupabaseStorageService {
  static const String bucketName = 'personal-vault';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadFile({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not signed in.');
    }

    final safeFileName =
        '${DateTime.now().millisecondsSinceEpoch}_$fileName';

    final path = '${user.uid}/$safeFileName';

    await _supabase.storage.from(bucketName).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: false,
          ),
        );

    return path;
  }

  Future<List<int>> downloadFile({
    required String path,
  }) async {
    final data = await _supabase.storage
        .from(bucketName)
        .download(path);

    return data;
  }

  Future<void> deleteFile({
    required String path,
  }) async {
    await _supabase.storage.from(bucketName).remove([path]);
  }

  Future<String> createSignedUrl({
    required String path,
    int expiresInSeconds = 3600,
  }) async {
    return _supabase.storage
        .from(bucketName)
        .createSignedUrl(
          path,
          expiresInSeconds,
        );
  }
}