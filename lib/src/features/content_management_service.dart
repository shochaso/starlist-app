import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_models.dart';

/// コンテンツ管理サービスクラス
class ContentManagementService {
  /// コンテンツを取得するメソッド
  Future<List<Content>> getContents({
    required String starId,
    ContentType? type,
    ContentStatus? status,
    PrivacyLevel? privacyLevel,
    String? searchQuery,
    List<String>? tags,
    int limit = 20,
    int offset = 0,
  }) async {
    // 実際のアプリではAPIからデータを取得
    // ここではモックデータを返す
    return List.generate(
      limit,
      (index) => Content(
        id: 'content_${offset + index}',
        starId: starId,
        title: 'テストコンテンツ #${offset + index}',
        description: 'これはテストコンテンツの説明です。#${offset + index}',
        type: type ?? _getRandomContentType(index),
        privacyLevel: privacyLevel ?? _getRandomPrivacyLevel(index),
        status: status ?? _getRandomContentStatus(index),
        createdAt: DateTime.now().subtract(Duration(days: index * 2)),
        scheduledAt: _shouldHaveScheduledDate(index) 
            ? DateTime.now().add(Duration(days: index % 7)) 
            : null,
        publishedAt: _shouldBePublished(index) 
            ? DateTime.now().subtract(Duration(days: index)) 
            : null,
        updatedAt: DateTime.now().subtract(Duration(hours: index * 5)),
        metadata: _generateMetadata(index),
        tags: _generateTags(index),
        visibilitySettings: _generateVisibilitySettings(),
        thumbnailUrl: 'https://example.com/thumbnails/image_$index.jpg',
        contentUrl: 'https://example.com/contents/content_$index',
        viewCount: 100 * (10 - (index % 10)),
        likeCount: 50 * (10 - (index % 10)),
        commentCount: 20 * (10 - (index % 10)),
        shareCount: 10 * (10 - (index % 10)),
      ),
    );
  }

  /// コンテンツを取得するメソッド
  Future<Content?> getContent(String contentId) async {
    // 実際のアプリではAPIからデータを取得
    // ここではモックデータを返す
    final index = int.tryParse(contentId.split('_').last) ?? 0;
    
    return Content(
      id: contentId,
      starId: 'star_1',
      title: 'テストコンテンツ #$index',
      description: 'これはテストコンテンツの説明です。#$index',
      type: _getRandomContentType(index),
      privacyLevel: _getRandomPrivacyLevel(index),
      status: _getRandomContentStatus(index),
      createdAt: DateTime.now().subtract(Duration(days: index * 2)),
      scheduledAt: _shouldHaveScheduledDate(index) 
          ? DateTime.now().add(Duration(days: index % 7)) 
          : null,
      publishedAt: _shouldBePublished(index) 
          ? DateTime.now().subtract(Duration(days: index)) 
          : null,
      updatedAt: DateTime.now().subtract(Duration(hours: index * 5)),
      metadata: _generateMetadata(index),
      tags: _generateTags(index),
      visibilitySettings: _generateVisibilitySettings(),
      thumbnailUrl: 'https://example.com/thumbnails/image_$index.jpg',
      contentUrl: 'https://example.com/contents/content_$index',
      viewCount: 100 * (10 - (index % 10)),
      likeCount: 50 * (10 - (index % 10)),
      commentCount: 20 * (10 - (index % 10)),
      shareCount: 10 * (10 - (index % 10)),
    );
  }

  /// コンテンツを作成するメソッド
  Future<Content> createContent({
    required String starId,
    required String title,
    String? description,
    required ContentType type,
    required PrivacyLevel privacyLevel,
    ContentStatus status = ContentStatus.draft,
    DateTime? scheduledAt,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    Map<String, bool>? visibilitySettings,
    String? thumbnailUrl,
    String? contentUrl,
  }) async {
    // 実際のアプリではAPIを呼び出してコンテンツを作成
    // ここではモックの処理を行う
    final now = DateTime.now();
    final contentId = 'content_${now.millisecondsSinceEpoch}';
    
    return Content(
      id: contentId,
      starId: starId,
      title: title,
      description: description,
      type: type,
      privacyLevel: privacyLevel,
      status: status,
      createdAt: now,
      scheduledAt: scheduledAt,
      publishedAt: status == ContentStatus.published ? now : null,
      updatedAt: now,
      metadata: metadata ?? {},
      tags: tags ?? [],
      visibilitySettings: visibilitySettings ?? _generateVisibilitySettings(),
      thumbnailUrl: thumbnailUrl,
      contentUrl: contentUrl,
      viewCount: 0,
      likeCount: 0,
      commentCount: 0,
      shareCount: 0,
    );
  }

