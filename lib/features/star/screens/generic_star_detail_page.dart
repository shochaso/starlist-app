import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user.dart';
import '../../../src/providers/theme_provider_enhanced.dart';
import '../../../data/mock_users/hanayama_mizuki.dart';

/// 汎用スター詳細ページ
/// 任意のスターの詳細情報を表示する再利用可能なコンポーネント
class GenericStarDetailPage extends ConsumerStatefulWidget {
  final String starId;
  final Map<String, dynamic>? starData;

  const GenericStarDetailPage({
    super.key,
    required this.starId,
    this.starData,
  });

  @override
  ConsumerState<GenericStarDetailPage> createState() => _GenericStarDetailPageState();
}

class _GenericStarDetailPageState extends ConsumerState<GenericStarDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _starData;
  bool _isFollowing = true; // フォローリストから来ているので初期値はtrue

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadStarData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// スターデータの動的読み込み
  void _loadStarData() {
    // 現在は花山瑞樹のみ実装、将来的に他スターのデータも追加
    if (widget.starId == 'hanayama_mizuki' || widget.starId == 'hanayama_mizuki_official') {
      _starData = HanayamaMizukiData.profile;
    } else if (widget.starData != null) {
      _starData = widget.starData;
    } else {
      // 汎用的なダミーデータ
      _starData = _generateGenericStarData(widget.starId);
    }
    setState(() {});
  }

  /// 汎用スターデータの生成（将来的にAPIから取得）
  Map<String, dynamic> _generateGenericStarData(String starId) {
    return {
      'id': starId,
      'name': 'スター名',
      'displayName': 'ニックネーム',
      'category': 'エンタメ',
      'verified': false,
      'bio': 'プロフィール情報',
      'followers': 10000,
      'following': 50,
      'gradientColors': [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      'primaryColor': const Color(0xFF6366F1),
      'secondaryColor': const Color(0xFF8B5CF6),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_starData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(isDark),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProfileHeader(isDark),
                _buildTabSection(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// スクロール可能なアプリバー
  Widget _buildSliverAppBar(bool isDark) {
    final gradientColors = _starData!['gradientColors'] as List<Color>? ?? 
        [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];

    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () => _shareProfile(),
        ),
        IconButton(
          icon: Icon(
            _isFollowing ? Icons.favorite : Icons.favorite_border,
            color: Colors.white,
          ),
          onPressed: () => _toggleFollow(),
        ),
      ],
    );
  }

  /// プロフィールヘッダー部分
  Widget _buildProfileHeader(bool isDark) {
    final gradientColors = _starData!['gradientColors'] as List<Color>? ?? 
        [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            gradientColors[0].withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        children: [
          // アバター
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0].withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _starData!['avatar'] ?? _starData!['name']?.substring(0, 1) ?? 'S',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 名前・認証バッジ
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _starData!['name'] ?? 'スター名',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_starData!['verified'] == true) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.verified,
                  color: gradientColors[0],
                  size: 24,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // カテゴリ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: gradientColors[0].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: gradientColors[0].withOpacity(0.3)),
            ),
            child: Text(
              _starData!['category'] ?? 'エンタメ',
              style: TextStyle(
                color: gradientColors[0],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // フォロワー情報
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('フォロワー', '${_starData!['followers'] ?? 0}', isDark),
              _buildStatItem('フォロー中', '${_starData!['following'] ?? 0}', isDark),
              _buildStatItem('投稿', '${_getPostCount()}', isDark),
            ],
          ),
          const SizedBox(height: 20),

          // プロフィール文
          if (_starData!['bio'] != null)
            Text(
              _starData!['bio'],
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 20),

          // フォローボタン
          _buildFollowButton(gradientColors),
        ],
      ),
    );
  }

  /// 統計アイテム
  Widget _buildStatItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /// フォローボタン
  Widget _buildFollowButton(List<Color> gradientColors) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => _toggleFollow(),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFollowing ? Colors.grey[300] : gradientColors[0],
          foregroundColor: _isFollowing ? Colors.black87 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: _isFollowing ? 0 : 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isFollowing ? Icons.check : Icons.add,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _isFollowing ? 'フォロー中' : 'フォローする',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// タブセクション
  Widget _buildTabSection(bool isDark) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '投稿'),
              Tab(text: '購入履歴'),
              Tab(text: 'アクティビティ'),
              Tab(text: '限定'),
            ],
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: (_starData!['primaryColor'] as Color?) ?? const Color(0xFF6366F1),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
            dividerColor: Colors.transparent,
          ),
        ),
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPostsTab(isDark),
              _buildPurchaseHistoryTab(isDark),
              _buildActivityTab(isDark),
              _buildPremiumTab(isDark),
            ],
          ),
        ),
      ],
    );
  }

  /// 投稿タブ
  Widget _buildPostsTab(bool isDark) {
    final posts = _getStarPosts();
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _buildPostCard(post, isDark);
      },
    );
  }

  /// 購入履歴タブ
  Widget _buildPurchaseHistoryTab(bool isDark) {
    final purchases = _getStarPurchases();
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: purchases.length,
      itemBuilder: (context, index) {
        final purchase = purchases[index];
        return _buildPurchaseCard(purchase, isDark);
      },
    );
  }

  /// アクティビティタブ
  Widget _buildActivityTab(bool isDark) {
    return Center(
      child: Text(
        'アクティビティ（実装予定）',
        style: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
    );
  }

  /// 限定タブ（プラン別制御）
  Widget _buildPremiumTab(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.diamond,
            size: 64,
            color: Colors.amber[600],
          ),
          const SizedBox(height: 16),
          Text(
            '限定コンテンツ',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'プレミアムプラン以上で閲覧可能',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 投稿カード
  Widget _buildPostCard(Map<String, dynamic> post, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post['title'] ?? '',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            post['description'] ?? '',
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.favorite_border,
                size: 20,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '${post['likes'] ?? 0}',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.comment_outlined,
                size: 20,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '${post['comments'] ?? 0}',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 購入履歴カード
  Widget _buildPurchaseCard(Map<String, dynamic> purchase, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shopping_bag, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  purchase['title'] ?? '',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  purchase['brand'] ?? '',
                  style: TextStyle(
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '¥${purchase['price'] ?? 0}',
                  style: TextStyle(
                    color: (_starData!['primaryColor'] as Color?) ?? const Color(0xFF6366F1),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// アクション関数
  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFollowing ? 'フォローしました' : 'フォローを解除しました'),
        backgroundColor: (_starData!['primaryColor'] as Color?) ?? const Color(0xFF6366F1),
      ),
    );
  }

  void _shareProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('プロフィールを共有（実装予定）')),
    );
  }

  /// データ取得ヘルパー関数
  int _getPostCount() {
    if (widget.starId == 'hanayama_mizuki' || widget.starId == 'hanayama_mizuki_official') {
      return HanayamaMizukiData.recentVideos.length + HanayamaMizukiData.recentPurchases.length;
    }
    return 0;
  }

  List<Map<String, dynamic>> _getStarPosts() {
    if (widget.starId == 'hanayama_mizuki' || widget.starId == 'hanayama_mizuki_official') {
      return HanayamaMizukiData.recentVideos;
    }
    return [];
  }

  List<Map<String, dynamic>> _getStarPurchases() {
    if (widget.starId == 'hanayama_mizuki' || widget.starId == 'hanayama_mizuki_official') {
      return HanayamaMizukiData.recentPurchases;
    }
    return [];
  }
} 