import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/privacy_models.dart';

/// プライバシー設定サービスクラス
class PrivacySettingsService {
  /// フィルタリング設定を取得するメソッド
  Future<FilteringSettings> getFilteringSettings(String userId) async {
    // 実際のアプリではAPIからデータを取得
    // ここではモックデータを返す
    return FilteringSettings(
      userId: userId,
      generalLevel: FilteringLevel.moderate,
      categoryLevels: {
        'comments': FilteringLevel.strict,
        'messages': FilteringLevel.moderate,
        'userContent': FilteringLevel.light,
        'recommendations': FilteringLevel.light,
      },
      customBlockedWords: [
        '不適切な単語1',
        '不適切な単語2',
        '不適切な単語3',
      ],
      customAllowedWords: [
        '例外単語1',
        '例外単語2',
      ],
      enableAIFiltering: true,
      autoRejectSpam: true,
      requireApproval: false,
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    );
  }

  /// フィルタリング設定を更新するメソッド
  Future<FilteringSettings> updateFilteringSettings({
    required String userId,
    FilteringLevel? generalLevel,
    Map<String, FilteringLevel>? categoryLevels,
    List<String>? customBlockedWords,
    List<String>? customAllowedWords,
    bool? enableAIFiltering,
    bool? autoRejectSpam,
    bool? requireApproval,
  }) async {
    // 実際のアプリではAPIを呼び出して設定を更新
    // ここではモックの処理を行う
    final currentSettings = await getFilteringSettings(userId);
    
    return currentSettings.copyWith(
      generalLevel: generalLevel,
      categoryLevels: categoryLevels,
      customBlockedWords: customBlockedWords,
      customAllowedWords: customAllowedWords,
      enableAIFiltering: enableAIFiltering,
      autoRejectSpam: autoRejectSpam,
      requireApproval: requireApproval,
      updatedAt: DateTime.now(),
    );
  }

  /// ブロック単語を追加するメソッド
  Future<FilteringSettings> addBlockedWord(String userId, String word) async {
    // 実際のアプリではAPIを呼び出して単語を追加
    // ここではモックの処理を行う
    final currentSettings = await getFilteringSettings(userId);
    return currentSettings.addBlockedWord(word);
  }

  /// 許可単語を追加するメソッド
  Future<FilteringSettings> addAllowedWord(String userId, String word) async {
    // 実際のアプリではAPIを呼び出して単語を追加
    // ここではモックの処理を行う
    final currentSettings = await getFilteringSettings(userId);
    return currentSettings.addAllowedWord(word);
  }

  /// テキストをフィルタリングするメソッド
  Future<String> filterText(String text, FilteringSettings settings) async {
    // 実際のアプリではAIフィルタリングやルールベースのフィルタリングを適用
    // ここではモックの処理を行う
    String filteredText = text;
    
    // カスタムブロック単語をフィルタリング
    for (final word in settings.customBlockedWords) {
      if (filteredText.toLowerCase().contains(word.toLowerCase())) {
        filteredText = filteredText.replaceAll(
          RegExp(word, caseSensitive: false),
          '***',
        );
      }
    }
    
    // カスタム許可単語は例外として処理
    for (final word in settings.customAllowedWords) {
      // 許可単語が含まれる場合は、その部分をマークして後で復元
      if (filteredText.toLowerCase().contains(word.toLowerCase())) {
        filteredText = filteredText.replaceAll(
          RegExp(word, caseSensitive: false),
          '___ALLOWED___$word___ALLOWED___',
        );
      }
    }
    
    // フィルタリングレベルに応じた処理
    switch (settings.generalLevel) {
      case FilteringLevel.none:
        // フィルタリングなし
        break;
      case FilteringLevel.light:
        // 軽度フィルタリング（重大な不適切単語のみ）
        filteredText = _applyLightFiltering(filteredText);
        break;
      case FilteringLevel.moderate:
        // 中程度フィルタリング
        filteredText = _applyModerateFiltering(filteredText);
        break;
      case FilteringLevel.strict:
        // 厳格フィルタリング
        filteredText = _applyStrictFiltering(filteredText);
        break;
      case FilteringLevel.custom:
        // カスタムフィルタリング（すでに適用済み）
        break;
    }
    
    // 許可単語を復元
    filteredText = filteredText.replaceAll(
      RegExp(r'___ALLOWED___(.+?)___ALLOWED___'),
      (match) => match.group(1) ?? '',
    );
    
    return filteredText;
  }

