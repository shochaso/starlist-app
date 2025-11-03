import 'package:flutter/material.dart';
import 'package:starlist_app/services/image_url_builder.dart';

import '../models/star.dart';
import '../routes/app_routes.dart';
import '../src/core/config/feature_flags.dart';

class FollowingScreen extends StatelessWidget {
  const FollowingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100;
    final secondaryTextColor =
        isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final dividerColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
    final accentColor = isDarkMode ? Colors.blue : Colors.black;

    // モック用のフォロー中データ
    final List<Star> followingStars = [
      Star(
        id: '1',
        name: 'YOASOBI',
        platforms: ['ミュージシャン'],
        genres: ['音楽', 'J-POP'],
        rank: 'S',
        followers: 1500000,
        imageUrl: 'https://example.com/yoasobi.jpg',
        isVerified: true,
      ),
      Star(
        id: '2',
        name: '米津玄師',
        platforms: ['ミュージシャン'],
        genres: ['音楽', 'J-POP', 'ロック'],
        rank: 'S',
        followers: 2000000,
        imageUrl: 'https://example.com/yonezu.jpg',
        isVerified: true,
      ),
      Star(
        id: '3',
        name: '星野源',
        platforms: ['ミュージシャン', '俳優'],
        genres: ['音楽', 'J-POP', 'エンタメ'],
        rank: 'A',
        followers: 1200000,
        imageUrl: 'https://example.com/hoshino.jpg',
        isVerified: true,
      ),
    ];

    // 課金ファンになっているスター
    final List<Star> paidFanStars = [
      Star(
        id: '4',
        name: '宮崎駿',
        platforms: ['クリエイター'],
        genres: ['映画', 'アート', 'アニメ'],
        rank: 'S+',
        followers: 5000000,
        imageUrl: 'https://example.com/miyazaki.jpg',
        isVerified: true,
      ),
      Star(
        id: '5',
        name: '佐藤健',
        platforms: ['俳優'],
        genres: ['映画', 'エンタメ'],
        rank: 'A+',
        followers: 800000,
        imageUrl: 'https://example.com/sato.jpg',
        isVerified: true,
      ),
    ];

