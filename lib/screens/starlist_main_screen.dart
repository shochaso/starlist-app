import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 新しく作成した画面をインポート
import '../features/search/screens/search_screen.dart';
import '../features/follow/screens/follow_screen.dart';
import '../features/mylist/screens/mylist_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/data_integration/screens/data_import_screen.dart';
import '../features/star/screens/star_dashboard_screen.dart';
import '../features/subscription/screens/plan_management_screen.dart';
import '../features/app/screens/settings_screen.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../src/core/components/service_icons.dart';

// データモデル
class StarData {
  final String name;
  final String category;
  final String followers;
  final String avatar;
  final List<Color> gradientColors;
  final bool isFollowing;

  StarData({
    required this.name,
    required this.category,
    required this.followers,
    required this.avatar,
    required this.gradientColors,
    this.isFollowing = false,
  });
}

class ContentData {
  final String title;
  final String subtitle;
  final String type;
  final IconData icon;
  final Color iconColor;
  final String timeAgo;

  ContentData({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.icon,
    required this.iconColor,
    required this.timeAgo,
  });
}

// プロバイダー
final selectedTabProvider = StateProvider<int>((ref) => 0);
final selectedDataTypeProvider = StateProvider<String?>((ref) => null);
final selectedDrawerPageProvider = StateProvider<String?>((ref) => null);

class StarlistMainScreen extends ConsumerStatefulWidget {
  const StarlistMainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StarlistMainScreen> createState() => _StarlistMainScreenState();
}

