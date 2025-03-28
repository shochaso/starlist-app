import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/badge_models.dart';

/// インタラクションサービスクラス
class InteractionService {
  /// インタラクションを取得するメソッド
  Future<List<Interaction>> getInteractions({
    required String starId,
    String? userId,
    InteractionType? type,
    int limit = 20,
    int offset = 0,
  }) async {
    // 実際のアプリではAPIからデータを取得
    // ここではモックデータを返す
    return List.generate(
      limit,
      (index) => Interaction(
        id: 'interaction_${offset + index}',
        userId: userId ?? 'user_${100 + index}',
        starId: starId,
        type: type ?? _getRandomInteractionType(index),
        timestamp: DateTime.now().subtract(Duration(hours: index * 2)),
        data: _generateInteractionData(index, type ?? _getRandomInteractionType(index)),
        isPublic: true,
      ),
    );
  }

  /// ユーザーとスター間のインタラクションを取得するメソッド
  Future<List<Interaction>> getUserStarInteractions({
    required String userId,
    required String starId,
    InteractionType? type,
    int limit = 20,
    int offset = 0,
  }) async {
    // 実際のアプリではAPIからデータを取得
    // ここではモックデータを返す
    return List.generate(
      limit,
      (index) => Interaction(
        id: 'user_star_interaction_${offset + index}',
        userId: userId,
        starId: starId,
        type: type ?? _getRandomInteractionType(index),
        timestamp: DateTime.now().subtract(Duration(days: index)),
        data: _generateInteractionData(index, type ?? _getRandomInteractionType(index)),
        isPublic: index % 3 != 0, // 一部のインタラクションは非公開
      ),
    );
  }

  /// コメントを投稿するメソッド
  Future<Interaction> postComment({
    required String userId,
    required String starId,
    required String content,
    bool isPublic = true,
  }) async {
    // 実際のアプリではAPIを呼び出してコメントを投稿
    // ここではモックの処理を行う
    return Interaction(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      starId: starId,
      type: InteractionType.comment,
      timestamp: DateTime.now(),
      data: {
        'content': content,
        'likes': 0,
        'replies': [],
      },
      isPublic: isPublic,
    );
  }

  /// いいねを送信するメソッド
  Future<Interaction> sendLike({
    required String userId,
    required String starId,
    required String targetId,
    String? targetType,
  }) async {
    // 実際のアプリではAPIを呼び出していいねを送信
    // ここではモックの処理を行う
    return Interaction(
      id: 'like_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      starId: starId,
      type: InteractionType.like,
      timestamp: DateTime.now(),
      data: {
        'targetId': targetId,
        'targetType': targetType ?? 'post',
      },
      isPublic: true,
    );
  }

  /// シェアを行うメソッド
  Future<Interaction> shareContent({
    required String userId,
    required String starId,
    required String contentId,
    String? contentType,
    String? message,
  }) async {
    // 実際のアプリではAPIを呼び出してシェアを行う
    // ここではモックの処理を行う
    return Interaction(
      id: 'share_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      starId: starId,
      type: InteractionType.share,
      timestamp: DateTime.now(),
      data: {
        'contentId': contentId,
        'contentType': contentType ?? 'post',
        'message': message,
      },
      isPublic: true,
    );
  }

  /// 購入情報を記録するメソッド
  Future<Interaction> recordPurchase({
    required String userId,
    required String starId,
    required String productId,
    required double amount,
    String? productName,
  }) async {
    // 実際のアプリではAPIを呼び出して購入情報を記録
    // ここではモックの処理を行う
    return Interaction(
      id: 'purchase_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      starId: starId,
      type: InteractionType.purchase,
      timestamp: DateTime.now(),
      data: {
        'productId': productId,
        'productName': productName,
        'amount': amount,
      },
      isPublic: false, // 購入情報は非公開
    );
  }

  /// 寄付を記録するメソッド
  Future<Interaction> recordDonation({
    required String userId,
    required String starId,
    required double amount,
    String? message,
  }) async {
    // 実際のアプリではAPIを呼び出して寄付を記録
    // ここではモックの処理を行う
    return Interaction(
      id: 'donation_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      starId: starId,
      type: InteractionType.donation,
      timestamp: DateTime.now(),
      data: {
        'amount': amount,
        'message': message,
      },
      isPublic: message != null, // メッセージがある場合は公開
    );
  }

