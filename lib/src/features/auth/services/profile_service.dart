import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:starlist/features/registration/application/profile_info_provider.dart';
import 'package:starlist/features/registration/application/sns_link_provider.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createProfile({
    required String userId,
    required String username,
    required String displayName,
    required String email,
    required ProfileInfoState profileInfo,
    required SnsLinkState snsInfo,
    required String? avatarUrl,
  }) async {
    try {
      final response = await _supabase.from('profiles').insert({
        'id': userId,
        'username': username,
        'display_name': displayName,
        'email': email,
        'avatar_url': avatarUrl,
        'date_of_birth': profileInfo.dateOfBirth?.toIso8601String(),
        'gender': profileInfo.gender?.toString().split('.').last,
        'is_affiliated': profileInfo.isAffiliated,
        'agency_name': profileInfo.agencyName,
        'genres': profileInfo.selectedGenres.toList(),
        'sns_links': {
          'x': snsInfo.xUsername,
          'instagram': snsInfo.instagramUsername,
          'youtube': snsInfo.youtubeUrl,
          'tiktok': snsInfo.tiktokUsername,
          'website': snsInfo.websiteUrl,
        },
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      // Note: Supabase insert doesn't throw by default on failure with upsert=false.
      // You might need to check the response if you have specific constraints.
      // For example, if the primary key (id) already exists.
      
    } catch (e) {
      // Re-throw the exception to be handled by the calling provider
      throw Exception('Failed to create profile: ${e.toString()}');
    }
  }
} 