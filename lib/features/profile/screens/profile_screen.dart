import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../star/screens/star_dashboard_screen.dart';
import '../../star/screens/schedule_management_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

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
    final currentUser = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
      body: SafeArea(
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
                    _buildTabItem('活動', 1, _selectedTabIndex),
                    _buildTabItem('バッジ', 2, _selectedTabIndex),
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
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
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
        return _buildActivityTabContent();
      case 2:
        return _buildBadgesTabContent();
      default:
        return Container();
    }
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
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
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

  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('プロフィール編集画面を開く'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  void _openSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('設定画面を開く'),
        backgroundColor: Color(0xFF4ECDC4),
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
} 