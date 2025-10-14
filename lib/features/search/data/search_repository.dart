import 'package:starlist_app/features/ingest/tag_only_saver.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Lightweight search result representation shared with the controller.
class SearchItem {
  const SearchItem({required this.id, this.payload});

  final String id;
  final Object? payload;
}

/// Abstraction for executing searches against the backing data store.
abstract class SearchRepository {
  Future<List<SearchItem>> search({String? query, required String mode});
  Future<void> insertTagOnly(TagPayload payload, {required String userId});
}

/// Supabase-backed implementation with direct client access.
class SupabaseSearchRepository implements SearchRepository {
  SupabaseSearchRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<SearchItem>> search({String? query, required String mode}) async {
    final q = (query ?? '').trim();
    
    try {
      if (mode == 'tag_only') {
        // tag_only_ingests テーブルから検索
        final searchTerm = _escapeLike(q);
        
        final rows = q.isNotEmpty
            ? await _client
                .from('tag_only_ingests')
                .select('source_id, tag_hash, category, payload_json, created_at')
                .ilike('payload_json::text', '%$searchTerm%')
                .order('created_at', ascending: false)
                .limit(200) as List<dynamic>
            : await _client
                .from('tag_only_ingests')
                .select('source_id, tag_hash, category, payload_json, created_at')
                .order('created_at', ascending: false)
                .limit(200) as List<dynamic>;
        return rows
            .map((r) {
              final row = r as Map<String, dynamic>;
              return SearchItem(
                id: 'tag:${row['tag_hash']}',
                payload: row,
              );
            })
            .toList();
      } else {
        // full: content_consumption テーブルから検索
        final searchTerm = _escapeLike(q);
        
        final rows = q.isNotEmpty
            ? await _client
                .from('content_consumption')
                .select('id, title, content, author, tags, updated_at, category')
                .or('title.ilike.%$searchTerm%,content.ilike.%$searchTerm%,tags::text.ilike.%$searchTerm%')
                .order('updated_at', ascending: false)
                .limit(200) as List<dynamic>
            : await _client
                .from('content_consumption')
                .select('id, title, content, author, tags, updated_at, category')
                .order('updated_at', ascending: false)
                .limit(200) as List<dynamic>;
        return rows
            .map((r) {
              final row = r as Map<String, dynamic>;
              return SearchItem(
                id: 'content:${row['id']}',
                payload: row,
              );
            })
            .toList();
      }
    } catch (e) {
      // エラー時は空リストを返す（ログは呼び出し側で記録）
      return [];
    }
  }

  @override
  Future<void> insertTagOnly(
    TagPayload payload, {
    required String userId,
  }) async {
    if (payload.category == 'game') return;

    try {
      final insertMap = {
        'user_id': userId,
        'source_id': payload.sourceId,
        'tag_hash': payload.tagHash,
        'category': payload.category,
        'payload_json': payload.payloadJson,
      };

      await _client.from('tag_only_ingests').upsert(
            insertMap,
            onConflict: 'source_id,tag_hash',
            ignoreDuplicates: true,
          );
    } catch (e) {
      rethrow;
    }
  }

  /// LIKE検索のエスケープ処理
  String _escapeLike(String s) {
    return s.replaceAll('%', r'\%').replaceAll('_', r'\_');
  }
}
