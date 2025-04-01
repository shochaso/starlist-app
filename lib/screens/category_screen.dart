import 'package:flutter/material.dart';
import 'package:starlist_app/data/mock_data.dart';
import 'package:starlist_app/models/star.dart';
import 'package:starlist_app/routes/app_routes.dart';
import 'package:starlist_app/theme/app_theme.dart';
import 'package:starlist_app/widgets/star_card.dart';

class CategoryScreen extends StatefulWidget {
  final String category;

  const CategoryScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<String> _categories;
  late int _initialIndex;
  String _selectedSubCategory = 'すべて';

  final List<String> _subCategories = [
    'すべて',
    '新着',
    '人気',
    'フォロワー多い順',
    'ランク順',
  ];

  @override
  void initState() {
    super.initState();
    _categories = MockData.getCategories();
    
    // 初期選択タブの設定
    if (_categories.contains(widget.category)) {
      _initialIndex = _categories.indexOf(widget.category);
    } else {
      _initialIndex = 0; // 該当するカテゴリがない場合は最初のタブを選択
    }
    
    _tabController = TabController(
      length: _categories.length,
      vsync: this,
      initialIndex: _initialIndex,
    );
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
        title: Text('おすすめスター'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: _categories.map((category) => Tab(text: category)).toList(),
        ),
      ),
      body: Column(
        children: [
          // サブカテゴリ（フィルター）
          _buildSubCategoryChips(),
          
          // スターのグリッド表示
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                return _buildStarGrid(category);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // サブカテゴリのチップフィルター
  Widget _buildSubCategoryChips() {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _subCategories.length,
        itemBuilder: (context, index) {
          final subCategory = _subCategories[index];
          final isSelected = subCategory == _selectedSubCategory;
          
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(subCategory),
              onSelected: (selected) {
                setState(() {
                  _selectedSubCategory = subCategory;
                });
              },
              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryColor : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  // スターのグリッド表示
  Widget _buildStarGrid(String category) {
    List<Star> filteredStars = MockData.getStars();
    
    // カテゴリによるフィルタリング（「おすすめ」と「ランキング」は除外）
    if (category != 'おすすめ' && category != 'ランキング') {
      filteredStars = filteredStars.where((star) => star.category == category).toList();
    }
    
    // サブカテゴリによるソート
    switch (_selectedSubCategory) {
      case '人気':
        filteredStars.sort((a, b) => b.followers.compareTo(a.followers));
        break;
      case 'フォロワー多い順':
        filteredStars.sort((a, b) => b.followers.compareTo(a.followers));
        break;
      case 'ランク順':
        filteredStars.sort((a, b) {
          const rankOrder = {'スーパー': 0, 'プラチナ': 1, 'レギュラー': 2};
          return rankOrder[a.rank]!.compareTo(rankOrder[b.rank]!);
        });
        break;
      case '新着':
        // 本来はデータに日付があればそれでソートする
        filteredStars = filteredStars.reversed.toList();
        break;
      default:
        // デフォルトは何もしない
        break;
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredStars.length,
      itemBuilder: (context, index) {
        return StarCard(
          star: filteredStars[index],
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.starDetail,
            arguments: filteredStars[index],
          ),
        );
      },
    );
  }
} 