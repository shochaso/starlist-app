import 'package:flutter/material.dart';
import '../models/star.dart';
import '../models/activity.dart';
import '../routes/app_routes.dart';
import '../widgets/star_card.dart';
import '../widgets/activity_card.dart';
import '../widgets/horizontal_section.dart';
import '../src/features/star/screens/star_timeline_sample_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onThemeToggle;

  const HomeScreen({
    super.key, 
    this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100;
    final accentColor = isDarkMode ? Colors.blue : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final searchBarColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;

    // モック用データ
    final List<Star> stars = [
      Star(
        id: '1',
        name: 'YOASOBI',
        platforms: ['ミュージシャン'],
        genres: ['音楽', 'J-POP'],
        rank: 'スーパー',
        followers: 1500000,
        imageUrl: 'https://example.com/yoasobi.jpg',
        isVerified: true,
        socialAccounts: [
          SocialAccount(
            platform: 'X (Twitter)',
            username: '@YOASOBI_staff',
            url: 'https://twitter.com/YOASOBI_staff',
            isVerified: true,
          ),
          SocialAccount(
            platform: 'YouTube',
            username: 'Ayase / YOASOBI',
            url: 'https://www.youtube.com/c/Ayase_YOASOBI',
            isVerified: true,
          ),
        ],
        genreRatings: {
          '音楽': GenreRating(
            level: 9,
            points: 950,
            lastUpdated: DateTime.now().subtract(const Duration(days: 7)),
          ),
        },
      ),
      Star(
        id: '2',
        name: 'King & Prince',
        platforms: ['アイドル', 'ミュージシャン'],
        genres: ['音楽', 'J-POP', 'アイドル'],
        rank: 'プラチナ',
        followers: 850000,
        imageUrl: 'https://example.com/kingandprince.jpg',
        isVerified: true,
        socialAccounts: [
          SocialAccount(
            platform: 'X (Twitter)',
            username: '@kingandprince_j',
            url: 'https://twitter.com/kingandprince_j',
            isVerified: true,
          ),
        ],
      ),
      Star(
        id: '3',
        name: 'バスケットボールスタイル',
        platforms: ['YouTuber', '実況者'],
        genres: ['ゲーム', 'スポーツ'],
        rank: 'レギュラー',
        followers: 350000,
        imageUrl: 'https://example.com/basketballstyle.jpg',
        isVerified: false,
      ),
    ];

    final List<Activity> activities = [
      Activity(
        id: '1',
        starId: '1',
        type: 'youtube',
        title: '新曲「祝福」MV公開',
        content: 'YOASOBIの新曲「祝福」ミュージックビデオがYouTubeで公開されました。',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        imageUrl: 'https://example.com/yoasobi_mv.jpg',
      ),
      Activity(
        id: '2',
        starId: '2',
        type: 'purchase',
        title: 'ニューアルバム「L&」発売',
        content: 'King & Princeのニューアルバム「L&」が発売されました。',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        imageUrl: 'https://example.com/kingandprince_album.jpg',
        price: 3300,
      ),
    ];

    final List<Map<String, dynamic>> categories = [
      {'name': 'YouTuber', 'icon': Icons.play_circle_filled, 'color': Colors.red.shade200},
      {'name': 'ミュージシャン', 'icon': Icons.music_note, 'color': Colors.blue.shade200},
      {'name': 'クリエイター', 'icon': Icons.create, 'color': Colors.purple.shade200},
      {'name': 'モデル', 'icon': Icons.face, 'color': Colors.orange.shade200},
      {'name': 'ストリーマー', 'icon': Icons.stream, 'color': Colors.green.shade200},
      {'name': 'イラストレーター', 'icon': Icons.brush, 'color': Colors.yellow.shade200},
    ];

    // 検索履歴に基づくおすすめ
    final List<Star> searchBasedRecommendations = [
      Star(
        id: '101',
        name: 'Eve',
        platforms: ['ミュージシャン'],
        genres: ['音楽', 'J-POP', 'アニメ'],
        rank: 'A',
        followers: 850000,
        imageUrl: 'https://example.com/eve.jpg',
        isVerified: true,
      ),
      Star(
        id: '102',
        name: 'ずっと真夜中でいいのに。',
        platforms: ['ミュージシャン'],
        genres: ['音楽', 'J-POP', 'ロック'],
        rank: 'A',
        followers: 780000,
        imageUrl: 'https://example.com/zutomayo.jpg',
        isVerified: true,
      ),
      Star(
        id: '103',
        name: 'Vaundy',
        platforms: ['ミュージシャン'],
        genres: ['音楽', 'J-POP'],
        rank: 'A',
        followers: 720000,
        imageUrl: 'https://example.com/vaundy.jpg',
        isVerified: true,
      ),
    ];
    
    // SNS連携に基づくおすすめ
    final List<Star> snsBasedRecommendations = [
      Star(
        id: '201',
        name: '水溜りボンド',
        platforms: ['YouTuber'],
        genres: ['エンタメ', 'お笑い'],
        rank: 'A',
        followers: 920000,
        imageUrl: 'https://example.com/mizutamari.jpg',
        isVerified: true,
      ),
      Star(
        id: '202',
        name: 'あまね',
        platforms: ['TikToker'],
        genres: ['ダンス', 'エンタメ'],
        rank: 'B+',
        followers: 560000,
        imageUrl: 'https://example.com/amane.jpg',
        isVerified: true,
      ),
      Star(
        id: '203',
        name: 'ヒカキン',
        platforms: ['YouTuber'],
        genres: ['エンタメ'],
        rank: 'S',
        followers: 2500000,
        imageUrl: 'https://example.com/hikakin.jpg',
        isVerified: true,
      ),
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // AppBarに相当する部分
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox.shrink(),
                        Row(
                          children: [
                            // テーマ切り替えボタン
                            IconButton(
                              icon: Icon(
                                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                                color: textColor,
                              ),
                              onPressed: onThemeToggle,
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                              child: Icon(
                                Icons.person,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 検索バー
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: searchBarColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'スターや作品を検索',
                            style: TextStyle(
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // クイックフィルター（水平スクロール）
                    const SizedBox(height: 12),
                    const SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.only(top: 4, bottom: 4),
                      child: Row(
                        children: [
                          _QuickFilterChip(label: '注目', icon: Icons.trending_up),
                          SizedBox(width: 8),
                          _QuickFilterChip(label: 'ミュージシャン', icon: Icons.music_note),
                          SizedBox(width: 8),
                          _QuickFilterChip(label: 'YouTube', icon: Icons.play_circle_fill),
                          SizedBox(width: 8),
                          _QuickFilterChip(label: 'アイドル', icon: Icons.star),
                          SizedBox(width: 8),
                          _QuickFilterChip(label: 'ゲーム', icon: Icons.sports_esports),
                        ],
                      ),
                    ),
                    
                    // スタータイムラインサンプルボタン（デモ用）を追加
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const StarTimelineSampleScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.timeline),
                      label: const Text('スタータイムラインのサンプルを表示'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // カテゴリーのタイトル
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'カテゴリー',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.categoryList);
                      },
                      child: Text(
                        'すべて表示',
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // カテゴリーグリッド
            SliverToBoxAdapter(
              child: SizedBox(
                height: 250,
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.category,
                          arguments: categories[index]['name'],
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: categories[index]['color'],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isDarkMode ? [] : [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 12,
                              left: 12,
                              child: Text(
                                categories[index]['name'],
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Icon(
                                categories[index]['icon'],
                                color: isDarkMode ? Colors.white : Colors.black87,
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // おすすめのスターのタイトル
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'あなたにおすすめのスター',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // すべて表示ボタンの処理
                      },
                      child: Text(
                        'すべて表示',
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 注目のスター（横スクロール）
            HorizontalSection(
              title: '注目のスター',
              seeMoreText: 'もっと見る',
              onSeeMoreTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.category,
                  arguments: {'title': '注目のスター'},
                );
              },
              children: stars.map((star) => StarCard(
                star: star,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.starDetail,
                    arguments: star,
                  );
                },
              )).toList(),
            ),

            // 検索履歴に基づくおすすめセクション
            HorizontalSection(
              title: '検索履歴に基づくおすすめ',
              seeMoreText: 'もっと見る',
              onSeeMoreTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.category,
                  arguments: {'title': '検索履歴に基づくおすすめ'},
                );
              },
              children: searchBasedRecommendations.map((star) => StarCard(
                star: star,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.starDetail,
                    arguments: star,
                  );
                },
              )).toList(),
            ),
            
            // SNS連携に基づくおすすめセクション
            HorizontalSection(
              title: 'SNSでフォロー中',
              seeMoreText: 'もっと見る',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.link,
                      color: Colors.blue,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'X連携中',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              onSeeMoreTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.category,
                  arguments: {'title': 'SNSでフォロー中'},
                );
              },
              children: snsBasedRecommendations.map((star) => StarCard(
                star: star,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.starDetail,
                    arguments: star,
                  );
                },
              )).toList(),
            ),

            // 今日のアクティビティ（横スクロール）
            HorizontalSection(
              title: '今日のアクティビティ',
              seeMoreText: 'すべて表示',
              itemWidth: 280,
              itemHeight: 300,
              children: activities.map((activity) => ActivityCard(
                activity: activity,
                onTap: () {
                  // アクティビティタップ時の処理
                },
              )).toList(),
            ),

            // 余白
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: backgroundColor,
        selectedItemColor: accentColor,
        unselectedItemColor: secondaryTextColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: '検索',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'カテゴリ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_outlined),
            activeIcon: Icon(Icons.person_add),
            label: 'フォロー中',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'マイページ',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // ホーム画面（現在の画面）
              break;
            case 1:
              // 検索画面
              break;
            case 2:
              // カテゴリ画面
              Navigator.pushNamed(context, AppRoutes.categoryList);
              break;
            case 3:
              // フォロー中画面
              Navigator.pushNamed(context, AppRoutes.following);
              break;
            case 4:
              // マイページ画面（現在はファンのマイページに遷移）
              Navigator.pushNamed(context, AppRoutes.fanMypage);
              break;
          }
        },
      ),
    );
  }
  
  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'youtube':
        return Icons.play_circle_outline;
      case 'purchase':
        return Icons.shopping_bag_outlined;
      case 'music':
        return Icons.music_note_outlined;
      default:
        return Icons.star_outline;
    }
  }
} 

// クイックフィルター用の軽量Chipウィジェット
class _QuickFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _QuickFilterChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final borderColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Container(
      decoration: ShapeDecoration(
        color: bgColor,
        shape: StadiumBorder(side: BorderSide(color: borderColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
} 