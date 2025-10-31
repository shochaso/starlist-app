import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starlist_app/services/image_url_builder.dart';
import '../../../core/components/layouts/timeline_view.dart';
import '../providers/star_activity_provider.dart';
import '../models/star_activity.dart';

enum TimelineSortOption {
  newest,
  oldest,
  groupedByType,
}

/// スターのアクティビティタイムラインスクリーン
class StarActivityTimelineScreen extends ConsumerStatefulWidget {
  /// スターのID
  final String starId;
  
  /// 表示するアクティビティタイプ（全てのアクティビティを表示する場合はnull）
  final ActivityType? activityType;
  
  /// スクリーンのタイトル（オプション）
  final String? title;

  const StarActivityTimelineScreen({
    super.key,
    required this.starId,
    this.activityType,
    this.title,
  });

  @override
  ConsumerState<StarActivityTimelineScreen> createState() => _StarActivityTimelineScreenState();
}

class _StarActivityTimelineScreenState extends ConsumerState<StarActivityTimelineScreen> {
  TimelineSortOption _sortOption = TimelineSortOption.newest;

  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(starActivitiesProvider(widget.starId));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'アクティビティタイムライン'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
          PopupMenuButton<TimelineSortOption>(
            tooltip: '並び替え',
            initialValue: _sortOption,
            onSelected: (value) => setState(() => _sortOption = value),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: TimelineSortOption.newest,
                child: Text('新しい順'),
              ),
              PopupMenuItem(
                value: TimelineSortOption.oldest,
                child: Text('古い順'),
              ),
              PopupMenuItem(
                value: TimelineSortOption.groupedByType,
                child: Text('タイプ別にまとめて表示'),
              ),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: activitiesAsync.when(
        data: (activities) {
          // 必要に応じてアクティビティをフィルタリング
          final filteredActivities = widget.activityType != null
              ? activities
                  .where((activity) => activity.type == widget.activityType)
                  .toList()
              : activities;
          final sortedActivities = _applySort(filteredActivities);
          
          return Column(
            children: [
              // アクティビティタイプフィルターチップ
              if (widget.activityType != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Wrap(
                    spacing: 8.0,
                    children: [
                      FilterChip(
                        label: Text(_getActivityTypeLabel(widget.activityType!)),
                        selected: true,
                        onSelected: (_) {
                          // フィルターをクリア
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => StarActivityTimelineScreen(
                                starId: widget.starId,
                                title: widget.title,
                              ),
                            ),
                          );
                        },
                        deleteIcon: const Icon(Icons.close, size: 18.0),
                        onDeleted: () {
                          // フィルターをクリア
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => StarActivityTimelineScreen(
                                starId: widget.starId,
                                title: widget.title,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              
              // タイムライン表示
              Expanded(
                child: TimelineView(
                  items: sortedActivities.map(_createTimelineItem).toList(),
                  isLoading: false,
                  emptyMessage: 'アクティビティがありません',
                  showDividers: true,
                  groupByDate: true,
                  padding: const EdgeInsets.all(16.0),
                  emptyWidget: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.hourglass_empty,
                          size: 64.0,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          'アクティビティがありません',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64.0, color: Colors.red),
              const SizedBox(height: 16.0),
              Text('データの読み込みに失敗しました: $error'),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => ref.refresh(starActivitiesProvider(widget.starId)),
                child: const Text('再読み込み'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<StarActivity> _applySort(List<StarActivity> activities) {
    if (_sortOption == TimelineSortOption.groupedByType) {
      final grouped = <ActivityType, List<StarActivity>>{};
      for (final activity in activities) {
        grouped.putIfAbsent(activity.type, () => []).add(activity);
      }
      final sortedTypes = grouped.keys.toList()
        ..sort((a, b) => _getActivityTypeLabel(a).compareTo(_getActivityTypeLabel(b)));
      final result = <StarActivity>[];
      for (final type in sortedTypes) {
        final items = [...grouped[type]!]
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        result.addAll(items);
      }
      return result;
    }

    final sorted = [...activities];
    sorted.sort((a, b) => _sortOption == TimelineSortOption.newest
        ? b.timestamp.compareTo(a.timestamp)
        : a.timestamp.compareTo(b.timestamp));
    return sorted;
  }

  /// アクティビティをTimelineItemに変換
  TimelineItem _createTimelineItem(StarActivity activity) {
    final bool hasImage = activity.imageUrl != null && activity.imageUrl!.isNotEmpty;
    final String formattedDate = DateFormat('yyyy/MM/dd').format(activity.timestamp);
    
    return TimelineItem(
      timestamp: activity.timestamp,
      title: activity.title,
      subtitle: formattedDate,
      leading: Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          color: _getActivityColor(activity.type).withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getActivityIcon(activity.type),
          color: _getActivityColor(activity.type),
          size: 20.0,
        ),
      ),
      content: activity.description != null && activity.description!.isNotEmpty
          ? Text(
              activity.description!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      media: hasImage
          ? Image.network(
              ImageUrlBuilder.thumbnail(activity.imageUrl!),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.broken_image, color: Colors.grey),
              ),
            )
          : null,
      actions: [
        Builder(
          builder: (context) => TextButton.icon(
            onPressed: () => _showActivityDetails(context, activity),
            icon: const Icon(Icons.visibility, size: 16.0),
            label: const Text('詳細'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            ),
          ),
        ),
      ],
      onTap: () => {},
    );
  }

  /// アクティビティの詳細を表示
  void _showActivityDetails(BuildContext context, StarActivity activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ハンドル
                  Center(
                    child: Container(
                      width: 40.0,
                      height: 4.0,
                      margin: const EdgeInsets.only(bottom: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  
                  // ヘッダー
                  Row(
                    children: [
                      // アイコン
                      Container(
                        width: 50.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                          color: _getActivityColor(activity.type).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getActivityIcon(activity.type),
                          color: _getActivityColor(activity.type),
                          size: 24.0,
                        ),
                      ),
                      
                      const SizedBox(width: 16.0),
                      
                      // タイプとタイムスタンプ
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getActivityTypeLabel(activity.type),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            Text(
                              _formatDateTime(activity.timestamp),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 32.0),
                  
                  // タイトル
                  Text(
                    activity.title,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  if (activity.description != null && activity.description!.isNotEmpty) ...[
                    const SizedBox(height: 12.0),
                    Text(
                      activity.description!,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ],
                  
                  if (activity.imageUrl != null) ...[
                    const SizedBox(height: 16.0),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        ImageUrlBuilder.thumbnail(activity.imageUrl!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ],
                  
                  if (activity.details != null && activity.details!.isNotEmpty) ...[
                    const SizedBox(height: 20.0),
                    const Text(
                      '詳細情報',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activity.details!.length,
                      itemBuilder: (context, index) {
                        final entry = activity.details!.entries.elementAt(index);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Text(
                                '${entry.key}: ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Text('${entry.value}'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  
                  if (activity.actionUrl != null) ...[
                    const SizedBox(height: 24.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: URLを開く処理を実装
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('URLを開く: ${activity.actionUrl}')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 12.0,
                          ),
                        ),
                        child: const Text('コンテンツを開く'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// アクティビティタイプに基づいてアイコンを取得
  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.post:
        return Icons.post_add;
      case ActivityType.comment:
        return Icons.comment;
      case ActivityType.like:
        return Icons.favorite;
      case ActivityType.share:
        return Icons.share;
      case ActivityType.release:
        return Icons.album;
      case ActivityType.live:
        return Icons.videocam;
      case ActivityType.media:
        return Icons.photo_library;
      case ActivityType.collaboration:
        return Icons.people;
      case ActivityType.award:
        return Icons.emoji_events;
      case ActivityType.milestone:
        return Icons.flag;
      default:
        return Icons.star;
    }
  }

  /// アクティビティタイプに基づいて色を取得
  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.post:
        return Colors.blue;
      case ActivityType.comment:
        return Colors.teal;
      case ActivityType.like:
        return Colors.red;
      case ActivityType.share:
        return Colors.purple;
      case ActivityType.release:
        return Colors.green;
      case ActivityType.live:
        return Colors.orange;
      case ActivityType.media:
        return Colors.amber;
      case ActivityType.collaboration:
        return Colors.indigo;
      case ActivityType.award:
        return Colors.deepOrange;
      case ActivityType.milestone:
        return Colors.brown;
      default:
        return Colors.blueGrey;
    }
  }

  /// アクティビティタイプのラベルを取得
  String _getActivityTypeLabel(ActivityType type) {
    switch (type) {
      case ActivityType.post:
        return '投稿';
      case ActivityType.comment:
        return 'コメント';
      case ActivityType.like:
        return 'いいね';
      case ActivityType.share:
        return 'シェア';
      case ActivityType.release:
        return 'リリース';
      case ActivityType.live:
        return 'ライブ';
      case ActivityType.media:
        return 'メディア';
      case ActivityType.collaboration:
        return 'コラボレーション';
      case ActivityType.award:
        return '受賞';
      case ActivityType.milestone:
        return 'マイルストーン';
      default:
        return 'その他';
    }
  }

  /// 日時のフォーマット
  String _formatDateTime(DateTime dateTime) {
    final date = '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  /// フィルターダイアログを表示
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('アクティビティフィルター'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: ActivityType.values.map((type) {
                return ListTile(
                  leading: Icon(
                    _getActivityIcon(type),
                    color: _getActivityColor(type),
                  ),
                  title: Text(_getActivityTypeLabel(type)),
                  onTap: () {
                    Navigator.of(context).pop();
                    
                    // 選択されたタイプでフィルタリング
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => StarActivityTimelineScreen(
                          starId: widget.starId,
                          activityType: type,
                          title: widget.title,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            if (widget.activityType != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  
                  // フィルターをクリア
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => StarActivityTimelineScreen(
                        starId: widget.starId,
                        title: widget.title,
                      ),
                    ),
                  );
                },
                child: const Text('フィルターをクリア'),
              ),
          ],
        );
      },
    );
  }

  /// アクティビティタップ時の処理
  void _handleActivityTap(BuildContext context, TimelineItem item) {
    // 詳細ページに遷移するなどの処理
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('選択: ${item.title}')),
    );
    
    // TODO: 詳細画面に遷移する処理を実装
  }
} 
