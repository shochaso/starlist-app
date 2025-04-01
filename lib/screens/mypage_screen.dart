import 'package:flutter/material.dart';
import 'package:starlist_app/data/mock_data.dart';
import 'package:starlist_app/models/star.dart';
import 'package:starlist_app/theme/app_theme.dart';
import 'package:starlist_app/widgets/star_card.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // サンプルユーザー情報
    final String username = 'スターリスト太郎';
    final String userId = '@starlist_user123';
    final int followCount = 27;
    final int followerCount = 5;
    final String userImage = 'https://placehold.jp/150x150.png?text=User';
    
    // お気に入りスターのサンプルデータ
    final List<Star> favoriteStars = MockData.getStars()
        .where((star) => star.followers > 100000)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('マイページ'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('設定画面は準備中です'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ユーザープロフィール
            _buildUserProfile(userImage, username, userId, followCount, followerCount, context),
            
            // アクティビティステータス
            _buildActivityStatus(),
            
            // ステータス集計
            _buildStatusSummary(),
            
            // お気に入りスター
            Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'お気に入りスター',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Container(
              height: 180,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: favoriteStars.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 120,
                    margin: EdgeInsets.only(right: 8),
                    child: StarCard(
                      star: favoriteStars[index],
                      isCompact: true,
                      onTap: () {},
                    ),
                  );
                },
              ),
            ),
            
            // アクティビティ履歴
            Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                '最近のアクティビティ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Container(
              height: 200,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return _buildActivityItem(index);
                },
              ),
            ),
            
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(String userImage, String username, String userId, int followCount, int followerCount, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          // プロフィール画像
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(userImage),
            backgroundColor: Colors.grey[300],
          ),
          SizedBox(width: 16),
          // ユーザー情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  userId,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'フォロー: $followCount',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'フォロワー: $followerCount',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // プロフィール編集ボタン
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('プロフィール編集画面は準備中です'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Text('編集'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStatus() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusItem('視聴', '132', Icons.visibility),
          _buildStatusItem('購入', '23', Icons.shopping_bag),
          _buildStatusItem('イベント', '5', Icons.event),
          _buildStatusItem('コメント', '47', Icons.chat_bubble_outline),
        ],
      ),
    );
  }
  
  Widget _buildStatusItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 28,
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatusSummary() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'スター月間ランク',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'プラチナ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.75,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'スーパーランクまであと25ポイント',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '75/100',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityItem(int index) {
    final List<Map<String, dynamic>> activities = [
      {
        'icon': Icons.favorite,
        'color': Colors.pink,
        'text': 'コムドットさんをお気に入りに追加しました',
        'time': '3時間前',
      },
      {
        'icon': Icons.remove_red_eye,
        'color': Colors.blue,
        'text': 'ゆきりぬさんの新しい動画を視聴しました',
        'time': '昨日',
      },
      {
        'icon': Icons.shopping_bag,
        'color': Colors.green,
        'text': '水溜りボンドさんおすすめの商品を購入しました',
        'time': '3日前',
      },
    ];
    
    final activity = activities[index];
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: (activity['color'] as Color).withOpacity(0.2),
        child: Icon(
          activity['icon'] as IconData,
          color: activity['color'] as Color,
          size: 20,
        ),
      ),
      title: Text(
        activity['text'] as String,
        style: TextStyle(
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        activity['time'] as String,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 4),
    );
  }
} 