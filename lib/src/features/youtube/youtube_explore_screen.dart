import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'youtube_video_list_view.dart';
import '../data_integration/models/youtube_video.dart';
import 'package:url_launcher/url_launcher.dart';

/// 検索クエリの状態プロバイダー
final searchQueryProvider = StateProvider<String>((ref) => '');

/// YouTube探索画面
class YouTubeExploreScreen extends ConsumerStatefulWidget {
  const YouTubeExploreScreen({super.key});

  @override
  ConsumerState<YouTubeExploreScreen> createState() => _YouTubeExploreScreenState();
}

class _YouTubeExploreScreenState extends ConsumerState<YouTubeExploreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _popularCategories = [
    'エンタメ',
    '音楽',
    'ゲーム',
    'スポーツ',
    'ニュース',
    'アニメ',
    '料理',
    '旅行',
  ];

  // タブを作成
  final List<Tab> _tabs = const [
    Tab(text: 'おすすめ'),
    Tab(text: '人気'),
    Tab(text: 'カテゴリー'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSearchQuery = ref.watch(searchQueryProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube探索'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // おすすめタブ
          _buildRecommendationsTab(),
          
          // 人気タブ
          _buildTrendingTab(),
          
          // カテゴリータブ
          _buildCategoriesTab(),
        ],
      ),
    );
  }

  /// おすすめタブの構築
  Widget _buildRecommendationsTab() {
    return ListView(
      children: [
        const SizedBox(height: 16.0),
        
        // 人気の動画セクション
        PopularYouTubeVideosSection(
          title: '人気の動画',
          subtitle: '今週よく見られている動画',
          isHorizontal: true,
          onViewAll: () {
            _tabController.animateTo(1); // 人気タブに切り替え
          },
          onVideoTap: _openYouTubeVideo,
        ),
        
        const SizedBox(height: 16.0),
        
        // 音楽カテゴリーセクション
        PopularYouTubeVideosSection(
          title: '音楽',
          subtitle: '人気の音楽動画',
          isHorizontal: true,
          onViewAll: () {
            ref.read(searchQueryProvider.notifier).state = '音楽';
            _tabController.animateTo(2); // カテゴリータブに切り替え
          },
          onVideoTap: _openYouTubeVideo,
        ),
        
        const SizedBox(height: 16.0),
        
        // ゲームカテゴリーセクション
        PopularYouTubeVideosSection(
          title: 'ゲーム',
          subtitle: '人気のゲーム動画',
          isHorizontal: true,
          onViewAll: () {
            ref.read(searchQueryProvider.notifier).state = 'ゲーム';
            _tabController.animateTo(2); // カテゴリータブに切り替え
          },
          onVideoTap: _openYouTubeVideo,
        ),
      ],
    );
  }

  /// 人気タブの構築
  Widget _buildTrendingTab() {
    return YouTubeVideoListView(
      searchQuery: 'popular videos japan',
      onVideoTap: _openYouTubeVideo,
    );
  }

  /// カテゴリータブの構築
  Widget _buildCategoriesTab() {
    final currentCategory = ref.watch(searchQueryProvider);
    
    return Column(
      children: [
        // カテゴリーセレクター
        Container(
          height: 60.0,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _popularCategories.length,
            itemBuilder: (context, index) {
              final category = _popularCategories[index];
              final isSelected = category == currentCategory;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(searchQueryProvider.notifier).state = category;
                    }
                  },
                ),
              );
            },
          ),
        ),
        
        // カテゴリーの動画リスト
        Expanded(
          child: currentCategory.isEmpty
              ? const Center(
                  child: Text('カテゴリーを選択してください'),
                )
              : YouTubeVideoListView(
                  searchQuery: currentCategory,
                  onVideoTap: _openYouTubeVideo,
                ),
        ),
      ],
    );
  }

  /// 検索ダイアログを表示
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('YouTube検索'),
          content: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: '検索キーワードを入力',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (value) {
              _performSearch(value);
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                _performSearch(_searchController.text);
                Navigator.pop(context);
              },
              child: const Text('検索'),
            ),
          ],
        );
      },
    );
  }

  /// 検索を実行
  void _performSearch(String query) {
    if (query.isNotEmpty) {
      ref.read(searchQueryProvider.notifier).state = query;
      _tabController.animateTo(2); // カテゴリータブに切り替え
    }
  }

  /// YouTubeビデオを開く
  void _openYouTubeVideo(YouTubeVideo video) async {
    final url = 'https://www.youtube.com/watch?v=${video.id}';
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('URLを開けませんでした: $url')),
        );
      }
    }
  }
} 