    // スターリスト
    final List<Map<String, dynamic>> starLists = [
      {
        'name': '音楽スター',
        'count': 3,
        'image': 'https://example.com/music_collection.jpg',
      },
      {
        'name': '2023年注目スター',
        'count': 5,
        'image': 'https://example.com/2023_stars.jpg',
      },
      {
        'name': '映画関連',
        'count': 2,
        'image': 'https://example.com/movie_collection.jpg',
      },
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const SizedBox.shrink(),
        backgroundColor: backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: textColor,
            ),
            onPressed: () {
              // 検索機能
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // スターリストセクション
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'スターリスト',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // リスト管理画面へ
                    },
                    child: Text(
                      '管理',
                      style: TextStyle(
                        color: isDarkMode ? Colors.blue : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // スターリスト
            SizedBox(
              height: 160,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: starLists.length + 1, // 追加ボタン用に+1
                itemBuilder: (context, index) {
                  if (index == starLists.length) {
                    // 最後の要素は追加ボタン
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: dividerColor,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: isDarkMode ? Colors.blue : Colors.black,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '新規作成',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final list = starLists[index];
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      image: FeatureFlags.hideSampleMedia
                          ? null
                          : DecorationImage(
                              image: NetworkImage(list['image']),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.3),
                                BlendMode.darken,
                              ),
                            ),
                    ),
                    child: Stack(
                      children: [
                        // グラデーション
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.center,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        // テキスト
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                list['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${list['count']}個のスター',
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 課金ファンセクション
            if (paidFanStars.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ファン登録中',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.workspace_premium,
                            color: Colors.amber,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Premium',
                            style: TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: paidFanStars.length,
                itemBuilder: (context, index) {
                  final star = paidFanStars[index];
                  return _buildStarListTile(context, star, cardColor, textColor,
                      secondaryTextColor, isDarkMode,
                      isPremium: true);
                },
              ),
            ],

            // フォロー中スターセクション
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'フォロー中のスター',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // 並べ替え
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.sort,
                          size: 16,
                          color: isDarkMode ? Colors.blue : Colors.black,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '並べ替え',
                          style: TextStyle(
                            color: isDarkMode ? Colors.blue : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // フォロー中スターリスト
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: followingStars.length,
              itemBuilder: (context, index) {
                final star = followingStars[index];
                return _buildStarListTile(context, star, cardColor, textColor,
                    secondaryTextColor, isDarkMode,
                    isPremium: false);
              },
            ),

            // SNS連携セクション
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.link,
                          color: accentColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SNSアカウント連携',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'SNSアカウントを連携すると、あなたが既にフォローしているスターを自動的に見つけることができます。また、お好みに合わせたおすすめのスターも表示されます。',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSocialConnectButton(
                          'YouTube',
                          Icons.play_arrow,
                          Colors.red,
                          false,
                        ),
                        _buildSocialConnectButton(
                          'X',
                          Icons.alternate_email,
                          Colors.blue,
                          true,
                        ),
                        _buildSocialConnectButton(
                          'Instagram',
                          Icons.camera_alt,
                          Colors.pink,
                          false,
                        ),
                        _buildSocialConnectButton(
                          'TikTok',
                          Icons.music_note,
                          Colors.black,
                          false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 余白
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // スターリストアイテム
  Widget _buildStarListTile(BuildContext context, Star star, Color cardColor,
      Color textColor, Color secondaryTextColor, bool isDarkMode,
      {bool isPremium = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDarkMode
              ? []
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          leading: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.network(
                    ImageUrlBuilder.thumbnail(
                      star.imageUrl,
                      width: 320,
                    ),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                        child: Center(
                          child: Text(
                            star.name.substring(0, 1),
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (isPremium)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            children: [
              Text(
                star.name,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 4),
              if (star.isVerified)
                const Icon(
                  Icons.verified,
                  color: Colors.blue,
                  size: 16,
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                star.platforms.isNotEmpty ? star.platforms.first : '',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getRankColor(star.rank, isDarkMode),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      star.rank,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.people_outline,
                    size: 14,
                    color: secondaryTextColor,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    _formatFollowers(star.followers),
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              isPremium ? Icons.favorite : Icons.person_remove_outlined,
              color: isPremium ? Colors.red : secondaryTextColor,
            ),
            onPressed: () {
              // フォロー解除または課金解除
            },
          ),
          onTap: () {
            // スター詳細画面へ
            Navigator.pushNamed(
              context,
              AppRoutes.starDetail,
              arguments: star,
            );
          },
        ),
      ),
    );
  }

  // SNS連携ボタン
  Widget _buildSocialConnectButton(
    String platform,
    IconData icon,
    Color color,
    bool isConnected,
  ) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              if (isConnected)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          platform,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          isConnected ? '連携済み' : '連携する',
          style: TextStyle(
            fontSize: 10,
            color: isConnected ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }

  // ランクに応じた色を返す
  Color _getRankColor(String rank, bool isDarkMode) {
    switch (rank) {
      case 'S+':
        return Colors.purple;
      case 'S':
        return Colors.blue;
      case 'A+':
        return Colors.green;
      case 'A':
        return Colors.teal;
      case 'B+':
        return Colors.amber;
      case 'B':
        return Colors.orange;
      default:
        return isDarkMode ? Colors.grey.shade700 : Colors.grey.shade600;
    }
  }

  // フォロワー数のフォーマット
  String _formatFollowers(int followers) {
    if (followers >= 10000) {
      double man = followers / 10000;
      return '${man.toStringAsFixed(man.truncateToDouble() == man ? 0 : 1)}万';
    } else if (followers >= 1000) {
      double kilo = followers / 1000;
      return '${kilo.toStringAsFixed(kilo.truncateToDouble() == kilo ? 0 : 1)}千';
    } else {
      return '$followers';
    }
  }
}
