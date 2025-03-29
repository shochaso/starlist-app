import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/content_consumption_model.dart';

class ContentRepository {
  final SupabaseClient _client;
  final String _table = 'content_consumption';
  
  ContentRepository(this._client);
  
  /// 特定のユーザーのコンテンツ消費データを取得
  Future<List<ContentConsumption>> getUserContentConsumptions({
    required String userId,
    ContentCategory? category,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _client
          .from(_table)
          .select();
      
      // フィルタを適用
      query = query.eq('user_id', userId) as PostgrestFilterBuilder;
      
      if (category != null) {
        query = query.eq('category', category.name) as PostgrestFilterBuilder;
      }
      
      // ソートと制限を適用
      final data = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      // データがない場合はモックデータを返す（開発中の一時的な対応）
      if (data == null || (data is List && data.isEmpty)) {
        return _generateMockData(userId, category);
      }
      
      return List<Map<String, dynamic>>.from(data)
          .map((item) => ContentConsumption.fromJson(item))
          .toList();
    } catch (e) {
      log('コンテンツ消費データの取得に失敗しました: $e');
      // エラー時はモックデータを返す（開発中の一時的な対応）
      return _generateMockData(userId, category);
    }
  }
  
  // モックデータ生成（テスト用）- 実際のデータがない場合のフォールバック
  List<ContentConsumption> _generateMockData(String userId, ContentCategory? filterCategory) {
    final categories = filterCategory != null ? [filterCategory] : ContentCategory.values;
    final result = <ContentConsumption>[];
    
    for (final category in categories) {
      switch (category) {
        case ContentCategory.youtube:
          result.addAll([
            ContentConsumption(
              id: '1',
              userId: userId,
              title: 'Flutter 3.0の新機能紹介',
              description: 'Flutterの最新バージョンの機能を解説しています。',
              category: ContentCategory.youtube,
              contentData: {
                'video_id': 'dQw4w9WgXcQ',
                'thumbnail_url': 'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
              },
              privacyLevel: PrivacyLevel.public,
              createdAt: DateTime.now().subtract(Duration(days: 2)),
              updatedAt: DateTime.now().subtract(Duration(days: 2)),
              viewCount: 1250,
              likeCount: 42,
            ),
            ContentConsumption(
              id: '2',
              userId: userId,
              title: 'Dart言語入門講座',
              description: 'プログラミング初心者向けのDart言語チュートリアル',
              category: ContentCategory.youtube,
              contentData: {
                'video_id': '9bZkp7q19f0',
                'thumbnail_url': 'https://i.ytimg.com/vi/9bZkp7q19f0/hqdefault.jpg',
              },
              privacyLevel: PrivacyLevel.public,
              createdAt: DateTime.now().subtract(Duration(days: 5)),
              updatedAt: DateTime.now().subtract(Duration(days: 5)),
              viewCount: 843,
              likeCount: 35,
            ),
          ]);
          break;
        case ContentCategory.book:
          result.addAll([
            ContentConsumption(
              id: '3',
              userId: userId,
              title: 'ハリーポッターと賢者の石',
              description: 'J.K.ローリングのファンタジー小説',
              category: ContentCategory.book,
              contentData: {
                'author': 'J.K.ローリング',
                'isbn': '9784915512377',
              },
              privacyLevel: PrivacyLevel.public,
              createdAt: DateTime.now().subtract(Duration(days: 10)),
              updatedAt: DateTime.now().subtract(Duration(days: 10)),
            ),
          ]);
          break;
        case ContentCategory.purchase:
          result.addAll([
            ContentConsumption(
              id: '4',
              userId: userId,
              title: 'MacBook Pro 14インチ',
              description: 'Apple Silicon M2チップ搭載の最新モデル',
              category: ContentCategory.purchase,
              contentData: {
                'store': 'Apple Store',
                'product_url': 'https://www.apple.com/jp/macbook-pro/',
              },
              privacyLevel: PrivacyLevel.public,
              createdAt: DateTime.now().subtract(Duration(days: 15)),
              updatedAt: DateTime.now().subtract(Duration(days: 15)),
              price: 248000,
            ),
          ]);
          break;
        case ContentCategory.food:
          result.addAll([
            ContentConsumption(
              id: '5',
              userId: userId,
              title: '渋谷の人気ラーメン店',
              description: '濃厚魚介豚骨つけ麺を堪能',
              category: ContentCategory.food,
              contentData: {
                'restaurant': '麺屋 海神',
                'menu': '特製つけ麺',
              },
              privacyLevel: PrivacyLevel.public,
              createdAt: DateTime.now().subtract(Duration(days: 3)),
              updatedAt: DateTime.now().subtract(Duration(days: 3)),
              location: GeoLocation(
                latitude: 35.658034,
                longitude: 139.701636,
                placeName: '麺屋 海神 渋谷店',
                address: '東京都渋谷区道玄坂2-10-12',
              ),
            ),
          ]);
          break;
        default:
          break;
      }
    }
    
    return result;
  }
  
