import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'star_activity_timeline_screen.dart';
import '../models/star_activity.dart';
import '../repositories/star_activity_repository.dart';

// スタンドアローンで実行するためのメイン関数
void main() {
  runApp(
    const ProviderScope(
      child: TimelineSampleApp(),
    ),
  );
}

// サンプルアプリ
class TimelineSampleApp extends StatelessWidget {
  const TimelineSampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'スタータイムラインサンプル',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const StarTimelineSampleScreen(),
    );
  }
}

// モックデータのプロバイダー
final mockStarsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {
      'id': 'star-1',
      'name': '山田 太郎',
      'category': 'ミュージシャン',
      'imageUrl': 'https://picsum.photos/id/1012/300',
      'followerCount': 12500,
      'isFollowing': true,
    },
    {
      'id': 'star-2',
      'name': '佐藤 花子',
      'category': '俳優',
      'imageUrl': 'https://picsum.photos/id/1027/300',
      'followerCount': 8700,
      'isFollowing': true,
    },
    {
      'id': 'star-3',
      'name': '鈴木 一郎',
      'category': 'アーティスト',
      'imageUrl': 'https://picsum.photos/id/1025/300',
      'followerCount': 5300,
      'isFollowing': false,
    },
    {
      'id': 'star-4',
      'name': '田中 美咲',
      'category': 'アイドル',
      'imageUrl': 'https://picsum.photos/id/1062/300',
      'followerCount': 15800,
      'isFollowing': true,
    },
    {
      'id': 'star-5',
      'name': '高橋 健太',
      'category': 'モデル',
      'imageUrl': 'https://picsum.photos/id/1074/300',
      'followerCount': 4200,
      'isFollowing': false,
    },
  ];
});

// 最近のアクティビティのプロバイダー
final recentActivitiesProvider = FutureProvider<List<StarActivity>>((ref) async {
  final repository = StarActivityRepository();
  
  // モックデータを複数のスターから取得して結合
  final allActivities = <StarActivity>[];
  
  for (final star in ref.watch(mockStarsProvider)) {
    if (star['isFollowing'] == true) {
      // 公開メソッドgetActivitiesByStarIdを使用（非同期）
      final activities = await repository.getActivitiesByStarId(star['id']);
      allActivities.addAll(activities);
    }
  }
  
  // 日時で降順ソート
  allActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  
  // 最新10件を返す
  return allActivities.take(10).toList();
});

