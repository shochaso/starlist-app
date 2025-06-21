import 'package:flutter/foundation.dart';

/// ランキングタイプの列挙型
enum RankingType {
  trending,
  popular,
  newest,
  recommended,
}

/// ランキング対象の列挙型
enum RankingTarget {
  content,
  star,
  category,
}

/// ランキング期間の列挙型
enum RankingPeriod {
  day,
  week,
  month,
  allTime,
}

/// ランキングモデルクラス
///
/// ランキングデータを表現するモデルクラスです。
class RankingModel {
  /// ランキングID
  final String id;
  
  /// ランキングタイプ
  final RankingType type;
  
  /// ランキング対象
  final RankingTarget target;
  
  /// ランキング期間
  final RankingPeriod period;
  
  /// ランキングタイトル
  final String title;
  
  /// ランキング説明
  final String? description;
  
  /// ランキングアイテムのリスト
  final List<RankingItemModel> items;
  
  /// 最終更新日時
  final DateTime lastUpdated;
  
  /// 次回更新予定日時
  final DateTime? nextUpdate;
  
  /// キャッシュの有効期限
  final DateTime cacheExpiry;

  /// コンストラクタ
  const RankingModel({
    required this.id,
    required this.type,
    required this.target,
    required this.period,
    required this.title,
    this.description,
    required this.items,
    required this.lastUpdated,
    this.nextUpdate,
    required this.cacheExpiry,
  });

  /// JSONからインスタンスを生成
  factory RankingModel.fromJson(Map<String, dynamic> json) {
    return RankingModel(
      id: json['id'] as String,
      type: RankingType.values.firstWhere(
        (e) => e.toString() == 'RankingType.${json['type']}',
        orElse: () => RankingType.trending,
      ),
      target: RankingTarget.values.firstWhere(
        (e) => e.toString() == 'RankingTarget.${json['target']}',
        orElse: () => RankingTarget.content,
      ),
      period: RankingPeriod.values.firstWhere(
        (e) => e.toString() == 'RankingPeriod.${json['period']}',
        orElse: () => RankingPeriod.week,
      ),
      title: json['title'] as String,
      description: json['description'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((item) => RankingItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      nextUpdate: json['next_update'] != null
          ? DateTime.parse(json['next_update'] as String)
          : null,
      cacheExpiry: DateTime.parse(json['cache_expiry'] as String),
    );
  }

  /// インスタンスからJSONを生成
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'target': target.toString().split('.').last,
      'period': period.toString().split('.').last,
      'title': title,
      'description': description,
      'items': items.map((item) => item.toJson()).toList(),
      'last_updated': lastUpdated.toIso8601String(),
      'next_update': nextUpdate?.toIso8601String(),
      'cache_expiry': cacheExpiry.toIso8601String(),
    };
  }

  /// 新しいインスタンスをコピーして生成
  RankingModel copyWith({
    String? id,
    RankingType? type,
    RankingTarget? target,
    RankingPeriod? period,
    String? title,
    String? description,
    List<RankingItemModel>? items,
    DateTime? lastUpdated,
    DateTime? nextUpdate,
    DateTime? cacheExpiry,
  }) {
    return RankingModel(
      id: id ?? this.id,
      type: type ?? this.type,
      target: target ?? this.target,
      period: period ?? this.period,
      title: title ?? this.title,
      description: description ?? this.description,
      items: items ?? this.items,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      nextUpdate: nextUpdate ?? this.nextUpdate,
      cacheExpiry: cacheExpiry ?? this.cacheExpiry,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is RankingModel &&
        other.id == id &&
        other.type == type &&
        other.target == target &&
        other.period == period &&
        other.title == title &&
        other.description == description &&
        listEquals(other.items, items) &&
        other.lastUpdated == lastUpdated &&
        other.nextUpdate == nextUpdate &&
        other.cacheExpiry == cacheExpiry;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        type.hashCode ^
        target.hashCode ^
        period.hashCode ^
        title.hashCode ^
        description.hashCode ^
        items.hashCode ^
        lastUpdated.hashCode ^
        nextUpdate.hashCode ^
        cacheExpiry.hashCode;
  }
}

/// ランキングアイテムモデルクラス
///
/// ランキング内の各アイテムを表現するモデルクラスです。
class RankingItemModel {
  /// アイテムID
  final String id;
  
  /// ランキング順位
  final int rank;
  
  /// アイテムタイプ
  final String type;
  
  /// アイテムタイトル
  final String title;
  
  /// アイテム説明
  final String? description;
  
  /// アイテム画像URL
  final String? imageUrl;
  
  /// アイテムスコア
  final double score;
  
  /// 前回のランキング順位
  final int? previousRank;
  
  /// アイテムメタデータ
  final Map<String, dynamic>? metadata;

  /// コンストラクタ
  const RankingItemModel({
    required this.id,
    required this.rank,
    required this.type,
    required this.title,
    this.description,
    this.imageUrl,
    required this.score,
    this.previousRank,
    this.metadata,
  });

  /// JSONからインスタンスを生成
  factory RankingItemModel.fromJson(Map<String, dynamic> json) {
    return RankingItemModel(
      id: json['id'] as String,
      rank: json['rank'] as int,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      score: (json['score'] as num).toDouble(),
      previousRank: json['previous_rank'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// インスタンスからJSONを生成
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rank': rank,
      'type': type,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'score': score,
      'previous_rank': previousRank,
      'metadata': metadata,
    };
  }

  /// 新しいインスタンスをコピーして生成
  RankingItemModel copyWith({
    String? id,
    int? rank,
    String? type,
    String? title,
    String? description,
    String? imageUrl,
    double? score,
    int? previousRank,
    Map<String, dynamic>? metadata,
  }) {
    return RankingItemModel(
      id: id ?? this.id,
      rank: rank ?? this.rank,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      score: score ?? this.score,
      previousRank: previousRank ?? this.previousRank,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is RankingItemModel &&
        other.id == id &&
        other.rank == rank &&
        other.type == type &&
        other.title == title &&
        other.description == description &&
        other.imageUrl == imageUrl &&
        other.score == score &&
        other.previousRank == previousRank &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        rank.hashCode ^
        type.hashCode ^
        title.hashCode ^
        description.hashCode ^
        imageUrl.hashCode ^
        score.hashCode ^
        previousRank.hashCode ^
        metadata.hashCode;
  }
}