  /// 軽度フィルタリングを適用するヘルパーメソッド
  String _applyLightFiltering(String text) {
    // 実際のアプリでは重大な不適切単語のリストを使用
    final badWords = ['重大な不適切単語1', '重大な不適切単語2', '重大な不適切単語3'];
    
    String filteredText = text;
    for (final word in badWords) {
      filteredText = filteredText.replaceAll(
        RegExp(word, caseSensitive: false),
        '***',
      );
    }
    
    return filteredText;
  }

  /// 中程度フィルタリングを適用するヘルパーメソッド
  String _applyModerateFiltering(String text) {
    // 軽度フィルタリングを適用
    String filteredText = _applyLightFiltering(text);
    
    // 実際のアプリでは中程度の不適切単語のリストを使用
    final badWords = ['中程度の不適切単語1', '中程度の不適切単語2', '中程度の不適切単語3'];
    
    for (final word in badWords) {
      filteredText = filteredText.replaceAll(
        RegExp(word, caseSensitive: false),
        '***',
      );
    }
    
    return filteredText;
  }

  /// 厳格フィルタリングを適用するヘルパーメソッド
  String _applyStrictFiltering(String text) {
    // 中程度フィルタリングを適用
    String filteredText = _applyModerateFiltering(text);
    
    // 実際のアプリでは軽度の不適切単語のリストを使用
    final badWords = ['軽度の不適切単語1', '軽度の不適切単語2', '軽度の不適切単語3'];
    
    for (final word in badWords) {
      filteredText = filteredText.replaceAll(
        RegExp(word, caseSensitive: false),
        '***',
      );
    }
    
    return filteredText;
  }

  /// コメントを取得するメソッド
  Future<List<Comment>> getComments({
    required String contentId,
    String? parentId,
    CommentStatus? status,
    int limit = 20,
    int offset = 0,
  }) async {
    // 実際のアプリではAPIからデータを取得
    // ここではモックデータを返す
    return List.generate(
      limit,
      (index) => Comment(
        id: 'comment_${contentId}_${offset + index}',
        contentId: contentId,
        parentId: parentId,
        authorId: 'user_${(offset + index) % 10}',
        authorName: 'ユーザー ${(offset + index) % 10}',
        authorAvatarUrl: 'https://example.com/avatars/user_${(offset + index) % 10}.jpg',
        text: 'これはテストコメント #${offset + index} です。コンテンツID: $contentId',
        status: status ?? _getRandomCommentStatus(index),
        createdAt: DateTime.now().subtract(Duration(hours: (offset + index) * 2)),
        updatedAt: (offset + index) % 3 == 0 ? DateTime.now().subtract(Duration(hours: (offset + index))) : null,
        likeCount: (offset + index) * 2,
        replyCount: (offset + index) % 5,
        isEdited: (offset + index) % 3 == 0,
        metadata: {
          'ip': '192.168.1.${(offset + index) % 255}',
          'userAgent': 'Mozilla/5.0 (Test Browser)',
          'flaggedBy': (offset + index) % 7 == 0 ? ['user_1', 'user_2'] : [],
        },
      ),
    );
  }

