import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../src/core/config/supabase_client_provider.dart';
import '../../../src/core/error/app_error.dart';

/// 検索結果アイテムのモデル
class SearchItem {
  final String id;
  final String title;
  final String? subtitle;
  final String? category;
  final String? imageUrl;
  final String type; // 'content', 'user', 'star' など
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;

  SearchItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.category,
    this.imageUrl,
    required this.type,
    this.metadata,
    this.createdAt,
  });

  factory SearchItem.fromJson(Map<String, dynamic> json) {
    return SearchItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      category: json['category']?.toString(),
      imageUrl: json['image_url']?.toString(),
      type: json['type']?.toString() ?? 'content',
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'image_url': imageUrl,
      'type': type,
      'metadata': metadata,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

/// 検索リポジトリのインターフェース
abstract class SearchRepository {
  /// 検索を実行
  /// 
  /// [query] 検索クエリ（任意）
  /// [mode] 検索モード ('full' | 'tag_only')
  Future<List<SearchItem>> search({String? query, required String mode});

  /// タグのみの検索結果を保存
  /// 
  /// [payload] 保存するデータ
  /// [userId] ユーザーID
  Future<void> insertTagOnly(Map<String, dynamic> payload, {required String userId});
}

/// Supabase実装のSearchRepository
class SupabaseSearchRepository implements SearchRepository {
  final SupabaseClient _client;

  SupabaseSearchRepository(this._client);

  @override
  Future<List<SearchItem>> search({String? query, required String mode}) async {
    try {
      final q = (query ?? '').trim();
      
      if (mode == 'tag_only') {
        return await _searchTagOnly(q);
      } else {
        return await _searchFull(q);
      }
    } catch (e) {
      throw AppError(
        message: '検索に失敗しました',
        code: 'SEARCH_ERROR',
        details: e.toString(),
      );
    }
  }

  /// full モードの検索（contents テーブル）
  Future<List<SearchItem>> _searchFull(String query) async {
    var searchQuery = _client
        .from('contents')
        .select<List<Map<String, dynamic>>>(
          'id, title, body, author, tags, category, updated_at, created_at'
        )
        .order('updated_at', ascending: false)
        .limit(200);

    if (query.isNotEmpty) {
      // タイトル、本文、タグを横断検索
      final escapedQuery = _escapeLike(query);
      searchQuery = searchQuery.or(
        'title.ilike.%$escapedQuery%,'
        'body.ilike.%$escapedQuery%,'
        'tags.ilike.%$escapedQuery%'
      );
    }

    final rows = await searchQuery;
    
    return rows.map((r) => SearchItem(
      id: r['id'].toString(),
      title: r['title']?.toString() ?? '',
      subtitle: r['author']?.toString(),
      category: r['category']?.toString(),
      type: 'content',
      metadata: {
        'body': r['body'],
        'tags': r['tags'],
        'author': r['author'],
      },
      createdAt: r['created_at'] != null
          ? DateTime.tryParse(r['created_at'].toString())
          : null,
    )).toList();
  }

  /// tag_only モードの検索（tag_only_ingests テーブル）
  Future<List<SearchItem>> _searchTagOnly(String query) async {
    var searchQuery = _client
        .from('tag_only_ingests')
        .select<List<Map<String, dynamic>>>(
          'source_id, tag_hash, category, payload_json, created_at'
        )
        .order('created_at', ascending: false)
        .limit(200);

    if (query.isNotEmpty) {
      // payload_json内のテキストを検索
      final escapedQuery = _escapeLike(query);
      searchQuery = searchQuery.ilike('payload_json::text', '%$escapedQuery%');
    }

    final rows = await searchQuery;
    
    return rows.map((r) {
      final payloadJson = r['payload_json'] as Map<String, dynamic>? ?? {};
      return SearchItem(
        id: r['tag_hash']?.toString() ?? r['source_id']?.toString() ?? '',
        title: payloadJson['title']?.toString() ?? 
               payloadJson['tag']?.toString() ?? 
               'タグアイテム',
        subtitle: payloadJson['description']?.toString(),
        category: r['category']?.toString(),
        type: 'tag_only',
        metadata: payloadJson,
        createdAt: r['created_at'] != null
            ? DateTime.tryParse(r['created_at'].toString())
            : null,
      );
    }).toList();
  }

  @override
  Future<void> insertTagOnly(Map<String, dynamic> payload, {required String userId}) async {
    try {
      // DoD: ゲームは保存しない（アプリ層でも既に弾く想定）
      if ((payload['category'] as String?) == 'game') {
        return;
      }

      // 冪等性: DB側 UNIQUE (source_id, tag_hash) でON CONFLICT DO NOTHING相当
      final insertMap = {
        'user_id': userId,
        'source_id': payload['source_id'],
        'tag_hash': payload['tag_hash'],
        'category': payload['category'],
        'payload_json': payload['raw'] ?? payload, // 後方互換
        'created_at': DateTime.now().toIso8601String(),
      };

      // SupabaseのUPSERTを利用（UNIQUEに基づき衝突時は無視）
      await _client
          .from('tag_only_ingests')
          .upsert(
            insertMap,
            onConflict: 'source_id,tag_hash',
            ignoreDuplicates: true,
          );
    } catch (e) {
      throw AppError(
        message: 'タグデータの保存に失敗しました',
        code: 'INSERT_TAG_ONLY_ERROR',
        details: e.toString(),
      );
    }
  }

  /// LIKE検索用のエスケープ処理
  String _escapeLike(String s) => s.replaceAll('%', '\\%').replaceAll('_', '\\_');
}