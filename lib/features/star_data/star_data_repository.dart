import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/supabase_client_provider.dart';
import '../../providers/current_user_provider.dart';
import 'models.dart';

final starDataRepositoryProvider = Provider<StarDataRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return StarDataRepository(client);
});

final starDashboardProvider = FutureProvider.autoDispose
    .family<StarDashboardData, bool>((ref, isStarView) async {
  final repo = ref.watch(starDataRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return StarDashboardData.sample();
  }
  return repo.fetchDashboard(userId: userId, isStarView: isStarView);
});

class StarDataRepository {
  StarDataRepository(this._client);

  final SupabaseClient _client;

  Future<StarDashboardData> fetchDashboard(
      {required String userId, required bool isStarView}) async {
    try {
      final response = await _client.functions.invoke(
        'api/star-data',
        method: HttpMethod.get,
        queryParameters: {
          'user_id': userId,
          'scope': isStarView ? 'star' : 'fan',
        },
      );
      final payload = response.data;
      if (payload == null) {
        log('[metrics] star_data_fetch_empty_total++');
        return StarDashboardData.sample();
      }
      if (payload is Map<String, dynamic>) {
        final data = payload['data'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(payload['data'] as Map)
            : payload;
        log('[metrics] star_data_fetch_success++');
        return StarDashboardData.fromJson(data);
      }
      if (payload is List && payload.isNotEmpty) {
        final first = payload.first;
        if (first is Map<String, dynamic>) {
          log('[metrics] star_data_fetch_success++');
          return StarDashboardData.fromJson(first);
        }
      }
      log('[metrics] star_data_fetch_unhandled_payload++');
      return StarDashboardData.sample();
    } catch (error, stack) {
      log('[metrics] star_data_fetch_failure++');
      log('Failed to load star dashboard', error: error, stackTrace: stack);
      return StarDashboardData.sample();
    }
  }
}