/// スタータイムラインのサンプル画面
class StarTimelineSampleScreen extends ConsumerWidget {
  const StarTimelineSampleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stars = ref.watch(mockStarsProvider);
    final followingStars = stars.where((star) => star['isFollowing'] == true).toList();
    final recentActivitiesAsync = ref.watch(recentActivitiesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('スタータイムライン'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('通知機能は開発中です')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // 実際のアプリではデータの再取得処理を行う
          ref.refresh(recentActivitiesProvider);
          await Future.delayed(const Duration(seconds: 1));
          return;
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24.0),
          children: [
            // フォロー中のスターセクション
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'フォロー中のスター',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('フォロー中のスター一覧は開発中です')),
                      );
                    },
                    child: const Text('すべて表示'),
                  ),
                ],
              ),
            ),
            
            // フォロー中のスターのカード
            SizedBox(
              height: 200.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemCount: followingStars.length,
                itemBuilder: (context, index) {
                  final star = followingStars[index];
                  return _buildStarCard(context, star);
                },
              ),
            ),
            
            // 最近のアクティビティセクション
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '最近のアクティビティ',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('フィルター機能は開発中です')),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // 最近のアクティビティリスト（AsyncValue対応）
            recentActivitiesAsync.when(
              data: (activities) {
                if (activities.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text('最近のアクティビティはありません'),
                    ),
                  );
                }
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return _buildActivityCard(context, activity, ref);
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stackTrace) => Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('エラーが発生しました: $error'),
                      ElevatedButton(
                        onPressed: () => ref.refresh(recentActivitiesProvider),
                        child: const Text('再読み込み'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('新しいスターを探す機能は開発中です')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // スターカードを構築
  Widget _buildStarCard(BuildContext context, Map<String, dynamic> star) {
    return Container(
      width: 160.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => StarActivityTimelineScreen(
                  starId: star['id'],
                  title: '${star['name']}のタイムライン',
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // スター画像
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 画像
                    Image.network(
                      star['imageUrl'],
                      fit: BoxFit.cover,
                    ),
                    
                    // グラデーションオーバーレイ
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60.0,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // スター名
                    Positioned(
                      bottom: 8.0,
                      left: 8.0,
                      right: 8.0,
                      child: Text(
                        star['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              
              // スター情報
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      star['category'],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '${_formatNumber(star['followerCount'])}フォロワー',
                      style: const TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // アクティビティカードを構築
  Widget _buildActivityCard(BuildContext context, StarActivity activity, WidgetRef ref) {
    // スター情報を取得
    final stars = ref.watch(mockStarsProvider);
    final star = stars.firstWhere(
      (s) => s['id'] == activity.starId,
      orElse: () => {'name': '不明なスター', 'imageUrl': 'https://picsum.photos/200'},
    );
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          _showActivityDetails(context, activity, star);
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー部分（スター情報）
              Row(
                children: [
                  // スターのアバター
                  CircleAvatar(
                    radius: 20.0,
                    backgroundImage: NetworkImage(star['imageUrl']),
                  ),
                  
                  const SizedBox(width: 12.0),
                  
                  // スター名と時間
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          star['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatTimeAgo(activity.timestamp),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12.0),
              
              // アクティビティ内容
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // アクティビティタイプアイコン
                  Container(
                    width: 32.0,
                    height: 32.0,
                    margin: const EdgeInsets.only(right: 12.0, top: 2.0),
                    decoration: BoxDecoration(
                      color: _getActivityColor(activity.type).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getActivityIcon(activity.type),
                      color: _getActivityColor(activity.type),
                      size: 16.0,
                    ),
                  ),
                  
                  // アクティビティ情報
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // アクティビティタイプ
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 14.0,
                            ),
                            children: [
                              TextSpan(
                                text: _getActivityTypeLabel(activity.type),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(text: 'を更新'),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 4.0),
                        
                        // タイトル
                        Text(
                          activity.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        
                        // 説明（省略可）
                        if (activity.description != null && activity.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              activity.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // 画像（存在する場合）
              if (activity.imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      activity.imageUrl!,
                      height: 180.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              
              // アクションボタン
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        _showActivityDetails(context, activity, star);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                      ),
                      child: const Text('詳細を見る'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // アクティビティの詳細を表示
  void _showActivityDetails(BuildContext context, StarActivity activity, Map<String, dynamic> star) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ハンドル
                  Center(
                    child: Container(
                      width: 40.0,
                      height: 4.0,
                      margin: const EdgeInsets.only(bottom: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  
                  // スター情報
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24.0,
                        backgroundImage: NetworkImage(star['imageUrl']),
                      ),
                      const SizedBox(width: 12.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            star['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          Text(
                            star['category'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const Divider(height: 32.0),
                  
                  // アクティビティヘッダー
                  Row(
                    children: [
                      Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: _getActivityColor(activity.type).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getActivityIcon(activity.type),
                          color: _getActivityColor(activity.type),
                          size: 20.0,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getActivityTypeLabel(activity.type),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          Text(
                            _formatDateTime(activity.timestamp),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16.0),
                  
                  // タイトル
                  Text(
                    activity.title,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // 説明
                  if (activity.description != null && activity.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        activity.description!,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                  
                  // 画像
                  if (activity.imageUrl != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.network(
                          activity.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  
                  // 詳細情報
                  if (activity.details != null && activity.details!.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                      child: Text(
                        '詳細情報',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: activity.details!.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 100.0,
                                    child: Text(
                                      '${entry.key}:',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text('${entry.value}'),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                  
                  // アクションボタン
                  if (activity.actionUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('URLを開く: ${activity.actionUrl}')),
                            );
                          },
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('コンテンツを開く'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 12.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  // アクティビティタイプに基づくアイコンを取得
  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.post:
        return Icons.post_add;
      case ActivityType.comment:
        return Icons.comment;
      case ActivityType.like:
        return Icons.favorite;
      case ActivityType.share:
        return Icons.share;
      case ActivityType.release:
        return Icons.album;
      case ActivityType.live:
        return Icons.videocam;
      case ActivityType.media:
        return Icons.photo_library;
      case ActivityType.collaboration:
        return Icons.people;
      case ActivityType.award:
        return Icons.emoji_events;
      case ActivityType.milestone:
        return Icons.flag;
      default:
        return Icons.star;
    }
  }

  // アクティビティタイプに基づく色を取得
  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.post:
        return Colors.blue;
      case ActivityType.comment:
        return Colors.teal;
      case ActivityType.like:
        return Colors.red;
      case ActivityType.share:
        return Colors.purple;
      case ActivityType.release:
        return Colors.green;
      case ActivityType.live:
        return Colors.orange;
      case ActivityType.media:
        return Colors.amber;
      case ActivityType.collaboration:
        return Colors.indigo;
      case ActivityType.award:
        return Colors.deepOrange;
      case ActivityType.milestone:
        return Colors.brown;
      default:
        return Colors.blueGrey;
    }
  }

  // アクティビティタイプのラベルを取得
  String _getActivityTypeLabel(ActivityType type) {
    switch (type) {
      case ActivityType.post:
        return '投稿';
      case ActivityType.comment:
        return 'コメント';
      case ActivityType.like:
        return 'いいね';
      case ActivityType.share:
        return 'シェア';
      case ActivityType.release:
        return 'リリース';
      case ActivityType.live:
        return 'ライブ配信';
      case ActivityType.media:
        return 'メディア';
      case ActivityType.collaboration:
        return 'コラボレーション';
      case ActivityType.award:
        return '受賞';
      case ActivityType.milestone:
        return 'マイルストーン';
      default:
        return 'その他';
    }
  }
  
  // 数値のフォーマット（K, Mの単位を使用）
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }
  
  // 経過時間の表示
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return 'たった今';
    }
  }
  
  // 日時のフォーマット
  String _formatDateTime(DateTime dateTime) {
    final year = dateTime.year.toString();
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    
    return '$year/$month/$day $hour:$minute';
  }
} 