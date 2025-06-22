import 'package:flutter/foundation.dart';

/// スターP取引タイプ
enum StarPointTransactionType {
  earned,  // 獲得
  spent,   // 使用
  bonus,   // ボーナス
  refund,  // 返金
}

/// スターP取引ソース
enum StarPointSourceType {
  dailyLogin,      // 日次ログイン
  voting,          // 投票参加
  premiumQuestion, // プレミアム質問
  purchase,        // 購入
  admin,           // 管理者操作
}

/// 投票選択肢
enum VoteOption {
  A, // オプションA
  B, // オプションB
}

/// スターP残高モデル
@immutable
class StarPointBalance {
  final String id;
  final String userId;
  final int balance;
  final int totalEarned;
  final int totalSpent;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StarPointBalance({
    required this.id,
    required this.userId,
    required this.balance,
    required this.totalEarned,
    required this.totalSpent,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSONからStarPointBalanceを作成
  factory StarPointBalance.fromJson(Map<String, dynamic> json) {
    return StarPointBalance(
      id: json['id'],
      userId: json['user_id'],
      balance: json['balance'] ?? 0,
      totalEarned: json['total_earned'] ?? 0,
      totalSpent: json['total_spent'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// StarPointBalanceをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'balance': balance,
      'total_earned': totalEarned,
      'total_spent': totalSpent,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// コピーを作成
  StarPointBalance copyWith({
    String? id,
    String? userId,
    int? balance,
    int? totalEarned,
    int? totalSpent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StarPointBalance(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      totalEarned: totalEarned ?? this.totalEarned,
      totalSpent: totalSpent ?? this.totalSpent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// スターPが足りているかチェック
  bool hasSufficientPoints(int requiredPoints) {
    return balance >= requiredPoints;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StarPointBalance &&
        other.id == id &&
        other.userId == userId &&
        other.balance == balance &&
        other.totalEarned == totalEarned &&
        other.totalSpent == totalSpent &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        balance,
        totalEarned,
        totalSpent,
        createdAt,
        updatedAt,
      );
}

/// スターP取引履歴モデル
@immutable
class StarPointTransaction {
  final String id;
  final String userId;
  final int amount;
  final StarPointTransactionType transactionType;
  final StarPointSourceType sourceType;
  final String? sourceId;
  final String? description;
  final DateTime createdAt;

  const StarPointTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.transactionType,
    required this.sourceType,
    this.sourceId,
    this.description,
    required this.createdAt,
  });

  /// JSONからStarPointTransactionを作成
  factory StarPointTransaction.fromJson(Map<String, dynamic> json) {
    return StarPointTransaction(
      id: json['id'],
      userId: json['user_id'],
      amount: json['amount'],
      transactionType: StarPointTransactionType.values.firstWhere(
        (e) => e.name == json['transaction_type'],
        orElse: () => StarPointTransactionType.earned,
      ),
      sourceType: StarPointSourceType.values.firstWhere(
        (e) => e.name == json['source_type'],
        orElse: () => StarPointSourceType.admin,
      ),
      sourceId: json['source_id'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// StarPointTransactionをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'transaction_type': transactionType.name,
      'source_type': sourceType.name,
      'source_id': sourceId,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 取引が収入かどうか
  bool get isEarning => amount > 0;

  /// 取引が支出かどうか
  bool get isSpending => amount < 0;

  /// 絶対値を取得
  int get absoluteAmount => amount.abs();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StarPointTransaction &&
        other.id == id &&
        other.userId == userId &&
        other.amount == amount &&
        other.transactionType == transactionType &&
        other.sourceType == sourceType &&
        other.sourceId == sourceId &&
        other.description == description &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        amount,
        transactionType,
        sourceType,
        sourceId,
        description,
        createdAt,
      );
}

/// 2択投稿モデル
@immutable
class VotingPost {
  final String id;
  final String starId;
  final String title;
  final String? description;
  final String optionA;
  final String optionB;
  final String? optionAImageUrl;
  final String? optionBImageUrl;
  final int votingCost;
  final DateTime? expiresAt;
  final bool isActive;
  final int totalVotes;
  final int optionAVotes;
  final int optionBVotes;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VotingPost({
    required this.id,
    required this.starId,
    required this.title,
    this.description,
    required this.optionA,
    required this.optionB,
    this.optionAImageUrl,
    this.optionBImageUrl,
    required this.votingCost,
    this.expiresAt,
    required this.isActive,
    required this.totalVotes,
    required this.optionAVotes,
    required this.optionBVotes,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSONからVotingPostを作成
  factory VotingPost.fromJson(Map<String, dynamic> json) {
    return VotingPost(
      id: json['id'],
      starId: json['star_id'],
      title: json['title'],
      description: json['description'],
      optionA: json['option_a'],
      optionB: json['option_b'],
      optionAImageUrl: json['option_a_image_url'],
      optionBImageUrl: json['option_b_image_url'],
      votingCost: json['voting_cost'] ?? 1,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
      isActive: json['is_active'] ?? true,
      totalVotes: json['total_votes'] ?? 0,
      optionAVotes: json['option_a_votes'] ?? 0,
      optionBVotes: json['option_b_votes'] ?? 0,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// VotingPostをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'star_id': starId,
      'title': title,
      'description': description,
      'option_a': optionA,
      'option_b': optionB,
      'option_a_image_url': optionAImageUrl,
      'option_b_image_url': optionBImageUrl,
      'voting_cost': votingCost,
      'expires_at': expiresAt?.toIso8601String(),
      'is_active': isActive,
      'total_votes': totalVotes,
      'option_a_votes': optionAVotes,
      'option_b_votes': optionBVotes,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// コピーを作成
  VotingPost copyWith({
    String? id,
    String? starId,
    String? title,
    String? description,
    String? optionA,
    String? optionB,
    String? optionAImageUrl,
    String? optionBImageUrl,
    int? votingCost,
    DateTime? expiresAt,
    bool? isActive,
    int? totalVotes,
    int? optionAVotes,
    int? optionBVotes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VotingPost(
      id: id ?? this.id,
      starId: starId ?? this.starId,
      title: title ?? this.title,
      description: description ?? this.description,
      optionA: optionA ?? this.optionA,
      optionB: optionB ?? this.optionB,
      optionAImageUrl: optionAImageUrl ?? this.optionAImageUrl,
      optionBImageUrl: optionBImageUrl ?? this.optionBImageUrl,
      votingCost: votingCost ?? this.votingCost,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      totalVotes: totalVotes ?? this.totalVotes,
      optionAVotes: optionAVotes ?? this.optionAVotes,
      optionBVotes: optionBVotes ?? this.optionBVotes,
      metadata: metadata ?? Map<String, dynamic>.from(this.metadata),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 投票が期限切れかどうか
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// 投票可能かどうか
  bool get canVote => isActive && !isExpired;

  /// オプションAの投票率（0.0-1.0）
  double get optionAPercentage {
    if (totalVotes == 0) return 0.0;
    return optionAVotes / totalVotes;
  }

  /// オプションBの投票率（0.0-1.0）
  double get optionBPercentage {
    if (totalVotes == 0) return 0.0;
    return optionBVotes / totalVotes;
  }

  /// 残り時間（期限がある場合）
  Duration? get timeRemaining {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expiresAt!)) return Duration.zero;
    return expiresAt!.difference(now);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VotingPost &&
        other.id == id &&
        other.starId == starId &&
        other.title == title &&
        other.description == description &&
        other.optionA == optionA &&
        other.optionB == optionB &&
        other.optionAImageUrl == optionAImageUrl &&
        other.optionBImageUrl == optionBImageUrl &&
        other.votingCost == votingCost &&
        other.expiresAt == expiresAt &&
        other.isActive == isActive &&
        other.totalVotes == totalVotes &&
        other.optionAVotes == optionAVotes &&
        other.optionBVotes == optionBVotes &&
        mapEquals(other.metadata, metadata) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        starId,
        title,
        description,
        optionA,
        optionB,
        optionAImageUrl,
        optionBImageUrl,
        votingCost,
        expiresAt,
        isActive,
        totalVotes,
        optionAVotes,
        optionBVotes,
        metadata,
        createdAt,
        updatedAt,
      );
}

/// 投票記録モデル
@immutable
class Vote {
  final String id;
  final String votingPostId;
  final String userId;
  final VoteOption selectedOption;
  final int sPointsSpent;
  final DateTime votedAt;

  const Vote({
    required this.id,
    required this.votingPostId,
    required this.userId,
    required this.selectedOption,
    required this.sPointsSpent,
    required this.votedAt,
  });

  /// JSONからVoteを作成
  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      id: json['id'],
      votingPostId: json['voting_post_id'],
      userId: json['user_id'],
      selectedOption: json['selected_option'] == 'A' ? VoteOption.A : VoteOption.B,
      sPointsSpent: json['s_points_spent'] ?? 1,
      votedAt: DateTime.parse(json['voted_at']),
    );
  }

  /// VoteをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'voting_post_id': votingPostId,
      'user_id': userId,
      'selected_option': selectedOption == VoteOption.A ? 'A' : 'B',
      's_points_spent': sPointsSpent,
      'voted_at': votedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vote &&
        other.id == id &&
        other.votingPostId == votingPostId &&
        other.userId == userId &&
        other.selectedOption == selectedOption &&
        other.sPointsSpent == sPointsSpent &&
        other.votedAt == votedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        votingPostId,
        userId,
        selectedOption,
        sPointsSpent,
        votedAt,
      );
}

/// 投票結果統計モデル
@immutable
class VotingStatistics {
  final String votingPostId;
  final int totalVotes;
  final int optionAVotes;
  final int optionBVotes;
  final double optionAPercentage;
  final double optionBPercentage;
  final int totalSPointsCollected;
  final DateTime lastUpdated;

  const VotingStatistics({
    required this.votingPostId,
    required this.totalVotes,
    required this.optionAVotes,
    required this.optionBVotes,
    required this.optionAPercentage,
    required this.optionBPercentage,
    required this.totalSPointsCollected,
    required this.lastUpdated,
  });

  /// VotingPostから統計を作成
  factory VotingStatistics.fromVotingPost(VotingPost post) {
    return VotingStatistics(
      votingPostId: post.id,
      totalVotes: post.totalVotes,
      optionAVotes: post.optionAVotes,
      optionBVotes: post.optionBVotes,
      optionAPercentage: post.optionAPercentage,
      optionBPercentage: post.optionBPercentage,
      totalSPointsCollected: post.totalVotes * post.votingCost,
      lastUpdated: post.updatedAt,
    );
  }

  /// 勝利オプションを取得
  VoteOption? get winningOption {
    if (optionAVotes > optionBVotes) return VoteOption.A;
    if (optionBVotes > optionAVotes) return VoteOption.B;
    return null; // 引き分け
  }

  /// 引き分けかどうか
  bool get isTie => optionAVotes == optionBVotes;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VotingStatistics &&
        other.votingPostId == votingPostId &&
        other.totalVotes == totalVotes &&
        other.optionAVotes == optionAVotes &&
        other.optionBVotes == optionBVotes &&
        other.optionAPercentage == optionAPercentage &&
        other.optionBPercentage == optionBPercentage &&
        other.totalSPointsCollected == totalSPointsCollected &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode => Object.hash(
        votingPostId,
        totalVotes,
        optionAVotes,
        optionBVotes,
        optionAPercentage,
        optionBPercentage,
        totalSPointsCollected,
        lastUpdated,
      );
}