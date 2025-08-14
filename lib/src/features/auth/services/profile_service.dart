import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:starlist_app/features/registration/application/profile_info_provider.dart';
import 'package:starlist_app/features/registration/application/sns_link_provider.dart';

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
      
    } catch (e) {
      throw Exception('Failed to create profile: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select('id, display_name, email, username, avatar_url, genres, sns_links')
          .eq('id', userId)
          .maybeSingle();
      return data;
    } catch (e) {
      throw Exception('Failed to fetch profile: ${e.toString()}');
    }
  }

  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
    String? website,
    List<String>? genres,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (displayName != null) updates['display_name'] = displayName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (genres != null) updates['genres'] = genres;

      if (website != null) {
        final current = await _supabase
            .from('profiles')
            .select('sns_links')
            .eq('id', userId)
            .maybeSingle();
        final Map<String, dynamic> snsLinks = (current?['sns_links'] as Map?)?.cast<String, dynamic>() ?? {};
        if (website.isEmpty) {
          snsLinks.remove('website');
        } else {
          snsLinks['website'] = website;
        }
        updates['sns_links'] = snsLinks;
      }

      await _supabase.from('profiles').update(updates).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }
} 