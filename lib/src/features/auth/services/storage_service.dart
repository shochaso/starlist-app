import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> uploadProfileImage(XFile image, String userId) async {
    try {
      final fileExtension = image.name.split('.').last;
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final path = 'public/avatars/$fileName';

      if (kIsWeb) {
        final Uint8List bytes = await image.readAsBytes();
        await _supabase.storage.from('avatars').uploadBinary(
              path,
              bytes,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: false,
                contentType: 'image/*',
              ),
            );
      } else {
        final file = File(image.path);
        await _supabase.storage.from('avatars').upload(
              path,
              file,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
            );
      }

      final urlResponse = _supabase.storage.from('avatars').getPublicUrl(path);
      return urlResponse;
    } catch (e) {
      return null;
    }
  }
} 