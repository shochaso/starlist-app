class ContentConsumptionModel {
  final String id;
  final String userId;
  final String contentId;
  final double progressPercentage;
  final DateTime lastAccessedAt;
  final bool isCompleted;

  ContentConsumptionModel({
    required this.id,
    required this.userId,
    required this.contentId,
    this.progressPercentage = 0.0,
    required this.lastAccessedAt,
    this.isCompleted = false,
  });

  // Supabaseからの変換メソッド
  factory ContentConsumptionModel.fromMap(Map<String, dynamic> map) {
    return ContentConsumptionModel(
      id: map['id'],
      userId: map['user_id'],
      contentId: map['content_id'],
      progressPercentage: map['progress_percentage'] ?? 0.0,
      lastAccessedAt: DateTime.parse(map['last_accessed_at']),
      isCompleted: map['is_completed'] ?? false,
    );
  }

  // Supabaseへの変換メソッド
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'content_id': contentId,
      'progress_percentage': progressPercentage,
      'last_accessed_at': lastAccessedAt.toIso8601String(),
      'is_completed': isCompleted,
    };
  }
} 