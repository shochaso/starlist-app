import 'package:flutter/foundation.dart';

import 'category.dart';
import 'visibility.dart';

@immutable
class StarData {
  const StarData({
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
}

@immutable
class StarProfile {
  const StarProfile({
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.bio,
    required this.totalFollowers,
    required this.snsLinks,
  });

  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final int? totalFollowers;
  final StarSnsLinks snsLinks;
}

@immutable
class StarSnsLinks {
  const StarSnsLinks({
    this.x,
    this.instagram,
    this.youtube,
  });

  final Uri? x;
  final Uri? instagram;
  final Uri? youtube;

  bool get hasAny => x != null || instagram != null || youtube != null;
}

@immutable
class StarDataViewerAccess {
  const StarDataViewerAccess({
    required this.isLoggedIn,
    required this.canViewFollowersOnlyContent,
    required this.isOwner,
    required this.canToggleActions,
    required this.categoryDigest,
  });

  final bool isLoggedIn;
  final bool canViewFollowersOnlyContent;
  final bool isOwner;
  final bool canToggleActions;
  final Map<StarDataCategory, int> categoryDigest;

  bool get shouldShowDigestOnly => !isLoggedIn;

  bool canViewItem(StarDataVisibility visibility) {
    if (visibility == StarDataVisibility.public) return true;
    if (visibility == StarDataVisibility.private) {
      return isOwner;
    }
    return canViewFollowersOnlyContent || isOwner;
  }
}

@immutable
class StarDataPage {
  const StarDataPage({
    required this.profile,
    required this.viewerAccess,
    required this.items,
    required this.nextCursor,
  });

  final StarProfile profile;
  final StarDataViewerAccess viewerAccess;
  final List<StarData> items;
  final String? nextCursor;

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;
}
