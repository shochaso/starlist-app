import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'schedule_management_screen.dart';

class StarProfileScreen extends ConsumerStatefulWidget {
  final String starId;
  final String starName;
  
  const StarProfileScreen({
    super.key,
    required this.starId,
    required this.starName,
  });

  @override
  ConsumerState<StarProfileScreen> createState() => _StarProfileScreenState();
}

class _StarProfileScreenState extends ConsumerState<StarProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isFollowing = false;

  // スターの情報
  final Map<String, dynamic> _starInfo = {
    'name': 'テックレビューアー田中',
    'category': 'テクノロジー・ガジェット',
    'followers': 245000,
    'totalViews': 12500000,
    'joinDate': '2020年3月',
    'bio': '最新のテクノロジーとガジェットをわかりやすくレビューしています。iPhone、Android、PC、カメラなど幅広くカバー。',
    'verified': true,
    'location': '東京都',
    'website': 'https://tech-review-tanaka.com',
  };

  // 最新コンテンツ
  final List<Map<String, dynamic>> _recentContents = [
    {
      'title': 'iPhone 15 Pro Max 詳細レビュー',
      'thumbnail': const Color(0xFF4ECDC4),
      'duration': '25:30',
      'views': 125000,
      'uploadTime': '2時間前',
      'type': 'video',
    },
    {
      'title': 'MacBook Pro M3 開封レビュー',
      'thumbnail': const Color(0xFF00B894),
      'duration': '18:45',
      'views': 89000,
      'uploadTime': '1日前',
      'type': 'video',
    },
    {
      'title': 'おすすめガジェット2024',
      'thumbnail': const Color(0xFFFFE66D),
      'duration': '32:15',
      'views': 156000,
      'uploadTime': '3日前',
      'type': 'video',
    },
  ];

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
    final schedules = ref.watch(scheduleProvider);
    final publicSchedules = schedules.where((s) => s.isPublic).toList();
    
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: CustomScrollView(
        slivers: [
          // カスタムAppBar
          SliverAppBar(
            backgroundColor: const Color(0xFF1A1A1A),
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF4ECDC4),
                      Color(0xFF1A1A1A),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        // プロフィール情報
                        Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  '田',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _starInfo['name'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (_starInfo['verified'])
                                        const Icon(
                                          Icons.verified,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _starInfo['category'],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${_formatNumber(_starInfo['followers'])}フォロワー',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // フォローボタン
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isFollowing = !_isFollowing;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isFollowing ? Colors.grey : Colors.white,
                              foregroundColor: _isFollowing ? Colors.white : const Color(0xFF4ECDC4),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _isFollowing ? 'フォロー中' : 'フォローする',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // タブバー
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                indicator: const BoxDecoration(
                  color: Color(0xFF4ECDC4),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white,
                tabs: const [
                  Tab(text: '概要'),
                  Tab(text: 'コンテンツ'),
                  Tab(text: 'スケジュール'),
                  Tab(text: '情報'),
                ],
              ),
            ),
          ),
          
          // タブコンテンツ
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildContentsTab(),
                _buildScheduleTab(publicSchedules),
                _buildInfoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
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
              _starInfo['bio'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // 統計情報
          Row(
            children: [
              _buildStatCard('フォロワー', _formatNumber(_starInfo['followers'])),
              const SizedBox(width: 12),
              _buildStatCard('総再生回数', _formatNumber(_starInfo['totalViews'])),
            ],
          ),
          const SizedBox(height: 24),
          
          // 最新コンテンツ
          const Text(
            '最新コンテンツ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ..._recentContents.take(3).map((content) => _buildContentCard(content)),
        ],
      ),
    );
  }

  Widget _buildContentsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _recentContents.length,
      itemBuilder: (context, index) {
        return _buildContentCard(_recentContents[index]);
      },
    );
  }

  Widget _buildScheduleTab(List<ScheduleItem> schedules) {
    final upcomingSchedules = schedules.where((s) => 
      s.startTime.isAfter(DateTime.now()) && s.status == 'scheduled'
    ).toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '今後の予定',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (upcomingSchedules.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  '予定されているスケジュールはありません',
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            ...upcomingSchedules.map((schedule) => _buildPublicScheduleCard(schedule)),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '詳細情報',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
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
                _buildInfoRow(Icons.calendar_today, '参加日', _starInfo['joinDate']),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.location_on, '所在地', _starInfo['location']),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.language, 'ウェブサイト', _starInfo['website']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4ECDC4),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF888888),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard(Map<String, dynamic> content) {
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
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              color: content['thumbnail'],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      content['duration'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatNumber(content['views'])}回視聴',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      content['uploadTime'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
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

  Widget _buildPublicScheduleCard(ScheduleItem schedule) {
    Color typeColor;
    IconData typeIcon;
    
    switch (schedule.type) {
      case 'youtube':
        typeColor = const Color(0xFFFF0000);
        typeIcon = Icons.video_library;
        break;
      case 'instagram':
        typeColor = const Color(0xFFE4405F);
        typeIcon = Icons.camera_alt;
        break;
      case 'tv':
        typeColor = const Color(0xFF6C5CE7);
        typeIcon = Icons.tv;
        break;
      case 'meal':
        typeColor = const Color(0xFFFF6B6B);
        typeIcon = Icons.restaurant;
        break;
      case 'meeting':
        typeColor = const Color(0xFFFFE66D);
        typeIcon = Icons.meeting_room;
        break;
      default:
        typeColor = const Color(0xFF888888);
        typeIcon = Icons.schedule;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      schedule.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      schedule.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: Color(0xFF4ECDC4),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${_formatDateTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4ECDC4),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getTypeLabel(schedule.type),
                  style: TextStyle(
                    fontSize: 10,
                    color: typeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
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

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'youtube':
        return 'YouTube';
      case 'instagram':
        return 'Instagram';
      case 'tv':
        return 'テレビ出演';
      case 'meal':
        return '食事';
      case 'meeting':
        return '会議';
      default:
        return 'その他';
    }
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
} 