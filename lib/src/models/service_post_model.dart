class ServicePost {
  final String id;
  final String starId;
  final String serviceId;
  final String serviceName;
  final String title;
  final String description;
  final String? thumbnailUrl;
  final String? serviceUrl;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic;
  final int viewCount;
  final int likeCount;
  final List<String> tags;

  const ServicePost({
    required this.id,
    required this.starId,
    required this.serviceId,
    required this.serviceName,
    required this.title,
    required this.description,
    this.thumbnailUrl,
    this.serviceUrl,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.isPublic = true,
    this.viewCount = 0,
    this.likeCount = 0,
    this.tags = const [],
  });

  factory ServicePost.fromJson(Map<String, dynamic> json) {
    return ServicePost(
      id: json['id'] as String,
      starId: json['star_id'] as String,
      serviceId: json['service_id'] as String,
      serviceName: json['service_name'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      serviceUrl: json['service_url'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isPublic: json['is_public'] as bool? ?? true,
      viewCount: json['view_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'star_id': starId,
      'service_id': serviceId,
      'service_name': serviceName,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'service_url': serviceUrl,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_public': isPublic,
      'view_count': viewCount,
      'like_count': likeCount,
      'tags': tags,
    };
  }

  ServicePost copyWith({
    String? id,
    String? starId,
    String? serviceId,
    String? serviceName,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? serviceUrl,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublic,
    int? viewCount,
    int? likeCount,
    List<String>? tags,
  }) {
    return ServicePost(
      id: id ?? this.id,
      starId: starId ?? this.starId,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      serviceUrl: serviceUrl ?? this.serviceUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      tags: tags ?? this.tags,
    );
  }
}

class ServiceStats {
  final String serviceId;
  final String serviceName;
  final int totalPosts;
  final int publicPosts;
  final int totalViews;
  final int totalLikes;
  final DateTime lastPosted;

  const ServiceStats({
    required this.serviceId,
    required this.serviceName,
    required this.totalPosts,
    required this.publicPosts,
    required this.totalViews,
    required this.totalLikes,
    required this.lastPosted,
  });

  factory ServiceStats.fromJson(Map<String, dynamic> json) {
    return ServiceStats(
      serviceId: json['service_id'] as String,
      serviceName: json['service_name'] as String,
      totalPosts: json['total_posts'] as int,
      publicPosts: json['public_posts'] as int,
      totalViews: json['total_views'] as int,
      totalLikes: json['total_likes'] as int,
      lastPosted: DateTime.parse(json['last_posted'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'service_name': serviceName,
      'total_posts': totalPosts,
      'public_posts': publicPosts,
      'total_views': totalViews,
      'total_likes': totalLikes,
      'last_posted': lastPosted.toIso8601String(),
    };
  }
} 