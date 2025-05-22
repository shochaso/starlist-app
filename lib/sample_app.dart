import 'package:flutter/material.dart';
import 'widgets/star_dashboard.dart';
import 'widgets/star_content_management.dart';
import 'widgets/star_fan_analytics.dart';
import 'widgets/fan_star_recommendations.dart';
import 'widgets/fan_following_stars.dart';
import 'widgets/fan_membership_plans.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Starlist Widget Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const WidgetShowcase(),
    );
  }
}

class WidgetShowcase extends StatelessWidget {
  const WidgetShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6, // ウィジェットの数
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Starlist ウィジェット一覧'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'スターダッシュボード'),
              Tab(text: 'コンテンツ管理'),
              Tab(text: 'ファン分析'),
              Tab(text: 'おすすめスター'),
              Tab(text: 'フォロー中のスター'),
              Tab(text: 'メンバーシッププラン'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // 各タブに対応するウィジェット
            SingleChildScrollView(child: StarDashboard()),
            SingleChildScrollView(child: StarContentManagement()),
            SingleChildScrollView(child: StarFanAnalytics()),
            SingleChildScrollView(child: FanStarRecommendations()),
            SingleChildScrollView(child: FanFollowingStars()),
            SingleChildScrollView(child: FanMembershipPlans()),
          ],
        ),
      ),
    );
  }
}

// ユーザータイプ別に表示する画面（参考用）
class UserTypeScreen extends StatefulWidget {
  const UserTypeScreen({super.key});

  @override
  State<UserTypeScreen> createState() => _UserTypeScreenState();
}

class _UserTypeScreenState extends State<UserTypeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    // スター向けウィジェット
    SingleChildScrollView(
      child: Column(
        children: [
          const StarDashboard(),
          const StarContentManagement(),
          const StarFanAnalytics(),
        ],
      ),
    ),
    // ファン向けウィジェット
    SingleChildScrollView(
      child: Column(
        children: [
          const FanStarRecommendations(),
          const FanFollowingStars(),
          const FanMembershipPlans(),
        ],
      ),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Starlist - ユーザータイプ'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'スター画面',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'ファン画面',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
} 