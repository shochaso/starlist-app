import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starlist_implementation/src/features/user_experience/engagement/models/badge_models.dart';
import 'package:starlist_implementation/src/features/user_experience/engagement/services/badge_service.dart';
import 'package:starlist_implementation/src/features/user_experience/engagement/services/interaction_service.dart';
import 'package:starlist_implementation/src/features/user_experience/analytics/models/analytics_models.dart';
import 'package:starlist_implementation/src/features/user_experience/analytics/services/analytics_service.dart';
import 'package:starlist_implementation/src/features/user_experience/content_management/models/content_models.dart';
import 'package:starlist_implementation/src/features/user_experience/content_management/services/content_management_service.dart';
import 'package:starlist_implementation/src/features/user_experience/ai_recommendation/models/recommendation_models.dart';
import 'package:starlist_implementation/src/features/user_experience/ai_recommendation/services/ai_recommendation_service.dart';
import 'package:starlist_implementation/src/features/user_experience/privacy_settings/models/privacy_models.dart';
import 'package:starlist_implementation/src/features/user_experience/privacy_settings/services/privacy_settings_service.dart';
import 'package:starlist_implementation/src/features/monetization/models/affiliate_product.dart';
import 'package:starlist_implementation/src/features/monetization/models/ad_model.dart';
import 'package:starlist_implementation/src/features/monetization/services/affiliate_service.dart';
import 'package:starlist_implementation/src/features/monetization/services/ad_service.dart';
import 'package:starlist_implementation/src/features/data_integration/models/youtube_video.dart';
import 'package:starlist_implementation/src/features/data_integration/services/youtube_api_service.dart';

/// Starlistアプリケーションのメインクラス
class StarlistApp extends ConsumerWidget {
  const StarlistApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Starlist',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        colorScheme: const ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const StarlistHomePage(),
    );
  }
}

/// ホーム画面
class StarlistHomePage extends ConsumerStatefulWidget {
  const StarlistHomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<StarlistHomePage> createState() => _StarlistHomePageState();
}

class _StarlistHomePageState extends ConsumerState<StarlistHomePage> {
  int _currentIndex = 0;
  final String _userId = 'user_1'; // 実際のアプリでは認証から取得
  final String _starId = 'star_1'; // 実際のアプリでは認証から取得
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Starlist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(userId: _userId),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: '探索',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'スター',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: '分析',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const HomeTab();
      case 1:
        return const ExploreTab();
      case 2:
        return StarTab(starId: _starId);
      case 3:
        return AnalyticsTab(userId: _userId, starId: _starId);
      case 4:
        return SettingsTab(userId: _userId);
      default:
        return const HomeTab();
    }
  }
}

