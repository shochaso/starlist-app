import 'package:flutter/material.dart';
import 'package:starlist_app/data/mock_data.dart';
import 'package:starlist_app/models/star.dart';
import 'package:starlist_app/models/activity.dart';
import 'package:starlist_app/routes/app_routes.dart';
import 'package:starlist_app/theme/app_theme.dart';
import 'package:starlist_app/widgets/star_card.dart';
import 'package:starlist_app/widgets/activity_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('お気に入り'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'スター'),
            Tab(text: 'アクティビティ'),
          ],
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFavoriteStars(),
          _buildFavoriteActivities(),
        ],
      ),
    );
  }

  Widget _buildFavoriteStars() {
    // サンプルとして上位3つのスターをお気に入りとして表示
    List<Star> favoriteStars = MockData.getStars()
        .where((star) => star.followers > 100000)
        .toList();
    
    if (favoriteStars.isEmpty) {
      return _buildEmptyState('スター', Icons.star_border);
    }
    
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: favoriteStars.length,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            StarCard(
              star: favoriteStars[index],
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.starDetail,
                arguments: favoriteStars[index],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: Colors.pink,
                    size: 20,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${favoriteStars[index].name}をお気に入りから削除しました'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFavoriteActivities() {
    // サンプルとして最初の2つのアクティビティをお気に入りとして表示
    List<Activity> favoriteActivities = MockData.getActivities().take(2).toList();
    
    if (favoriteActivities.isEmpty) {
      return _buildEmptyState('アクティビティ', Icons.favorite_border);
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: favoriteActivities.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ActivityCard(
                activity: favoriteActivities[index],
                onTap: () {
                  // アクティビティの詳細画面は実装しない
                },
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: Colors.pink,
                      size: 20,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('アクティビティをお気に入りから削除しました'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String type, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'お気に入り$typeはありません',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(Icons.search),
            label: Text('スターを探す'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
} 