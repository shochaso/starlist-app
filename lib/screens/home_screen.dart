import 'package:flutter/material.dart';
import 'package:starlist_app/data/mock_data.dart';
import 'package:starlist_app/models/star.dart';
import 'package:starlist_app/models/activity.dart';
import 'package:starlist_app/routes/app_routes.dart';
import 'package:starlist_app/screens/explore_screen.dart';
import 'package:starlist_app/screens/favorites_screen.dart';
import 'package:starlist_app/screens/mypage_screen.dart';
import 'package:starlist_app/theme/app_theme.dart';
import 'package:starlist_app/widgets/star_card.dart';
import 'package:starlist_app/widgets/activity_card.dart';
import 'package:starlist_app/widgets/horizontal_section.dart';
import 'package:starlist_app/widgets/category_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Star> stars = MockData.getStars();
    final List<Activity> activities = MockData.getActivities();
    final List<String> categories = MockData.getCategories();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Starlist',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // 検索機能は実装しない
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications_none),
            onPressed: () {
              // 通知機能は実装しない
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // メインビジュアルスライダー
            _buildMainVisual(),
            
            // カテゴリから探す
            HorizontalSection(
              title: 'カテゴリから探す',
              itemWidth: 80,
              itemHeight: 100,
              children: categories
                  .map((category) => CategoryCard(
                        category: category,
                        icon: CategoryCard.getCategoryIcon(category),
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.category,
                          arguments: category,
                        ),
                      ))
                  .toList(),
              onSeeMore: null, // すべてのカテゴリを表示しているので不要
            ),
            
            // おすすめスター
            HorizontalSection(
              title: 'おすすめスター',
              itemWidth: 140,
              itemHeight: 220,
              children: stars
                  .take(4)
                  .map((star) => StarCard(
                        star: star,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.starDetail,
                          arguments: star,
                        ),
                      ))
                  .toList(),
              onSeeMore: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.category,
                  arguments: 'おすすめ',
                );
              },
            ),
            
            // 人気ランキング
            HorizontalSection(
              title: '人気ランキング',
              itemWidth: 140,
              itemHeight: 220,
              children: _buildRankedStars(stars, context),
              onSeeMore: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.category,
                  arguments: 'ランキング',
                );
              },
            ),
            
            // 今話題のスターの日常
            HorizontalSection(
              title: '今話題のスターの日常',
              itemWidth: 280,
              itemHeight: 240,
              children: activities
                  .map((activity) => ActivityCard(
                        activity: activity,
                        onTap: () {
                          // アクティビティの詳細画面は実装しない
                        },
                      ))
                  .toList(),
              onSeeMore: () {
                // アクティビティの一覧画面は実装しない
              },
            ),
            
            SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: '探す',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'お気に入り',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'マイページ',
          ),
        ],
        onTap: (index) {
          if (index != 0) {
            // 各タブに対応する画面に遷移
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  switch (index) {
                    case 1:
                      return ExploreScreen();
                    case 2:
                      return FavoritesScreen();
                    case 3:
                      return MyPageScreen();
                    default:
                      return const SizedBox();
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }

  // メインビジュアルスライダー
  Widget _buildMainVisual() {
    return Container(
      height: 180,
      child: PageView(
        children: [
          _buildMainVisualItem(
            'スターの日常を身近に',
            'お気に入りのスターの活動をチェックしよう',
            Colors.blue.shade100,
            Icons.star,
          ),
          _buildMainVisualItem(
            '注目のスターをピックアップ',
            '人気急上昇中の新スターをチェック',
            Colors.purple.shade100,
            Icons.trending_up,
          ),
          _buildMainVisualItem(
            'スターと交流しよう',
            'あなたの応援がスターの活力に',
            Colors.orange.shade100,
            Icons.favorite,
          ),
        ],
      ),
    );
  }

  // メインビジュアルの各アイテム
  Widget _buildMainVisualItem(String title, String subtitle, Color bgColor, IconData icon) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              icon,
              size: 150,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ランキング表示用のスターカードリスト
  List<Widget> _buildRankedStars(List<Star> stars, BuildContext context) {
    List<Star> rankedStars = List.from(stars)
      ..sort((a, b) => b.followers.compareTo(a.followers));
    rankedStars = rankedStars.take(5).toList();

    return List.generate(rankedStars.length, (index) {
      final star = rankedStars[index];
      return Stack(
        children: [
          StarCard(
            star: star,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.starDetail,
              arguments: star,
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _getRankBadgeColor(index),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  // ランキングバッジの色
  Color _getRankBadgeColor(int rank) {
    switch (rank) {
      case 0:
        return Colors.amber; // 1位: 金
      case 1:
        return Colors.grey.shade400; // 2位: 銀
      case 2:
        return Colors.brown.shade300; // 3位: 銅
      default:
        return AppTheme.primaryColor;
    }
  }
} 