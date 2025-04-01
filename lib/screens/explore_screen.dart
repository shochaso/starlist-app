import 'package:flutter/material.dart';
import 'package:starlist_app/data/mock_data.dart';
import 'package:starlist_app/models/star.dart';
import 'package:starlist_app/routes/app_routes.dart';
import 'package:starlist_app/theme/app_theme.dart';
import 'package:starlist_app/widgets/star_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _recentSearches = [
    'モデル',
    'ゲーマー',
    'YouTuber女性',
    '人気ランキング',
  ];

  List<String> _trends = [
    '週間人気',
    '新着スター',
    '10代に人気',
    'フォロワー急上昇',
    'SNSで話題',
  ];

  @override
  Widget build(BuildContext context) {
    final List<Star> stars = MockData.getStars();
    List<Star> filteredStars = stars;
    
    // 検索クエリがある場合は絞り込み
    if (_searchQuery.isNotEmpty) {
      filteredStars = stars
          .where((star) =>
              star.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              star.category.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('探す'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'スターを検索',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onSubmitted: (value) {
                if (value.isNotEmpty && !_recentSearches.contains(value)) {
                  setState(() {
                    _recentSearches.insert(0, value);
                    if (_recentSearches.length > 5) {
                      _recentSearches.removeLast();
                    }
                  });
                }
              },
            ),
          ),
        ),
      ),
      body: _searchQuery.isEmpty
          ? _buildExploreContent()
          : _buildSearchResults(filteredStars),
    );
  }

  Widget _buildExploreContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 最近の検索
          if (_recentSearches.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                '最近の検索',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: _recentSearches.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(_recentSearches[index]),
                      onPressed: () {
                        setState(() {
                          _searchController.text = _recentSearches[index];
                          _searchQuery = _recentSearches[index];
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],

          // トレンド
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              '人気のトレンド',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Container(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _trends.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: ActionChip(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    label: Text(
                      _trends[index],
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    onPressed: () {
                      // トレンド検索機能は実装しない
                    },
                  ),
                );
              },
            ),
          ),

          // おすすめカテゴリ
          Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Text(
              'おすすめカテゴリ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildCategoryButton('YouTuber', Icons.play_circle_filled, Colors.red),
                _buildCategoryButton('ミュージシャン', Icons.music_note, Colors.purple),
                _buildCategoryButton('モデル', Icons.face, Colors.pink),
                _buildCategoryButton('ゲーマー', Icons.sports_esports, Colors.blue),
                _buildCategoryButton('料理家', Icons.restaurant, Colors.orange),
                _buildCategoryButton('アーティスト', Icons.palette, Colors.teal),
              ],
            ),
          ),
          
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String title, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.category,
          arguments: title,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              SizedBox(width: 12),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<Star> stars) {
    if (stars.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              '「$_searchQuery」に一致する\nスターが見つかりませんでした',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: stars.length,
      itemBuilder: (context, index) {
        return StarCard(
          star: stars[index],
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.starDetail,
            arguments: stars[index],
          ),
        );
      },
    );
  }
} 