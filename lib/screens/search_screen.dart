import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 検索タブの状態管理
final searchTabProvider = StateProvider<int>((ref) => 0);
final searchQueryProvider = StateProvider<String>((ref) => '');

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<String> tabTitles = [
    '最新の検索結果',
    'スター',
    'カテゴリー',
    'コンテンツ',
    'タグ',
    'YouTube',
    'Spotify',
    'Amazon',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabTitles.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildSearchHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDefaultSearchView(),
                _buildStarsView(),
                _buildCategoryView(),
                _buildContentView(),
                _buildTagsView(),
                _buildYouTubeView(),
                _buildSpotifyView(),
                _buildAmazonView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'スター、コンテンツ、タグを検索',
              prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: const Color(0xFF3B82F6),
        labelColor: const Color(0xFF3B82F6),
        unselectedLabelColor: const Color(0xFF6B7280),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: tabTitles.map((title) => Tab(text: title)).toList(),
      ),
    );
  }

  Widget _buildDefaultSearchView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '最新の検索結果',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildTagCard('#新着コンテンツ', '今週の新しい投稿'),
          const SizedBox(height: 12),
          _buildStarResultCard(
            '田中 太郎',
            '24.5万フォロワー',
            '1',
            Colors.yellow,
            [Colors.purple, Colors.blue],
            false,
          ),
          const SizedBox(height: 12),
          _buildStarResultCard(
            '佐藤 花子',
            '18.3万フォロワー',
            '2',
            Colors.grey,
            [Colors.green, Colors.blue],
            true,
          ),
          const SizedBox(height: 12),
          _buildStarResultCard(
            '鈴木 次郎',
            '9.7万フォロワー',
            '3',
            Colors.orange,
            [Colors.red, Colors.yellow],
            false,
          ),
          const SizedBox(height: 24),
          const Text(
            'トレンド検索',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildContentCard(),
          const SizedBox(height: 12),
          _buildTagCard('#アニメレビュー', '1,284件の投稿'),
        ],
      ),
    );
  }

  Widget _buildStarsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStarSection('あなたにおすすめ', [
            _buildStarProfile('田中 太郎', '音楽・エンタメ', 'T', [Colors.purple, Colors.pink]),
            _buildStarProfile('佐藤 花子', 'ファッション', 'S', [Colors.green, Colors.teal]),
            _buildStarProfile('鈴木 次郎', 'ゲーム', 'SZ', [Colors.red, Colors.orange]),
            _buildStarProfile('山田 一郎', 'YouTuber', 'Y', [Colors.yellow, Colors.orange]),
            _buildStarProfile('中村 愛', '美容・コスメ', 'N', [Colors.blue, Colors.indigo]),
          ]),
          const SizedBox(height: 32),
          _buildStarSection('ゲーム', [
            _buildStarProfile('高橋 ゲーマー', 'eスポーツ選手', 'G1', [Colors.red, Colors.pink]),
            _buildStarProfile('佐々木 プレイヤー', 'ゲーム実況者', 'G2', [Colors.purple, Colors.indigo]),
            _buildStarProfile('伊藤 ゲーム', 'ゲームクリエイター', 'G3', [Colors.blue, Colors.cyan]),
            _buildStarProfile('渡辺 ストリーマー', 'ゲーム配信者', 'G4', [Colors.green, Colors.teal]),
          ]),
          const SizedBox(height: 32),
          _buildStarSection('料理・グルメ', [
            _buildStarProfile('斎藤 シェフ', '料理研究家', 'C1', [Colors.amber, Colors.orange]),
            _buildStarProfile('加藤 グルメ', '食レポーター', 'C2', [Colors.red, Colors.pink]),
            _buildStarProfile('小林 ベジタリアン', 'ベジタリアン料理家', 'C3', [Colors.green, Colors.lime]),
            _buildStarProfile('吉田 カフェ', 'カフェオーナー', 'C4', [Colors.blue, Colors.lightBlue]),
          ]),
        ],
      ),
    );
  }

  Widget _buildCategoryView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildCategoryCard(Icons.music_note, '音楽', '246人のスター', [Colors.purple, Colors.indigo]),
              _buildCategoryCard(Icons.movie, '映画・ドラマ', '189人のスター', [Colors.blue, Colors.cyan]),
              _buildCategoryCard(Icons.restaurant, '料理・グルメ', '134人のスター', [Colors.green, Colors.teal]),
              _buildCategoryCard(Icons.games, 'ゲーム', '211人のスター', [Colors.red, Colors.pink]),
              _buildCategoryCard(Icons.book, '書籍・マンガ', '97人のスター', [Colors.yellow, Colors.amber]),
              _buildCategoryCard(Icons.shopping_bag, 'ファッション', '178人のスター', [Colors.orange, Colors.red]),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'おすすめカテゴリー',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecommendedCategoryCard(),
        ],
      ),
    );
  }

  Widget _buildContentView() {
    return const Center(
      child: Text(
        'コンテンツ検索',
        style: TextStyle(fontSize: 18, color: Colors.black54),
      ),
    );
  }

  Widget _buildTagsView() {
    return const Center(
      child: Text(
        'タグ検索',
        style: TextStyle(fontSize: 18, color: Colors.black54),
      ),
    );
  }

  Widget _buildYouTubeView() {
    return const Center(
      child: Text(
        'YouTube検索',
        style: TextStyle(fontSize: 18, color: Colors.black54),
      ),
    );
  }

  Widget _buildSpotifyView() {
    return const Center(
      child: Text(
        'Spotify検索',
        style: TextStyle(fontSize: 18, color: Colors.black54),
      ),
    );
  }

  Widget _buildAmazonView() {
    return const Center(
      child: Text(
        'Amazon検索',
        style: TextStyle(fontSize: 18, color: Colors.black54),
      ),
    );
  }

  Widget _buildTagCard(String tag, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tag,
            style: const TextStyle(
              color: Color(0xFF3B82F6),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarResultCard(
    String name,
    String followers,
    String rank,
    Color rankColor,
    List<Color> gradientColors,
    bool isFollowing,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            rank,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: rankColor,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  followers,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: isFollowing ? Colors.grey : const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Text(
              isFollowing ? 'フォロー中' : 'フォロー',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 8,
                backgroundColor: Color(0xFFA7F3D0),
                child: Text(
                  'S',
                  style: TextStyle(fontSize: 8, color: Color(0xFF047857)),
                ),
              ),
              SizedBox(width: 8),
              Text(
                '佐藤 花子さんが投稿',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.music_note, color: Color(0xFF10B981), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lo-Fi Study Beats',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'ChillHop Music - アルバム',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '4時間前',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarSection(String title, List<Widget> stars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'すべて表示',
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: stars.length,
            itemBuilder: (context, index) {
              return Container(
                width: 128,
                margin: const EdgeInsets.only(right: 16),
                child: stars[index],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStarProfile(String name, String category, String initial, List<Color> colors) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          category,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCategoryCard(IconData icon, String title, String subtitle, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCategoryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF87171), Color(0xFFEC4899)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.headphones,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '音楽プロデューサー',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '68人のスター',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F4F6),
                  foregroundColor: Colors.black54,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'フォロー',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...List.generate(4, (index) => Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    'P${index + 1}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              )),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Text(
                    '+64',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 