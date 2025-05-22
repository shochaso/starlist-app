/// フォロー関係を表すモデルクラス
class FollowModel {
  final String id;
  final String followerId; // フォローするユーザーのID
  final String followedId; // フォローされるユーザーのID
  final DateTime createdAt;
  
  FollowModel({
    required this.id,
    required this.followerId,
    required this.followedId,
    required this.createdAt,
  });
  
  /// JSONからフォローモデルを生成
  factory FollowModel.fromJson(Map<String, dynamic> json) {
    return FollowModel(
      id: json['id'],
      followerId: json['follower_id'],
      followedId: json['followed_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  /// フォローモデルからJSONを生成
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'follower_id': followerId,
      'followed_id': followedId,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 