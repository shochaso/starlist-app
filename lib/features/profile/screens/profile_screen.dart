import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/user_provider.dart';
import '../../../models/user.dart';
import '../../../src/providers/theme_provider_enhanced.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final bool showAppBar;
  
  const ProfileScreen({super.key, this.showAppBar = true});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (_selectedTabIndex != _tabController.index) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    // showAppBarがfalseの場合、AppBarとDrawerなしでコンテンツのみ表示
    if (!widget.showAppBar) {
      return Container(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
        child: _buildContent(currentUser, isDark),
      );
    }
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        title: Text(
          'マイページ',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, color: isDark ? Colors.white : Colors.black87),
          onPressed: () {
            HapticFeedback.lightImpact();
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: isDark ? Colors.white : Colors.black87),
            onPressed: () => _navigateToEditProfile(),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildContent(currentUser, isDark),
    );
  }

  Widget _buildContent(currentUser, bool isDark) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // プロフィールヘッダー
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // アバターとユーザー情報
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: currentUser.isStar ? const LinearGradient(
                            colors: [Color(0xFFFFB6C1), Color(0xFFFFC0CB)],
                          ) : const LinearGradient(
                            colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: currentUser.isStar ? const Color(0xFFFFB6C1).withValues(alpha: 0.3) : const Color(0xFF4ECDC4).withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            currentUser.isStar ? '花' : 'F',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentUser.name,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              currentUser.isStar ? '@${currentUser.name.toLowerCase().replaceAll(' ', '_').replaceAll('花山瑞樹', 'hanayama_mizuki')}' : '@fan_user',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.black54,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4ECDC4).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                currentUser.planDisplayName,
                                style: const TextStyle(
                                  color: Color(0xFF4ECDC4),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // 統計情報
                  Row(
                    children: [
                      _buildStatItem(
                        currentUser.isStar ? '${currentUser.followers}' : '15', 
                        currentUser.isStar ? 'フォロワー' : 'フォロー'
                      ),
                      _buildStatItem(
                        currentUser.isStar ? '125' : '8', 
                        currentUser.isStar ? 'コンテンツ' : 'フォロワー'
                      ),
                      _buildStatItem('42', 'お気に入り'),
                      _buildStatItem('6', 'プレイリスト'),
                    ],
                  ),
                  
                  // プラン切り替えボタン（テスト用）
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.swap_horiz, color: isDark ? const Color(0xFF888888) : Colors.black54, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'テスト用プラン切り替え:',
                              style: TextStyle(color: isDark ? const Color(0xFF888888) : Colors.black54, fontSize: 10),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            _buildPlanButton('スター', UserRole.star, null, currentUser, isDark),
                            _buildPlanButton('無料ファン', UserRole.fan, FanPlanType.free, currentUser, isDark),
                            _buildPlanButton('ライト', UserRole.fan, FanPlanType.light, currentUser, isDark),
                            _buildPlanButton('スタンダード', UserRole.fan, FanPlanType.standard, currentUser, isDark),
                            _buildPlanButton('プレミアム', UserRole.fan, FanPlanType.premium, currentUser, isDark),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // タブバー
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  _buildTabItem('概要', 0, _selectedTabIndex),
                  _buildTabItem('フォロー', 1, _selectedTabIndex),
                  _buildTabItem('コンテンツ', 2, _selectedTabIndex),
                  _buildTabItem('活動', 3, _selectedTabIndex),
                  _buildTabItem('バッジ', 4, _selectedTabIndex),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // タブコンテンツ
            _buildTabContent(_selectedTabIndex, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index, int selectedIndex) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: index == selectedIndex ? const Color(0xFF4ECDC4) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: index == selectedIndex ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
              fontSize: 14,
              fontWeight: index == selectedIndex ? FontWeight.w600 : FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  // データ構造の復元
  final List<Map<String, dynamic>> _contentCategories = [
    {
      'id': 'following',
      'title': 'フォロー中',
      'icon': Icons.person_add_outlined,
      'color': Color(0xFF4ECDC4),
      'count': 15,
    },
    {
      'id': 'favorites',
      'title': 'お気に入り',
      'icon': Icons.favorite_outline,
      'color': Color(0xFFFF6B6B),
      'count': 42,
    },
    {
      'id': 'playlists',
      'title': 'プレイリスト',
      'icon': Icons.playlist_play_outlined,
      'color': Color(0xFF8B5CF6),
      'count': 6,
    },
    {
      'id': 'saved',
      'title': '保存済み',
      'icon': Icons.bookmark_outline,
      'color': Color(0xFFFFE66D),
      'count': 28,
    },
  ];

  final Map<String, List<Map<String, dynamic>>> _contentData = {
    'following': [
      {
        'id': '1',
        'name': 'テックレビューアー田中',
        'category': 'テクノロジー',
        'followers': '24.5K',
        'avatar': null,
        'isVerified': true,
        'followedDate': '2024/01/15',
      },
      {
        'id': '2',
        'name': '料理研究家佐藤',
        'category': '料理・グルメ',
        'followers': '18.3K',
        'avatar': null,
        'isVerified': false,
        'followedDate': '2024/01/10',
      },
      {
        'id': '3',
        'name': 'フィットネス山田',
        'category': 'フィットネス',
        'followers': '12.1K',
        'avatar': null,
        'isVerified': true,
        'followedDate': '2024/01/08',
      },
    ],
    'favorites': [
      {
        'id': '1',
        'title': 'iPhone 15 Pro Max 詳細レビュー',
        'star': 'テックレビューアー田中',
        'duration': '25:30',
        'addedDate': '2024/01/15',
        'thumbnail': null,
        'category': 'テクノロジー',
      },
      {
        'id': '2',
        'title': '簡単チキンカレーの作り方',
        'star': '料理研究家佐藤',
        'duration': '12:45',
        'addedDate': '2024/01/14',
        'thumbnail': null,
        'category': '料理・グルメ',
      },
      {
        'id': '3',
        'title': '朝の10分ストレッチルーティン',
        'star': 'フィットネス山田',
        'duration': '10:15',
        'addedDate': '2024/01/13',
        'thumbnail': null,
        'category': 'フィットネス',
      },
    ],
  };

  final Map<String, dynamic> _userProfile = {
    'name': '田中太郎',
    'username': '@tanaka_taro',
    'email': 'tanaka@example.com',
    'bio': 'テクノロジーとガジェットが大好きです。最新のスマートフォンやPCのレビューを見るのが趣味です。',
    'joinDate': '2023年8月',
    'avatar': null,
    'isVerified': false,
    'location': '東京都',
    'website': 'https://tanaka-blog.com',
  };

  final Map<String, dynamic> _stats = {
    'following': 15,
    'followers': 8,
    'favorites': 42,
    'playlists': 6,
    'totalViews': 1250,
    'totalLikes': 89,
  };

  final List<Map<String, dynamic>> _recentActivities = [
    {
      'type': 'favorite',
      'action': 'お気に入りに追加',
      'target': 'iPhone 15 Pro レビュー',
      'star': 'テックレビューアー田中',
      'time': '2時間前',
    },
    {
      'type': 'follow',
      'action': 'フォロー開始',
      'target': '料理研究家佐藤',
      'time': '1日前',
    },
    {
      'type': 'playlist',
      'action': 'プレイリスト作成',
      'target': 'プログラミング学習',
      'time': '3日前',
    },
  ];

  final List<Map<String, dynamic>> _badges = [
    {
      'id': 'early_adopter',
      'name': 'アーリーアダプター',
      'description': 'Starlistの初期ユーザー',
      'icon': Icons.star,
      'color': Color(0xFFFFD700),
      'earned': true,
      'earnedDate': '2023-08-15',
    },
    {
      'id': 'active_user',
      'name': 'アクティブユーザー',
      'description': '30日連続でアプリを利用',
      'icon': Icons.local_fire_department,
      'color': Color(0xFFFF6B6B),
      'earned': true,
      'earnedDate': '2023-12-01',
    },
    {
      'id': 'curator',
      'name': 'キュレーター',
      'description': '50個以上のコンテンツをお気に入り',
      'icon': Icons.collections_bookmark,
      'color': Color(0xFF4ECDC4),
      'earned': false,
      'progress': 42,
      'target': 50,
    },
  ];

  Widget _buildTabContent(int index, bool isDark) {
    switch (index) {
      case 0:
        return _buildOverviewTabContent();
      case 1:
        return _buildFollowTabContent();
      case 2:
        return _buildContentTabContent();
      case 3:
        return _buildActivityTabContent();
      case 4:
        return _buildBadgesTabContent();
      default:
        return Container();
    }
  }

  Widget _buildOverviewTabContent() {
    final currentUser = ref.watch(currentUserProvider);
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 自己紹介
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
            ),
            child: Text(
              currentUser.isStar 
                ? '最新のテクノロジーとガジェットをわかりやすくレビューしています。iPhone、Android、PC、カメラなど幅広くカバー。'
                : 'テクノロジーとガジェットが大好きです。最新のスマートフォンやPCのレビューを見るのが趣味です。',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 100), // ボトムナビゲーション用の余白
        ],
      ),
    );
  }

  Widget _buildFollowTabContent() {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    final followingData = _contentData['following'] ?? [];
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'フォロー中のユーザー',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...followingData.map((user) => _buildFollowUserCard(user, isDark)).toList(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildContentTabContent() {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: _contentCategories.length,
            itemBuilder: (context, index) {
              final category = _contentCategories[index];
              return _buildContentCategoryCard(category, isDark);
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildActivityTabContent() {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ..._recentActivities.map((activity) => _buildActivityCard(activity)).toList(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildBadgesTabContent() {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '獲得済みバッジ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ..._badges.where((badge) => badge['earned']).map((badge) => _buildBadgeCard(badge)).toList(),
          const SizedBox(height: 24),
          Text(
            '未獲得バッジ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ..._badges.where((badge) => !badge['earned']).map((badge) => _buildBadgeCard(badge)).toList(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    final currentUser = ref.watch(currentUserProvider);
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      child: Column(
        children: [
          SafeArea(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4ECDC4),
                    Color(0xFF44A08D),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Starlist',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          currentUser.isStar ? 'スター' : 'ファン',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildDrawerItem(
                  icon: Icons.home,
                  title: 'ホーム',
                  isActive: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  isDark: isDark,
                ),
                _buildDrawerItem(
                  icon: Icons.search,
                  title: '検索',
                  isActive: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/search');
                  },
                  isDark: isDark,
                ),
                _buildDrawerItem(
                  icon: Icons.star,
                  title: 'マイリスト',
                  isActive: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/mylist');
                  },
                  isDark: isDark,
                ),
                // スターのみ表示
                if (currentUser.isStar) ...[
                  _buildDrawerItem(
                    icon: Icons.camera_alt,
                    title: 'データ取込み',
                    isActive: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/data-import');
                    },
                    isDark: isDark,
                  ),
                  _buildDrawerItem(
                    icon: Icons.analytics,
                    title: 'スターダッシュボード',
                    isActive: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/star-dashboard');
                    },
                    isDark: isDark,
                  ),
                  _buildDrawerItem(
                    icon: Icons.workspace_premium,
                    title: 'プランを管理',
                    isActive: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/plan-management');
                    },
                    isDark: isDark,
                  ),
                ],
                _buildDrawerItem(
                  icon: Icons.person,
                  title: 'マイページ',
                  isActive: true,
                  onTap: () {
                    Navigator.pop(context);
                    // 既にマイページなので何もしない
                  },
                  isDark: isDark,
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: '設定',
                  isActive: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/settings');
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isActive ? const Color(0xFF4ECDC4).withValues(alpha: 0.15) : null,
        border: isActive ? Border.all(
          color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
          width: 1,
        ) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive 
              ? const Color(0xFF4ECDC4)
              : (isDark ? Colors.white10 : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isActive 
              ? Colors.white
              : (isDark ? Colors.white54 : Colors.grey.shade600),
            size: 18,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive 
              ? const Color(0xFF4ECDC4) 
              : (isDark ? Colors.white : Colors.grey.shade800),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
        trailing: isActive ? const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFF4ECDC4),
          size: 14,
        ) : null,
        onTap: onTap,
      ),
    );
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileEditScreen()),
    );
  }

  Widget _buildPlanButton(String label, UserRole role, FanPlanType? planType, UserInfo currentUser, bool isDark) {
    final isSelected = currentUser.role == role && currentUser.fanPlanType == planType;
    
    return GestureDetector(
      onTap: () {
        String name;
        String? category;
        int? followers;
        
        if (role == UserRole.star) {
          name = '花山瑞樹';
          category = '日常Blog・ファッション';
          followers = 127000;
        } else {
          name = 'ファンユーザー';
          category = null;
          followers = null;
        }
        
        ref.read(currentUserProvider.notifier).state = UserInfo(
          id: currentUser.id,
          name: name,
          email: currentUser.email,
          role: role,
          fanPlanType: planType,
          starCategory: category,
          followers: followers,
          isVerified: role == UserRole.star,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4ECDC4) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF4ECDC4) : (isDark ? const Color(0xFF444444) : const Color(0xFFCCCCCC)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ),
    );
  }

  // ヘルパーメソッドの実装
  Widget _buildFollowUserCard(Map<String, dynamic> user, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF4ECDC4), const Color(0xFF44A08D)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                user['name'][0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user['name'],
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user['isVerified'])
                      const Icon(
                        Icons.verified,
                        color: Color(0xFF4ECDC4),
                        size: 16,
                      ),
                  ],
                ),
                Text(
                  user['category'],
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.black54,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${user['followers']} フォロワー',
                  style: TextStyle(
                    color: const Color(0xFF4ECDC4),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('フォロー管理機能（実装予定）'),
                  backgroundColor: Color(0xFF4ECDC4),
                ),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF4ECDC4).withOpacity(0.1),
              foregroundColor: const Color(0xFF4ECDC4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              '管理',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCategoryCard(Map<String, dynamic> category, bool isDark) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${category['title']}の詳細表示（実装予定）'),
            backgroundColor: const Color(0xFF4ECDC4),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: category['color'].withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                category['icon'],
                color: category['color'],
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              category['title'],
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${category['count']}件',
              style: TextStyle(
                color: category['color'],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    IconData icon;
    Color iconColor;
    
    switch (activity['type']) {
      case 'favorite':
        icon = Icons.favorite;
        iconColor = const Color(0xFFFF6B6B);
        break;
      case 'follow':
        icon = Icons.person_add;
        iconColor = const Color(0xFF4ECDC4);
        break;
      case 'playlist':
        icon = Icons.playlist_add;
        iconColor = const Color(0xFF8B5CF6);
        break;
      default:
        icon = Icons.info;
        iconColor = const Color(0xFF888888);
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['action'],
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  activity['target'],
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.black54,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (activity['star'] != null)
                  Text(
                    'by ${activity['star']}',
                    style: TextStyle(
                      color: const Color(0xFF4ECDC4),
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Text(
            activity['time'],
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    final isEarned = badge['earned'] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEarned 
            ? badge['color'].withOpacity(0.5)
            : (isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isEarned 
                ? badge['color'].withOpacity(0.2)
                : (isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              badge['icon'],
              color: isEarned ? badge['color'] : (isDark ? Colors.grey[600] : Colors.grey[400]),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge['name'],
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  badge['description'],
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.black54,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                if (!isEarned && badge['progress'] != null) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: badge['progress'] / badge['target'],
                    backgroundColor: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
                    valueColor: AlwaysStoppedAnimation<Color>(badge['color']),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${badge['progress']} / ${badge['target']}',
                    style: TextStyle(
                      color: badge['color'],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ] else if (isEarned && badge['earnedDate'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '獲得日: ${badge['earnedDate']}',
                    style: TextStyle(
                      color: const Color(0xFF4ECDC4),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}