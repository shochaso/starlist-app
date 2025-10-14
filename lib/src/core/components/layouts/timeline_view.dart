import 'package:flutter/material.dart';

/// タイムラインの項目
class TimelineItem {
  /// タイムラインの日時
  final DateTime timestamp;
  
  /// タイトル
  final String? title;
  
  /// サブタイトル
  final String? subtitle;
  
  /// リードインウィジェット
  final Widget? leading;
  
  /// トレイリンウィジェット
  final Widget? trailing;
  
  /// コンテンツ
  final Widget? content;
  
  /// メディア
  final Widget? media;
  
  /// アクション
  final List<Widget>? actions;
  
  /// アイテムがタップされたときのコールバック
  final VoidCallback? onTap;

  TimelineItem({
    required this.timestamp,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.content,
    this.media,
    this.actions,
    this.onTap,
  });
}

/// タイムライン表示のためのウィジェット
class TimelineView extends StatelessWidget {
  /// タイムラインの項目リスト
  final List<TimelineItem> items;
  
  /// ローディング中かどうか
  final bool isLoading;
  
  /// 項目が空の場合に表示するウィジェット
  final Widget? emptyWidget;
  
  /// ローディング中に表示するウィジェット
  final Widget? loadingWidget;
  
  /// 項目が空の場合に表示するメッセージ
  final String? emptyMessage;
  
  /// 表示するかどうか
  final bool showDividers;
  
  /// 日付でグループ化するかどうか
  final bool groupByDate;
  
  /// パディング
  final EdgeInsetsGeometry? padding;

  const TimelineView({
    super.key,
    required this.items,
    this.isLoading = false,
    this.loadingWidget,
    this.emptyMessage,
    this.emptyWidget,
    this.showDividers = true,
    this.groupByDate = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ?? const Center(child: CircularProgressIndicator());
    }
    
    if (items.isEmpty) {
      return emptyWidget ?? 
        Center(
          child: Text(emptyMessage ?? 'アイテムがありません'),
        );
    }
    
    if (groupByDate) {
      return _buildGroupedTimeline(context);
    }
    
    return _buildFlatTimeline(context);
  }

  Widget _buildFlatTimeline(BuildContext context) {
    return ListView.separated(
      padding: padding ?? const EdgeInsets.all(16.0),
      itemCount: items.length,
      separatorBuilder: (context, index) {
        return showDividers
            ? const Divider(height: 24, thickness: 1)
            : const SizedBox(height: 16);
      },
      itemBuilder: (context, index) {
        return _buildTimelineItem(context, items[index]);
      },
    );
  }

  Widget _buildGroupedTimeline(BuildContext context) {
    // 日付でグループ化
    Map<String, List<TimelineItem>> groupedItems = {};
    
    for (var item in items) {
      final dateStr = _formatDate(item.timestamp);
      if (!groupedItems.containsKey(dateStr)) {
        groupedItems[dateStr] = [];
      }
      groupedItems[dateStr]!.add(item);
    }

    // 日付ごとのリストを作成
    List<Widget> sections = [];
    
    groupedItems.forEach((date, dateItems) {
      sections.add(
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
          child: Text(
            date,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
      
      for (int i = 0; i < dateItems.length; i++) {
        sections.add(_buildTimelineItem(context, dateItems[i]));
        
        if (i < dateItems.length - 1 && showDividers) {
          sections.add(const Divider(height: 24, thickness: 1));
        } else if (i < dateItems.length - 1) {
          sections.add(const SizedBox(height: 16));
        }
      }
    });

    return ListView(
      padding: padding ?? const EdgeInsets.all(16.0),
      children: sections,
    );
  }

  Widget _buildTimelineItem(BuildContext context, TimelineItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600), // コンテンツの最大幅を制限
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.leading != null) ...[
                  item.leading!,
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.title != null) ...[
                        Text(
                          item.title!,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (item.subtitle != null) ...[
                        Text(
                          item.subtitle!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ],
                  ),
                ),
                if (item.trailing != null) item.trailing!,
              ],
            ),
            if (item.content != null) ...[
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 560, // コンテンツの最大幅をさらに制限
                ),
                child: item.content!,
              ),
            ],
            if (item.media != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 200,
                    maxWidth: 560, // 画像の最大幅も制限
                  ),
                  child: item.media!,
                ),
              ),
            ],
            if (item.actions != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: item.actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 日付をフォーマット
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);
    
    if (dateToCheck == today) {
      return '今日';
    } else if (dateToCheck == yesterday) {
      return '昨日';
    } else {
      return '${date.year}年${date.month}月${date.day}日';
    }
  }
} 