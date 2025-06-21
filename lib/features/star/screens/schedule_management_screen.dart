import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// スケジュールのモデル
class ScheduleItem {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String type; // 'live', 'event', 'meeting', 'other'
  final String? location;
  final bool isPublic;
  final String status; // 'scheduled', 'ongoing', 'completed', 'cancelled'

  ScheduleItem({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.location,
    this.isPublic = true,
    this.status = 'scheduled',
  });
}

// スケジュール管理プロバイダー
final scheduleProvider = StateProvider<List<ScheduleItem>>((ref) {
  return [
    ScheduleItem(
      id: '1',
      title: 'iPhone 15 Pro Max YouTube動画投稿',
      description: 'iPhone 15 Pro Maxの詳細レビュー動画をYouTubeに投稿予定',
      startTime: DateTime.now().add(const Duration(hours: 2)),
      endTime: DateTime.now().add(const Duration(hours: 3)),
      type: 'youtube',
      isPublic: true,
      status: 'scheduled',
    ),
    ScheduleItem(
      id: '2',
      title: 'ファンとの質問会（Instagram Live）',
      description: 'テクノロジーに関する質問にInstagramライブでお答えします',
      startTime: DateTime.now().add(const Duration(days: 1)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 1)),
      type: 'instagram',
      isPublic: true,
      status: 'scheduled',
    ),
    ScheduleItem(
      id: '3',
      title: 'テレビ番組出演',
      description: '朝の情報番組でガジェット特集のコメンテーター出演',
      startTime: DateTime.now().add(const Duration(days: 2)),
      endTime: DateTime.now().add(const Duration(days: 2, hours: 1)),
      type: 'tv',
      location: 'テレビ局スタジオ',
      isPublic: true,
      status: 'scheduled',
    ),
    ScheduleItem(
      id: '4',
      title: 'みんなでランチタイム',
      description: '新作ハンバーガーを一緒に食べましょう！購入リスト：マクドナルド新商品セット、ポテトL、コーラM',
      startTime: DateTime.now().add(const Duration(days: 3, hours: 12)),
      endTime: DateTime.now().add(const Duration(days: 3, hours: 13)),
      type: 'meal',
      location: 'マクドナルド渋谷店',
      isPublic: true,
      status: 'scheduled',
    ),
    ScheduleItem(
      id: '5',
      title: 'コラボ企画会議',
      description: '他のクリエイターとのコラボ企画について',
      startTime: DateTime.now().add(const Duration(days: 4)),
      endTime: DateTime.now().add(const Duration(days: 4, hours: 1)),
      type: 'meeting',
      isPublic: false,
      status: 'scheduled',
    ),
  ];
});

class ScheduleManagementScreen extends ConsumerStatefulWidget {
  const ScheduleManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ScheduleManagementScreen> createState() => _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends ConsumerState<ScheduleManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schedules = ref.watch(scheduleProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          'スケジュール管理',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF4ECDC4)),
            onPressed: () => _showAddScheduleDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // タブバー
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF4ECDC4),
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.white,
              labelPadding: const EdgeInsets.symmetric(vertical: 16),
              tabs: const [
                Tab(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '今後の予定',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '進行中',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '完了済み',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // コンテンツ
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildScheduledTab(schedules),
                _buildOngoingTab(schedules),
                _buildCompletedTab(schedules),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledTab(List<ScheduleItem> schedules) {
    final scheduledItems = schedules.where((s) => s.status == 'scheduled').toList();
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: scheduledItems.length,
      itemBuilder: (context, index) {
        return _buildScheduleCard(scheduledItems[index]);
      },
    );
  }

  Widget _buildOngoingTab(List<ScheduleItem> schedules) {
    final ongoingItems = schedules.where((s) => s.status == 'ongoing').toList();
    
    if (ongoingItems.isEmpty) {
      return const Center(
        child: Text(
          '進行中の予定はありません',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: ongoingItems.length,
      itemBuilder: (context, index) {
        return _buildScheduleCard(ongoingItems[index]);
      },
    );
  }

  Widget _buildCompletedTab(List<ScheduleItem> schedules) {
    final completedItems = schedules.where((s) => s.status == 'completed').toList();
    
    if (completedItems.isEmpty) {
      return const Center(
        child: Text(
          '完了した予定はありません',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: completedItems.length,
      itemBuilder: (context, index) {
        return _buildScheduleCard(completedItems[index]);
      },
    );
  }

  Widget _buildScheduleCard(ScheduleItem schedule) {
    Color typeColor;
    IconData typeIcon;
    
    switch (schedule.type) {
      case 'youtube':
        typeColor = const Color(0xFFFF0000);
        typeIcon = Icons.video_library;
        break;
      case 'instagram':
        typeColor = const Color(0xFFE4405F);
        typeIcon = Icons.camera_alt;
        break;
      case 'tv':
        typeColor = const Color(0xFF6C5CE7);
        typeIcon = Icons.tv;
        break;
      case 'meal':
        typeColor = const Color(0xFFFF6B6B);
        typeIcon = Icons.restaurant;
        break;
      case 'meeting':
        typeColor = const Color(0xFFFFE66D);
        typeIcon = Icons.meeting_room;
        break;
      default:
        typeColor = const Color(0xFF888888);
        typeIcon = Icons.schedule;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(typeIcon, color: typeColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            schedule.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (!schedule.isPublic)
                          const Icon(
                            Icons.lock,
                            color: Color(0xFF888888),
                            size: 16,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      schedule.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Color(0xFF888888)),
                color: const Color(0xFF2A2A2A),
                onSelected: (value) => _handleScheduleAction(value, schedule),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('編集', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        Icon(Icons.copy, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('複製', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('削除', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: const Color(0xFF4ECDC4),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${_formatDateTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4ECDC4),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getTypeLabel(schedule.type),
                  style: TextStyle(
                    fontSize: 10,
                    color: typeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (schedule.location != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFF888888),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  schedule.location!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'youtube':
        return 'YouTube';
      case 'instagram':
        return 'Instagram';
      case 'tv':
        return 'テレビ出演';
      case 'meal':
        return '食事';
      case 'meeting':
        return '会議';
      default:
        return 'その他';
    }
  }

  void _showAddScheduleDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('新しいスケジュールを追加'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  void _handleScheduleAction(String action, ScheduleItem schedule) {
    switch (action) {
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('「${schedule.title}」を編集'),
            backgroundColor: const Color(0xFF4ECDC4),
          ),
        );
        break;
      case 'duplicate':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('「${schedule.title}」を複製'),
            backgroundColor: const Color(0xFF4ECDC4),
          ),
        );
        break;
      case 'delete':
        _showDeleteDialog(schedule);
        break;
    }
  }

  void _showDeleteDialog(ScheduleItem schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'スケジュールを削除',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '「${schedule.title}」を削除しますか？',
          style: const TextStyle(color: Color(0xFF888888)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'キャンセル',
              style: TextStyle(color: Color(0xFF888888)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final schedules = ref.read(scheduleProvider);
              ref.read(scheduleProvider.notifier).state = 
                  schedules.where((s) => s.id != schedule.id).toList();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('「${schedule.title}」を削除しました'),
                  backgroundColor: const Color(0xFF4ECDC4),
                ),
              );
            },
            child: const Text(
              '削除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
} 