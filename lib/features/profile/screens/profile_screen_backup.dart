import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/user_provider.dart';
import '../../../src/providers/theme_provider_enhanced.dart';
import 'profile_edit_screen.dart';
import '../../app/screens/settings_screen.dart';
import '../../star/screens/star_dashboard_screen.dart';
import '../../star/screens/schedule_management_screen.dart';
import '../../data_integration/screens/data_import_screen.dart';
import '../../subscription/screens/fan_subscription_screen.dart';
import '../../search/screens/search_screen.dart';
import '../../mylist/screens/mylist_screen.dart';

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
  
  // コンテンツカテゴリ
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
  
  // サンプルデータ
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
    'playlists': [
      {
        'id': '1',
        'name': 'プログラミング学習',
        'description': 'Flutter開発に関する動画',
        'itemCount': 12,
        'createdDate': '2024/01/10',
        'thumbnail': null,
        'isPublic': false,
      },
      {
        'id': '2',
        'name': 'お気に入りガジェット',
        'description': '2024年のおすすめガジェット',
        'itemCount': 8,
        'createdDate': '2024/01/05',
        'thumbnail': null,
        'isPublic': true,
      },
    ],
    'saved': [
      {
        'id': '1',
        'title': 'Dartの非同期処理完全ガイド',
        'star': 'プログラミング講師伊藤',
        'savedDate': '2024/01/12',
        'category': 'プログラミング',
        'readingTime': '15分',
      },
      {
        'id': '2',
        'title': '効率的なワークフローの作り方',
        'star': '生産性コンサルタント',
        'savedDate': '2024/01/11',
        'category': 'ビジネス',
        'readingTime': '8分',
      },
    ],
  };

  // ユーザー情報
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

  // 統計情報
  final Map<String, dynamic> _stats = {
    'following': 15,
    'followers': 8,
    'favorites': 42,
    'playlists': 6,
    'totalViews': 1250,
    'totalLikes': 89,
  };

  // 最近の活動
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

  // バッジ・実績
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
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
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: isDark ? Colors.white : Colors.black87),
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: isDark ? Colors.white : Colors.black87, size: 20),
                    const SizedBox(width: 8),
                    Text('プロフィール編集', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, color: isDark ? Colors.white : Colors.black87, size: 20),
                    const SizedBox(width: 8),
                    Text('プロフィール共有', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: isDark ? Colors.white : Colors.black87, size: 20),
                    const SizedBox(width: 8),
                    Text('設定', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  ],
                ),
              ),
            ],
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
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4ECDC4).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '田',
                              style: TextStyle(
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
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      currentUser.isStar ? currentUser.name : '田中太郎',
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black87,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (currentUser.isStar && currentUser.isVerified)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 4),
                                      child: Icon(
                                        Icons.verified,
                                        color: Color(0xFF4ECDC4),
                                        size: 18,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currentUser.isStar ? '@${currentUser.name.toLowerCase().replaceAll(' ', '_')}' : '@tanaka_taro',
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
                                  color: const Color(0xFF4ECDC4).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  currentUser.isStar ? 'スター' : 'ファン',
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
                        IconButton(
                          icon: Icon(Icons.share, color: isDark ? Colors.white : Colors.black54, size: 20),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.more_vert, color: isDark ? Colors.white : Colors.black54, size: 20),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // スター専用ボタン（ダッシュボードとスケジュール管理）
                    if (currentUser.isStar) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const StarDashboardScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.dashboard, size: 18),
                              label: const Text('ダッシュボード'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                                foregroundColor: isDark ? Colors.white : Colors.black87,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const ScheduleManagementScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.schedule, size: 18),
                              label: const Text('スケジュール'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                                foregroundColor: isDark ? Colors.white : Colors.black87,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    
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
                    
                    // 役割切り替えボタン（テスト用）
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.swap_horiz, color: isDark ? const Color(0xFF888888) : Colors.black54, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'テスト用役割切り替え:',
                            style: TextStyle(color: isDark ? const Color(0xFF888888) : Colors.black54, fontSize: 10),
                          ),
                          const Spacer(),
                          ToggleButtons(
                            isSelected: [currentUser.isStar, currentUser.isFan],
                            onPressed: (index) {
                              final newRole = index == 0 ? UserRole.star : UserRole.fan;
                              ref.read(currentUserProvider.notifier).state = UserInfo(
                                id: currentUser.id,
                                name: newRole == UserRole.star ? 'テックレビューアー田中' : '田中太郎',
                                email: currentUser.email,
                                role: newRole,
                                starCategory: newRole == UserRole.star ? 'テクノロジー' : null,
                                followers: newRole == UserRole.star ? 24500 : null,
                                isVerified: newRole == UserRole.star,
                              );
                            },
                            borderRadius: BorderRadius.circular(6),
                            selectedColor: Colors.black,
                            fillColor: const Color(0xFF4ECDC4),
                            color: isDark ? Colors.white : Colors.black87,
                            constraints: const BoxConstraints(minHeight: 28, minWidth: 50),
                            children: const [
                              Text('スター', style: TextStyle(fontSize: 9)),
                              Text('ファン', style: TextStyle(fontSize: 9)),
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
              _buildTabContentForScroll(_selectedTabIndex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(String label, int index, int selectedIndex) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: index == _selectedTabIndex ? const Color(0xFF4ECDC4) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: index == _selectedTabIndex ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContentForScroll(int index) {
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

  Widget _buildFollowTabContent() {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    // フォロー中のユーザーデータ
    final followingData = _contentData['following'] ?? [];
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.people,
                  color: Color(0xFF4ECDC4),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'フォロー中',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${followingData.length}人をフォロー中',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // フォロー管理ボタン
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('フォロー管理機能（実装予定）'),
                      backgroundColor: Color(0xFF4ECDC4),
                    ),
                  );
                },
                icon: const Icon(Icons.manage_accounts, size: 16),
                label: const Text('管理'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ECDC4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // フォロー中のユーザーリスト
          ...followingData.map((user) => _buildFollowUserCard(user, isDark)).toList(),
          
          const SizedBox(height: 100), // ボトムナビゲーション用の余白
        ],
      ),
    );
  }

  Widget _buildFollowUserCard(Map<String, dynamic> user, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          // アバター
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                user['name']?.substring(0, 1) ?? 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // ユーザー情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user['name'] ?? 'Unknown User',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user['isVerified'] == true)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.verified,
                          color: Color(0xFF4ECDC4),
                          size: 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user['category'] ?? 'カテゴリ不明',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      color: isDark ? Colors.grey[500] : Colors.black38,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${user['followers']} フォロワー',
                      style: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.black38,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.calendar_today,
                      color: isDark ? Colors.grey[500] : Colors.black38,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'フォロー日: ${user['followedDate']}',
                      style: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.black38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // アクションボタン
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${user['name']}のプロフィールを表示'),
                      backgroundColor: const Color(0xFF4ECDC4),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ECDC4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                  minimumSize: const Size(60, 28),
                ),
                child: const Text(
                  'プロフィール',
                  style: TextStyle(fontSize: 10),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${user['name']}のフォローを解除しました'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  minimumSize: const Size(60, 24),
                ),
                child: const Text(
                  'フォロー解除',
                  style: TextStyle(fontSize: 9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTabContent() {
    final currentUser = ref.watch(currentUserProvider);
    
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
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Text(
              currentUser.isStar 
                ? '最新のテクノロジーとガジェットをわかりやすくレビューしています。iPhone、Android、PC、カメラなど幅広くカバー。'
                : 'テクノロジーとガジェットが大好きです。最新のスマートフォンやPCのレビューを見るのが趣味です。',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoSection(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildRecentStats(),
          const SizedBox(height: 100), // ボトムナビゲーション用の余白
        ],
      ),
    );
  }

  Widget _buildActivityTabContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ..._recentActivities.map((activity) => _buildActivityCard(activity)).toList(),
          const SizedBox(height: 100), // ボトムナビゲーション用の余白
        ],
      ),
    );
  }

  Widget _buildBadgesTabContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '獲得済みバッジ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ..._badges.where((badge) => badge['earned']).map((badge) => _buildBadgeCard(badge)).toList(),
          const SizedBox(height: 24),
          const Text(
            '未獲得バッジ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ..._badges.where((badge) => !badge['earned']).map((badge) => _buildBadgeCard(badge)).toList(),
          const SizedBox(height: 100), // ボトムナビゲーション用の余白
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '基本情報',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.email, 'メールアドレス', _userProfile['email']),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on, '所在地', _userProfile['location']),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.language, 'ウェブサイト', _userProfile['website']),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4ECDC4), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF888888),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'クイックアクション',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                Icons.edit,
                'プロフィール編集',
                () => _editProfile(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                Icons.settings,
                '設定',
                () => _openSettings(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                Icons.download,
                'データエクスポート',
                () => _exportData(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                Icons.help,
                'ヘルプ',
                () => _openHelp(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: const Color(0xFF2A2A2A),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF4ECDC4), size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentStats() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '今月の統計',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('総視聴回数', '${_stats['totalViews']}', Icons.visibility),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('いいね数', '${_stats['totalLikes']}', Icons.favorite),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    IconData typeIcon;
    Color typeColor;
    
    switch (activity['type']) {
      case 'favorite':
        typeIcon = Icons.favorite;
        typeColor = Colors.red;
        break;
      case 'follow':
        typeIcon = Icons.person_add;
        typeColor = const Color(0xFF4ECDC4);
        break;
      case 'playlist':
        typeIcon = Icons.playlist_add;
        typeColor = const Color(0xFFFFE66D);
        break;
      default:
        typeIcon = Icons.circle;
        typeColor = const Color(0xFF888888);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(typeIcon, color: typeColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['action'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['target'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4ECDC4),
                  ),
                ),
                if (activity['star'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'by ${activity['star']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  activity['time'],
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge) {
    final isEarned = badge['earned'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEarned ? badge['color'] : const Color(0xFF333333),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (isEarned ? badge['color'] : const Color(0xFF888888)).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              badge['icon'],
              color: isEarned ? badge['color'] : const Color(0xFF888888),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isEarned ? Colors.white : const Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  badge['description'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
                if (isEarned && badge['earnedDate'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '獲得日: ${badge['earnedDate']}',
                    style: TextStyle(
                      fontSize: 10,
                      color: badge['color'],
                    ),
                  ),
                ] else if (!isEarned && badge['progress'] != null) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: badge['progress'] / badge['target'],
                    backgroundColor: const Color(0xFF333333),
                    valueColor: AlwaysStoppedAnimation<Color>(badge['color']),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${badge['progress']} / ${badge['target']}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF888888),
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

  Widget _buildStatItem(String value, String label) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    // プライバシー保護：フォロー情報とプレイリストは非公開
    final bool isPrivateData = label.contains('フォロー') || label.contains('プレイリスト');
    
    return Expanded(
      child: GestureDetector(
        onTap: isPrivateData ? () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$labelの詳細は非公開です'),
              backgroundColor: isDark ? const Color(0xFF4ECDC4) : const Color(0xFF4ECDC4),
            ),
          );
        } : null,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isPrivateData) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.lock,
                    size: 12,
                    color: isDark ? Colors.grey[400] : Colors.black54,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileEditScreen(),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('データをエクスポート中...'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  void _openHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ヘルプセンターを開く'),
        backgroundColor: Color(0xFF4ECDC4),
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
          // カテゴリグリッド
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
          const SizedBox(height: 24),
          
          // 最近のコンテンツ
          _buildRecentContentSection(isDark),
          
          const SizedBox(height: 100), // ボトムナビゲーション用の余白
        ],
      ),
    );
  }
  
  Widget _buildContentCategoryCard(Map<String, dynamic> category, bool isDark) {
    return GestureDetector(
      onTap: () => _showCategoryDetail(category),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.black).withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (category['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category['icon'] as IconData,
                  color: category['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                category['title'],
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${category['count']}件',
                style: TextStyle(
                  color: category['color'] as Color,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRecentContentSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '最近の活動',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => _showAllRecentContent(),
              child: const Text(
                'すべて見る',
                style: TextStyle(
                  color: Color(0xFF4ECDC4),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 最近のフォロー
        _buildRecentContentCard(
          'フォロー開始',
          '料理研究家佐藤',
          '1日前',
          Icons.person_add,
          const Color(0xFF4ECDC4),
          isDark,
        ),
        const SizedBox(height: 12),
        
        // 最近のお気に入り
        _buildRecentContentCard(
          'お気に入りに追加',
          'iPhone 15 Pro Max 詳細レビュー',
          '2時間前',
          Icons.favorite,
          const Color(0xFFFF6B6B),
          isDark,
        ),
        const SizedBox(height: 12),
        
        // 最近のプレイリスト
        _buildRecentContentCard(
          'プレイリスト作成',
          'プログラミング学習',
          '3日前',
          Icons.playlist_add,
          const Color(0xFF8B5CF6),
          isDark,
        ),
      ],
    );
  }
  
  Widget _buildRecentContentCard(
    String action,
    String title,
    String time,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.black38,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showCategoryDetail(Map<String, dynamic> category) {
    final themeState = ref.read(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ハンドル
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // ヘッダー
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (category['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      category['icon'] as IconData,
                      color: category['color'] as Color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category['title'],
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${category['count']}件のアイテム',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // コンテンツリスト
            Expanded(
              child: _buildCategoryContentList(category['id'], isDark),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategoryContentList(String categoryId, bool isDark) {
    final items = _contentData[categoryId] ?? [];
    
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildContentListItem(categoryId, item, isDark);
      },
    );
  }
  
  Widget _buildContentListItem(String categoryId, Map<String, dynamic> item, bool isDark) {
    switch (categoryId) {
      case 'following':
        return _buildFollowingItem(item, isDark);
      case 'favorites':
        return _buildFavoriteItem(item, isDark);
      case 'playlists':
        return _buildPlaylistItem(item, isDark);
      case 'saved':
        return _buildSavedItem(item, isDark);
      default:
        return Container();
    }
  }
  
  Widget _buildFollowingItem(Map<String, dynamic> item, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          // アバター
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                item['name'][0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // 情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['name'],
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item['isVerified'])
                      const Icon(
                        Icons.verified,
                        color: Color(0xFF4ECDC4),
                        size: 16,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item['category'],
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.black54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${item['followers']} フォロワー',
                      style: TextStyle(
                        color: const Color(0xFF4ECDC4),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'フォロー開始: ${item['followedDate']}',
                      style: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.black38,
                        fontSize: 10,
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
  }
  
  Widget _buildFavoriteItem(Map<String, dynamic> item, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          // サムネイル
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
              ),
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Color(0xFFFF6B6B),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // 情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item['star'],
                  style: TextStyle(
                    color: const Color(0xFF4ECDC4),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      item['duration'],
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '追加: ${item['addedDate']}',
                      style: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.black38,
                        fontSize: 10,
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
  }
  
  Widget _buildPlaylistItem(Map<String, dynamic> item, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          // プレイリストアイコン
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.playlist_play,
              color: Color(0xFF8B5CF6),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // 情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['name'],
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item['isPublic'])
                      Icon(
                        Icons.public,
                        color: isDark ? Colors.grey[400] : Colors.black54,
                        size: 16,
                      )
                    else
                      Icon(
                        Icons.lock,
                        color: isDark ? Colors.grey[400] : Colors.black54,
                        size: 16,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item['description'],
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.black54,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${item['itemCount']}件のアイテム',
                      style: TextStyle(
                        color: const Color(0xFF8B5CF6),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '作成: ${item['createdDate']}',
                      style: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.black38,
                        fontSize: 10,
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
  }
  
  Widget _buildSavedItem(Map<String, dynamic> item, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          // ブックマークアイコン
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE66D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.bookmark,
              color: Color(0xFFFFE66D),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // 情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item['star'],
                  style: TextStyle(
                    color: const Color(0xFF4ECDC4),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE66D).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item['category'],
                        style: const TextStyle(
                          color: Color(0xFFFFE66D),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '読了時間: ${item['readingTime']}',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.black54,
                        fontSize: 10,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '保存: ${item['savedDate']}',
                      style: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.black38,
                        fontSize: 10,
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
  }
  
  void _showAllRecentContent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('すべての最近の活動を表示'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileEditScreen(),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _navigateToEditProfile();
        break;
      case 'share':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('プロフィールを共有しました'),
            backgroundColor: Color(0xFF4ECDC4),
          ),
        );
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SettingsScreen(),
          ),
        );
        break;
    }
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
                _buildDrawerItem(Icons.home, 'ホーム', false, () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/');
                }),
                _buildDrawerItem(Icons.search, '検索', false, () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/search');
                }),
                _buildDrawerItem(Icons.star, 'マイリスト', false, () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/mylist');
                }),
                // スターのみ表示
                if (currentUser.isStar) ...[
                  _buildDrawerItem(Icons.camera_alt, 'データ取込み', false, () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/data-import');
                  }),
                  _buildDrawerItem(Icons.analytics, 'スターダッシュボード', false, () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/star-dashboard');
                  }),
                  _buildDrawerItem(Icons.workspace_premium, 'プランを管理', false, () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/plan-management');
                  }),
                ],
                _buildDrawerItem(Icons.person, 'マイページ', true, () {
                  Navigator.pop(context);
                }),
                _buildDrawerItem(Icons.settings, '設定', false, () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/settings');
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, bool isActive, VoidCallback onTap) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
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
} 