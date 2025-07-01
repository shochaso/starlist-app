import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({Key? key}) : super(key: key);

  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> with SingleTickerProviderStateMixin {
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100;
    final accentColor = isDarkMode ? Colors.blue : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;

    // プラットフォームカテゴリー
    final List<Map<String, dynamic>> platformCategories = [
      {'name': 'YouTuber', 'icon': Icons.play_circle_filled, 'color': Colors.red.shade200, 'count': 157},
      {'name': 'ミュージシャン', 'icon': Icons.music_note, 'color': Colors.blue.shade200, 'count': 205},
      {'name': 'アイドル', 'icon': Icons.star, 'color': Colors.pink.shade200, 'count': 118},
      {'name': '実況者', 'icon': Icons.videogame_asset, 'color': Colors.purple.shade200, 'count': 76},
      {'name': 'ストリーマー', 'icon': Icons.stream, 'color': Colors.green.shade200, 'count': 62},
      {'name': 'お笑い芸人', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.orange.shade200, 'count': 93},
      {'name': 'モデル', 'icon': Icons.face, 'color': Colors.yellow.shade200, 'count': 129},
      {'name': 'クリエイター', 'icon': Icons.create, 'color': Colors.teal.shade200, 'count': 83},
    ];

    // ジャンルカテゴリー
    final List<Map<String, dynamic>> genreCategories = [
      {'name': '音楽', 'icon': Icons.music_note, 'color': Colors.blue.shade200, 'count': 245},
      {'name': 'ゲーム', 'icon': Icons.sports_esports, 'color': Colors.indigo.shade200, 'count': 183},
      {'name': '料理', 'icon': Icons.restaurant, 'color': Colors.amber.shade200, 'count': 79},
      {'name': 'スポーツ', 'icon': Icons.sports_basketball, 'color': Colors.green.shade200, 'count': 112},
      {'name': 'エンタメ', 'icon': Icons.movie, 'color': Colors.purple.shade200, 'count': 167},
      {'name': 'ビューティー', 'icon': Icons.face, 'color': Colors.pink.shade200, 'count': 94},
      {'name': '旅行', 'icon': Icons.flight, 'color': Colors.cyan.shade200, 'count': 58},
      {'name': 'テクノロジー', 'icon': Icons.devices, 'color': Colors.grey.shade200, 'count': 67},
      {'name': 'アート', 'icon': Icons.brush, 'color': Colors.yellow.shade200, 'count': 83},
      {'name': 'ファッション', 'icon': Icons.style, 'color': Colors.orange.shade200, 'count': 76},
      {'name': '教育', 'icon': Icons.school, 'color': Colors.brown.shade200, 'count': 41},
      {'name': 'ライフスタイル', 'icon': Icons.home, 'color': Colors.lime.shade200, 'count': 104},
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'カテゴリ一覧',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accentColor,
          labelColor: textColor,
          tabs: const [
            Tab(text: 'プラットフォーム'),
            Tab(text: 'ジャンル'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // プラットフォームタブ
          _buildCategoryTab(
            context: context,
            categories: platformCategories,
            isDarkMode: isDarkMode,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
          ),
          
          // ジャンルタブ
          _buildCategoryTab(
            context: context,
            categories: genreCategories,
            isDarkMode: isDarkMode,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryTab({
    required BuildContext context,
    required List<Map<String, dynamic>> categories,
    required bool isDarkMode,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 検索バー
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
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
                    'カテゴリーを検索',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // カテゴリーグリッド
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
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
                          top: 16,
                          right: 16,
                          child: Icon(
                            categories[index]['icon'],
                            color: isDarkMode ? Colors.white : Colors.black87,
                            size: 36,
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                categories[index]['name'],
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${categories[index]['count']}人のスター',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 