  /// コンテンツを更新するメソッド
  Future<Content> updateContent({
    required String contentId,
    String? title,
    String? description,
    ContentType? type,
    PrivacyLevel? privacyLevel,
    ContentStatus? status,
    DateTime? scheduledAt,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    Map<String, bool>? visibilitySettings,
    String? thumbnailUrl,
    String? contentUrl,
  }) async {
    // 実際のアプリではAPIを呼び出してコンテンツを更新
    // ここではモックの処理を行う
    final content = await getContent(contentId);
    if (content == null) {
      throw Exception('Content not found');
    }
    
    final now = DateTime.now();
    final updatedContent = content.copyWith(
      title: title,
      description: description,
      type: type,
      privacyLevel: privacyLevel,
      status: status,
      scheduledAt: scheduledAt,
      updatedAt: now,
      publishedAt: status == ContentStatus.published && content.publishedAt == null ? now : content.publishedAt,
      metadata: metadata != null ? {...content.metadata, ...metadata} : content.metadata,
      tags: tags,
      visibilitySettings: visibilitySettings,
      thumbnailUrl: thumbnailUrl,
      contentUrl: contentUrl,
    );
    
    return updatedContent;
  }

  /// コンテンツを公開するメソッド
  Future<Content> publishContent(String contentId, {DateTime? publishAt}) async {
    // 実際のアプリではAPIを呼び出してコンテンツを公開
    // ここではモックの処理を行う
    final content = await getContent(contentId);
    if (content == null) {
      throw Exception('Content not found');
    }
    
    if (!content.isPublishable()) {
      throw Exception('Content is not publishable');
    }
    
    final now = DateTime.now();
    
    if (publishAt != null && publishAt.isAfter(now)) {
      // 公開予定日時が未来の場合はスケジュール設定
      return content.copyWith(
        status: ContentStatus.scheduled,
        scheduledAt: publishAt,
        updatedAt: now,
      );
    } else {
      // 即時公開
      return content.copyWith(
        status: ContentStatus.published,
        publishedAt: now,
        updatedAt: now,
      );
    }
  }

  /// コンテンツをアーカイブするメソッド
  Future<Content> archiveContent(String contentId) async {
    // 実際のアプリではAPIを呼び出してコンテンツをアーカイブ
    // ここではモックの処理を行う
    final content = await getContent(contentId);
    if (content == null) {
      throw Exception('Content not found');
    }
    
    return content.copyWith(
      status: ContentStatus.archived,
      updatedAt: DateTime.now(),
    );
  }

  /// コンテンツを削除するメソッド
  Future<bool> deleteContent(String contentId) async {
    // 実際のアプリではAPIを呼び出してコンテンツを削除
    // ここではモックの処理を行う
    return true;
  }

  /// コンテンツコレクションを取得するメソッド
  Future<List<ContentCollection>> getContentCollections({
    required String starId,
    PrivacyLevel? privacyLevel,
    bool? isDefault,
    int limit = 20,
    int offset = 0,
  }) async {
    // 実際のアプリではAPIからデータを取得
    // ここではモックデータを返す
    return List.generate(
      limit,
      (index) => ContentCollection(
        id: 'collection_${offset + index}',
        starId: starId,
        title: 'コレクション #${offset + index}',
        description: 'これはテストコレクションの説明です。#${offset + index}',
        contentIds: List.generate(5, (i) => 'content_${i + (index * 5)}'),
        privacyLevel: privacyLevel ?? _getRandomPrivacyLevel(index),
        createdAt: DateTime.now().subtract(Duration(days: index * 3)),
        updatedAt: DateTime.now().subtract(Duration(hours: index * 8)),
        thumbnailUrl: 'https://example.com/thumbnails/collection_$index.jpg',
        isDefault: isDefault ?? (index == 0),
        visibilitySettings: _generateVisibilitySettings(),
      ),
    );
  }

