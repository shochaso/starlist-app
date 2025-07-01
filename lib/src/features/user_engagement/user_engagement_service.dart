import 'dart:math';

/// ユーザーエンゲージメントを向上させるサービス
class UserEngagementService {
  /// ユーザーの活動レベルを計算
  static double calculateEngagementScore({
    required int dailyLogins,
    required int contentViews,
    required int interactions,
    required int sharesCount,
    required int commentsCount,
  }) {
    // エンゲージメントスコアの計算ロジック
    final loginScore = min(dailyLogins * 10, 100);
    final viewScore = min(contentViews * 2, 200);
    final interactionScore = min(interactions * 5, 150);
    final shareScore = min(sharesCount * 15, 100);
    final commentScore = min(commentsCount * 10, 100);
    
    final totalScore = loginScore + viewScore + interactionScore + shareScore + commentScore;
    return min(totalScore / 650 * 100, 100); // 100点満点
  }

  /// おすすめコンテンツの提案
  static List<Map<String, dynamic>> getRecommendedContent({
    required String userId,
    required List<String> userInterests,
    required List<String> followingStars,
  }) {
    // モックデータとしてのおすすめコンテンツ
    final recommendations = <Map<String, dynamic>>[
      {
        'id': 'rec_1',
        'type': 'video',
        'title': 'あなたにおすすめの動画',
        'description': '最近の視聴履歴に基づいた提案',
        'priority': 'high',
        'category': userInterests.isNotEmpty ? userInterests.first : 'general',
      },
      {
        'id': 'rec_2',
        'type': 'star',
        'title': '新しいスターを発見',
        'description': 'あなたの興味に合うクリエイター',
        'priority': 'medium',
        'category': 'discovery',
      },
      {
        'id': 'rec_3',
        'type': 'community',
        'title': 'コミュニティに参加',
        'description': '同じ趣味を持つファンとつながろう',
        'priority': 'low',
        'category': 'social',
      },
    ];

    return recommendations;
  }

  /// ユーザーの成長レベルを計算
  static Map<String, dynamic> calculateUserGrowth({
    required int currentLevel,
    required int totalExperience,
    required int monthlyActivity,
  }) {
    final nextLevelExp = (currentLevel + 1) * 1000;
    final progressToNext = (totalExperience % 1000) / 1000 * 100;
    
    return {
      'currentLevel': currentLevel,
      'nextLevel': currentLevel + 1,
      'progressPercentage': progressToNext,
      'experienceToNext': nextLevelExp - totalExperience,
      'monthlyGrowth': monthlyActivity,
      'achievements': _getAchievements(totalExperience, monthlyActivity),
    };
  }

  /// 達成可能なバッジ・実績を取得
  static List<Map<String, dynamic>> _getAchievements(int totalExp, int monthlyActivity) {
    final achievements = <Map<String, dynamic>>[];
    
    if (totalExp >= 5000) {
      achievements.add({
        'id': 'veteran',
        'title': 'ベテランファン',
        'description': '5000ポイントを達成',
        'icon': '🏆',
        'unlocked': true,
      });
    }
    
    if (monthlyActivity >= 100) {
      achievements.add({
        'id': 'active_monthly',
        'title': '月間アクティブユーザー',
        'description': '月間100回以上のアクティビティ',
        'icon': '⚡',
        'unlocked': true,
      });
    }
    
    // 未達成の目標も表示
    achievements.add({
      'id': 'social_butterfly',
      'title': 'ソーシャルバタフライ',
      'description': '50人のスターをフォロー',
      'icon': '🦋',
      'unlocked': false,
      'progress': 30,
      'target': 50,
    });
    
    return achievements;
  }

  /// ユーザーのパーソナライズされた体験を提供
  static Map<String, dynamic> getPersonalizedExperience({
    required String userId,
    required Map<String, dynamic> userPreferences,
    required List<String> recentActivity,
  }) {
    return {
      'welcomeMessage': _getPersonalizedWelcome(userPreferences),
      'todaysTasks': _getTodaysTasks(recentActivity),
      'featuredContent': _getFeaturedContent(userPreferences),
      'socialUpdates': _getSocialUpdates(userId),
    };
  }

  static String _getPersonalizedWelcome(Map<String, dynamic> preferences) {
    final hour = DateTime.now().hour;
    String timeGreeting;
    
    if (hour < 12) {
      timeGreeting = 'おはようございます';
    } else if (hour < 18) {
      timeGreeting = 'こんにちは';
    } else {
      timeGreeting = 'こんばんは';
    }
    
    return '$timeGreeting！今日も素敵なコンテンツを楽しみましょう✨';
  }

  static List<Map<String, dynamic>> _getTodaysTasks(List<String> recentActivity) {
    return [
      {
        'id': 'daily_login',
        'title': 'デイリーログイン',
        'description': 'スターPを獲得しよう',
        'reward': '10 スターP',
        'completed': recentActivity.contains('login'),
      },
      {
        'id': 'watch_content',
        'title': 'コンテンツ視聴',
        'description': '新しい動画を1本視聴',
        'reward': '5 スターP',
        'completed': recentActivity.contains('watch'),
      },
      {
        'id': 'interact',
        'title': 'コミュニティ参加',
        'description': 'いいねやコメントをしよう',
        'reward': '3 スターP',
        'completed': recentActivity.contains('interact'),
      },
    ];
  }

  static List<Map<String, dynamic>> _getFeaturedContent(Map<String, dynamic> preferences) {
    return [
      {
        'id': 'featured_1',
        'title': '今週の注目スター',
        'type': 'star_spotlight',
        'thumbnail': 'https://example.com/featured1.jpg',
      },
      {
        'id': 'featured_2',
        'title': 'トレンド動画',
        'type': 'trending_video',
        'thumbnail': 'https://example.com/featured2.jpg',
      },
    ];
  }

  static List<Map<String, dynamic>> _getSocialUpdates(String userId) {
    return [
      {
        'id': 'update_1',
        'type': 'follow',
        'message': '田中太郎さんが新しいスターをフォローしました',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'id': 'update_2',
        'type': 'achievement',
        'message': '佐藤花子さんがベテランファンバッジを獲得しました',
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
      },
    ];
  }
} 