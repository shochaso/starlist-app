import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/theme_provider.dart';

// プロバイダー
final selectedTabProvider = StateProvider<int>((ref) => 0);

class MylistScreen extends ConsumerStatefulWidget {
  const MylistScreen({super.key});

  @override
  ConsumerState<MylistScreen> createState() => _MylistScreenState();
}

class _MylistScreenState extends ConsumerState<MylistScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  // ダミーデータ
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // タブバー
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _buildTabItem('スター', 0, _selectedTabIndex),
                  _buildTabItem('コンテンツ', 1, _selectedTabIndex),
                  _buildTabItem('プレイリスト', 2, _selectedTabIndex),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // タブコンテンツ
            Expanded(
              child: _buildTabContent(_selectedTabIndex),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String label, int index, int selectedTab) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.index = index;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selectedTab == index ? const Color(0xFF4ECDC4) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: selectedTab == index ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(int selectedTab) {
    switch (selectedTab) {
      case 0:
        return _buildStarsTab();
      case 1:
        return _buildContentsTab();
      case 2:
        return _buildPlaylistsTab();
      default:
        return Container();
    }
  }

  Widget _buildStarsTab() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
        ],
      ),
    );
  }

  Widget _buildContentsTab() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
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
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
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
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
    final themeMode = ref.read(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
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

  void _showAddOptions() {
    final themeMode = ref.read(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
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
              '追加',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.star, color: Color(0xFF4ECDC4)),
              title: Text(
                'スターをお気に入りに追加',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              onTap: () {
                Navigator.pop(context);
                _addStar();
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark, color: Color(0xFF4ECDC4)),
              title: Text(
                'コンテンツをお気に入りに追加',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              onTap: () {
                Navigator.pop(context);
                _addContent();
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add, color: Color(0xFF4ECDC4)),
              title: Text(
                '新しいプレイリストを作成',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              onTap: () {
                Navigator.pop(context);
                _createPlaylist();
              },
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

  void _addStar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('スターをお気に入りに追加'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  void _addContent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('コンテンツをお気に入りに追加'),
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

  void _showCreatePlaylistDialog() {
    final themeMode = ref.read(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
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
} 