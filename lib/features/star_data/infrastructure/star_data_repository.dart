import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../src/config/providers.dart' as core_providers;
import '../domain/category.dart';
import '../domain/star_data.dart';
import 'dto/star_data_dto.dart';

final starDataRepositoryProvider = Provider<StarDataRepository>((ref) {
  final client = ref.read(core_providers.supabaseClientProvider);
  return StarDataRepository(client);
});

class StarDataRepository {
  const StarDataRepository(this._client);

  final SupabaseClient _client;

  Future<StarDataPage> fetchStarData({
    required String username,
    StarDataCategory? category,
    String? cursor,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'api/star-data',
        method: HttpMethod.get,
        queryParameters: <String, dynamic>{
          'username': username,
          if (category != null) 'category': category.apiValue,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return StarDataPageDto.fromJson(data).toDomain();
      }

      log(
        'Unexpected payload from star-data Edge Function',
        error: data,
      );
    } catch (error, stackTrace) {
      log(
        'Failed to fetch star data',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }

    return const StarDataPage(
      profile: StarProfile(
        username: '',
        displayName: '-',
        avatarUrl: null,
        bio: null,
        totalFollowers: null,
        snsLinks: StarSnsLinks(),
      ),
      viewerAccess: StarDataViewerAccess(
        isLoggedIn: false,
        canViewFollowersOnlyContent: false,
        isOwner: false,
        canToggleActions: false,
        categoryDigest: {},
      ),
      items: <StarData>[],
      nextCursor: null,
    );
  }
}
