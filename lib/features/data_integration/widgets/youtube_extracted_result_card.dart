import 'package:flutter/material.dart';

import '../../../src/models/youtube_import_item.dart';

class YoutubeExtractedResultCard extends StatelessWidget {
  const YoutubeExtractedResultCard({
    super.key,
    required this.items,
    required this.isLinkEnriching,
    required this.isUploading,
    required this.enrichProgress,
    required this.enrichTotal,
    required this.onToggleSelected,
    required this.onTogglePublic,
    required this.onRemove,
    required this.onUpload,
    required this.onSelectAll,
    required this.onClearSelection,
  });

  final List<YoutubeImportItem> items;
  final bool isLinkEnriching;
  final bool isUploading;
  final int enrichProgress;
  final int enrichTotal;
  final void Function(String id) onToggleSelected;
  final void Function(String id) onTogglePublic;
  final void Function(String id) onRemove;
  final VoidCallback onUpload;
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
      padding: const EdgeInsets.all(12),
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatSummary(
            selectedCount: selectedCount,
            publicCount: publicCount,
          ),
          const SizedBox(height: 18),
          _buildActionButtons(
            context: context,
            selectedCount: selectedCount,
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

  Widget _buildStatSummary({
    required int selectedCount,
    required int publicCount,
  }) {
    final stats = [
      _StatSummaryData(
        label: '総数',
        value: '${items.length}',
        caption: '読み込み済み',
        icon: Icons.inventory_2_outlined,
        color: const Color(0xFF5A6AF0),
      ),
      _StatSummaryData(
        label: '選択中',
        value: '$selectedCount',
        caption: '登録候補',
        icon: Icons.check_circle_outline,
        color: const Color(0xFF1BC47D),
      ),
      _StatSummaryData(
        label: '公開予定',
        value: '$publicCount',
        caption: '公開待ち',
        icon: Icons.public_outlined,
        color: const Color(0xFF1AA7EC),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 640;
        if (isCompact) {
          return Column(
            children: [
              for (final stat in stats) ...[
                _StatSummaryCard(data: stat, isCompact: true),
                const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              Expanded(child: _StatSummaryCard(data: stats[i])),
              if (i != stats.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }

  Widget _buildActionButtons({
    required BuildContext context,
    required int selectedCount,
  }) {
    final actions = [
      _ToolbarAction(
        icon: Icons.done_all_rounded,
        label: '全件選択',
        onPressed: items.isEmpty ? null : onSelectAll,
        isPrimary: true,
      ),
      _ToolbarAction(
        icon: Icons.remove_done,
        label: '選択解除',
        onPressed: selectedCount == 0 ? null : onClearSelection,
        isPrimary: false,
      ),
      _ToolbarAction(
        icon: Icons.cloud_upload_outlined,
        label: isUploading ? '登録中…' : 'DB登録',
        onPressed: isUploading ? null : onUpload,
        isPrimary: true,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;
        if (isCompact) {
          final children = <Widget>[];
          for (var i = 0; i < actions.length; i++) {
            children.add(_buildActionButton(actions[i]));
            if (i != actions.length - 1) {
              children.add(const SizedBox(height: 12));
            }
          }
          return Column(children: children);
        }

        return Row(
          children: [
            for (var i = 0; i < actions.length; i++) ...[
              Expanded(child: _buildActionButton(actions[i])),
              if (i != actions.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }

  Widget _buildActionButton(_ToolbarAction action) {
    final primaryStyle = FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      backgroundColor: const Color(0xFF4C63F5),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
    final secondaryStyle = OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      foregroundColor: const Color(0xFF4C63F5),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
      side: const BorderSide(color: Color(0xFFCAD5FD), width: 1.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );

    final button = action.isPrimary
        ? FilledButton.icon(
            onPressed: action.onPressed,
            icon: Icon(action.icon, size: 18),
            label: Text(action.label),
            style: primaryStyle,
          )
        : OutlinedButton.icon(
            onPressed: action.onPressed,
            icon: Icon(action.icon, size: 18),
            label: Text(action.label),
            style: secondaryStyle,
          );

    return SizedBox(
      height: 48,
      child: button,
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

}

class _StatSummaryData {
  const _StatSummaryData({
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String caption;
  final IconData icon;
  final Color color;
}

class _StatSummaryCard extends StatelessWidget {
  const _StatSummaryCard({
    required this.data,
    this.isCompact = false,
  });

  final _StatSummaryData data;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isCompact ? null : 90,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            data.color.withOpacity(0.16),
            data.color.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: data.color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: data.color.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: data.color.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              data.icon,
              color: data.color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.label,
                  style: TextStyle(
                    color: data.color.withOpacity(0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.value,
                  style: TextStyle(
                    color: data.color.darken(),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.caption,
                  style: TextStyle(
                    color: data.color.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarAction {
  const _ToolbarAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
}

extension on Color {
  Color darken([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
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
