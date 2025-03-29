import '../../auth/models/user_model.dart';

/// コメントモデル
class CommentModel {
  final String id;
  final String userId;
  final String contentId;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likeCount;
  final UserModel? user; // コメントを投稿したユーザー情報（任意）
  
  CommentModel({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    this.likeCount = 0,
    this.user,
  });
  
  /// JSONからコメントモデルを生成
  factory CommentModel.fromJson(Map<String, dynamic> json, {UserModel? user}) {
    return CommentModel(
      id: json['id'],
      userId: json['user_id'],
      contentId: json['content_id'],
      text: json['text'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      likeCount: json['like_count'] ?? 0,
      user: user,
    );
  }
  
  /// コメントモデルからJSONを生成
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content_id': contentId,
      'text': text,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'like_count': likeCount,
    };
  }
  
  /// コメントモデルのコピーを作成し、一部のプロパティを変更
  CommentModel copyWith({
    String? id,
    String? userId,
    String? contentId,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likeCount,
    UserModel? user,
  }) {
    return CommentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contentId: contentId ?? this.contentId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likeCount: likeCount ?? this.likeCount,
      user: user ?? this.user,
    );
  }
} 