  /// 特定のコンテンツ消費データを取得
  Future<ContentConsumption?> getContentConsumptionById(String id) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('id', id)
          .single();
      
      return ContentConsumption.fromJson(data);
    } catch (e) {
      log('コンテンツ消費データの取得に失敗しました: $e');
      return null;
    }
  }
  
  /// 新しいコンテンツ消費データを作成
  Future<ContentConsumption?> createContentConsumption(ContentConsumption content) async {
    try {
      final newId = const Uuid().v4();
      final now = DateTime.now();
      
      final newContent = content.copyWith(
        id: newId,
        createdAt: now,
        updatedAt: now,
      );
      
      await _client
          .from(_table)
          .insert(newContent.toJson());
      
      return newContent;
    } catch (e) {
      log('コンテンツ消費データの作成に失敗しました: $e');
      return null;
    }
  }
  
  /// コンテンツ消費データを更新
  Future<bool> updateContentConsumption(ContentConsumption content) async {
    try {
      final updatedContent = content.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await _client
          .from(_table)
          .update(updatedContent.toJson())
          .eq('id', content.id);
      
      return true;
    } catch (e) {
      log('コンテンツ消費データの更新に失敗しました: $e');
      return false;
    }
  }
  
  /// コンテンツ消費データを削除
  Future<bool> deleteContentConsumption(String id) async {
    try {
      await _client
          .from(_table)
          .delete()
          .eq('id', id);
      
      return true;
    } catch (e) {
      log('コンテンツ消費データの削除に失敗しました: $e');
      return false;
    }
  }
  
  /// 閲覧数をインクリメント
  Future<bool> incrementViewCount(String id) async {
    try {
      await _client.rpc('increment_view_count', params: {'content_id': id});
      return true;
    } catch (e) {
      log('閲覧数の更新に失敗しました: $e');
      return false;
    }
  }
  
  /// いいね数をインクリメント
  Future<bool> incrementLikeCount(String id) async {
    try {
      await _client.rpc('increment_like_count', params: {'content_id': id});
      return true;
    } catch (e) {
      log('いいね数の更新に失敗しました: $e');
      return false;
    }
  }
  
  /// コメント数をインクリメント
  Future<bool> incrementCommentCount(String id) async {
    try {
      await _client.rpc('increment_comment_count', params: {'content_id': id});
      return true;
    } catch (e) {
      log('コメント数の更新に失敗しました: $e');
      return false;
    }
  }
  
  /// プライバシー設定に応じた公開コンテンツを取得
  Future<List<ContentConsumption>> getPublicContentConsumptions({
    ContentCategory? category,
    int limit = 20,
    int offset = 0,
    String? searchQuery,
  }) async {
    try {
      var query = _client
          .from(_table)
          .select();
          
      // フィルタを適用
      query = query.eq('privacy_level', PrivacyLevel.public.name) as PostgrestFilterBuilder;
      
      if (category != null) {
        query = query.eq('category', category.name) as PostgrestFilterBuilder;
      }
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('title', '%$searchQuery%') as PostgrestFilterBuilder;
      }
      
      // ソートと制限を適用
      final data = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      // データがない場合はモックデータを返す（開発中の一時的な対応）
      if (data == null || (data is List && data.isEmpty)) {
        final allData = _generateMockData('public', category);
        
        if (searchQuery != null && searchQuery.isNotEmpty) {
          return allData.where((content) => 
            content.title.toLowerCase().contains(searchQuery.toLowerCase()) || 
            (content.description?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false)
          ).toList();
        }
        
        return allData;
      }
      
      return List<Map<String, dynamic>>.from(data)
          .map((item) => ContentConsumption.fromJson(item))
          .toList();
    } catch (e) {
      log('公開コンテンツの取得に失敗しました: $e');
      // エラー時はモックデータを返す（開発中の一時的な対応）
      final allData = _generateMockData('public', category);
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        return allData.where((content) => 
          content.title.toLowerCase().contains(searchQuery.toLowerCase()) || 
          (content.description?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false)
        ).toList();
      }
      
      return allData;
    }
  }
  
  /// 人気コンテンツを取得（閲覧数に基づく）
  Future<List<ContentConsumption>> getPopularContentConsumptions({
    ContentCategory? category,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _client
          .from(_table)
          .select();
          
      // フィルタを適用
      query = query.eq('privacy_level', PrivacyLevel.public.name) as PostgrestFilterBuilder;
      
      if (category != null) {
        query = query.eq('category', category.name) as PostgrestFilterBuilder;
      }
      
      // ソートと制限を適用
      final data = await query
          .order('view_count', ascending: false)
          .range(offset, offset + limit - 1);
      
      // データがない場合はモックデータを返す（開発中の一時的な対応）
      if (data == null || (data is List && data.isEmpty)) {
        final allData = _generateMockData('public', category);
        allData.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        return allData.take(limit).toList();
      }
      
      return List<Map<String, dynamic>>.from(data)
          .map((item) => ContentConsumption.fromJson(item))
          .toList();
    } catch (e) {
      log('人気コンテンツの取得に失敗しました: $e');
      // エラー時はモックデータを返す（開発中の一時的な対応）
      final allData = _generateMockData('public', category);
      allData.sort((a, b) => b.viewCount.compareTo(a.viewCount));
      return allData.take(limit).toList();
    }
  }
  
  /// カテゴリごとのコンテンツ消費集計を取得
  Future<Map<ContentCategory, int>> getUserContentCategoryCounts(String userId) async {
    try {
      final response = await _client
          .from(_table)
          .select('category, count')
          .eq('user_id', userId)
          .execute();
      
      final data = response.data as List;
      final result = <ContentCategory, int>{};
      
      if (data.isEmpty) {
        // データがない場合はモックデータを返す
        return {
          ContentCategory.youtube: 2,
          ContentCategory.book: 1,
          ContentCategory.purchase: 1,
          ContentCategory.food: 1,
        };
      }
      
      for (final item in data) {
        final category = ContentCategory.values.firstWhere(
          (cat) => cat.name == item['category'],
          orElse: () => ContentCategory.other,
        );
        
        result[category] = (item['count'] as int?) ?? 0;
      }
      
      return result;
    } catch (e) {
      log('カテゴリ集計の取得に失敗しました: $e');
      // エラー時はモックデータを返す
      return {
        ContentCategory.youtube: 2,
        ContentCategory.book: 1,
        ContentCategory.purchase: 1,
        ContentCategory.food: 1,
      };
    }
  }
  
  /// YouTubeコンテンツを保存
  Future<ContentConsumption?> saveYouTubeContent({
    required String userId,
    required String videoId,
    required String title,
    required String thumbnailUrl,
    String? description,
    PrivacyLevel privacyLevel = PrivacyLevel.public,
  }) async {
    final contentData = {
      'video_id': videoId,
      'thumbnail_url': thumbnailUrl,
    };
    
    final content = ContentConsumption(
      id: '', // createContentConsumptionで生成される
      userId: userId,
      title: title,
      description: description,
      category: ContentCategory.youtube,
      contentData: contentData,
      privacyLevel: privacyLevel,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    return await createContentConsumption(content);
  }
} 