/// ホームタブ
class HomeTab extends ConsumerWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const SectionTitle(title: 'おすすめスター'),
        const SizedBox(height: 8.0),
        SizedBox(
          height: 120.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (context, index) {
              return StarCard(
                starId: 'star_$index',
                name: 'スター $index',
                imageUrl: 'https://example.com/stars/$index.jpg',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StarProfileScreen(starId: 'star_$index'),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 24.0),
        const SectionTitle(title: '最新のアクティビティ'),
        const SizedBox(height: 8.0),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return ActivityCard(
              starId: 'star_$index',
              starName: 'スター $index',
              activityType: index % 3 == 0 ? 'post' : (index % 3 == 1 ? 'video' : 'product'),
              title: 'アクティビティ $index',
              timestamp: DateTime.now().subtract(Duration(hours: index * 2)),
              onTap: () {
                // アクティビティの詳細画面に遷移
              },
            );
          },
        ),
        const SizedBox(height: 24.0),
        const SectionTitle(title: 'おすすめ商品'),
        const SizedBox(height: 8.0),
        SizedBox(
          height: 200.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return ProductCard(
                productId: 'product_$index',
                title: '商品 $index',
                price: 1000 * (index + 1),
                imageUrl: 'https://example.com/products/$index.jpg',
                starId: 'star_${index % 3}',
                starName: 'スター ${index % 3}',
                onTap: () {
                  // 商品詳細画面に遷移
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 探索タブ
class ExploreTab extends ConsumerWidget {
  const ExploreTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const SearchBar(),
        const SizedBox(height: 24.0),
        const SectionTitle(title: 'カテゴリ'),
        const SizedBox(height: 8.0),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            final categories = [
              'ファッション',
              'ビューティー',
              'テクノロジー',
              'エンターテイメント',
              'ライフスタイル',
              'フード',
            ];
            final icons = [
              Icons.shopping_bag,
              Icons.face,
              Icons.devices,
              Icons.movie,
              Icons.home,
              Icons.restaurant,
            ];
            return CategoryCard(
              title: categories[index],
              icon: icons[index],
              onTap: () {
                // カテゴリ詳細画面に遷移
              },
            );
          },
        ),
        const SizedBox(height: 24.0),
        const SectionTitle(title: '人気のスター'),
        const SizedBox(height: 8.0),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return PopularStarCard(
              rank: index + 1,
              starId: 'star_$index',
              name: 'スター $index',
              imageUrl: 'https://example.com/stars/$index.jpg',
              followerCount: 10000 * (5 - index),
              category: index % 2 == 0 ? 'ファッション' : 'ライフスタイル',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StarProfileScreen(starId: 'star_$index'),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

/// スタータブ
class StarTab extends ConsumerWidget {
  final String starId;

  const StarTab({Key? key, required this.starId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // バッジサービスからバッジ情報を取得
    final badgesAsync = ref.watch(userBadgesProvider(starId));
    
    // コンテンツ管理サービスからコンテンツ情報を取得
    final contentsAsync = ref.watch(contentsProvider({
      'starId': starId,
      'status': ContentStatus.published,
      'limit': 10,
      'offset': 0,
    }));
    
    // AIレコメンデーションサービスから推奨情報を取得
    final recommendationsAsync = ref.watch(recommendationsProvider({
      'starId': starId,
      'activeOnly': true,
      'limit': 3,
    }));

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const StarProfileHeader(
          name: 'スターユーザー',
          bio: 'これはスターユーザーのプロフィールです。ファッション、ライフスタイル、テクノロジーに関する情報を共有しています。',
          imageUrl: 'https://example.com/stars/profile.jpg',
          followerCount: 25000,
          rank: 'プラチナスター',
        ),
        const SizedBox(height: 16.0),
        
        // バッジセクション
        const SectionTitle(title: 'バッジ'),
        const SizedBox(height: 8.0),
        badgesAsync.when(
          data: (badges) {
            return SizedBox(
              height: 80.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: badges.length,
                itemBuilder: (context, index) {
                  final badge = badges[index];
                  return BadgeItem(
                    title: badge.title,
                    icon: Icons.star,
                    color: _getBadgeColor(badge.level),
                    onTap: () {
                      // バッジ詳細を表示
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(badge.title),
                          content: Text(badge.description),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('閉じる'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('エラー: $error'),
        ),
        const SizedBox(height: 24.0),
        
        // コンテンツセクション
        const SectionTitle(title: 'コンテンツ'),
        const SizedBox(height: 8.0),
        contentsAsync.when(
          data: (contents) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: contents.length,
              itemBuilder: (context, index) {
                final content = contents[index];
                return ContentCard(
                  title: content.title,
                  description: content.description ?? '',
                  type: _getContentTypeString(content.type),
                  thumbnailUrl: content.thumbnailUrl,
                  publishedAt: content.publishedAt,
                  viewCount: content.viewCount,
                  likeCount: content.likeCount,
                  onTap: () {
                    // コンテンツ詳細画面に遷移
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContentDetailScreen(contentId: content.id),
                      ),
                    );
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('エラー: $error'),
        ),
        const SizedBox(height: 24.0),
        
        // レコメンデーションセクション
        const SectionTitle(title: 'おすすめ'),
        const SizedBox(height: 8.0),
        recommendationsAsync.when(
          data: (recommendations) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final recommendation = recommendations[index];
                return RecommendationCard(
                  title: recommendation.title,
                  description: recommendation.description,
                  type: _getRecommendationTypeString(recommendation.type),
                  relevanceScore: recommendation.relevanceScore,
                  onTap: () {
                    // レコメンデーション詳細画面に遷移
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecommendationDetailScreen(
                          recommendationId: recommendation.id,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('エラー: $error'),
        ),
      ],
    );
  }
  
  Color _getBadgeColor(BadgeLevel level) {
    switch (level) {
      case BadgeLevel.bronze:
        return Colors.brown;
      case BadgeLevel.silver:
        return Colors.grey;
      case BadgeLevel.gold:
        return Colors.amber;
      default:
        return Colors.blue;
    }
  }
  
  String _getContentTypeString(ContentType type) {
    switch (type) {
      case ContentType.post:
        return '投稿';
      case ContentType.article:
     <response clipped><NOTE>To save on context only part of this file has been shown to you. You should retry this tool after you have searched inside the file with `grep -n` in order to find the line numbers of what you are looking for.</NOTE>