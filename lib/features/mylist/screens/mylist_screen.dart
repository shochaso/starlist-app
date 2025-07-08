import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../src/providers/theme_provider_enhanced.dart';
import '../../../providers/user_provider.dart';

// プロバイダー
final selectedTabProvider = StateProvider<int>((ref) => 0);

class MylistScreen extends ConsumerStatefulWidget {
  final bool showAppBar;
  
  const MylistScreen({super.key, this.showAppBar = true});

  @override
  ConsumerState<MylistScreen> createState() => _MylistScreenState();
}

class _MylistScreenState extends ConsumerState<MylistScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ダミーデータ - フォロー中のスター
  final List<Map<String, dynamic>> _followingStars = [
    {
      'id': '1',
      'name': 'テックレビューアー田中',
      'category': 'テクノロジー',
      'followers': 15420,
      'avatar': null,
      'verified': true,
      'lastPost': '2時間前',
      'isOnline': true,
      'newPosts': 3,
    },
    {
      'id': '2',
      'name': '料理研究家佐藤',
      'category': '料理・グルメ',
      'followers': 8930,
      'avatar': null,
      'verified': false,
      'lastPost': '1日前',
      'isOnline': false,
      'newPosts': 1,
    },
    {
      'id': '3',
      'name': 'ゲーム実況者山田',
      'category': 'ゲーム',
      'followers': 23450,
      'avatar': null,
      'verified': true,
      'lastPost': '30分前',
      'isOnline': true,
      'newPosts': 5,
    },
  ];

  // お気に入りのスター
  final List<Map<String, dynamic>> _favoriteStars = [
    {
      'id': '1',
      'name': 'テックレビューアー田中',
      'category': 'テクノロジー',
      'followers': 15420,
      'avatar': null,
      'verified': true,
      'addedDate': '2024-01-15',
      'lastViewed': '2時間前',
    },
    {
      'id': '2',
      'name': '料理研究家佐藤',
      'category': '料理・グルメ',
      'followers': 8930,
      'avatar': null,
      'verified': false,
      'addedDate': '2024-01-10',
      'lastViewed': '1日前',
    },
  ];

  // 最近の活動データ
  final List<Map<String, dynamic>> _recentActivities = [
    {
      'star': 'テックレビューアー田中',
      'action': '新しい動画を投稿しました',
      'content': 'iPhone 15 Pro Max 詳細レビュー',
      'time': '2時間前',
      'type': 'video',
    },
    {
      'star': 'ゲーム実況者山田',
      'action': 'ライブ配信を開始しました',
      'content': 'Apex Legends ランクマッチ',
      'time': '30分前',
      'type': 'live',
    },
    {
      'star': '料理研究家佐藤',
      'action': '新しいレシピを投稿しました',
      'content': '簡単チキンカレーの作り方',
      'time': '1日前',
      'type': 'recipe',
    },
  ];

  final List<Map<String, dynamic>> _favoriteContents = [
    {
      'id': '1',
      'title': 'iPhone 15 Pro レビュー',
      'star': 'テックレビューアー田中',
      'category': 'テクノロジー',
      'likes': 234,
      'views': 1520,
      'addedDate': '2024-01-20',
      'duration': '15:30',
      'type': 'video',
    },
    {
      'id': '2',
      'title': '簡単パスタレシピ集',
      'star': '料理研究家佐藤',
      'category': '料理・グルメ',
      'likes': 156,
      'views': 890,
      'addedDate': '2024-01-18',
      'duration': '8:45',
      'type': 'recipe',
    },
    {
      'id': '3',
      'title': 'Flutter開発のコツ',
      'star': 'テックレビューアー田中',
      'category': 'テクノロジー',
      'likes': 89,
      'views': 456,
      'addedDate': '2024-01-16',
      'duration': '12:20',
      'type': 'tutorial',
    },
  ];

  final List<Map<String, dynamic>> _playlists = [
    {
      'id': '1',
      'name': 'お気に入りレシピ',
      'description': '作ってみたい料理レシピ集',
      'itemCount': 12,
      'createdDate': '2024-01-01',
      'thumbnail': null,
      'isPublic': false,
    },
    {
      'id': '2',
      'name': 'プログラミング学習',
      'description': 'Flutter・Dart関連の動画',
      'itemCount': 8,
      'createdDate': '2024-01-05',
      'thumbnail': null,
      'isPublic': true,
    },
  ];

  String _sortBy = 'recent';

  // プレミアムタブウィジェット - アイコン重視版
  Widget _buildPremiumTab(String label, IconData icon) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    try {
      _tabController = TabController(length: 4, vsync: this);
      _tabController.addListener(() {
        if (mounted && _selectedTabIndex != _tabController.index) {
          setState(() {
            _selectedTabIndex = _tabController.index;
          });
        }
      });
    } catch (e) {
      debugPrint('MylistScreen初期化エラー: $e');
    }
  }

  @override
  void dispose() {
    try {
      _tabController.dispose();
    } catch (e) {
      debugPrint('MylistScreen dispose エラー: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    // 安全チェック
    if (!mounted) return const SizedBox.shrink();
    
    // showAppBarがfalseの場合、AppBarとDrawerなしでコンテンツのみ表示
    if (!widget.showAppBar) {
      return Container(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
        child: _buildContent(isDark),
      );
    }
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        title: Text(
          'マイリスト',
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
            icon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black87),
            onPressed: () => _searchMylist(),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: isDark ? Colors.white : Colors.black87),
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'sort',
                child: Row(
                  children: [
                    Icon(Icons.sort, color: isDark ? Colors.white : Colors.black87, size: 20),
                    const SizedBox(width: 8),
                    Text('並び替え', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, color: isDark ? Colors.white : Colors.black87, size: 20),
                    const SizedBox(width: 8),
                    Text('エクスポート', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
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
      body: _buildContent(isDark),
    );
  }

  Widget _buildContent(bool isDark) {
    return SafeArea(
      child: Column(
        children: [
          // 洗練されたタブバー
          Container(
            margin: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark 
                  ? [const Color(0xFF2A2A2A), const Color(0xFF1F1F1F)]
                  : [Colors.white, const Color(0xFFF8FAFC)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark 
                  ? const Color(0xFF404040).withValues(alpha: 0.5)
                  : const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark 
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: isDark 
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.9),
                  blurRadius: 0,
                  offset: const Offset(0, 1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4ECDC4).withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: isDark 
                ? Colors.white.withValues(alpha: 0.6)
                : const Color(0xFF64748B),
              labelStyle: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 2),
              tabs: [
                _buildPremiumTab('フォロー', Icons.people_rounded),
                _buildPremiumTab('お気に入り', Icons.favorite_rounded),
                _buildPremiumTab('リスト', Icons.playlist_play_rounded),
                _buildPremiumTab('活動', Icons.timeline_rounded),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // タブコンテンツ
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFollowingTab(),
                _buildStarsTab(), // お気に入りコンテンツも統合
                _buildPlaylistsTab(),
                _buildActivitiesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildStarsTab() {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // お気に入りのスターセクション
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'お気に入りのスター',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () => _showAllStars(),
                child: const Text(
                  'すべて見る',
                  style: TextStyle(color: Color(0xFF4ECDC4)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._favoriteStars.map((star) => _buildStarCard(star)).toList(),
          
          const SizedBox(height: 32),
          
          // お気に入りコンテンツセクション
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'お気に入りコンテンツ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              DropdownButton<String>(
                value: _sortBy,
                dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                underline: Container(),
                items: const [
                  DropdownMenuItem(value: 'recent', child: Text('最近追加')),
                  DropdownMenuItem(value: 'popular', child: Text('人気順')),
                  DropdownMenuItem(value: 'name', child: Text('名前順')),
                ],
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._favoriteContents.map((content) => _buildContentCard(content)).toList(),
        ],
      ),
    );
  }


  Widget _buildPlaylistsTab() {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'プレイリスト',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showCreatePlaylistDialog(),
                icon: const Icon(Icons.add, color: Color(0xFF4ECDC4), size: 16),
                label: const Text(
                  '新規作成',
                  style: TextStyle(color: Color(0xFF4ECDC4)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._playlists.map((playlist) => _buildPlaylistCard(playlist)).toList(),
        ],
      ),
    );
  }

  Widget _buildStarCard(Map<String, dynamic> star) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2A2A2A),
                Color(0xFF1F1F1F),
              ],
            )
          : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Color(0xFFFAFBFC),
              ],
            ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark 
            ? const Color(0xFF404040).withValues(alpha: 0.3)
            : const Color(0xFFE2E8F0).withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: isDark
              ? Colors.black.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.8),
            blurRadius: 0,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                star['name'][0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
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
                        star['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (star['verified'])
                      const Icon(
                        Icons.verified,
                        color: Color(0xFF4ECDC4),
                        size: 16,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  star['category'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  '${star['followers']}人のフォロワー',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : Colors.black38,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '追加日: ${star['addedDate']} • 最終視聴: ${star['lastViewed']}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey[600] : Colors.black26,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.grey[400] : Colors.black54,
            ),
            onPressed: () => _showStarOptions(star),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(Map<String, dynamic> content) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black).withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content['title'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFF4ECDC4),
                child: Text(
                  content['star'][0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  content['star'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  content['category'],
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF4ECDC4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.favorite_outline,
                color: isDark ? Colors.grey[500] : Colors.black38,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${content['likes']}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.black38,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.visibility_outlined,
                color: isDark ? Colors.grey[500] : Colors.black38,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${content['views']}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.black38,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time,
                color: isDark ? Colors.grey[500] : Colors.black38,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                content['duration'],
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.black38,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: isDark ? Colors.grey[400] : Colors.black54,
                  size: 16,
                ),
                onPressed: () => _showContentOptions(content),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistCard(Map<String, dynamic> playlist) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black).withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.playlist_play,
              color: Colors.white,
              size: 28,
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
                        playlist['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (playlist['isPublic'])
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
                  playlist['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Text(
                  '${playlist['itemCount']}個のアイテム • 作成日: ${playlist['createdDate']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.grey[400] : Colors.black54,
            ),
            onPressed: () => _showPlaylistOptions(playlist),
          ),
        ],
      ),
    );
  }

  void _searchMylist() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('マイリスト検索機能'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'sort':
        _showSortOptions();
        break;
      case 'export':
        _exportMylist();
        break;
      case 'settings':
        _showMylistSettings();
        break;
    }
  }

  void _showSortOptions() {
    final themeState = ref.read(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '並び替え',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.access_time, color: Color(0xFF4ECDC4)),
              title: Text(
                '最近追加順',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha, color: Color(0xFF4ECDC4)),
              title: Text(
                '名前順',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.category, color: Color(0xFF4ECDC4)),
              title: Text(
                'カテゴリー順',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }


  void _showAllStars() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('すべてのお気に入りスターを表示'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  void _exportMylist() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('マイリストをエクスポートしました'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  void _showMylistSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('マイリスト設定'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }


  void _createPlaylist() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('プレイリストが作成されました'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  void _showStarOptions(Map<String, dynamic> star) {
    // Implement the logic to show star options
  }

  void _showContentOptions(Map<String, dynamic> content) {
    // Implement the logic to show content options
  }

  void _showPlaylistOptions(Map<String, dynamic> playlist) {
    // Implement the logic to show playlist options
  }

  Widget _buildFollowingTab() {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFollowingStats(),
          const SizedBox(height: 24),
          Text(
            'フォロー中のスター',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ..._followingStars.map((star) => _buildFollowingStarCard(star)).toList(),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _recentActivities.length,
      itemBuilder: (context, index) {
        final activity = _recentActivities[index];
        return _buildActivityCard(activity);
      },
    );
  }

  Widget _buildFollowingStats() {
    final totalFollowing = _followingStars.length;
    final totalNewPosts = _followingStars.fold<int>(0, (sum, star) => sum + (star['newPosts'] as int));

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4ECDC4),
            Color(0xFF44A08D),
            Color(0xFF3A8B7A),
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4ECDC4).withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.dashboard_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'フォロー状況',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'あなたのフォロー統計',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildEnhancedStatItem(
                  'フォロー中', 
                  '$totalFollowing人', 
                  Icons.people_rounded,
                  const Color(0xFFFFFFFF),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildEnhancedStatItem(
                  '新着投稿', 
                  '$totalNewPosts件', 
                  Icons.fiber_new_rounded,
                  const Color(0xFFFFE66D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildEnhancedStatItem(String label, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowingStarCard(Map<String, dynamic> star) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : Colors.grey.shade200,
        ),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF4ECDC4),
                child: Text(
                  star['name'][0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (star['isOnline'])
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
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
                        star['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (star['verified'])
                      const Icon(
                        Icons.verified,
                        color: Color(0xFF4ECDC4),
                        size: 16,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  star['category'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '最終投稿: ${star['lastPost']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.black38,
                      ),
                    ),
                    if (star['newPosts'] > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4ECDC4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${star['newPosts']}件の新着',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.grey[400] : Colors.black54,
            ),
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            onSelected: (value) => _handleFollowingStarAction(value, star),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.person, color: isDark ? Colors.white : Colors.black87, size: 20),
                    const SizedBox(width: 8),
                    Text('プロフィールを見る', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'notification',
                child: Row(
                  children: [
                    Icon(Icons.notifications, color: isDark ? Colors.white : Colors.black87, size: 20),
                    const SizedBox(width: 8),
                    Text('通知設定', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'favorite',
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: isDark ? Colors.white : Colors.black87, size: 20),
                    const SizedBox(width: 8),
                    Text('お気に入りに追加', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'unfollow',
                child: Row(
                  children: [
                    Icon(Icons.person_remove, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('フォロー解除', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    IconData typeIcon;
    Color typeColor;
    
    switch (activity['type']) {
      case 'video':
        typeIcon = Icons.play_circle_outline;
        typeColor = const Color(0xFF4ECDC4);
        break;
      case 'live':
        typeIcon = Icons.live_tv;
        typeColor = Colors.red;
        break;
      case 'recipe':
        typeIcon = Icons.restaurant;
        typeColor = const Color(0xFFFFE66D);
        break;
      default:
        typeIcon = Icons.article;
        typeColor = const Color(0xFF888888);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.2),
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
                  activity['star'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4ECDC4),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  activity['action'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  activity['content'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF888888) : Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Text(
                  activity['time'],
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? const Color(0xFF888888) : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: isDark ? const Color(0xFF888888) : Colors.black54, size: 16),
            onPressed: () => _viewActivity(activity),
          ),
        ],
      ),
    );
  }

  void _handleFollowingStarAction(String action, Map<String, dynamic> star) {
    switch (action) {
      case 'view':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${star['name']}のプロフィールを表示'),
            backgroundColor: const Color(0xFF4ECDC4),
          ),
        );
        break;
      case 'notification':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${star['name']}の通知設定を変更'),
            backgroundColor: const Color(0xFF4ECDC4),
          ),
        );
        break;
      case 'favorite':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${star['name']}をお気に入りに追加'),
            backgroundColor: const Color(0xFF4ECDC4),
          ),
        );
        break;
      case 'unfollow':
        _showUnfollowDialog(star);
        break;
    }
  }

  void _showUnfollowDialog(Map<String, dynamic> star) {
    final themeState = ref.read(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        title: Text(
          'フォロー解除',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: Text(
          '${star['name']}のフォローを解除しますか？',
          style: TextStyle(color: isDark ? const Color(0xFF888888) : Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'キャンセル',
              style: TextStyle(color: isDark ? const Color(0xFF888888) : Colors.black54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _followingStars.removeWhere((s) => s['id'] == star['id']);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${star['name']}のフォローを解除しました'),
                  backgroundColor: const Color(0xFF4ECDC4),
                ),
              );
            },
            child: const Text(
              'フォロー解除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _viewActivity(Map<String, dynamic> activity) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${activity['content']}を表示'),
        backgroundColor: const Color(0xFF4ECDC4),
      ),
    );
  }

  void _showCreatePlaylistDialog() {
    final themeState = ref.read(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        title: Text(
          'プレイリストを作成',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'プレイリストの名前',
                labelStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.black54,
                ),
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.black38,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF333333) : const Color(0xFFF8FAFC),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF444444) : const Color(0xFFE5E7EB),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF444444) : const Color(0xFFE5E7EB),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              maxLines: 3,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'プレイリストの説明（任意）',
                alignLabelWithHint: true,
                labelStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.black54,
                ),
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.black38,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF333333) : const Color(0xFFF8FAFC),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF444444) : const Color(0xFFE5E7EB),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF444444) : const Color(0xFFE5E7EB),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark ? Colors.grey[600]! : Colors.black26,
                        ),
                      ),
                    ),
                    child: Text(
                      'キャンセル',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _createPlaylist();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4ECDC4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '作成',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
                _buildDrawerItem(Icons.home, 'ホーム', false, () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/');
                }),
                _buildDrawerItem(Icons.search, '検索', false, () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/search');
                }),
                _buildDrawerItem(Icons.star, 'マイリスト', true, () {
                  Navigator.pop(context);
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
                _buildDrawerItem(Icons.person, 'マイページ', false, () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/profile');
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