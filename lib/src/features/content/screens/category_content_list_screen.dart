import 'package:flutter/material.dart';

import '../models/content_consumption_model.dart';
import '../sample/mock_public_content_data.dart';

class CategoryContentListScreen extends StatefulWidget {
  final ContentCategory? initialCategory;
  final String? title;

  const CategoryContentListScreen({
    Key? key,
    this.initialCategory,
    this.title,
  }) : super(key: key);

  @override
  State<CategoryContentListScreen> createState() => _CategoryContentListScreenState();
}

class _CategoryContentListScreenState extends State<CategoryContentListScreen> {
  late ContentCategory? _selectedCategory = widget.initialCategory;
  String _searchQuery = '';

  Iterable<ContentConsumption> get _filteredContents {
    final lowerQuery = _searchQuery.trim().toLowerCase();
    return MockPublicContentData.contents.where((content) {
      final matchesCategory = _selectedCategory == null || content.category == _selectedCategory;
      if (lowerQuery.isEmpty) {
        return matchesCategory;
      }
      final target = '${content.title}\n${content.description ?? ''}\n${(content.tags ?? []).join(' ')}'.toLowerCase();
      return matchesCategory && target.contains(lowerQuery);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contents = _filteredContents.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? _buildTitle()),
        actions: [
          IconButton(
            onPressed: () => _showCategoryPicker(context),
            icon: const Icon(Icons.tune),
            tooltip: 'カテゴリ/検索フィルター',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'キーワードで絞り込み',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                IconButton(
                  tooltip: '検索条件をクリア',
                  onPressed: () => setState(() {
                    _searchQuery = '';
                    _selectedCategory = widget.initialCategory;
                  }),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ChoiceChip(
                  label: const Text('すべて'),
                  selected: _selectedCategory == null,
                  onSelected: (_) => setState(() => _selectedCategory = null),
                ),
                const SizedBox(width: 8),
                ...ContentCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_categoryLabel(category)),
                      selected: _selectedCategory == category,
                      onSelected: (_) => setState(() => _selectedCategory = category),
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: contents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: theme.colorScheme.outlineVariant),
                        const SizedBox(height: 12),
                        Text('該当するコンテンツがありません', style: theme.textTheme.bodyLarge),
                        const SizedBox(height: 8),
                        Text(
                          '絞り込み条件を変更してもう一度お試しください',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: contents.length,
                    itemBuilder: (context, index) {
                      final content = contents[index];
                      return _ContentCard(content: content);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _buildTitle() {
    if (_selectedCategory == null) {
      return 'カテゴリ別コンテンツ';
    }
    return '${_categoryLabel(_selectedCategory!)}のコンテンツ';
  }

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('カテゴリを選択', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('すべて'),
                      selected: _selectedCategory == null,
                      onSelected: (_) {
                        setState(() => _selectedCategory = null);
                        Navigator.pop(context);
                      },
                    ),
                    ...ContentCategory.values.map((category) {
                      return FilterChip(
                        label: Text(_categoryLabel(category)),
                        selected: _selectedCategory == category,
                        onSelected: (_) {
                          setState(() => _selectedCategory = category);
                          Navigator.pop(context);
                        },
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
}

class _ContentCard extends StatelessWidget {
  final ContentConsumption content;

  const _ContentCard({required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    IconData icon;
    switch (content.category) {
      case ContentCategory.youtube:
        icon = Icons.play_circle_fill;
        break;
      case ContentCategory.music:
        icon = Icons.music_note;
        break;
      case ContentCategory.purchase:
        icon = Icons.shopping_bag;
        break;
      case ContentCategory.food:
        icon = Icons.restaurant;
        break;
      case ContentCategory.location:
        icon = Icons.place;
        break;
      case ContentCategory.book:
        icon = Icons.menu_book;
        break;
      case ContentCategory.other:
        icon = Icons.auto_awesome;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  child: Icon(icon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.title,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(content.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if ((content.description ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                content.description!,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if ((content.tags ?? []).isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: content.tags!
                    .map((tag) => Chip(
                          label: Text('#$tag'),
                          backgroundColor: theme.colorScheme.surfaceVariant,
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _IconStat(icon: Icons.visibility, label: content.viewCount.toString()),
                const SizedBox(width: 16),
                _IconStat(icon: Icons.favorite, label: content.likeCount.toString()),
                const Spacer(),
                Text(_categoryLabel(content.category), style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays >= 7) {
      return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    }
    if (difference.inDays >= 1) {
      return '${difference.inDays}日前';
    }
    if (difference.inHours >= 1) {
      return '${difference.inHours}時間前';
    }
    if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}分前';
    }
    return 'たった今';
  }

  static String _categoryLabel(ContentCategory category) {
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
}

class _IconStat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _IconStat({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
