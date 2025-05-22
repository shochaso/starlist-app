import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/fan_star_recommendations.dart';
import '../widgets/fan_following_stars.dart';
import '../widgets/fan_membership_plans.dart';

class FanHomeScreen extends StatelessWidget {
  const FanHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Starlist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 検索画面に遷移
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: 通知画面に遷移
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: マイページに遷移
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const FanStarRecommendations(),
            const FanFollowingStars(),
            const FanMembershipPlans(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
            icon: Icon(Icons.favorite),
            label: 'お気に入り',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: '通知',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'マイページ',
          ),
        ],
        onTap: (index) {
          // TODO: タブ切り替え処理
        },
      ),
    );
  }
} 