  /// コンテンツコレクションを取得するメソッド
  Future<ContentCollection?> getContentCollection(String collectionId) async {
    // 実際のアプリではAPIからデータを取得
    // ここではモックデータを返す
    final index = int.tryParse(collectionId.split('_').last) ?? 0;
    
    return ContentCollection(
      id: collectionId,
      starId: 'star_1',
      title: 'コレクション #$index',
      description: 'これはテストコレクションの説明です。#$index',
      contentIds: List.generate(5, (i) => 'content_${i + (index * 5)}'),
      privacyLevel: _getRandomPrivacyLevel(index),
      createdAt: DateTime.now().subtract(Duration(days: index * 3)),
      updatedAt: DateTime.now().subtract(Duration(hours: index * 8)),
      thumbnailUrl: 'https://example.com/thumbnails/collection_$index.jpg',
      isDefault: index == 0,
      visibilitySettings: _generateVisibilitySettings(),
    );
  }

  /// コンテンツコレクションを作成するメソッド
  Future<ContentCollection> createContentCollection({
    required String starId,
    required String title,
    String? description,
    List<String>? contentIds,
    required PrivacyLevel privacyLevel,
    String? thumbnailUrl,
    bool isDefault = false,
    Map<String, bool>? visibilitySettings,
  }) async {
    // 実際のアプリではAPIを呼び出してコレクションを作成
    // ここではモックの処理を行う
    final now = DateTime.now();
    final collectionId = 'collection_${now.millisecondsSinceEpoch}';
    
    return ContentCollection(
      id: collectionId,
      starId: starId,
      title: title,
      description: description,
      contentIds: contentIds ?? [],
      privacyLevel: privacyLevel,
      createdAt: now,
      updatedAt: now,
      thumbnailUrl: thumbnailUrl,
      isDefault: isDefault,
      visibilitySettings: visibilitySettings ?? _generateVisibilitySettings(),
    );
  }

  /// コンテンツコレクションを更新するメソッド
  Future<ContentCollection> updateContentCollection({
    required String collectionId,
    String? title,
    String? description,
    List<String>? contentIds,
    PrivacyLevel? privacyLevel,
    String? thumbnailUrl,
    bool? isDefault,
    Map<String, bool>? visibilitySettings,
  }) async {
    // 実際のアプリではAPIを呼び出してコレクションを更新
    // ここではモックの処理を行う
    final collection = await getContentCollection(collectionId);
    if (collection == null) {
      throw Exception('Collection not found');
    }
    
    return collection.copyWith(
      title: title,
      description: description,
      contentIds: contentIds,
      privacyLevel: privacyLevel,
      thumbnailUrl: thumbnailUrl,
      isDefault: isDefault,
      visibilitySettings: visibilitySettings,
      updatedAt: DateTime.now(),
    );
  }

  /// コンテンツコレクションを削除するメソッド
  Future<bool> deleteContentCollection(String collectionId) async {
    // 実際のアプリではAPIを呼び出してコレクションを削除
    // ここではモックの処理を行う
    return true;
  }

  /// コンテンツスケジュールを取得するメソッド
  Future<List<ContentSchedule>> getContentSchedules({
    required String starId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isPublished,
    int limit = 20,
    int offset = 0,
  }) async {
    // 実際のアプリではAPIからデータを取得
    // ここではモックデータを返す
    final now = DateTime.now();
    final start = startDate ?? now.subtract(const Duration(days: 7));
    final end = endDate ?? now.add(const Duration(days: 30));
    
    return List.generate(
      limit,
      (index) {
        final scheduledAt = now.add(Duration(days: index % 14 - 7));
        return ContentSchedule(
          id: 'schedule_${offset + index}',
          starId: starId,
          contentId: 'content_${offset + index}',
          scheduledAt: scheduledAt,
          isPublished: isPublished ?? scheduledAt.isBefore(now),
          createdAt: now.subtract(Duration(days: index + 1)),
          updatedAt: now.subtract(Duration(hours: index * 2)),
          metadata: {
            'title': 'スケジュールされたコンテンツ #${offset + index}',
            'type': _getRandomContentType(index).toString().split('.').last,
          },
        );
      },
    );
  }

  /// コンテンツスケジュールを作成するメソッド
  Future<ContentSchedule> createContentSchedule({
    required String starId,
    required String contentId,
    required DateTime scheduledAt,
    Map<String, dynamic>? metadata,
  }) async {
    // 実際のアプリではAPIを呼び出してスケジュールを作成
    // ここではモックの処理を行う
    final now = DateTime.now();
    final scheduleId = 'schedule_${now.millisecondsSinceEpoch}';
    
    return ContentSchedule(
      id: scheduleId,
      starId: starId,
      contentId: contentId,
      scheduledAt: scheduledAt,
      isPublished: false,
      createdAt: now,
      updatedAt: now,
      metadata: metadata ?? {},
    );
  }

