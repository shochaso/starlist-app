import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/voting_repository.dart';
import '../../../data/models/voting_models.dart';

/// 投票システムのビジネスロジック層
class VotingService {
  final VotingRepository _repository;

  VotingService({
    required VotingRepository repository,
  }) : _repository = repository;

  /// Sポイント残高を取得
  Future<SPointBalance?> getSPointBalance(String userId) async {
    return await _repository.getSPointBalance(userId);
  }

  /// Sポイント取引履歴を取得
  Future<List<SPointTransaction>> getSPointTransactions(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    return await _repository.getSPointTransactions(
      userId,
      limit: limit,
      offset: offset,
    );
  }

  /// アクティブな投票投稿を取得
  Future<List<VotingPost>> getActiveVotingPosts({
    int limit = 20,
    int offset = 0,
  }) async {
    return await _repository.getActiveVotingPosts(
      limit: limit,
      offset: offset,
    );
  }

  /// 特定のスターの投票投稿を取得
  Future<List<VotingPost>> getVotingPostsByStar(
    String starId, {
    int limit = 20,
    int offset = 0,
  }) async {
    return await _repository.getVotingPostsByStar(
      starId,
      limit: limit,
      offset: offset,
    );
  }

  /// 投票投稿を作成（バリデーション付き）
  Future<VotingPost> createVotingPost({
    required String starId,
    required String title,
    String? description,
    required String optionA,
    required String optionB,
    String? optionAImageUrl,
    String? optionBImageUrl,
    int votingCost = 1,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) async {
    // バリデーション
    if (title.trim().isEmpty) {
      throw ArgumentError('タイトルは必須です');
    }
    if (optionA.trim().isEmpty || optionB.trim().isEmpty) {
      throw ArgumentError('両方の選択肢は必須です');
    }
    if (votingCost < 1) {
      throw ArgumentError('投票コストは1以上である必要があります');
    }
    if (expiresAt != null && expiresAt.isBefore(DateTime.now())) {
      throw ArgumentError('有効期限は未来の日時である必要があります');
    }

    return await _repository.createVotingPost(
      starId: starId,
      title: title,
      description: description,
      optionA: optionA,
      optionB: optionB,
      optionAImageUrl: optionAImageUrl,
      optionBImageUrl: optionBImageUrl,
      votingCost: votingCost,
      expiresAt: expiresAt,
      metadata: metadata,
    );
  }

  /// 投票を実行（バリデーション付き）
  Future<VotingResult> castVote(
    String userId,
    String votingPostId,
    VoteOption selectedOption,
  ) async {
    try {
      // 既に投票済みかチェック
      final existingVote = await _repository.getUserVoteForPost(
        userId,
        votingPostId,
      );
      if (existingVote != null) {
        return VotingResult(
          success: false,
          message: '既にこの投稿に投票済みです',
          errorCode: VotingErrorCode.alreadyVoted,
        );
      }

      // Sポイント残高をチェック
      final balance = await _repository.getSPointBalance(userId);
      if (balance == null) {
        return VotingResult(
          success: false,
          message: 'Sポイント残高が見つかりません',
          errorCode: VotingErrorCode.balanceNotFound,
        );
      }

      // 投票を実行
      final result = await _repository.castVote(votingPostId, selectedOption);
      
      if (result['success'] == true) {
        return VotingResult(
          success: true,
          message: '投票が完了しました',
        );
      } else {
        return VotingResult(
          success: false,
          message: result['error'] ?? '投票に失敗しました',
          errorCode: _parseErrorCode(result['error']),
        );
      }
    } catch (e) {
      return VotingResult(
        success: false,
        message: '予期しないエラーが発生しました: $e',
        errorCode: VotingErrorCode.unknown,
      );
    }
  }

  /// ユーザーの投票履歴を取得
  Future<List<Vote>> getUserVotes(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    return await _repository.getUserVotes(
      userId,
      limit: limit,
      offset: offset,
    );
  }

  /// 特定の投票投稿に対するユーザーの投票を取得
  Future<Vote?> getUserVoteForPost(
    String userId,
    String votingPostId,
  ) async {
    return await _repository.getUserVoteForPost(userId, votingPostId);
  }

  /// 投票投稿を非アクティブ化
  Future<void> deactivateVotingPost(String votingPostId) async {
    await _repository.deactivateVotingPost(votingPostId);
  }

  /// 投票投稿の統計を計算
  VotingStatistics calculateStatistics(VotingPost post) {
    return VotingStatistics.fromVotingPost(post);
  }

  /// 日次ログインボーナスを付与
  Future<DailyBonusResult> grantDailyLoginBonus(String userId) async {
    try {
      final granted = await _repository.grantDailyLoginBonus(userId);
      return DailyBonusResult(
        granted: granted,
        message: granted ? '日次ログインボーナス+10Sポイント獲得！' : '本日のボーナスは既に受け取り済みです',
      );
    } catch (e) {
      return DailyBonusResult(
        granted: false,
        message: 'ボーナス付与でエラーが発生しました: $e',
      );
    }
  }

  /// 投票投稿のリアルタイム更新を監視
  Stream<VotingPost> watchVotingPost(String votingPostId) {
    return _repository.watchVotingPost(votingPostId);
  }

  /// Sポイント残高のリアルタイム更新を監視
  Stream<SPointBalance> watchSPointBalance(String userId) {
    return _repository.watchSPointBalance(userId);
  }

  /// エラーコードを解析
  VotingErrorCode _parseErrorCode(String? error) {
    if (error == null) return VotingErrorCode.unknown;
    
    if (error.contains('Already voted')) {
      return VotingErrorCode.alreadyVoted;
    } else if (error.contains('Insufficient S-points')) {
      return VotingErrorCode.insufficientPoints;
    } else if (error.contains('expired')) {
      return VotingErrorCode.expired;
    } else if (error.contains('not active')) {
      return VotingErrorCode.notActive;
    } else if (error.contains('not found')) {
      return VotingErrorCode.notFound;
    } else {
      return VotingErrorCode.unknown;
    }
  }
}

/// 投票結果
class VotingResult {
  final bool success;
  final String message;
  final VotingErrorCode? errorCode;

  VotingResult({
    required this.success,
    required this.message,
    this.errorCode,
  });
}

/// 投票エラーコード
enum VotingErrorCode {
  alreadyVoted,      // 既に投票済み
  insufficientPoints, // Sポイント不足
  expired,           // 期限切れ
  notActive,         // 非アクティブ
  notFound,          // 見つからない
  balanceNotFound,   // 残高情報なし
  unknown,           // 不明なエラー
}

/// 日次ボーナス結果
class DailyBonusResult {
  final bool granted;
  final String message;

  DailyBonusResult({
    required this.granted,
    required this.message,
  });
}

// プロバイダーは voting_providers.dart に移動