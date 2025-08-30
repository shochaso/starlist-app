import 'package:flutter/material.dart';

/// ガチャ回数情報
class GachaAttempts {
  const GachaAttempts({
    required this.id,
    required this.userId,
    required this.date,
    required this.baseAttempts,
    required this.bonusAttempts,
    required this.usedAttempts,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final DateTime date;
  final int baseAttempts;      // 基本ガチャ回数（1日1回）
  final int bonusAttempts;     // 広告視聴によるボーナス回数
  final int usedAttempts;      // 使用済み回数
  final DateTime createdAt;
  final DateTime updatedAt;

  factory GachaAttempts.fromJson(Map<String, dynamic> json) {
    return GachaAttempts(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      baseAttempts: json['base_attempts'] as int,
      bonusAttempts: json['bonus_attempts'] as int,
      usedAttempts: json['used_attempts'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'base_attempts': baseAttempts,
      'bonus_attempts': bonusAttempts,
      'used_attempts': usedAttempts,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// ガチャ回数の統計情報
class GachaAttemptsStats {
  const GachaAttemptsStats({
    required this.baseAttempts,      // 基本ガチャ回数
    required this.bonusAttempts,     // ボーナス回数
    required this.usedAttempts,      // 使用済み回数
    required this.availableAttempts, // 利用可能な回数
    required this.date,              // 対象日付
  });

  final int baseAttempts;
  final int bonusAttempts;
  final int usedAttempts;
  final int availableAttempts;
  final DateTime date;

  factory GachaAttemptsStats.fromJson(Map<String, dynamic> json) {
    return GachaAttemptsStats(
      baseAttempts: json['baseAttempts'] as int,
      bonusAttempts: json['bonusAttempts'] as int,
      usedAttempts: json['usedAttempts'] as int,
      availableAttempts: json['availableAttempts'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseAttempts': baseAttempts,
      'bonusAttempts': bonusAttempts,
      'usedAttempts': usedAttempts,
      'availableAttempts': availableAttempts,
      'date': date.toIso8601String().split('T')[0],
    };
  }

  /// copyWithメソッドを追加
  GachaAttemptsStats copyWith({
    int? baseAttempts,
    int? bonusAttempts,
    int? usedAttempts,
    int? availableAttempts,
    DateTime? date,
  }) {
    return GachaAttemptsStats(
      baseAttempts: baseAttempts ?? this.baseAttempts,
      bonusAttempts: bonusAttempts ?? this.bonusAttempts,
      usedAttempts: usedAttempts ?? this.usedAttempts,
      availableAttempts: availableAttempts ?? this.availableAttempts,
      date: date ?? this.date,
    );
  }

  /// 利用可能な回数を計算
  int get calculatedAvailableAttempts => baseAttempts + bonusAttempts - usedAttempts;
  
  /// ガチャが可能かどうか
  bool get canDrawGacha => calculatedAvailableAttempts > 0;

  @override
  String toString() {
    return 'GachaAttemptsStats(baseAttempts: $baseAttempts, bonusAttempts: $bonusAttempts, usedAttempts: $usedAttempts, availableAttempts: $availableAttempts, date: $date)';
  }
}

/// 広告視聴記録
class AdView {
  const AdView({
    required this.id,
    required this.userId,
    required this.adType,
    required this.adProvider,
    required this.adId,
    required this.viewDuration,
    required this.completed,
    required this.rewardAttempts,
    required this.viewedAt,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String adType;         // 'video', 'banner', 'interstitial'
  final String adProvider;     // 広告ネットワーク
  final String adId;           // 広告ユニットID
  final int viewDuration;      // 視聴時間（秒）
  final bool completed;        // 視聴完了フラグ
  final int rewardAttempts;    // 獲得するガチャ回数
  final DateTime viewedAt;
  final DateTime createdAt;

  factory AdView.fromJson(Map<String, dynamic> json) {
    return AdView(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      adType: json['ad_type'] as String,
      adProvider: json['ad_provider'] as String,
      adId: json['ad_id'] as String,
      viewDuration: json['view_duration'] as int,
      completed: json['completed'] as bool,
      rewardAttempts: json['reward_attempts'] as int,
      viewedAt: DateTime.parse(json['viewed_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'ad_type': adType,
      'ad_provider': adProvider,
      'ad_id': adId,
      'view_duration': viewDuration,
      'completed': completed,
      'reward_attempts': rewardAttempts,
      'viewed_at': viewedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// 広告視聴の種類
enum AdType {
  video,
  banner,
  interstitial,
}

/// 広告視聴の状態
sealed class AdViewState {
  const AdViewState();
}

class AdViewInitial extends AdViewState {
  const AdViewInitial();
}

class AdViewLoading extends AdViewState {
  const AdViewLoading();
}

class AdViewPlaying extends AdViewState {
  const AdViewPlaying({required this.currentDuration});
  final int currentDuration;
}

class AdViewCompleted extends AdViewState {
  const AdViewCompleted({required this.rewardedAttempts});
  final int rewardedAttempts;
}

class AdViewError extends AdViewState {
  const AdViewError(this.message);
  final String message;
}

class AdViewCancelled extends AdViewState {
  const AdViewCancelled();
}

/// ガチャ履歴
class GachaHistory {
  const GachaHistory({
    required this.id,
    required this.userId,
    required this.gachaResult,
    required this.attemptsUsed,
    required this.source,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final Map<String, dynamic> gachaResult; // ガチャ結果（JSON）
  final int attemptsUsed;     // 使用した回数
  final String source;        // 'normal' or 'bonus'
  final DateTime createdAt;

  factory GachaHistory.fromJson(Map<String, dynamic> json) {
    return GachaHistory(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      gachaResult: json['gacha_result'] as Map<String, dynamic>,
      attemptsUsed: json['attempts_used'] as int,
      source: json['source'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'gacha_result': gachaResult,
      'attempts_used': attemptsUsed,
      'source': source,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// ガチャ制限の状態
class GachaLimitState {
  const GachaLimitState({
    required this.stats,
    required this.recentAdViews,
    required this.recentHistory,
    required this.adViewState,
  });

  final GachaAttemptsStats stats;
  final List<AdView> recentAdViews;
  final List<GachaHistory> recentHistory;
  final AdViewState adViewState;

  /// ガチャが可能かどうか
  bool get canDrawGacha => stats.canDrawGacha;
  
  /// 残り回数
  int get remainingAttempts => stats.calculatedAvailableAttempts;
  
  /// ボーナス回数
  int get bonusAttempts => stats.bonusAttempts;
}
