import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/theme_provider.dart';

// プロバイダー
final selectedTabProvider = StateProvider<int>((ref) => 0);

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  String _searchQuery = '';
  int? _selectedResultIndex;

  // 人気スターデータを大幅に追加
  final List<Map<String, dynamic>> _popularStars = [
    {
      'name': 'テックレビューアー田中',
      'category': 'テクノロジー・ガジェット',
      'followers': 245000,
      'avatar': 'T',
      'verified': true,
      'description': '最新ガジェットの詳細レビューと比較',
      'gradientColors': [Color(0xFF4ECDC4), Color(0xFF44A08D)],
    },
    {
      'name': '料理研究家佐藤',
      'category': '料理・グルメ',
      'followers': 183000,
      'avatar': 'S',
      'verified': true,
      'description': '簡単で美味しい家庭料理レシピ',
      'gradientColors': [Color(0xFFFFE66D), Color(0xFFFF6B6B)],
    },
    {
      'name': 'ゲーム実況者山田',
      'category': 'ゲーム・エンタメ',
      'followers': 327000,
      'avatar': 'G',
      'verified': true,
      'description': 'FPS・RPGゲームの実況とレビュー',
      'gradientColors': [Color(0xFF667EEA), Color(0xFF764BA2)],
    },
    {
      'name': '旅行ブロガー鈴木',
      'category': '旅行・写真',
      'followers': 158000,
      'avatar': 'T',
      'verified': false,
      'description': '世界各地の絶景スポットと旅行Tips',
      'gradientColors': [Color(0xFF74B9FF), Color(0xFF0984E3)],
    },
    {
      'name': 'ファッション系インフルエンサー',
      'category': 'ファッション・ライフスタイル',
      'followers': 281000,
      'avatar': 'F',
      'verified': true,
      'description': 'トレンドファッションとコーディネート',
      'gradientColors': [Color(0xFFE17055), Color(0xFFD63031)],
    },
    {
      'name': 'ビジネス系YouTuber中村',
      'category': 'ビジネス・投資',
      'followers': 412000,
      'avatar': 'B',
      'verified': true,
      'description': '投資戦略と起業ノウハウ',
      'gradientColors': [Color(0xFF6C5CE7), Color(0xFDA4DE)],
    },
    {
      'name': 'アニメレビュアー小林',
      'category': 'アニメ・マンガ',
      'followers': 196000,
      'avatar': 'A',
      'verified': false,
      'description': '最新アニメの詳細レビューと考察',
      'gradientColors': [Color(0xFFFF7675), Color(0xFFE84393)],
    },
    {
      'name': 'DIYクリエイター木村',
      'category': 'DIY・ハンドメイド',
      'followers': 124000,
      'avatar': 'D',
      'verified': false,
      'description': '初心者でもできるDIYプロジェクト',
      'gradientColors': [Color(0xFF00B894), Color(0xFF00A085)],
    },
    {
      'name': 'プログラミング講師伊藤',
      'category': 'プログラミング・教育',
      'followers': 89000,
      'avatar': 'P',
      'verified': true,
      'description': 'Flutter・React開発チュートリアル',
      'gradientColors': [Color(0xFF00B894), Color(0xFF00A085)],
    },
    {
      'name': 'フィットネストレーナー渡辺',
      'category': 'フィットネス・健康',
      'followers': 156000,
      'avatar': 'F',
      'verified': false,
      'description': '自宅でできる効果的なトレーニング',
      'gradientColors': [Color(0xFFE84393), Color(0xFDD5D5)],
    },
  ];

  // カテゴリデータを大幅に追加
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'テクノロジー・ガジェット',
      'icon': Icons.devices,
      'color': Color(0xFF4ECDC4),
      'starCount': 156,
      'contentCount': 2340,
      'description': 'スマートフォン、PC、最新ガジェットのレビュー',
    },
    {
      'name': '料理・グルメ',
      'icon': Icons.restaurant,
      'color': Color(0xFFFF6B6B),
      'starCount': 89,
      'contentCount': 1890,
      'description': 'レシピ、レストランレビュー、料理テクニック',
    },
    {
      'name': 'ゲーム・エンタメ',
      'icon': Icons.sports_esports,
      'color': Color(0xFF667EEA),
      'starCount': 234,
      'contentCount': 4560,
      'description': 'ゲーム実況、レビュー、攻略情報',
    },
    {
      'name': 'ファッション・美容',
      'icon': Icons.checkroom,
      'color': Color(0xFFE17055),
      'starCount': 178,
      'contentCount': 3210,
      'description': 'コーディネート、メイク、美容情報',
    },
    {
      'name': 'ビジネス・投資',
      'icon': Icons.trending_up,
      'color': Color(0xFF6C5CE7),
      'starCount': 67,
      'contentCount': 1450,
      'description': '投資戦略、起業ノウハウ、ビジネススキル',
    },
    {
      'name': '旅行・写真',
      'icon': Icons.camera_alt,
      'color': Color(0xFF74B9FF),
      'starCount': 123,
      'contentCount': 2780,
      'description': '旅行記、写真撮影テクニック、観光情報',
    },
    {
      'name': 'アニメ・マンガ',
      'icon': Icons.movie,
      'color': Color(0xFFFF7675),
      'starCount': 145,
      'contentCount': 3890,
      'description': 'アニメレビュー、マンガ紹介、声優情報',
    },
    {
      'name': 'フィットネス・健康',
      'icon': Icons.fitness_center,
      'color': Color(0xFFE84393),
      'starCount': 98,
      'contentCount': 1670,
      'description': 'トレーニング、ダイエット、健康管理',
    },
    {
      'name': 'プログラミング・IT',
      'icon': Icons.code,
      'color': Color(0xFF00B894),
      'starCount': 76,
      'contentCount': 1230,
      'description': 'プログラミング学習、IT技術解説',
    },
    {
      'name': 'DIY・ハンドメイド',
      'icon': Icons.build,
      'color': Color(0xFF00A085),
      'starCount': 54,
      'contentCount': 890,
      'description': 'DIYプロジェクト、手作り作品、工具レビュー',
    },
    {
      'name': '音楽・楽器',
      'icon': Icons.music_note,
      'color': Color(0xFFFFD93D),
      'starCount': 87,
      'contentCount': 1560,
      'description': '楽器演奏、音楽理論、機材レビュー',
    },
    {
      'name': 'ペット・動物',
      'icon': Icons.pets,
      'color': Color(0xFF55A3FF),
      'starCount': 112,
      'contentCount': 2100,
      'description': 'ペットケア、動物の生態、飼育方法',
    },
  ];

  // 検索結果データを拡充
  final List<Map<String, dynamic>> _searchResults = [
    {
      'type': 'star',
      'name': 'テックレビューアー田中',
      'category': 'テクノロジー・ガジェット',
      'followers': 245000,
      'avatar': 'T',
      'verified': true,
      'description': '最新ガジェットの詳細レビューと比較',
      'gradientColors': [Color(0xFF4ECDC4), Color(0xFF44A08D)],
    },
    {
      'type': 'star',
      'name': '料理研究家佐藤',
      'category': '料理・グルメ',
      'followers': 183000,
      'avatar': 'S',
      'verified': true,
      'description': '簡単で美味しい家庭料理レシピ',
      'gradientColors': [Color(0xFFFFE66D), Color(0xFFFF6B6B)],
    },
    {
      'type': 'content',
      'title': 'iPhone 15 Pro Max 完全レビュー - カメラ性能が革命的！',
      'star': 'テックレビューアー田中',
      'category': 'テクノロジー・ガジェット',
      'likes': 2340,
      'views': 15200,
      'duration': '25:30',
      'uploadDate': '2日前',
    },
    {
      'type': 'content',
      'title': '30分で作れる絶品パスタレシピ5選',
      'star': '料理研究家佐藤',
      'category': '料理・グルメ',
      'likes': 1560,
      'views': 8900,
      'duration': '12:45',
      'uploadDate': '1日前',
    },
    {
      'type': 'content',
      'title': 'Flutter 3.0 新機能完全解説',
      'star': 'プログラミング講師伊藤',
      'category': 'プログラミング・IT',
      'likes': 890,
      'views': 4560,
      'duration': '32:15',
      'uploadDate': '3日前',
    },
  ];

  final List<String> _trendingKeywords = [
    'iPhone 15',
    'Flutter 3.0',
    'パスタレシピ',
    'ゲーム実況',
    '映画レビュー',
    'ファッション',
    'DIY',
    '投資',
    'アニメ',
    'フィットネス',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // TabControllerの変更を状態に反映
      });
      ref.read(selectedTabProvider.notifier).state = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // 検索バー
            Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'スター、コンテンツを検索...',
                  hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? Colors.transparent : const Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? Colors.transparent : const Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4ECDC4)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
              ),
            ),
            
            // タブバー
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _buildTabItem('検索結果', 0),
                  _buildTabItem('人気スター', 1),
                  _buildTabItem('カテゴリ', 2),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // タブビュー
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSearchResults(),
                  _buildPopularStars(),
                  _buildCategories(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    if (_searchQuery.isEmpty) {
      return _buildTrendingSection();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        final isSelected = _selectedResultIndex == index;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedResultIndex = isSelected ? null : index;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected 
                    ? const Color(0xFF4ECDC4)
                    : (isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.black).withOpacity(0.08),
                  blurRadius: isSelected ? 20 : 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: result['type'] == 'star' 
                ? _buildStarResultItem(result, isDark, isSelected)
                : _buildContentResultItem(result, isDark, isSelected),
          ),
        );
      },
    );
  }

  Widget _buildStarResultItem(Map<String, dynamic> star, bool isDark, bool isSelected) {
    final gradientColors = star['gradientColors'] as List<Color>;
    
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradientColors.first.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              star['avatar'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
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
                      star['name'],
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (star['verified'])
                    const Icon(
                      Icons.verified,
                      color: Color(0xFF4ECDC4),
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                star['category'],
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                star['description'],
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black45,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                '${(star['followers'] / 1000).toStringAsFixed(1)}万フォロワー',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'フォロー',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentResultItem(Map<String, dynamic> content, bool isDark, bool isSelected) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF4ECDC4).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.play_arrow,
            color: Color(0xFF4ECDC4),
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content['title'],
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${content['star']} • ${content['category']}',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.thumb_up,
                    size: 14,
                    color: isDark ? Colors.white54 : Colors.black38,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${content['likes']}',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black38,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.visibility,
                    size: 14,
                    color: isDark ? Colors.white54 : Colors.black38,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${(content['views'] / 1000).toStringAsFixed(1)}k',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black38,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    content['duration'],
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingSection() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'トレンドキーワード',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: _trendingKeywords.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final keyword = _trendingKeywords[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : Colors.black).withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    keyword,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularStars() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _popularStars.length,
      itemBuilder: (context, index) {
        final star = _popularStars[index];
        final gradientColors = star['gradientColors'] as List<Color>;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.black).withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors.first.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    star['avatar'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
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
                            star['name'],
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (star['verified'])
                          const Icon(
                            Icons.verified,
                            color: Color(0xFF4ECDC4),
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      star['category'],
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      star['description'],
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black45,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(star['followers'] / 1000).toStringAsFixed(1)}万フォロワー',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'フォロー',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategories() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.black).withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: category['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category['icon'],
                  color: category['color'],
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                category['name'],
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${category['starCount']}スター • ${(category['contentCount'] / 1000).toStringAsFixed(1)}kコンテンツ',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black38,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                category['description'],
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black45,
                  fontSize: 10,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    final isSelected = _selectedFilter == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4ECDC4) : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF4ECDC4) : (isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE5E7EB)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    final isSelected = _tabController.index == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.index = index;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4ECDC4) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
} 