class _StarlistMainScreenState extends ConsumerState<StarlistMainScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late ScrollController _scrollController;

  // サンプルデータ
  final List<StarData> recommendedStars = [
    StarData(
      name: 'テックレビューアー田中',
      category: 'テクノロジー / ガジェット',
      followers: '24.5万',
      avatar: 'T1',
      gradientColors: [const Color(0xFF4ECDC4), const Color(0xFF44A08D)],
    ),
    StarData(
      name: '料理研究家佐藤',
      category: '料理・グルメ / レシピ',
      followers: '18.3万',
      avatar: 'S2',
      gradientColors: [const Color(0xFFFFE66D), const Color(0xFFFF6B6B)],
    ),
    StarData(
      name: 'ゲーム実況者山田',
      category: 'ゲーム / エンタメ',
      followers: '32.7万',
      avatar: 'G3',
      gradientColors: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
    ),
    StarData(
      name: '旅行ブロガー鈴木',
      category: '旅行 / 写真',
      followers: '15.8万',
      avatar: 'T4',
      gradientColors: [const Color(0xFF74B9FF), const Color(0xFF0984E3)],
    ),
    StarData(
      name: 'ファッション系インフルエンサー',
      category: 'ファッション / ライフスタイル',
      followers: '28.1万',
      avatar: 'F5',
      gradientColors: [const Color(0xFFE17055), const Color(0xFFD63031)],
    ),
    StarData(
      name: 'ビジネス系YouTuber中村',
      category: 'ビジネス / 投資',
      followers: '41.2万',
      avatar: 'B6',
      gradientColors: [const Color(0xFF6C5CE7), const Color(0xFDA4DE)],
    ),
    StarData(
      name: 'アニメレビュアー小林',
      category: 'アニメ / マンガ',
      followers: '19.6万',
      avatar: 'A7',
      gradientColors: [const Color(0xFFFF7675), const Color(0xFFE84393)],
    ),
    StarData(
      name: 'DIYクリエイター木村',
      category: 'DIY / ハンドメイド',
      followers: '12.4万',
      avatar: 'D8',
      gradientColors: [const Color(0xFF00B894), const Color(0xFF00A085)],
    ),
  ];

  final List<StarData> newStars = [
    StarData(
      name: 'プログラミング講師伊藤',
      category: 'プログラミング / 教育',
      followers: '5.2万',
      avatar: 'P1',
      gradientColors: [const Color(0xFF00B894), const Color(0xFF00A085)],
    ),
    StarData(
      name: 'フィットネストレーナー渡辺',
      category: 'フィットネス / 健康',
      followers: '8.9万',
      avatar: 'F2',
      gradientColors: [const Color(0xFFE84393), const Color(0xFDD5D5)],
    ),
    StarData(
      name: 'アート系クリエイター高橋',
      category: 'アート / デザイン',
      followers: '3.8万',
      avatar: 'A3',
      gradientColors: [const Color(0xFF6C5CE7), const Color(0xFDA4DE)],
    ),
    StarData(
      name: '音楽プロデューサー松本',
      category: '音楽 / DTM',
      followers: '7.1万',
      avatar: 'M4',
      gradientColors: [const Color(0xFFFFD93D), const Color(0xFFFF6B35)],
    ),
    StarData(
      name: 'ペット系YouTuber佐々木',
      category: 'ペット / 動物',
      followers: '11.3万',
      avatar: 'P5',
      gradientColors: [const Color(0xFF74B9FF), const Color(0xFF0984E3)],
    ),
    StarData(
      name: '語学学習コーチ田村',
      category: '語学 / 教育',
      followers: '6.7万',
      avatar: 'L6',
      gradientColors: [const Color(0xFF55A3FF), const Color(0xFF003D82)],
    ),
  ];

  final List<ContentData> recentContent = [
    ContentData(
      title: 'iPhone 15 Pro Max 詳細レビュー',
      subtitle: 'テックレビューアー田中 • 25:30',
      type: '動画',
      icon: Icons.play_arrow,
      iconColor: const Color(0xFF4ECDC4),
      timeAgo: '2時間前',
    ),
    ContentData(
      title: 'Sony α7 IV ミラーレスカメラ',
      subtitle: 'Amazon • ¥289,800',
      type: '商品',
      icon: Icons.shopping_bag,
      iconColor: const Color(0xFFFFE66D),
      timeAgo: '3時間前',
    ),
    ContentData(
      title: '簡単チキンカレーの作り方',
      subtitle: '料理研究家佐藤 • 12:45',
      type: 'レシピ',
      icon: Icons.restaurant,
      iconColor: const Color(0xFFFF6B6B),
      timeAgo: '4時間前',
    ),
    ContentData(
      title: 'Apex Legends ランクマッチ配信',
      subtitle: 'ゲーム実況者山田 • ライブ',
      type: 'ライブ',
      icon: Icons.live_tv,
      iconColor: const Color(0xFF667EEA),
      timeAgo: '30分前',
    ),
    ContentData(
      title: '京都の隠れた名所巡り',
      subtitle: '旅行ブロガー鈴木 • 18:20',
      type: '動画',
      icon: Icons.place,
      iconColor: const Color(0xFF74B9FF),
      timeAgo: '1日前',
    ),
    ContentData(
      title: '秋冬コーディネート特集',
      subtitle: 'ファッション系インフルエンサー • 15:10',
      type: '動画',
      icon: Icons.checkroom,
      iconColor: const Color(0xFFE17055),
      timeAgo: '1日前',
    ),
    ContentData(
      title: 'Flutter開発のベストプラクティス',
      subtitle: 'プログラミング講師伊藤 • 32:15',
      type: 'チュートリアル',
      icon: Icons.code,
      iconColor: const Color(0xFF00B894),
      timeAgo: '2日前',
    ),
    ContentData(
      title: '自宅でできる筋トレメニュー',
      subtitle: 'フィットネストレーナー渡辺 • 20:30',
      type: '動画',
      icon: Icons.fitness_center,
      iconColor: const Color(0xFFE84393),
      timeAgo: '2日前',
    ),
    ContentData(
      title: '投資初心者のための株式投資講座',
      subtitle: 'ビジネス系YouTuber中村 • 28:45',
      type: '動画',
      icon: Icons.trending_up,
      iconColor: const Color(0xFF6C5CE7),
      timeAgo: '3日前',
    ),
    ContentData(
      title: '鬼滅の刃 最新話レビュー',
      subtitle: 'アニメレビュアー小林 • 16:20',
      type: '動画',
      icon: Icons.movie,
      iconColor: const Color(0xFFFF7675),
      timeAgo: '3日前',
    ),
    ContentData(
      title: 'DIY本棚の作り方',
      subtitle: 'DIYクリエイター木村 • 22:10',
      type: 'チュートリアル',
      icon: Icons.build,
      iconColor: const Color(0xFF00B894),
      timeAgo: '4日前',
    ),
    ContentData(
      title: 'Lo-Fi Hip Hop ビートメイキング',
      subtitle: '音楽プロデューサー松本 • 35:40',
      type: '音楽',
      icon: Icons.music_note,
      iconColor: const Color(0xFFFFD93D),
      timeAgo: '4日前',
    ),
    ContentData(
      title: '猫の健康管理のコツ',
      subtitle: 'ペット系YouTuber佐々木 • 14:30',
      type: '動画',
      icon: Icons.pets,
      iconColor: const Color(0xFF74B9FF),
      timeAgo: '5日前',
    ),
    ContentData(
      title: '英語リスニング上達法',
      subtitle: '語学学習コーチ田村 • 19:15',
      type: '教育',
      icon: Icons.school,
      iconColor: const Color(0xFF55A3FF),
      timeAgo: '5日前',
    ),
    ContentData(
      title: 'MacBook Pro M3 開封レビュー',
      subtitle: 'テックレビューアー田中 • 21:30',
      type: '動画',
      icon: Icons.laptop_mac,
      iconColor: const Color(0xFF4ECDC4),
      timeAgo: '6日前',
    ),
  ];

  // 追加のテストデータ
  final List<Map<String, dynamic>> trendingTopics = [
    {
      'title': 'iPhone 15',
      'posts': '1,234',
      'color': const Color(0xFF4ECDC4),
    },
    {
      'title': 'Flutter 3.0',
      'posts': '892',
      'color': const Color(0xFF00B894),
    },
    {
      'title': '秋のファッション',
      'posts': '2,156',
      'color': const Color(0xFFE17055),
    },
    {
      'title': 'Apex Legends',
      'posts': '3,421',
      'color': const Color(0xFF667EEA),
    },
    {
      'title': 'ChatGPT',
      'posts': '4,567',
      'color': const Color(0xFF6C5CE7),
    },
    {
      'title': '鬼滅の刃',
      'posts': '1,890',
      'color': const Color(0xFFFF7675),
    },
    {
      'title': 'DIY',
      'posts': '987',
      'color': const Color(0xFF00B894),
    },
    {
      'title': '投資',
      'posts': '2,345',
      'color': const Color(0xFFFFD93D),
    },
  ];

  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'テックレビューアー田中が新しい動画を投稿しました',
      'time': '5分前',
      'type': 'new_post',
      'read': false,
    },
    {
      'title': 'ゲーム実況者山田がライブ配信を開始しました',
      'time': '30分前',
      'type': 'live',
      'read': false,
    },
    {
      'title': '料理研究家佐藤があなたの投稿にいいねしました',
      'time': '2時間前',
      'type': 'like',
      'read': false,
    },
    {
      'title': 'ビジネス系YouTuber中村が新しい投資動画を投稿',
      'time': '3時間前',
      'type': 'new_post',
      'read': true,
    },
    {
      'title': 'フィットネストレーナー渡辺があなたをフォローしました',
      'time': '5時間前',
      'type': 'follow',
      'read': true,
    },
    {
      'title': 'アニメレビュアー小林があなたのコメントに返信しました',
      'time': '1日前',
      'type': 'reply',
      'read': true,
    },
    {
      'title': 'DIYクリエイター木村が新しいチュートリアルを投稿',
      'time': '1日前',
      'type': 'new_post',
      'read': true,
    },
    {
      'title': '音楽プロデューサー松本があなたの楽曲をシェアしました',
      'time': '2日前',
      'type': 'share',
      'read': true,
    },
  ];

  // 新しいセクション用データ
  final List<Map<String, dynamic>> featuredPlaylists = [
    {
      'title': '今週のトップ動画',
      'description': '最も人気の高い動画をまとめました',
      'itemCount': 12,
      'thumbnail': const Color(0xFF4ECDC4),
      'creator': 'Starlist編集部',
    },
    {
      'title': 'プログラミング学習',
      'description': '初心者から上級者まで対応',
      'itemCount': 8,
      'thumbnail': const Color(0xFF00B894),
      'creator': 'プログラミング講師伊藤',
    },
    {
      'title': '料理レシピ集',
      'description': '簡単で美味しいレシピばかり',
      'itemCount': 15,
      'thumbnail': const Color(0xFFFF6B6B),
      'creator': '料理研究家佐藤',
    },
    {
      'title': 'ゲーム攻略',
      'description': '最新ゲームの攻略法',
      'itemCount': 20,
      'thumbnail': const Color(0xFF667EEA),
      'creator': 'ゲーム実況者山田',
    },
  ];

  final List<Map<String, dynamic>> liveStreams = [
    {
      'title': 'Apex Legends ランクマッチ',
      'streamer': 'ゲーム実況者山田',
      'viewers': '2,341',
      'category': 'ゲーム',
      'thumbnail': const Color(0xFF667EEA),
    },
    {
      'title': 'リアルタイム料理配信',
      'streamer': '料理研究家佐藤',
      'viewers': '1,567',
      'category': '料理',
      'thumbnail': const Color(0xFFFF6B6B),
    },
    {
      'title': 'プログラミング質問会',
      'streamer': 'プログラミング講師伊藤',
      'viewers': '892',
      'category': '教育',
      'thumbnail': const Color(0xFF00B894),
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(selectedTabProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildBody(selectedTab),
      bottomNavigationBar: _buildBottomNavigationBar(selectedTab),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final selectedTab = ref.watch(selectedTabProvider);
    final themeMode = ref.watch(themeProvider);
    final titles = ['ホーム', '検索', 'データ取込み', 'マイリスト', 'マイページ'];
    final isDark = themeMode == AppThemeMode.dark;
    
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      title: Text(
        titles[selectedTab],
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      leading: selectedTab == 0 ? Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu, color: isDark ? Colors.white54 : Colors.black54),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ) : null,
      automaticallyImplyLeading: false, // 戻るボタンを無効化
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: isDark ? Colors.white54 : Colors.black54),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
          onPressed: () {
            ref.read(themeProvider.notifier).toggleTheme();
          },
        ),
        IconButton(
          icon: Icon(Icons.settings_outlined, color: isDark ? Colors.white54 : Colors.black54),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    final currentUser = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              border: Border(
                bottom: BorderSide(color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Starlist',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4ECDC4),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: isDark ? Colors.white54 : Colors.black54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildDrawerItem(Icons.home, 'ホーム', 0, null),
                _buildDrawerItem(Icons.search, '検索', 1, null),
                _buildDrawerItem(Icons.people, 'フォロー中', -1, 'follow'),
                _buildDrawerItem(Icons.star, 'マイリスト', 3, null),
                // スターのみ表示
                if (currentUser.isStar) ...[
                  _buildDrawerItem(Icons.camera_alt, 'データ取込み', 2, null),
                  _buildDrawerItem(Icons.analytics, 'スターダッシュボード', -1, 'dashboard'),
                  _buildDrawerItem(Icons.workspace_premium, 'プランを管理', -1, 'plan'),
                ],
                _buildDrawerItem(Icons.person, 'マイページ', 4, null),
                _buildDrawerItem(Icons.settings, '設定', -1, 'settings'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int tabIndex, String? pageKey) {
    final selectedTab = ref.watch(selectedTabProvider);
    final selectedPage = ref.watch(selectedDrawerPageProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    // 選択状態の判定を修正：タブページとナビゲーションページが同時に選択されないように
    final isTabActive = tabIndex != -1 && selectedTab == tabIndex && selectedPage == null;
    final isPageActive = pageKey != null && selectedPage == pageKey;
    final isActive = isTabActive || isPageActive;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? const Color(0xFF4ECDC4) : (isDark ? Colors.white54 : Colors.black54),
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? const Color(0xFF4ECDC4) : (isDark ? Colors.white : Colors.black87),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: isActive ? const Color(0xFF4ECDC4).withOpacity(0.1) : null,
        onTap: () {
          Navigator.of(context).pop();
          if (tabIndex != -1) {
            ref.read(selectedTabProvider.notifier).state = tabIndex;
            ref.read(selectedDrawerPageProvider.notifier).state = null;
          } else if (pageKey != null) {
            ref.read(selectedDrawerPageProvider.notifier).state = pageKey;
            _navigateToPage(pageKey);
          }
        },
      ),
    );
  }

  void _navigateToPage(String pageKey) {
    Widget page;
    switch (pageKey) {
      case 'follow':
        page = const FollowScreen();
        break;
      case 'dashboard':
        page = const StarDashboardScreen();
        break;
      case 'plan':
        page = const PlanManagementScreen();
        break;
      case 'settings':
        page = const SettingsScreen();
        break;
      default:
        return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Widget _buildBody(int selectedTab) {
    switch (selectedTab) {
      case 0:
        return _buildHomeView();
      case 1:
        return const SearchScreen();
      case 2:
        return const DataImportScreen();
      case 3:
        return const MylistScreen();
      case 4:
        return const ProfileScreen();
      default:
        return _buildHomeView();
    }
  }

  Widget _buildHomeView() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 最新YouTube履歴セクション（新規追加）
          _buildLatestYouTubeHistorySection(),
          const SizedBox(height: 24),
          
          // 通知セクション
          _buildNotificationsSection(),
          const SizedBox(height: 24),
          
          // 自然な広告1（おすすめアプリ）
          _buildNativeAd1(),
          const SizedBox(height: 24),
          
          // トレンドトピックセクション
          _buildTrendingTopicsSection(),
          const SizedBox(height: 24),
          
          // プレイリストセクション
          _buildFeaturedPlaylistsSection(),
          const SizedBox(height: 24),
          
          // 自然な広告2（スポンサードコンテンツ）
          _buildNativeAd2(),
          const SizedBox(height: 24),
          
          // おすすめスターセクション
          _buildRecommendedStarsSection(),
          const SizedBox(height: 24),
          
          // 新しく参加したスターセクション
          _buildNewStarsSection(),
          const SizedBox(height: 24),
          
          // 今日のピックアップセクション
          _buildTodayPickupSection(),
          const SizedBox(height: 100), // ボトムナビゲーション用の余白
        ],
      ),
    );
  }

  Widget _buildLatestYouTubeHistorySection() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    final youtubeHistory = [
      {
        'title': 'iPhone 15 Pro Max 詳細レビュー - カメラ性能が凄すぎる！',
        'channel': 'テックレビューアー田中',
        'duration': '25:30',
        'uploadTime': '2時間前',
        'views': '12.5万回視聴',
        'thumbnail': const Color(0xFFFF0000),
      },
      {
        'title': 'MacBook Pro M3 開封レビュー',
        'channel': 'テックレビューアー田中',
        'duration': '18:45',
        'uploadTime': '5時間前',
        'views': '8.9万回視聴',
        'thumbnail': const Color(0xFFFF0000),
      },
      {
        'title': 'Flutter 3.0 新機能解説 - 完全ガイド',
        'channel': 'プログラミング講師伊藤',
        'duration': '32:15',
        'uploadTime': '1日前',
        'views': '5.2万回視聴',
        'thumbnail': const Color(0xFF00B894),
      },
      {
        'title': '簡単チキンカレーの作り方 - 30分で完成',
        'channel': '料理研究家佐藤',
        'duration': '12:45',
        'uploadTime': '1日前',
        'views': '15.3万回視聴',
        'thumbnail': const Color(0xFFFF6B6B),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('最新YouTube履歴'),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.92),
            padEnds: true,
            itemCount: youtubeHistory.length,
            itemBuilder: (context, index) {
              final video = youtubeHistory[index];
    return Container(
                width: MediaQuery.of(context).size.width * 0.88,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : Colors.black).withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
                ),
                child: Row(
            children: [
              Container(
                      width: 60,
                      height: 45,
                decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ServiceIcons.buildIcon(
                        serviceId: 'youtube',
                        size: 24,
                        isDark: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                            video['title'] as String,
                    style: TextStyle(
                              fontSize: 14,
                      fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                    ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                  ),
                          const SizedBox(height: 4),
                  Text(
                            video['channel'] as String,
                    style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                video['duration'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? Colors.white54 : Colors.black38,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                video['uploadTime'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? Colors.white54 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ],
          ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNativeAd1() {
    return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
        ),
              borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
            width: 50,
            height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
              Icons.apps,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
          Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                Row(
                  children: [
                    const Text(
                      'おすすめアプリ',
                        style: TextStyle(
                        fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PR',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                    ),
                  ),
                          ),
                        ],
                      ),
                const SizedBox(height: 4),
          const Text(
                  'あなたの興味に合わせたアプリを発見',
            style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
            ),
          ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '見る',
              style: TextStyle(
              color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNativeAd2() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
        ),
              borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                Container(
            width: 50,
            height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                colors: [Color(0xFFFFE66D), Color(0xFFFF6B35)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
              Icons.star,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
          Expanded(
                  child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
                      'スポンサードコンテンツ',
              style: TextStyle(
                        fontSize: 14,
                          fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
              child: const Text(
                        'AD',
                style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFFF59E0B),
                          fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
                const SizedBox(height: 4),
                const Text(
                  '新しいスターを発見して、特別なコンテンツを楽しもう',
                  style: TextStyle(
                    fontSize: 12,
                          color: Colors.black54,
          ),
        ),
      ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(8),
            ),
              child: const Text(
              '詳細',
                style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildNotificationsSection() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    final notifications = [
      {
        'type': 'upload',
        'title': '新しい動画がアップロードされました',
        'subtitle': 'テックレビューアー田中 • iPhone 15 Pro レビュー',
        'time': '2時間前',
        'isUnread': true,
        'icon': Icons.video_library,
        'iconColor': const Color(0xFF4ECDC4),
      },
      {
        'type': 'follow',
        'title': '新しいフォロワーがいます',
        'subtitle': '5人の新しいフォロワー',
        'time': '4時間前',
        'isUnread': true,
        'icon': Icons.person_add,
        'iconColor': const Color(0xFFFF6B6B),
      },
      {
        'type': 'live',
        'title': 'ライブ配信が開始されました',
        'subtitle': 'ゲーム実況者山田 • Apex Legends ランクマッチ',
        'time': '6時間前',
        'isUnread': false,
        'icon': Icons.live_tv,
        'iconColor': const Color(0xFFFFE66D),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('通知'),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.85),
            padEnds: false,
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final isUnread = notification['isUnread'] as bool;
              
    return Container(
                width: MediaQuery.of(context).size.width * 0.8,
                margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isUnread ? const Color(0xFF4ECDC4).withOpacity(0.3) : 
                           (isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
                    width: isUnread ? 2 : 1,
                  ),
        boxShadow: [
          BoxShadow(
                      color: (isDark ? Colors.black : Colors.black).withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
      ),
      child: Row(
        children: [
          Container(
                      width: 32,
                      height: 32,
            decoration: BoxDecoration(
                        color: (notification['iconColor'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        notification['icon'] as IconData,
                        color: notification['iconColor'] as Color,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                            notification['title'] as String,
                            style: TextStyle(
                              fontSize: 13,
                    fontWeight: FontWeight.w600,
                              color: isUnread ? (isDark ? Colors.white : Colors.black87) : 
                                     (isDark ? Colors.white70 : Colors.grey[700]),
                  ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                ),
                          const SizedBox(height: 2),
                Text(
                            notification['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                Text(
                            notification['time'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.white54 : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4ECDC4),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              );
            },
            ),
          ),
        ],
    );
  }

  Widget _buildTrendingTopicsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('トレンドトピック'),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: trendingTopics.length,
            itemBuilder: (context, index) {
              final topic = trendingTopics[index];
    return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
                  gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
                    colors: [
                      topic['color'],
                      topic['color'].withOpacity(0.7),
                    ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
        children: [
                    Text(
                      topic['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                    color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${topic['posts']} 投稿',
                      style: const TextStyle(
                  fontSize: 12,
                        color: Colors.white,
                ),
              ),
            ],
          ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedPlaylistsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('プレイリスト'),
          const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: featuredPlaylists.length,
            itemBuilder: (context, index) {
              final playlist = featuredPlaylists[index];
              return Container(
                width: 180,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      playlist['thumbnail'],
                      playlist['thumbnail'].withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      playlist['title'],
                      style: const TextStyle(
                        fontSize: 16,
                fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      playlist['description'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedStarsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('おすすめスター'),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.9),
            padEnds: false,
            itemCount: recommendedStars.length,
            itemBuilder: (context, index) {
              final star = recommendedStars[index];
              return _buildStarCard(star, 350);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewStarsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        _buildSectionTitle('新しく参加したスター'),
            const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.9),
            padEnds: false,
            itemCount: newStars.length,
            itemBuilder: (context, index) {
              final star = newStars[index];
              return _buildStarCard(star, 350);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStarCard(StarData star, double height) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: star.gradientColors,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                star.avatar,
            style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
        children: [
              Text(
                  star.name,
                style: TextStyle(
                    fontSize: 16,
                  fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  star.category,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${star.followers}フォロワー',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black38,
                ),
              ),
            ],
          ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
              backgroundColor: star.isFollowing ? Colors.grey : star.gradientColors.first,
                    foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
              elevation: 0,
              minimumSize: const Size(60, 32),
            ),
            child: Text(
              star.isFollowing ? 'フォロー中' : 'フォロー',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildTodayPickupSection() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    final todayPickup = [
      {
        'title': '今日のおすすめスター',
        'subtitle': 'テックレビューアー田中',
        'description': '最新のガジェットレビューが人気',
        'color': const Color(0xFF3B82F6),
        'icon': Icons.star,
      },
      {
        'title': '注目のコンテンツ',
        'subtitle': 'iPhone 15 Pro Max レビュー',
        'description': '詳細なカメラ性能テスト',
        'color': const Color(0xFF10B981),
        'icon': Icons.video_library,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今日のピックアップ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...todayPickup.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.black).withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: item['color'] as Color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['subtitle'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                        Text(
                      item['description'] as String,
                      style: TextStyle(
                            fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isDark ? Colors.white54 : Colors.black38,
                size: 16,
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildMyListView() {
    return const MylistScreen();
  }

  Widget _buildProfileView() {
    return const ProfileScreen();
  }

  Widget _buildBottomNavigationBar(int selectedTab) {
    final currentUser = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border(
          top: BorderSide(color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBottomNavItem(Icons.home, 'ホーム', 0, selectedTab, isDark),
              _buildBottomNavItem(Icons.search, '検索', 1, selectedTab, isDark),
              // スターのみ取込みタブを表示
              if (currentUser.isStar)
                _buildBottomNavItem(Icons.camera_alt, '取込', 2, selectedTab, isDark),
              _buildBottomNavItem(Icons.star, 'マイリスト', 3, selectedTab, isDark),
              _buildBottomNavItem(Icons.person, 'マイページ', 4, selectedTab, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index, int selectedTab, bool isDark) {
    final isSelected = selectedTab == index;
    
    return Expanded(
      child: GestureDetector(
      onTap: () {
        ref.read(selectedTabProvider.notifier).state = index;
          ref.read(selectedDrawerPageProvider.notifier).state = null; // ドロワー選択をリセット
      },
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
                size: 22,
                color: isSelected ? const Color(0xFF4ECDC4) : (isDark ? Colors.white54 : const Color(0xFF9CA3AF)),
            ),
              const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                  fontSize: 10,
                fontWeight: FontWeight.w500,
                  color: isSelected ? const Color(0xFF4ECDC4) : (isDark ? Colors.white54 : const Color(0xFF9CA3AF)),
              ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'すべて見る',
              style: TextStyle(
                color: Color(0xFF4ECDC4),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 