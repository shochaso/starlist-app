import '../../domain/category.dart';
import '../../domain/star_data.dart';
import '../../domain/visibility.dart';

class StarDataDto {
  StarDataDto({
    required this.id,
    required this.category,
    required this.title,
    required this.serviceIcon,
    required this.createdAt,
    required this.visibility,
    this.description,
    this.url,
    this.imageUrl,
    this.starComment,
    this.enrichedMetadata,
  });

  factory StarDataDto.fromJson(Map<String, dynamic> json) {
    return StarDataDto(
      id: json['id']?.toString() ?? '',
      category: StarDataCategory.maybeFrom(json['category'] as String?) ??
          StarDataCategory.other,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      serviceIcon: json['service_icon'] as String? ?? '',
      url: _parseUri(json['url']),
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      visibility: StarDataVisibility.fromApi(
        json['visibility'] as String?,
      ),
      starComment: json['star_comment'] as String?,
      enrichedMetadata: json['enriched_metadata'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(
              json['enriched_metadata'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  final String id;
  final StarDataCategory category;
  final String title;
  final String? description;
  final String serviceIcon;
  final Uri? url;
  final String? imageUrl;
  final DateTime createdAt;
  final StarDataVisibility visibility;
  final String? starComment;
  final Map<String, dynamic>? enrichedMetadata;

  StarData toDomain() {
    return StarData(
      id: id,
      category: category,
      title: title,
      description: description,
      serviceIcon: serviceIcon,
      url: url,
      imageUrl: imageUrl,
      createdAt: createdAt,
      visibility: visibility,
      starComment: starComment,
      enrichedMetadata: enrichedMetadata,
    );
  }
}

class StarProfileDto {
  StarProfileDto({
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.bio,
    required this.totalFollowers,
    required this.snsLinks,
  });

  factory StarProfileDto.fromJson(Map<String, dynamic> json) {
    return StarProfileDto(
      username: json['username'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      totalFollowers: json['followers_total'] as int?,
      snsLinks: StarSnsLinksDto.fromJson(
        json['sns_links'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final int? totalFollowers;
  final StarSnsLinksDto snsLinks;

  StarProfile toDomain() {
    return StarProfile(
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      bio: bio,
      totalFollowers: totalFollowers,
      snsLinks: snsLinks.toDomain(),
    );
  }
}

class StarSnsLinksDto {
  const StarSnsLinksDto({
    this.x,
    this.instagram,
    this.youtube,
  });

  factory StarSnsLinksDto.fromJson(Map<String, dynamic> json) {
    return StarSnsLinksDto(
      x: _parseUri(json['x']),
      instagram: _parseUri(json['instagram']),
      youtube: _parseUri(json['youtube']),
    );
  }

  final Uri? x;
  final Uri? instagram;
  final Uri? youtube;

  StarSnsLinks toDomain() {
    return StarSnsLinks(
      x: x,
      instagram: instagram,
      youtube: youtube,
    );
  }
}

class StarDataViewerAccessDto {
  const StarDataViewerAccessDto({
    required this.isLoggedIn,
    required this.canViewFollowersOnlyContent,
    required this.isOwner,
    required this.canToggleActions,
    required this.categoryDigest,
  });

  factory StarDataViewerAccessDto.fromJson(Map<String, dynamic> json) {
    final rawDigest =
        json['category_digest'] as Map<String, dynamic>? ?? const {};
    return StarDataViewerAccessDto(
      isLoggedIn: json['is_logged_in'] as bool? ?? false,
      canViewFollowersOnlyContent: json['can_view_followers'] as bool? ?? false,
      isOwner: json['is_owner'] as bool? ?? false,
      canToggleActions: json['can_toggle_actions'] as bool? ?? false,
      categoryDigest: rawDigest.map((key, value) {
        final category = StarDataCategory.maybeFrom(key);
        if (category == null) {
          return MapEntry(StarDataCategory.other, value as int? ?? 0);
        }
        return MapEntry(category, value as int? ?? 0);
      }),
    );
  }

  final bool isLoggedIn;
  final bool canViewFollowersOnlyContent;
  final bool isOwner;
  final bool canToggleActions;
  final Map<StarDataCategory, int> categoryDigest;

  StarDataViewerAccess toDomain() {
    return StarDataViewerAccess(
      isLoggedIn: isLoggedIn,
      canViewFollowersOnlyContent: canViewFollowersOnlyContent,
      isOwner: isOwner,
      canToggleActions: canToggleActions,
      categoryDigest: categoryDigest,
    );
  }
}

class StarDataPageDto {
  StarDataPageDto({
    required this.profile,
    required this.viewerAccess,
    required this.items,
    required this.nextCursor,
  });

  factory StarDataPageDto.fromJson(Map<String, dynamic> json) {
    return StarDataPageDto(
      profile: StarProfileDto.fromJson(
        json['profile'] as Map<String, dynamic>? ?? const {},
      ),
      viewerAccess: StarDataViewerAccessDto.fromJson(
        json['viewer'] as Map<String, dynamic>? ?? const {},
      ),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((raw) =>
              StarDataDto.fromJson(raw as Map<String, dynamic>).toDomain())
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );
  }

  final StarProfileDto profile;
  final StarDataViewerAccessDto viewerAccess;
  final List<StarData> items;
  final String? nextCursor;

  StarDataPage toDomain() {
    return StarDataPage(
      profile: profile.toDomain(),
      viewerAccess: viewerAccess.toDomain(),
      items: items,
      nextCursor: nextCursor,
    );
  }
}

Uri? _parseUri(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return Uri.tryParse(value);
  }
  return null;
}