  /// コメントを取得するメソッド
  Future<Comment?> getComment(String commentId) async {
    // 実際のアプリではAPIからデータを取得
    // ここではモックデータを返す
    final parts = commentId.split('_');
    if (parts.length < 3) return null;
    
    final contentId = parts[1];
    final index = int.tryParse(parts[2]) ?? 0;
    
    return Comment(
      id: commentId,
      contentId: contentId,
      parentId: index % 5 == 0 ? null : 'comment_${contentId}_${index - (index % 5)}',
      authorId: 'user_${index % 10}',
      authorName: 'ユーザー ${index % 10}',
      authorAvatarUrl: 'https://example.com/avatars/user_${index % 10}.jpg',
      text: 'これはテストコメント #$index です。コンテンツID: $contentId',
      status: _getRandomCommentStatus(index),
      createdAt: DateTime.now().subtract(Duration(hours: index * 2)),
      updatedAt: index % 3 == 0 ? DateTime.now().subtract(Duration(hours: index)) : null,
      likeCount: index * 2,
      replyCount: index % 5,
      isEdited: index % 3 == 0,
      metadata: {
        'ip': '192.168.1.${index % 255}',
        'userAgent': 'Mozilla/5.0 (Test Browser)',
        'flaggedBy': index % 7 == 0 ? ['user_1', 'user_2'] : [],
      },
    );
  }

  /// コメントを作成するメソッド
  Future<Comment> createComment({
    required String contentId,
    String? parentId,
    required String authorId,
    required String authorName,
    String? authorAvatarUrl,
    required String text,
    Map<String, dynamic>? metadata,
  }) async {
    // 実際のアプリではAPIを呼び出してコメントを作成
    // ここではモックの処理を行う
    final now = DateTime.now();
    final commentId = 'comment_${contentId}_${now.millisecondsSinceEpoch}';
    
    // フィルタリング設定を取得
    final filteringSettings = await getFilteringSettings(authorId);
    
    // テキストをフィルタリング
    final filteredText = await filterText(text, filteringSettings);
    
    // 自動承認するかどうかを決定
    final status = filteringSettings.requireApproval
        ? CommentStatus.pending
        : CommentStatus.approved;
    
    return Comment(
      id: commentId,
      contentId: contentId,
      parentId: parentId,
      authorId: authorId,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      text: filteredText,
      status: status,
      createdAt: now,
      updatedAt: null,
      likeCount: 0,
      replyCount: 0,
      isEdited: false,
      metadata: metadata ?? {
        'ip': '192.168.1.1',
        'userAgent': 'Mozilla/5.0 (Test Browser)',
        'flaggedBy': [],
      },
    );
  }

  /// コメントを更新するメソッド
  Future<Comment> updateComment({
    required String commentId,
    required String text,
    required String currentUserId,
  }) async {
    // 実際のアプリではAPIを呼び出してコメントを更新
    // ここではモックの処理を行う
    final comment = await getComment(commentId);
    if (comment == null) {
      throw Exception('Comment not found');
    }
    
    if (!comment.isEditable(currentUserId)) {
      throw Exception('You do not have permission to edit this comment');
    }
    
    // フィルタリング設定を取得
    final filteringSettings = await getFilteringSettings(currentUserId);
    
    // テキストをフィルタリング
    final filteredText = await filterText(text, filteringSettings);
    
    return comment.copyWith(
      text: filteredText,
      updatedAt: DateTime.now(),
      isEdited: true,
    );
  }

  /// コメントステータスを更新するメソッド
  Future<Comment> updateCommentStatus({
    required String commentId,
    required CommentStatus status,
  }) async {
    // 実際のアプリではAPIを呼び出してコメントステータスを更新
    // ここではモックの処理を行う
    final comment = await getComment(commentId);
    if (comment == null) {
      throw Exception('Comment not found');
    }
    
    return comment.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
  }

  /// コメントを削除するメソッド
  Future<bool> deleteComment(String commentId, String currentUserId) async {
    // 実際のアプリではAPIを呼び出してコメントを削除
    // ここではモックの処理を行う
    final comment = await getComment(commentId);
    if (comment == null) {
      throw Exception('Comment not found');
    }
    
    if (comment.authorId != currentUserId) {
      throw Exception('You do not have permission to delete this comment');
    }
    
    return true;
  }

  /// コメント通知設定を取得するメソッド
  Future<CommentNotificationSettings> getCommentNotificationSettings(String userId) async {
    // 実際のアプリではAPIからデータを取得
    // ここではモックデータを返す
    return CommentNotificationSettings(
      userId: userId,
      notifyOnNewComment: true,
      notifyOnReply: true,
      notifyOnLike: true,
      notifyOnApproval: true,
      notifyOnRejection: true,
      emailNotifications: true,
      pushNotifications: true,
      mutedContentIds: [],
      mutedUserIds: [],
      updatedAt: DateTime.now().subtract(const Duration(days: 14)),
    );
  }

