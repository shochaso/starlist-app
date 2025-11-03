import 'package:flutter/foundation.dart';

@immutable
class StarDashboardData {
  const StarDashboardData({
    required this.summary,
    required this.posts,
    required this.ranking,
    required this.stats,
    required this.awards,
  });

  factory StarDashboardData.fromJson(Map<String, dynamic> json) {
    return StarDashboardData(
      summary: StarSummary.fromJson(
          json['summary'] as Map<String, dynamic>? ?? const {}),
      posts: (json['posts'] as List<dynamic>? ?? [])
          .map((raw) => StarPost.fromJson(raw as Map<String, dynamic>))
          .toList(),
      ranking: (json['ranking'] as List<dynamic>? ?? [])
          .map((raw) => FanRankingItem.fromJson(raw as Map<String, dynamic>))
          .toList(),
      stats: StarStats.fromJson(
          json['stats'] as Map<String, dynamic>? ?? const {}),
      awards: (json['awards'] as List<dynamic>? ?? [])
          .map((raw) => StarAward.fromJson(raw as Map<String, dynamic>))
          .toList(),
    );
  }

  const StarDashboardData.empty()
      : summary = const StarSummary.empty(),
        posts = const [],
        ranking = const [],
        stats = const StarStats.empty(),
        awards = const [];

  factory StarDashboardData.sample() {
    return const StarDashboardData(
      summary: StarSummary(
        name: '星ノ海 めぐみ',
        avatarUrl: 'https://cdn.starry.social/avatar/megu.png',
        followerCount: 128430,
        growthRate: 12.4,
        connectedSocials: 3,
        revenueThisMonth: 1840000,
        fanSupportRate: 92,
      ),
      posts: [
        StarPost(
          id: 'p1',
          title: '7/10 配信アーカイブ',
          coverUrl: 'https://cdn.starry.social/post1.jpg',
          impressions: 42000,
          likes: 5200,
          comments: 480,
          publishedAt: '2024-07-10',
        ),
        StarPost(
          id: 'p2',
          title: '新曲ティザー',
          coverUrl: 'https://cdn.starry.social/post2.jpg',
          impressions: 88000,
          likes: 12400,
          comments: 1340,
          publishedAt: '2024-07-08',
        ),
      ],
      ranking: [
        FanRankingItem(rank: 1, fanName: 'こはる', score: 98),
        FanRankingItem(rank: 2, fanName: 'Daiki', score: 95),
        FanRankingItem(rank: 3, fanName: 'Nori', score: 90),
      ],
      stats: StarStats(
          postCount: 42, views: 1200000, revenue: 2800000, engagement: 18),
      awards: [
        StarAward(title: '人気配信者アワード', date: '2024/06/01'),
        StarAward(title: 'ファン投票 1位', date: '2024/05/12'),
      ],
    );
  }

  final StarSummary summary;
  final List<StarPost> posts;
  final List<FanRankingItem> ranking;
  final StarStats stats;
  final List<StarAward> awards;
}

@immutable
class StarSummary {
  const StarSummary({
    required this.name,
    required this.avatarUrl,
    required this.followerCount,
    required this.growthRate,
    required this.connectedSocials,
    required this.revenueThisMonth,
    required this.fanSupportRate,
  });

  const StarSummary.empty()
      : name = '-',
        avatarUrl = '',
        followerCount = 0,
        growthRate = 0,
        connectedSocials = 0,
        revenueThisMonth = 0,
        fanSupportRate = 0;

  factory StarSummary.fromJson(Map<String, dynamic> json) {
    return StarSummary(
      name: json['name'] as String? ?? '-',
      avatarUrl: json['avatar_url'] as String? ?? '',
      followerCount: (json['followers'] as num?)?.toDouble() ?? 0,
      growthRate: (json['growth_rate'] as num?)?.toDouble() ?? 0,
      connectedSocials: json['connected_socials'] as int? ?? 0,
      revenueThisMonth: (json['revenue_month'] as num?)?.toDouble() ?? 0,
      fanSupportRate: json['fan_support_rate'] as int? ?? 0,
    );
  }

  final String name;
  final String avatarUrl;
  final double followerCount;
  final double growthRate;
  final int connectedSocials;
  final double revenueThisMonth;
  final int fanSupportRate;
}

@immutable
class StarPost {
  const StarPost({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.impressions,
    required this.likes,
    required this.comments,
    required this.publishedAt,
  });

  factory StarPost.fromJson(Map<String, dynamic> json) {
    return StarPost(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '-',
      coverUrl: json['cover_url'] as String? ?? '',
      impressions: json['impressions'] as int? ?? 0,
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      publishedAt: json['published_at'] as String? ?? '',
    );
  }

  final String id;
  final String title;
  final String coverUrl;
  final int impressions;
  final int likes;
  final int comments;
  final String publishedAt;
}

@immutable
class FanRankingItem {
  const FanRankingItem({
    required this.rank,
    required this.fanName,
    required this.score,
  });

  factory FanRankingItem.fromJson(Map<String, dynamic> json) {
    return FanRankingItem(
      rank: json['rank'] as int? ?? 0,
      fanName: json['fan_name'] as String? ?? '-',
      score: json['score'] as int? ?? 0,
    );
  }

  final int rank;
  final String fanName;
  final int score;
}

@immutable
class StarStats {
  const StarStats({
    required this.postCount,
    required this.views,
    required this.revenue,
    required this.engagement,
  });

  const StarStats.empty()
      : postCount = 0,
        views = 0,
        revenue = 0,
        engagement = 0;

  factory StarStats.fromJson(Map<String, dynamic> json) {
    return StarStats(
      postCount: json['post_count'] as int? ?? 0,
      views: (json['views'] as num?)?.toDouble() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      engagement: (json['engagement'] as num?)?.toDouble() ?? 0,
    );
  }

  final int postCount;
  final double views;
  final double revenue;
  final double engagement;
}

@immutable
class StarAward {
  const StarAward({required this.title, required this.date});

  factory StarAward.fromJson(Map<String, dynamic> json) {
    return StarAward(
      title: json['title'] as String? ?? '-',
      date: json['date'] as String? ?? '',
    );
  }

  final String title;
  final String date;
}
