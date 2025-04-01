import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:starlist_app/data/mock_data.dart';
import 'package:starlist_app/models/activity.dart';
import 'package:starlist_app/models/star.dart';
import 'package:starlist_app/theme/app_theme.dart';
import 'package:starlist_app/widgets/activity_card.dart';

class StarDetailScreen extends StatefulWidget {
  final Star star;

  const StarDetailScreen({
    Key? key,
    required this.star,
  }) : super(key: key);

  @override
  _StarDetailScreenState createState() => _StarDetailScreenState();
}

class _StarDetailScreenState extends State<StarDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFollowing = false;
  
  final List<String> _tabs = [
    'すべて',
    '視聴履歴',
    '音楽',
    '映像',
    '購入',
    'アプリ',
    '食事',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 240,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildProfileHeader(),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.share_outlined),
                  onPressed: () {
                    // シェア機能は実装しない
                  },
                ),
              ],
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppTheme.primaryColor,
                  tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: _tabs.map((tab) {
            return _buildActivitiesForTab(tab);
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isFollowing = !_isFollowing;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isFollowing ? '${widget.star.name}をフォローしました' : 'フォローを解除しました'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        backgroundColor: _isFollowing ? Colors.pink : AppTheme.primaryColor,
        child: Icon(
          _isFollowing ? Icons.favorite : Icons.favorite_border,
        ),
      ),
    );
  }

  // プロフィールヘッダー
  Widget _buildProfileHeader() {
    return Stack(
      children: [
        // 背景画像
        Container(
          height: 160,
          width: double.infinity,
          color: AppTheme.primaryColor.withOpacity(0.1),
          child: Center(
            child: Icon(
              Icons.star,
              size: 80,
              color: AppTheme.primaryColor.withOpacity(0.2),
            ),
          ),
        ),
        // プロフィール情報
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // アバター画像
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      widget.star.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // プロフィールテキスト
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 名前とランク
                      Row(
                        children: [
                          Text(
                            widget.star.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.getRankColor(widget.star.rank),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.star.rank,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      // カテゴリ
                      Text(
                        widget.star.category,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      // フォロワー数
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            _formatFollowers(widget.star.followers),
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // フォロワー数のフォーマット（1万以上は万単位で表示）
  String _formatFollowers(int followers) {
    if (followers >= 10000) {
      double man = followers / 10000;
      return '${man.toStringAsFixed(man.truncateToDouble() == man ? 0 : 1)}万人のファン';
    } else {
      return '${followers}人のファン';
    }
  }

  // タブごとのアクティビティ表示
  Widget _buildActivitiesForTab(String tab) {
    List<Activity> activities = MockData.getActivities()
        .where((activity) => activity.starId == widget.star.id)
        .toList();
    
    // タブによるフィルター
    if (tab != 'すべて') {
      final typeMap = {
        '視聴履歴': 'youtube',
        '音楽': 'music',
        '映像': 'youtube',
        '購入': 'purchase',
        'アプリ': 'app',
        '食事': 'food',
      };
      
      if (typeMap.containsKey(tab)) {
        activities = activities.where((activity) => activity.type == typeMap[tab]).toList();
      }
    }

    // アクティビティがない場合
    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'まだアクティビティがありません',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // アクティビティリスト
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        return ActivityCard(
          activity: activities[index],
          onTap: () {
            // アクティビティ詳細は実装しない
          },
        );
      },
    );
  }
}

// SliverPersistentHeaderに使用するデリゲート
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
} 