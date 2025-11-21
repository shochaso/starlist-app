import 'package:flutter/material.dart';

import '../../../src/models/youtube_import_item.dart';

class YoutubeExtractedResultCard extends StatelessWidget {
  const YoutubeExtractedResultCard({
    super.key,
    required this.items,
    required this.isLinkEnriching,
    required this.isUploading,
    required this.isPublishing,
    required this.enrichProgress,
    required this.enrichTotal,
    required this.onToggleSelected,
    required this.onTogglePublic,
    required this.onRemove,
    required this.onEnrichSelected,
    required this.onEnrichAll,
    required this.onUpload,
    required this.onPublish,
    required this.onSelectAll,
    required this.onClearSelection,
  });

  final List<YoutubeImportItem> items;
  final bool isLinkEnriching;
  final bool isUploading;
  final bool isPublishing;
  final int enrichProgress;
  final int enrichTotal;
  final void Function(String id) onToggleSelected;
  final void Function(String id) onTogglePublic;
  final void Function(String id) onRemove;
  final VoidCallback onEnrichSelected;
  final VoidCallback onEnrichAll;
  final VoidCallback onUpload;
  final VoidCallback onPublish;
  final VoidCallback onSelectAll;
  final VoidCallback onClearSelection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE1E7FF)),
        ),
        child: Center(
          child: Text(
            'OCR解析を実行すると動画リストが表示されます。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    }

    final selectedCount = items.where((item) => item.selected).length;
    final publicCount = items.where((item) => item.isPublic).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E7FF)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const _StepBadge(index: 3),
              const SizedBox(width: 12),
              Text(
                '抽出結果の確認・編集',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildToolbar(
                  context: context,
                  selectedCount: selectedCount,
                  publicCount: publicCount,
                ),
                const Divider(height: 1),
                _buildList(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar({
    required BuildContext context,
    required int selectedCount,
    required int publicCount,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildStatChip(
                label: '総数',
                value: '${items.length}',
                color: theme.colorScheme.primary,
              ),
              _buildStatChip(
                label: '選択中',
                value: '$selectedCount',
                color: theme.colorScheme.secondary,
              ),
              _buildStatChip(
                label: '公開予定',
                value: '$publicCount',
                color: Colors.teal,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _toolbarButton(
                icon: Icons.done_all,
                label: '全件選択',
                onPressed: onSelectAll,
              ),
              _toolbarButton(
                icon: Icons.remove_done,
                label: '選択解除',
                onPressed: onClearSelection,
                outlined: true,
              ),
              _toolbarButton(
                icon: Icons.auto_fix_high_outlined,
                label: '選択をリンク補完',
                onPressed: isLinkEnriching ? null : onEnrichSelected,
              ),
              _toolbarButton(
                icon: Icons.search,
                label: '全件検索',
                onPressed: isLinkEnriching ? null : onEnrichAll,
                outlined: true,
              ),
              _toolbarButton(
                icon: Icons.cloud_upload_outlined,
                label: isUploading ? '登録中…' : 'DB登録',
                onPressed: isUploading ? null : onUpload,
              ),
              _toolbarButton(
                icon: Icons.public,
                label: isPublishing ? '公開中…' : '公開設定',
                onPressed: isPublishing ? null : onPublish,
                outlined: true,
              ),
            ],
          ),
          if (isLinkEnriching)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(
                value: enrichTotal == 0 ? null : enrichProgress / enrichTotal,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: Theme.of(context).dividerColor),
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: item.selected,
                    onChanged: (_) => onToggleSelected(item.id),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Chip(
                              label: Text(item.channel.isEmpty
                                  ? 'channel不明'
                                  : item.channel),
                            ),
                            if (item.matchScore != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Chip(
                                  avatar: const Icon(Icons.shield, size: 16),
                                  label: Text(
                                      '一致率 ${(item.matchScore! * 100).round()}%'),
                                  backgroundColor: Colors.green.shade50,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => onRemove(item.id),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
              if (item.videoUrl != null)
                Padding(
                  padding: const EdgeInsets.only(left: 40, top: 8),
                  child: InkWell(
                    onTap: () {},
                    child: Text(
                      item.videoUrl!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ),
                ),
              if (item.enrichError != null)
                Padding(
                  padding: const EdgeInsets.only(left: 40, top: 4),
                  child: Text(
                    item.enrichError!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.red),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(left: 40, top: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5FF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          Switch(
                            value: item.isPublic,
                            onChanged: item.isSaved
                                ? (_) => onTogglePublic(item.id)
                                : null,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.isSaved
                                ? (item.isPublic ? '公開' : '非公開')
                                : '保存前',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (item.isLinkLoading) ...[
                      const SizedBox(width: 12),
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Text(
          label.substring(0, 1),
          style: TextStyle(color: color),
        ),
      ),
      label: Text('$label: $value'),
    );
  }

  Widget _toolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool outlined = false,
  }) {
    return outlined
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 18),
            label: Text(label),
          )
        : FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 18),
            label: Text(label),
          );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF5A6AF0),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Center(
        child: Text(
          '$index',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
