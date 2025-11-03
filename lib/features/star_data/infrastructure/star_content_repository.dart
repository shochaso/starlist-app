import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../providers/user_provider.dart';
import '../../../providers/youtube_history_provider.dart';
import '../domain/star_content_entry.dart';

final starContentRepositoryProvider = Provider<StarContentRepository>((ref) {
  final client = Supabase.instance.client;
  return StarContentRepository(client);
});

final starYoutubeTimelineProvider = FutureProvider.autoDispose<List<StarContentEntry>>((ref) async {
  final repository = ref.watch(starContentRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  final localHistory = ref.watch(youtubeHistoryProvider);

  final localEntries = localHistory
      .map(StarContentEntry.fromHistoryItem)
      .toList(growable: false);

  if (user.id.isEmpty) {
    localEntries.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return localEntries;
  }

  try {
    final remoteEntries = await repository.fetchYoutubeContents(
      authorId: user.id,
      limit: 120,
    );

    final merged = <String, StarContentEntry>{};
    for (final entry in localEntries) {
      merged[entry.uniqueKey] = entry;
    }
    for (final entry in remoteEntries) {
      merged[entry.uniqueKey] = entry;
    }

    final combined = merged.values.toList()
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return combined;
  } catch (error, stackTrace) {
    log(
      'Failed to fetch YouTube contents',
      error: error,
      stackTrace: stackTrace,
    );
    localEntries.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return localEntries;
  }
});

class StarContentRepository {
  const StarContentRepository(this._client);

  final SupabaseClient _client;

  Future<List<StarContentEntry>> fetchYoutubeContents({
    required String authorId,
    int limit = 100,
  }) async {
    final response = await _client
        .from('contents')
        .select(
          'id,title,description,url,metadata,occurred_at,created_at,tags,service,category',
        )
        .eq('author_id', authorId)
        .eq('service', 'youtube')
        .order('occurred_at', ascending: false)
        .limit(limit);

    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map(StarContentEntry.fromSupabase)
          .toList();
    }

    if (response is Map<String, dynamic>) {
      return [StarContentEntry.fromSupabase(response)];
    }

    return const <StarContentEntry>[];
  }
}
