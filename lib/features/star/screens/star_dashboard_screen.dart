import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../src/providers/theme_provider_enhanced.dart';
import '../../../providers/user_provider.dart';
import '../../subscription/screens/plan_management_screen.dart';
import '../../app/screens/settings_screen.dart';
import '../../data_integration/screens/data_import_screen.dart';
import '../../../src/features/youtube_easy/star_watch_history_widget.dart';

class StarDashboardScreen extends ConsumerStatefulWidget {
  const StarDashboardScreen({super.key});

  @override
  ConsumerState<StarDashboardScreen> createState() => _StarDashboardScreenState();
}

class _StarDashboardScreenState extends ConsumerState<StarDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // ダミーデータ
  final Map<String, dynamic> _dashboardData = {
    'totalRevenue': 125000,
    'monthlyRevenue': 45000,
    'totalFans': 2847,
    'activeFans': 1923,
    'contentViews': 15420,
    'engagementRate': 8.5,
    'dataImportCount': 342,
    'dataImportThisMonth': 28,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        title: Text(
          'スターダッシュボード',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: const Color(0xFF4ECDC4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: const Color(0xFF888888),
                        labelPadding: EdgeInsets.zero,
                        tabs: const [
                          Tab(
                            child: Text(
                              '概要',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Tab(
                            child: Text(
                              '視聴履歴',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Tab(
                            child: Text(
                              'ファン',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Tab(
                            child: Text(
                              'コンテンツ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        SingleChildScrollView(child: _buildOverviewTab()),
                        _buildWatchHistoryTab(),
                        SingleChildScrollView(child: _buildFansTab()),
                        SingleChildScrollView(child: _buildContentTab()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildQuickStats(),
          const SizedBox(height: 20),
          _buildQuickActions(),
          const SizedBox(height: 20),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
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
            'おかえりなさい！',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '今月の収益が先月比15%アップしています',
            style: TextStyle(
              fontSize: 16,
              color: Color.fromRGBO(255, 255, 255, 0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                '¥${_formatNumber(_dashboardData['monthlyRevenue'])}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'クイック統計',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '総収益',
                '¥${_formatNumber(_dashboardData['totalRevenue'])}',
                Icons.monetization_on,
                const Color(0xFF4ECDC4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'ファン数',
                '${_formatNumber(_dashboardData['totalFans'])}人',
                Icons.people,
                const Color(0xFFFF6B6B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'コンテンツ閲覧',
                '${_formatNumber(_dashboardData['contentViews'])}回',
                Icons.visibility,
                const Color(0xFFFFE66D),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'データ取込み',
                '${_formatNumber(_dashboardData['dataImportCount'])}件',
                Icons.upload,
                const Color(0xFF95E1D3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
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
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'データ取り込み',
                Icons.upload,
                const Color(0xFF4ECDC4),
                () => _navigateToDataImport(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'プラン管理',
                Icons.card_membership,
                const Color(0xFFFF6B6B),
                () => _navigateToPlanManagement(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'コンテンツ投稿',
                Icons.add_circle,
                const Color(0xFFFFE66D),
                () => _navigateToContentPost(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'ファン分析',
                Icons.analytics,
                const Color(0xFF95E1D3),
                () => _navigateToFanAnalytics(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: const Color(0xFF2A2A2A),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
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

  Widget _buildRecentActivity() {
    final activityData = [
      {
        'title': '新しいファンが3人追加されました',
        'time': '2時間前',
        'icon': Icons.person_add,
        'color': const Color(0xFF4ECDC4),
        'badge': '+3',
      },
      {
        'title': 'YouTube視聴履歴が更新されました',
        'time': '4時間前',
        'icon': FontAwesomeIcons.youtube,
        'color': const Color(0xFFFF6B6B),
        'badge': '5本',
      },
      {
        'title': 'プレミアムプランの収益が発生しました',
        'time': '6時間前',
        'icon': Icons.monetization_on,
        'color': const Color(0xFFFFE66D),
        'badge': '¥2,500',
      },
      {
        'title': 'Spotifyプレイリストが更新されました',
        'time': '8時間前',
        'icon': FontAwesomeIcons.spotify,
        'color': const Color(0xFF1DB954),
        'badge': '12曲',
      },
      {
        'title': 'アフィリエイト収益が発生しました',
        'time': '12時間前',
        'icon': Icons.link,
        'color': const Color(0xFF95E1D3),
        'badge': '¥890',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '最近のアクティビティ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: activityData.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final item = activityData[index];
              return _buildActivityCard(
                item['title'] as String,
                item['time'] as String,
                item['icon'] as IconData,
                item['color'] as Color,
                item['badge'] as String,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(String title, String time, IconData icon, Color color, String badge) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF888888),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWatchHistoryOverview(),
          const SizedBox(height: 20),
          _buildWatchHistoryActions(),
          const SizedBox(height: 20),
          _buildSharedHistoryPreview(),
        ],
      ),
    );
  }

  Widget _buildWatchHistoryOverview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7E57C2), Color(0xFF9C27B0)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.video_library, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                '視聴履歴管理',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'YouTubeの視聴履歴をファンと共有して、\nより深いつながりを築きましょう',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildHistoryStatCard('インポート済み', '12件', Icons.cloud_download),
              const SizedBox(width: 16),
              _buildHistoryStatCard('共有中', '8件', Icons.share),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchHistoryActions() {
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
                child: _buildActionButtonWithSubtitle(
                  '📥 履歴インポート',
                  '新しい視聴履歴を追加',
                  Colors.blue,
                  () => _navigateToWatchHistoryImport(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButtonWithSubtitle(
                  '⚙️ 共有設定',
                  '公開する履歴を選択',
                  Colors.green,
                  () => _configureSharing(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonWithSubtitle(String title, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSharedHistoryPreview() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ファンと共有中の履歴',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () => _viewAllSharedHistory(),
                child: const Text(
                  'すべて表示',
                  style: TextStyle(color: Color(0xFF4ECDC4)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildSharedHistoryItem(
            'Flutter 3.0の新機能解説',
            'Flutter Official',
            '2日前に視聴',
            '👁️ 124人のファンが閲覧',
          ),
          const SizedBox(height: 12),
          _buildSharedHistoryItem(
            'プログラミング初心者向けTips',
            'Tech Channel',
            '1週間前に視聴',
            '👁️ 89人のファンが閲覧',
          ),
          const SizedBox(height: 12),
          _buildSharedHistoryItem(
            'デザインパターン入門',
            'Code Academy',
            '2週間前に視聴',
            '👁️ 156人のファンが閲覧',
          ),
        ],
      ),
    );
  }

  Widget _buildSharedHistoryItem(String title, String channel, String watchTime, String viewCount) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.grey.shade700,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  channel,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  '$watchTime • $viewCount',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF4ECDC4),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const Icon(Icons.share, color: Colors.green, size: 16),
        ],
      ),
    );
  }

  void _navigateToWatchHistoryImport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StarWatchHistoryWidget(
          starId: 'current_star_id',
        ),
      ),
    );
  }

  void _configureSharing() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('共有設定機能は開発中です'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _viewAllSharedHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('全履歴表示機能は開発中です'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _navigateToPlanManagement() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('プラン管理画面に移動します'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  void _navigateToContentPost() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('コンテンツ投稿画面に移動します'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  void _navigateToFanAnalytics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ファン分析画面に移動します'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  Widget _buildFansTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFanOverview(),
          const SizedBox(height: 20),
          _buildFanGrowth(),
          const SizedBox(height: 20),
          _buildTopFans(),
        ],
      ),
    );
  }

  Widget _buildFanOverview() {
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
            'ファン概要',
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
                child: _buildFanStatItem(
                  '総ファン数',
                  '${_formatNumber(_dashboardData['totalFans'])}人',
                  Icons.people,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFanStatItem(
                  'アクティブファン',
                  '${_formatNumber(_dashboardData['activeFans'])}人',
                  Icons.favorite,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFanStatItem(String title, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF4ECDC4), size: 16),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF888888),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildFanGrowth() {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: const Center(
        child: Text(
          'ファン成長チャート\n（実装予定）',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF888888),
          ),
        ),
      ),
    );
  }

  Widget _buildTopFans() {
    final topFansData = [
      // ... (データは省略)
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'トップファン',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: topFansData.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final fan = topFansData[index];
              return _buildTopFanCard(
                fan['name'] as String,
                fan['plan'] as String,
                fan['amount'] as String,
                fan['avatar'] as String,
                fan['color'] as Color,
                fan['joinDate'] as String,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopFanCard(String name, String plan, String amount, String avatar, Color color, String joinDate) {
    // ... (実装は省略)
    return Container();
  }

  Widget _buildContentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContentOverview(),
          const SizedBox(height: 20),
          _buildRecentContent(),
        ],
      ),
    );
  }

  Widget _buildContentOverview() {
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
            'コンテンツ概要',
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
                child: _buildContentStatItem(
                  '総閲覧数',
                  '${_formatNumber(_dashboardData['contentViews'])}回',
                  Icons.visibility,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildContentStatItem(
                  'エンゲージメント',
                  '${_dashboardData['engagementRate']}%',
                  Icons.favorite,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentStatItem(String title, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF4ECDC4), size: 16),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF888888),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentContent() {
    final recentContentData = [
       // ... (データは省略)
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '最近のコンテンツ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: recentContentData.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final item = recentContentData[index];
              return _buildContentCard(
                item['title'] as String,
                item['description'] as String,
                item['time'] as String,
                item['icon'] as IconData,
                item['color'] as Color,
                item['count'] as String,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard(String title, String description, String time, IconData icon, Color color, String count) {
    // ... (実装は省略)
    return Container();
  }

  void _navigateToDataImport() {
    // データ取り込み画面への遷移
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DataImportScreen()),
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
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentUser.name ?? 'スター',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          currentUser.email,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.home,
                  title: 'ホーム',
                  onTap: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
                if (currentUser.isStar) ...[
                  _buildDrawerItem(
                    icon: Icons.dashboard,
                    title: 'ダッシュボード',
                    isSelected: true,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.upload,
                    title: 'データ取り込み',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DataImportScreen()),
                      );
                    },
                  ),
                ],
                _buildDrawerItem(
                  icon: Icons.card_membership,
                  title: 'プラン管理',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PlanManagementScreen()),
                    );
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: '設定',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
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
    bool isSelected = false,
  }) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? const Color(0xFF4ECDC4)
            : (isDark ? Colors.white70 : Colors.black54),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected
              ? const Color(0xFF4ECDC4)
              : (isDark ? Colors.white : Colors.black87),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFF4ECDC4).withValues(alpha: 0.1),
      onTap: onTap,
    );
  }
} 