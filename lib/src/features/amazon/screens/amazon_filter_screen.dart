import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/amazon_providers.dart';
import '../../../data/models/amazon_models.dart';

/// Amazonフィルター画面
class AmazonFilterScreen extends ConsumerStatefulWidget {
  const AmazonFilterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AmazonFilterScreen> createState() => _AmazonFilterScreenState();
}

class _AmazonFilterScreenState extends ConsumerState<AmazonFilterScreen> {
  late AmazonPurchaseFilter _filter;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _filter = ref.read(amazonPurchaseFilterProvider);
    _searchController.text = _filter.searchQuery ?? '';
    _minPriceController.text = _filter.minPrice?.toInt().toString() ?? '';
    _maxPriceController.text = _filter.maxPrice?.toInt().toString() ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('フィルター'),
        actions: [
          TextButton(
            onPressed: () => _resetFilter(),
            child: const Text(
              'リセット',
              style: TextStyle(color: Color(0xFFFF9900)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 検索
            _buildSearchSection(),
            const SizedBox(height: 24),
            
            // 日付範囲
            _buildDateRangeSection(),
            const SizedBox(height: 24),
            
            // カテゴリ
            _buildCategorySection(),
            const SizedBox(height: 24),
            
            // 価格範囲
            _buildPriceRangeSection(),
            const SizedBox(height: 24),
            
            // その他のフィルター
            _buildOtherFiltersSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => _applyFilter(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9900),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '適用',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 検索セクション
  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '商品検索',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '商品名またはブランド名',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.search, color: Color(0xFFFF9900)),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                      });
                    },
                    icon: const Icon(Icons.clear, color: Colors.grey),
                  )
                : null,
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  /// 日付範囲セクション
  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '購入期間',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: '開始日',
                date: _filter.startDate,
                onTap: () => _selectStartDate(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                label: '終了日',
                date: _filter.endDate,
                onTap: () => _selectEndDate(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 日付フィールド
  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFFFF9900), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date != null
                        ? DateFormat('yyyy/MM/dd').format(date)
                        : '未設定',
                    style: TextStyle(
                      color: date != null ? Colors.white : Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (date != null)
              IconButton(
                onPressed: () {
                  setState(() {
                    if (label == '開始日') {
                      _filter = _filter.copyWith(startDate: null);
                    } else {
                      _filter = _filter.copyWith(endDate: null);
                    }
                  });
                },
                icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  /// カテゴリセクション
  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'カテゴリ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AmazonPurchaseCategory.values.map((category) {
            final isSelected = _filter.categories?.contains(category) ?? false;
            return FilterChip(
              label: Text(_getCategoryDisplayName(category)),
              selected: isSelected,
              onSelected: (selected) => _toggleCategory(category),
              selectedColor: const Color(0xFFFF9900),
              backgroundColor: const Color(0xFF2A2A2A),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 12,
              ),
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected ? const Color(0xFFFF9900) : const Color(0xFF333333),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 価格範囲セクション
  Widget _buildPriceRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '価格範囲',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minPriceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '最小価格',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixText: '¥',
                  prefixStyle: const TextStyle(color: Color(0xFFFF9900)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text('〜', style: TextStyle(color: Colors.grey)),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _maxPriceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '最大価格',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixText: '¥',
                  prefixStyle: const TextStyle(color: Color(0xFFFF9900)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// その他のフィルターセクション
  Widget _buildOtherFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'その他',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // レビュー済みのみ
        _buildSwitchTile(
          title: 'レビュー済みのみ',
          subtitle: 'レビューを投稿した商品のみ表示',
          value: _filter.hasReview ?? false,
          onChanged: (value) {
            setState(() {
              _filter = _filter.copyWith(hasReview: value);
            });
          },
        ),
        const SizedBox(height: 8),
        
        // 返品商品を除外
        _buildSwitchTile(
          title: '返品商品を除外',
          subtitle: '返品済みの商品を表示しない',
          value: _filter.excludeReturned ?? false,
          onChanged: (value) {
            setState(() {
              _filter = _filter.copyWith(excludeReturned: value);
            });
          },
        ),
      ],
    );
  }

  /// スイッチタイル
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFFF9900),
          ),
        ],
      ),
    );
  }

  /// カテゴリ表示名取得
  String _getCategoryDisplayName(AmazonPurchaseCategory category) {
    return AmazonPurchase(
      id: '',
      userId: '',
      orderId: '',
      productId: '',
      productName: '',
      price: 0,
      currency: 'JPY',
      quantity: 1,
      category: category,
      purchaseDate: DateTime.now(),
      isReturned: false,
      isRefunded: false,
      metadata: const {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ).categoryDisplayName;
  }

  /// カテゴリ切り替え
  void _toggleCategory(AmazonPurchaseCategory category) {
    setState(() {
      final categories = List<AmazonPurchaseCategory>.from(_filter.categories ?? []);
      if (categories.contains(category)) {
        categories.remove(category);
      } else {
        categories.add(category);
      }
      _filter = _filter.copyWith(
        categories: categories.isEmpty ? null : categories,
      );
    });
  }

  /// 開始日選択
  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filter.startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFF9900),
              surface: Color(0xFF2A2A2A),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _filter = _filter.copyWith(startDate: picked);
      });
    }
  }

  /// 終了日選択
  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filter.endDate ?? DateTime.now(),
      firstDate: _filter.startDate ?? DateTime(2010),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFF9900),
              surface: Color(0xFF2A2A2A),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _filter = _filter.copyWith(endDate: picked);
      });
    }
  }

  /// フィルターリセット
  void _resetFilter() {
    setState(() {
      _filter = const AmazonPurchaseFilter();
      _searchController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
    });
  }

  /// フィルター適用
  void _applyFilter() {
    // 検索クエリ
    final searchQuery = _searchController.text.trim();
    _filter = _filter.copyWith(
      searchQuery: searchQuery.isEmpty ? null : searchQuery,
    );
    
    // 最小価格
    final minPrice = double.tryParse(_minPriceController.text);
    _filter = _filter.copyWith(minPrice: minPrice);
    
    // 最大価格
    final maxPrice = double.tryParse(_maxPriceController.text);
    _filter = _filter.copyWith(maxPrice: maxPrice);
    
    // フィルター適用
    ref.read(amazonPurchaseActionProvider).updateFilter(_filter);
    Navigator.pop(context);
  }
}