class FanStarRelationshipModel {
  final String id;
  final String fanId;
  final String starId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String relationshipType;
  final int supportLevel;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  FanStarRelationshipModel({
    required this.id,
    required this.fanId,
    required this.starId,
    required this.createdAt,
    required this.updatedAt,
    required this.relationshipType,
    this.supportLevel = 1,
    this.isActive = true,
    this.metadata,
  });

  // Supabaseからの変換メソッド
  factory FanStarRelationshipModel.fromMap(Map<String, dynamic> map) {
    return FanStarRelationshipModel(
      id: map['id'],
      fanId: map['fan_id'],
      starId: map['star_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      relationshipType: map['relationship_type'],
      supportLevel: map['support_level'] ?? 1,
      isActive: map['is_active'] ?? true,
      metadata: map['metadata'],
    );
  }

  // Supabaseへの変換メソッド
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fan_id': fanId,
      'star_id': starId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'relationship_type': relationshipType,
      'support_level': supportLevel,
      'is_active': isActive,
      'metadata': metadata,
    };
  }

  // コピーメソッド
  FanStarRelationshipModel copyWith({
    String? id,
    String? fanId,
    String? starId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? relationshipType,
    int? supportLevel,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return FanStarRelationshipModel(
      id: id ?? this.id,
      fanId: fanId ?? this.fanId,
      starId: starId ?? this.starId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      relationshipType: relationshipType ?? this.relationshipType,
      supportLevel: supportLevel ?? this.supportLevel,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }
}