  /// コメント通知設定を更新するメソッド
  Future<CommentNotificationSettings> updateCommentNotificationSettings({
    required String userId,
    bool? notifyOnNewComment,
    bool? notifyOnReply,
    bool? notifyOnLike,
    bool? notifyOnApproval,
    bool? notifyOnRejection,
    bool? emailNotifications,
    bool? pushNotifications,
    List<String>? mutedContentIds,
    List<String>? mutedUserIds,
  }) async {
    // 実際のアプリではAPIを呼び出して設定を更新
    // ここではモックの処理を行う
    final currentSettings = await getCommentNotificationSettings(userId);
    
    return currentSettings.copyWith(
      notifyOnNewComment: notifyOnNewComment,
      notifyOnReply: notifyOnReply,
      notifyOnLike: notifyOnLike,
      notifyOnApproval: notifyOnApproval,
      notifyOnRejection: notifyOnRejection,
      emailNotifications: emailNotifications,
      pushNotifications: pushNotifications,
      mutedContentIds: mutedContentIds,
      mutedUserIds: mutedUserIds,
      updatedAt: DateTime.now(),
    );
  }

  /// コンテンツをミュートするメソッド
  Future<CommentNotificationSettings> muteContent(String userId, String contentId) async {
    // 実際のアプリではAPIを呼び出してコンテンツをミュート
    // ここではモックの処理を行う
    final currentSettings = await getCommentNotificationSettings(userId);
    return currentSettings.muteContent(contentId);
  }

  /// ユーザーをミュートするメソッド
  Future<CommentNotificationSettings> muteUser(String userId, String targetUserId) async {
    // 実際のアプリではAPIを呼び出してユーザーをミュート
    // ここではモックの処理を行う
    final currentSettings = await getCommentNotificationSettings(userId);
    return currentSettings.muteUser(targetUserId);
  }

  /// ランダムなコメントステータスを取得するヘルパーメソッド
  CommentStatus _getRandomCommentStatus(int seed) {
    final statuses = [
      CommentStatus.approved,
      CommentStatus.approved,
      CommentStatus.approved,
      CommentStatus.approved,
      CommentStatus.pending,
      CommentStatus.flagged,
      CommentStatus.rejected,
      CommentStatus.spam,
    ];
    return statuses[seed % statuses.length];
  }
}

/// プライバシー設定サービスのプロバイダー
final privacySettingsServiceProvider = Provider<PrivacySettingsService>((ref) {
  return PrivacySettingsService();
});

/// フィルタリング設定のプロバイダー
final filteringSettingsProvider = FutureProvider.family<FilteringSettings, String>((ref, userId) async {
  final privacyService = ref.watch(privacySettingsServiceProvider);
  return await privacyService.getFilteringSettings(userId);
});

/// コメントリストのプロバイダー
final commentsProvider = FutureProvider.family<List<Comment>, Map<String, dynamic>>((ref, params) async {
  final privacyService = ref.watch(privacySettingsServiceProvider);
  return await privacyService.getComments(
    contentId: params['contentId'] as String,
    parentId: params['parentId'] as String?,
    status: params['status'] as CommentStatus?,
    limit: params['limit'] as int? ?? 20,
    offset: params['offset'] as int? ?? 0,
  );
});

/// コメント詳細のプロバイダー
final commentDetailProvider = FutureProvider.family<Comment?, String>((ref, commentId) async {
  final privacyService = ref.watch(privacySettingsServiceProvider);
  return await privacyService.getComment(commentId);
});

/// コメント通知設定のプロバイダー
final commentNotificationSettingsProvider = FutureProvider.family<CommentNotificationSettings, String>((ref, userId) async {
  final privacyService = ref.watch(privacySettingsServiceProvider);
  return await privacyService.getCommentNotificationSettings(userId);
});
