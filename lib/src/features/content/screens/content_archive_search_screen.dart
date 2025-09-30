import 'package:flutter/material.dart';

import '../models/content_consumption_model.dart';
import '../sample/mock_public_content_data.dart';

class ContentArchiveSearchScreen extends StatefulWidget {
  const ContentArchiveSearchScreen({Key? key}) : super(key: key);

  @override
  State<ContentArchiveSearchScreen> createState() => _ContentArchiveSearchScreenState();
}

class _ContentArchiveSearchScreenState extends State<ContentArchiveSearchScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  ContentCategory? _selectedCategory;
  String _keyword = '';
  late List<ContentConsumption> _results = MockPublicContentData.contents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('投稿アーカイブ検索'),
      ),
      body: Column(
        children: [
          _buildFilters(theme),
          const Divider(height: 1),
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: theme.colorScheme.outlineVariant),
                        const SizedBox(height: 12),
                        Text('該当する投稿が見つかりません', style: theme.textTheme.bodyLarge),
                        const SizedBox(height: 8),
                        Text(
                          '条件を見直してもう一度検索してください',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final content = _results[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          foregroundColor: theme.colorScheme.onPrimaryContainer,
                          child: Icon(_categoryIcon(content.category)),
                        ),
                        title: Text(content.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((content.description ?? '').isNotEmpty)
                              Text(
                                content.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            Text(
                              '${_formatDate(content.createdAt)}・${_categoryLabel(content.category)}',
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.visibility, size: 16),
                            Text(content.viewCount.toString()),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _DateSelector(
                label: '開始日',
                value: _startDate,
                onTap: () async {
                  final picked = await _pickDate(initial: _startDate ?? DateTime.now().subtract(const Duration(days: 7)));
                  if (picked != null) {
                    setState(() => _startDate = picked);
                  }
                },
              ),
              _DateSelector(
                label: '終了日',
                value: _endDate,
                onTap: () async {
                  final picked = await _pickDate(initial: _endDate ?? DateTime.now());
                  if (picked != null) {
                    setState(() => _endDate = picked);
                  }
                },
              ),
              DropdownButton<ContentCategory?>(
                value: _selectedCategory,
                hint: const Text('カテゴリを選択'),
                items: [
                  const DropdownMenuItem<ContentCategory?>(value: null, child: Text('すべて')),
                  ...ContentCategory.values.map(
                    (category) => DropdownMenuItem<ContentCategory?>(
                      value: category,
                      child: Text(_categoryLabel(category)),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'キーワード',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => _keyword = value,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _applyFilters,
                  icon: const Icon(Icons.filter_alt),
                  label: const Text('検索する'),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => setState(() {
                  _startDate = null;
                  _endDate = null;
                  _selectedCategory = null;
                  _keyword = '';
                  _results = MockPublicContentData.contents;
                }),
                child: const Text('クリア'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _pickDate({required DateTime initial}) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
  }

  void _applyFilters() {
    final query = _keyword.trim().toLowerCase();
    final filtered = MockPublicContentData.contents.where((content) {
      final matchesCategory = _selectedCategory == null || content.category == _selectedCategory;
      final matchesStart = _startDate == null || !content.createdAt.isBefore(_startDate!);
      final matchesEnd = _endDate == null || !content.createdAt.isAfter(_endDate!);
      final matchesKeyword = query.isEmpty
          ? true
          : '${content.title}\n${content.description ?? ''}\n${(content.tags ?? []).join(' ')}'
              .toLowerCase()
              .contains(query);
      return matchesCategory && matchesStart && matchesEnd && matchesKeyword;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() => _results = filtered);
  }

  IconData _categoryIcon(ContentCategory category) {
    switch (category) {
      case ContentCategory.youtube:
        return Icons.play_circle_fill;
      case ContentCategory.music:
        return Icons.music_note;
      case ContentCategory.purchase:
        return Icons.shopping_cart;
      case ContentCategory.food:
        return Icons.restaurant;
      case ContentCategory.location:
        return Icons.place;
      case ContentCategory.book:
        return Icons.menu_book;
      case ContentCategory.other:
        return Icons.layers;
    }
  }

  String _categoryLabel(ContentCategory category) {
    switch (category) {
      case ContentCategory.youtube:
        return 'YouTube';
      case ContentCategory.music:
        return '音楽';
      case ContentCategory.purchase:
        return '購入';
      case ContentCategory.food:
        return 'フード';
      case ContentCategory.location:
        return 'ロケーション';
      case ContentCategory.book:
        return '書籍';
      case ContentCategory.other:
        return 'その他';
    }
  }

  String _formatDate(DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year/$month/$day';
  }
}

class _DateSelector extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateSelector({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final display = value == null
        ? '未設定'
        : '${value!.year}/${value!.month.toString().padLeft(2, '0')}/${value!.day.toString().padLeft(2, '0')}';
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.event),
      label: Text('$label: $display'),
    );
  }
}