  /// メッセージを送信するメソッド
  Future<Interaction> sendMessage({
    required String userId,
    required String starId,
    required String content,
    List<String>? attachments,
  }) async {
    // 実際のアプリではAPIを呼び出してメッセージを送信
    // ここではモックの処理を行う
    return Interaction(
      id: 'message_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      starId: starId,
      type: InteractionType.message,
      timestamp: DateTime.now(),
      data: {
        'content': content,
        'attachments': attachments ?? [],
        'read': false,
      },
      isPublic: false, // メッセージは非公開
    );
  }

  /// インタラクションを削除するメソッド
  Future<bool> deleteInteraction(String interactionId) async {
    // 実際のアプリではAPIを呼び出してインタラクションを削除
    // ここではモックの処理を行う
    return true;
  }

  /// インタラクションの公開設定を更新するメソッド
  Future<Interaction> updateInteractionVisibility(String interactionId, bool isPublic) async {
    // 実際のアプリではAPIを呼び出して公開設定を更新
    // ここではモックの処理を行う
    final interactions = await getInteractions(starId: 'star_1', limit: 50);
    final interaction = interactions.firstWhere((i) => i.id == interactionId);
    
    return Interaction(
      id: interaction.id,
      userId: interaction.userId,
      starId: interaction.starId,
      type: interaction.type,
      timestamp: interaction.timestamp,
      data: interaction.data,
      isPublic: isPublic,
    );
  }

  /// ランダムなインタラクションタイプを取得するヘルパーメソッド
  InteractionType _getRandomInteractionType(int seed) {
    final types = [
      InteractionType.comment,
      InteractionType.like,
      InteractionType.share,
      InteractionType.purchase,
      InteractionType.donation,
      InteractionType.message,
    ];
    return types[seed % types.length];
  }

  /// インタラクションデータを生成するヘルパーメソッド
  Map<String, dynamic> _generateInteractionData(int index, InteractionType type) {
    switch (type) {
      case InteractionType.comment:
        return {
          'content': 'これはテストコメント #$index です。スターの投稿に対するファンからのコメントです。',
          'likes': index % 10,
          'replies': List.generate(index % 3, (i) => {
            'userId': 'user_${200 + i}',
            'content': 'これは返信 #$i です。',
            'timestamp': DateTime.now().subtract(Duration(hours: i)).toIso8601String(),
          }),
        };
      case InteractionType.like:
        return {
          'targetId': 'post_$index',
          'targetType': index % 2 == 0 ? 'post' : 'comment',
        };
      case InteractionType.share:
        return {
          'contentId': 'post_$index',
          'contentType': 'post',
          'message': index % 2 == 0 ? 'このコンテンツをシェアします！' : null,
        };
      case InteractionType.purchase:
        return {
          'productId': 'product_$index',
          'productName': 'テスト商品 #$index',
          'amount': 1000.0 + (index * 500.0),
        };
      case InteractionType.donation:
        return {
          'amount': 500.0 + (index * 100.0),
          'message': index % 2 == 0 ? 'いつも応援しています！' : null,
        };
      case InteractionType.message:
        return {
          'content': 'これはテストメッセージ #$index です。',
          'attachments': index % 3 == 0 ? ['attachment_1', 'attachment_2'] : [],
          'read': index % 2 == 0,
        };
    }
  }
}

/// インタラクションサービスのプロバイダー
final interactionServiceProvider = Provider<InteractionService>((ref) {
  return InteractionService();
});

/// スターのインタラクションのプロバイダー
final starInteractionsProvider = FutureProvider.family<List<Interaction>, Map<String, dynamic>>((ref, params) async {
  final interactionService = ref.watch(interactionServiceProvider);
  return await interactionService.getInteractions(
    starId: params['starId'] as String,
    type: params['type'] as InteractionType?,
    limit: params['limit'] as int? ?? 20,
    offset: params['offset'] as int? ?? 0,
  );
});

/// ユーザーとスター間のインタラクションのプロバイダー
final userStarInteractionsProvider = FutureProvider.family<List<Interaction>, Map<String, dynamic>>((ref, params) async {
  final interactionService = ref.watch(interactionServiceProvider);
  return await interactionService.getUserStarInteractions(
    userId: params['userId'] as String,
    starId: params['starId'] as String,
    type: params['type'] as InteractionType?,
    limit: params['limit'] as int? ?? 20,
    offset: params['offset'] as int? ?? 0,
  );
});
