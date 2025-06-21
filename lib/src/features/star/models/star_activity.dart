/// スターのアクティビティタイプ
enum ActivityType {
  /// 投稿
  post,
  
  /// コメント
  comment,
  
  /// いいね
  like,
  
  /// シェア
  share,
  
  /// リリース（新曲、新作など）
  release,
  
  /// ライブ配信
  live,
  
  /// メディア出演
  media,
  
  /// コラボレーション
  collaboration,
  
  /// 受賞
  award,
  
  /// マイルストーン（記念など）
  milestone,
  
  /// YouTube
  youtube,
  
  /// 買い物
  shopping,
  
  /// 音楽ストリーミング
  spotify,
  
  /// Instagram
  instagram,
  
  /// TikTok
  tiktok,
  
  /// その他
  other,
}

/// スターのアクティビティモデル
class StarActivity {
  /// アクティビティのID
  final String id;
  
  /// スターのID
  final String starId;
  
  /// アクティビティのタイプ
  final ActivityType type;
  
  /// アクティビティのタイトル
  final String title;
  
  /// アクティビティの説明
  final String? description;
  
  /// アクティビティの日時
  final DateTime timestamp;
  
  /// 関連コンテンツのID（オプション）
  final String? contentId;
  
  /// 詳細情報
  final Map<String, dynamic>? details;
  
  /// 画像URL（オプション）
  final String? imageUrl;
  
  /// アクティビティURL（オプション）
  final String? actionUrl;

  StarActivity({
    required this.id,
    required this.starId,
    required this.type,
    required this.title,
    this.description,
    required this.timestamp,
    this.contentId,
    this.details,
    this.imageUrl,
    this.actionUrl,
  });

  /// JSONからStarActivityを作成
  factory StarActivity.fromJson(Map<String, dynamic> json) {
    return StarActivity(
      id: json['id'] as String,
      starId: json['starId'] as String,
      type: _typeFromString(json['type'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      contentId: json['contentId'] as String?,
      details: json['details'] as Map<String, dynamic>?,
      imageUrl: json['imageUrl'] as String?,
      actionUrl: json['actionUrl'] as String?,
    );
  }

  /// StarActivityをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'starId': starId,
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'contentId': contentId,
      'details': details,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
    };
  }

  /// 文字列からActivityTypeに変換
  static ActivityType _typeFromString(String typeString) {
    return ActivityType.values.firstWhere(
      (type) => type.toString().split('.').last == typeString,
      orElse: () => ActivityType.other,
    );
  }
} 