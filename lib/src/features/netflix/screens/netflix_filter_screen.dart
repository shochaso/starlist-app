import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/netflix_providers.dart';
import '../../../data/models/netflix_models.dart';

/// Netflixフィルター画面
class NetflixFilterScreen extends ConsumerStatefulWidget {
  const NetflixFilterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NetflixFilterScreen> createState() => _NetflixFilterScreenState();
}

class _NetflixFilterScreenState extends ConsumerState<NetflixFilterScreen> {
  late NetflixViewingFilter _filter;
  late TextEditingController _searchController;
  DateTime? _tempStartDate;
  DateTime? _tempEndDate;

  @override
  void initState() {
    super.initState();
    _filter = ref.read(netflixViewingFilterProvider);
    _searchController = TextEditingController(text: _filter.searchQuery ?? '');
    _tempStartDate = _filter.startDate;
    _tempEndDate = _filter.endDate;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'フィルター',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // リセットボタン
          TextButton(
            onPressed: () => _resetFilters(),
            child: const Text(
              'リセット',
              style: TextStyle(color: Color(0xFFE50914)),
            ),
          ),
          // 適用ボタン
          TextButton(
            onPressed: () => _applyFilters(),
            child: const Text(
              '適用',
              style: TextStyle(
                color: Color(0xFFE50914),
                fontWeight: FontWeight.bold,
              ),
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
            
            // コンテンツタイプ
            _buildContentTypeSection(),
            const SizedBox(height: 24),
            
            // ジャンル
            _buildGenreSection(),
            const SizedBox(height: 24),
            
            // 視聴状態
            _buildWatchStatusSection(),
            const SizedBox(height: 24),
            
            // 日付範囲
            _buildDateRangeSection(),
            const SizedBox(height: 24),
            
            // 評価
            _buildRatingSection(),
            const SizedBox(height: 24),
            
            // 並び順
            _buildSortSection(),
          ],
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
          '検索',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'タイトル、キャスト、ジャンルで検索...',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF333333)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF333333)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE50914)),
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: Colors.grey,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.grey,
                    ),
                  )
                : null,
          ),
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  /// コンテンツタイプセクション
  Widget _buildContentTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'コンテンツタイプ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: NetflixContentType.values.map((type) {
            final isSelected = _filter.contentTypes?.contains(type) ?? false;
            return FilterChip(
              label: Text(_getContentTypeDisplayName(type)),
              selected: isSelected,
              onSelected: (selected) => _toggleContentType(type, selected),
              backgroundColor: const Color(0xFF1A1A1A),
              selectedColor: const Color(0xFFE50914).withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFFE50914) : Colors.white,
                fontSize: 12,
              ),
              side: BorderSide(
                color: isSelected 
                    ? const Color(0xFFE50914)
                    : const Color(0xFF333333),
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }

  /// ジャンルセクション
  Widget _buildGenreSection() {
    // 一般的なNetflixジャンル
    final commonGenres = [
      'アクション', 'コメディ', 'ドラマ', 'ホラー', 'ロマンス',
      'SF', 'アニメ', 'ドキュメンタリー', 'スリラー', 'ファンタジー',
      '日本', 'アメリカ', 'イギリス', 'フランス', '韓国',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ジャンル',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: commonGenres.map((genre) {
            final isSelected = _filter.genres?.contains(genre) ?? false;
            return FilterChip(
              label: Text(genre),
              selected: isSelected,
              onSelected: (selected) => _toggleGenre(genre, selected),
              backgroundColor: const Color(0xFF1A1A1A),
              selectedColor: const Color(0xFFE50914).withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFFE50914) : Colors.white,
                fontSize: 12,
              ),
              side: BorderSide(
                color: isSelected 
                    ? const Color(0xFFE50914)
                    : const Color(0xFF333333),
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 視聴状態セクション
  Widget _buildWatchStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '視聴状態',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: NetflixWatchStatus.values.map((status) {
            final isSelected = _filter.watchStatuses?.contains(status) ?? false;
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getWatchStatusIcon(status),
                    size: 16,
                    color: isSelected 
                        ? const Color(0xFFE50914)
                        : _getWatchStatusColor(status),
                  ),
                  const SizedBox(width: 4),
                  Text(_getWatchStatusDisplayName(status)),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) => _toggleWatchStatus(status, selected),
              backgroundColor: const Color(0xFF1A1A1A),
              selectedColor: const Color(0xFFE50914).withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFFE50914) : Colors.white,
                fontSize: 12,
              ),
              side: BorderSide(
                color: isSelected 
                    ? const Color(0xFFE50914)
                    : const Color(0xFF333333),
              ),
              showCheckmark: false,
            );
          }).toList(),
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
          '視聴日',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // 開始日
            Expanded(
              child: GestureDetector(
                onTap: () => _selectStartDate(),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '開始日',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Color(0xFFE50914),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _tempStartDate != null
                                ? DateFormat('yyyy/MM/dd').format(_tempStartDate!)
                                : '選択してください',
                            style: TextStyle(
                              color: _tempStartDate != null ? Colors.white : Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // 終了日
            Expanded(
              child: GestureDetector(
                onTap: () => _selectEndDate(),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '終了日',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Color(0xFFE50914),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _tempEndDate != null
                                ? DateFormat('yyyy/MM/dd').format(_tempEndDate!)
                                : '選択してください',
                            style: TextStyle(
                              color: _tempEndDate != null ? Colors.white : Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        
        // 日付クリアボタン
        if (_tempStartDate != null || _tempEndDate != null) ...[ 
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _tempStartDate = null;
                  _tempEndDate = null;
                });
              },
              icon: const Icon(
                Icons.clear,
                color: Colors.grey,
                size: 16,
              ),
              label: const Text(
                '日付をクリア',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 評価セクション
  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '評価',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [1, 2, 3, 4, 5].map((rating) {
            final isSelected = _filter.minRating != null && rating >= _filter.minRating!;
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...List.generate(rating, (index) => const Icon(
                    Icons.star,
                    size: 14,
                    color: Color(0xFFE50914),
                  )),
                  const SizedBox(width: 4),
                  const Text('以上'),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) => _toggleRating(rating, selected),
              backgroundColor: const Color(0xFF1A1A1A),
              selectedColor: const Color(0xFFE50914).withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFFE50914) : Colors.white,
                fontSize: 12,
              ),
              side: BorderSide(
                color: isSelected 
                    ? const Color(0xFFE50914)
                    : const Color(0xFF333333),
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 並び順セクション
  Widget _buildSortSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '並び順',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: DropdownButton<String>(
            value: _filter.sortBy ?? 'watchedAt',
            isExpanded: true,
            dropdownColor: const Color(0xFF1A1A1A),
            style: const TextStyle(color: Colors.white),
            underline: const SizedBox.shrink(),
            items: const [
              DropdownMenuItem(value: 'watchedAt', child: Text('視聴日')),
              DropdownMenuItem(value: 'title', child: Text('タイトル')),
              DropdownMenuItem(value: 'releaseYear', child: Text('公開年')),
              DropdownMenuItem(value: 'rating', child: Text('評価')),
              DropdownMenuItem(value: 'duration', child: Text('時間')),
            ],
            onChanged: (value) {
              setState(() {
                _filter = _filter.copyWith(sortBy: value);
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                value: false,
                groupValue: _filter.isAscending ?? false,
                onChanged: (value) {
                  setState(() {
                    _filter = _filter.copyWith(isAscending: value);
                  });
                },
                title: const Text(
                  '降順',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                activeColor: const Color(0xFFE50914),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                value: true,
                groupValue: _filter.isAscending ?? false,
                onChanged: (value) {
                  setState(() {
                    _filter = _filter.copyWith(isAscending: value);
                  });
                },
                title: const Text(
                  '昇順',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                activeColor: const Color(0xFFE50914),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// コンテンツタイプ切り替え
  void _toggleContentType(NetflixContentType type, bool selected) {
    setState(() {
      final types = List<NetflixContentType>.from(_filter.contentTypes ?? []);
      if (selected) {
        types.add(type);
      } else {
        types.remove(type);
      }
      _filter = _filter.copyWith(contentTypes: types.isEmpty ? null : types);
    });
  }

  /// ジャンル切り替え
  void _toggleGenre(String genre, bool selected) {
    setState(() {
      final genres = List<String>.from(_filter.genres ?? []);
      if (selected) {
        genres.add(genre);
      } else {
        genres.remove(genre);
      }
      _filter = _filter.copyWith(genres: genres.isEmpty ? null : genres);
    });
  }

  /// 視聴状態切り替え
  void _toggleWatchStatus(NetflixWatchStatus status, bool selected) {
    setState(() {
      final statuses = List<NetflixWatchStatus>.from(_filter.watchStatuses ?? []);
      if (selected) {
        statuses.add(status);
      } else {
        statuses.remove(status);
      }
      _filter = _filter.copyWith(watchStatuses: statuses.isEmpty ? null : statuses);
    });
  }

  /// 評価切り替え
  void _toggleRating(int rating, bool selected) {
    setState(() {
      _filter = _filter.copyWith(minRating: selected ? rating : null);
    });
  }

  /// 開始日選択
  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _tempStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFE50914),
              surface: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _tempStartDate = date);
    }
  }

  /// 終了日選択
  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _tempEndDate ?? DateTime.now(),
      firstDate: _tempStartDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFE50914),
              surface: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _tempEndDate = date);
    }
  }

  /// フィルターリセット
  void _resetFilters() {
    setState(() {
      _filter = const NetflixViewingFilter();
      _searchController.clear();
      _tempStartDate = null;
      _tempEndDate = null;
    });
  }

  /// フィルター適用
  void _applyFilters() {
    final finalFilter = _filter.copyWith(
      searchQuery: _searchController.text.isNotEmpty ? _searchController.text : null,
      startDate: _tempStartDate,
      endDate: _tempEndDate,
    );
    
    ref.read(netflixViewingActionProvider).updateFilter(finalFilter);
    Navigator.pop(context);
  }

  /// コンテンツタイプ表示名取得
  String _getContentTypeDisplayName(NetflixContentType contentType) {
    switch (contentType) {
      case NetflixContentType.movie:
        return '映画';
      case NetflixContentType.series:
        return 'シリーズ';
      case NetflixContentType.documentary:
        return 'ドキュメンタリー';
      case NetflixContentType.anime:
        return 'アニメ';
      case NetflixContentType.standup:
        return 'スタンダップコメディ';
      case NetflixContentType.kids:
        return 'キッズ';
      case NetflixContentType.reality:
        return 'リアリティ番組';
      case NetflixContentType.other:
        return 'その他';
    }
  }

  /// 視聴状態表示名取得
  String _getWatchStatusDisplayName(NetflixWatchStatus status) {
    switch (status) {
      case NetflixWatchStatus.completed:
        return '完了';
      case NetflixWatchStatus.inProgress:
        return '視聴中';
      case NetflixWatchStatus.watchlist:
        return 'ウォッチリスト';
      case NetflixWatchStatus.stopped:
        return '中断';
    }
  }

  /// 視聴状態アイコン取得
  IconData _getWatchStatusIcon(NetflixWatchStatus status) {
    switch (status) {
      case NetflixWatchStatus.completed:
        return Icons.check_circle;
      case NetflixWatchStatus.inProgress:
        return Icons.play_circle;
      case NetflixWatchStatus.watchlist:
        return Icons.bookmark;
      case NetflixWatchStatus.stopped:
        return Icons.pause_circle;
    }
  }

  /// 視聴状態色取得
  Color _getWatchStatusColor(NetflixWatchStatus status) {
    switch (status) {
      case NetflixWatchStatus.completed:
        return Colors.green;
      case NetflixWatchStatus.inProgress:
        return const Color(0xFFE50914);
      case NetflixWatchStatus.watchlist:
        return Colors.orange;
      case NetflixWatchStatus.stopped:
        return Colors.grey;
    }
  }
}