  /// コンテンツスケジュールを更新するメソッド
  Future<ContentSchedule> updateContentSchedule({
    required String scheduleId,
    DateTime? scheduledAt,
    bool? isPublished,
    Map<String, dynamic>? metadata,
  }) async {
    // 実際のアプリではAPIを呼び出してスケジュールを更新
    // ここではモックの処理を行う
    final index = int.tryParse(scheduleId.split('_').last) ?? 0;
    final now = DateTime.now();
    
    return ContentSchedule(
      id: scheduleId,
      starId: 'star_1',
      contentId: 'content_$index',
      scheduledAt: scheduledAt ?? now.add(Duration(days: index % 14 - 7)),
      isPublished: isPublished ?? false,
      createdAt: now.subtract(Duration(days: index + 1)),
      updatedAt: now,
      metadata: metadata ?? {
        'title': 'スケジュールされたコンテンツ #$index',
        'type': _getRandomContentType(index).toString().split('.').last,
      },
    );
  }

  /// コンテンツスケジュールを削除するメソッド
  Future<bool> deleteContentSchedule(String scheduleId) async {
    // 実際のアプリではAPIを呼び出してスケジュールを削除
    // ここではモックの処理を行う
    return true;
  }

  /// プライバシー設定を取得するメソッド
  Future<PrivacySettings> getPrivacySettings(String starId) async {
    // 実際のアプリではAPIからデータを取得
    // ここではモックデータを返す
    return PrivacySettings(
      starId: starId,
      defaultLevels: {
        'post': PrivacyLevel.public,
        'article': PrivacyLevel.followers,
        'video': PrivacyLevel.public,
        'audio': PrivacyLevel.followers,
        'product': PrivacyLevel.public,
        'event': PrivacyLevel.followers,
        'exclusive': PrivacyLevel.members,
      },
      visibilityToggles: {
        'profile_age': false,
        'profile_location': true,
        'consumption_history': false,
        'purchase_history': false,
        'liked_content': true,
        'commented_content': true,
        'shared_content': true,
      },
      allowedUserIds: {
        'exclusive': ['user_1', 'user_2', 'user_3'],
        'private': ['user_1'],
      },
      blockedUserIds: {
        'all': ['user_99', 'user_100'],
        'comments': ['user_98', 'user_97'],
      },
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    );
  }

  /// プライバシー設定を更新するメソッド
  Future<PrivacySettings> updatePrivacySettings({
    required String starId,
    Map<String, PrivacyLevel>? defaultLevels,
    Map<String, bool>? visibilityToggles,
    Map<String, List<String>>? allowedUserIds,
    Map<String, List<String>>? blockedUserIds,
  }) async {
    // 実際のアプリではAPIを呼び出して設定を更新
    // ここではモックの処理を行う
    final currentSettings = await getPrivacySettings(starId);
    
    return currentSettings.copyWith(
      defaultLevels: defaultLevels,
      visibilityToggles: visibilityToggles,
      allowedUserIds: allowedUserIds,
      blockedUserIds: blockedUserIds,
      updatedAt: DateTime.now(),
    );
  }

  /// ランダムなコンテンツタイプを取得するヘルパーメソッド
  ContentType _getRandomContentType(int seed) {
    final types = ContentType.values;
    return types[seed % types.length];
  }

  /// ランダムなプライバシーレベルを取得するヘルパーメソッド
  PrivacyLevel _getRandomPrivacyLevel(int seed) {
    final levels = PrivacyLevel.values;
    return levels[seed % levels.length];
  }

  /// ランダムなコンテンツステータスを取得するヘルパーメソッド
  ContentStatus _getRandomContentStatus(int seed) {
    final statuses = [
      ContentStatus.draft,
      ContentStatus.scheduled,
      ContentStatus.published,
      ContentStatus.published,
      ContentStatus.published,
      ContentStatus.archived,
    ];
    return statuses[seed % statuses.length];
  }

  /// スケジュール日時を持つべきかどうかを判定するヘルパーメソッド
  bool _shouldHaveScheduledDate(int seed) {
    return seed % 3 == 1;
  }

  /// 公開済みかどうかを判定するヘルパーメソッド
  bool _<response clipped><NOTE>To save on context only part of this file has been shown to you. You should retry this tool after you have searched inside the file with `grep -n` in order to find the line numbers of what you are looking for.</NOTE>