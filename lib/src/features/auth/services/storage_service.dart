import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> uploadProfileImage(XFile image, String userId) async {
    try {
      final file = File(image.path);
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.${image.path.split('.').last}';
      final path = 'public/avatars/$fileName';

      await _supabase.storage.from('avatars').upload(
            path,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      
      final urlResponse = _supabase.storage.from('avatars').getPublicUrl(path);
      return urlResponse;
    } catch (e) {
      // Handle exceptions
      return null;
    }
  }
} 