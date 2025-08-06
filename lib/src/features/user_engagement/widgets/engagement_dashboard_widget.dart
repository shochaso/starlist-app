import 'package:flutter/material.dart';
import '../user_engagement_service.dart';

/// ユーザーエンゲージメントダッシュボードウィジェット
/// 
/// パフォーマンス最適化:
/// - const constructors for all static widgets
/// - Efficient widget decomposition
/// - Optimized list rendering
class EngagementDashboardWidget extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> userPreferences;
  final List<String> recentActivity;

  const EngagementDashboardWidget({
    Key? key,
    required this.userId,
    required this.userPreferences,
    required this.recentActivity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final personalizedData = UserEngagementService.getPersonalizedExperience(
      userId: userId,
      userPreferences: userPreferences,
      recentActivity: recentActivity,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ウェルカムメッセージ
          _WelcomeSection(message: personalizedData['welcomeMessage']),
          
          const SizedBox(height: 24),
          
          // 今日のタスク
          _TodaysTasksSection(tasks: personalizedData['todaysTasks']),
          
          const SizedBox(height: 24),
          
          // おすすめコンテンツ
          _FeaturedContentSection(content: personalizedData['featuredContent']),
          
          const SizedBox(height: 24),
          
          // ソーシャルアップデート
          _SocialUpdatesSection(updates: personalizedData['socialUpdates']),
        ],
      ),
    );
  }

  // 非推奨メソッド - パフォーマンス向上のため削除予定
  @deprecated
  Widget _buildWelcomeSection(String welcomeMessage) {
    return _WelcomeSection(message: welcomeMessage);
  }

  @deprecated  
  Widget _buildTodaysTasksSection(List<Map<String, dynamic>> tasks) {
    return _TodaysTasksSection(tasks: tasks);
  }

  @deprecated
  Widget _buildTaskCard(Map<String, dynamic> task) {
    return _TaskCard(task: task);
  }

  @deprecated
  Widget _buildFeaturedContentSection(List<Map<String, dynamic>> content) {
    return _FeaturedContentSection(content: content);
  }

  @deprecated
  Widget _buildFeaturedCard(Map<String, dynamic> item) {
    return _FeaturedCard(item: item);
  }

  @deprecated
  Widget _buildSocialUpdatesSection(List<Map<String, dynamic>> updates) {
    return _SocialUpdatesSection(updates: updates);
  }

  @deprecated
  Widget _buildUpdateCard(Map<String, dynamic> update) {
    return _UpdateCard(update: update);
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else {
      return '${difference.inDays}日前';
    }
  }
}

// パフォーマンス最適化されたサブウィジェットクラス

class _WelcomeSection extends StatelessWidget {
  final String message;
  
  const _WelcomeSection({required this.message});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity( 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.waving_hand,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'ウェルカム',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaysTasksSection extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  
  const _TodaysTasksSection({required this.tasks});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.today,
              color: Color(0xFF4ECDC4),
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              '今日のタスク',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // パフォーマンス最適化: ListView.builderを使用
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) => _TaskCard(task: tasks[index]),
        ),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Map<String, dynamic> task;
  
  const _TaskCard({required this.task});
  
  @override
  Widget build(BuildContext context) {
    final isCompleted = task['completed'] as bool;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCompleted ? const Color(0xFF10B981) : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? const Color(0xFF065F46) : const Color(0xFF1A1A2E),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isCompleted ? const Color(0xFF059669) : const Color(0xFF65676B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              task['reward'],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFD97706),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedContentSection extends StatelessWidget {
  final List<Map<String, dynamic>> content;
  
  const _FeaturedContentSection({required this.content});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.star,
              color: Color(0xFFFF6B6B),
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'おすすめコンテンツ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: content.length,
            cacheExtent: 500, // パフォーマンス最適化
            itemBuilder: (context, index) => _FeaturedCard(item: content[index]),
          ),
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Map<String, dynamic> item;
  
  const _FeaturedCard({required this.item});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Text(
                item['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialUpdatesSection extends StatelessWidget {
  final List<Map<String, dynamic>> updates;
  
  const _SocialUpdatesSection({required this.updates});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.people,
              color: Color(0xFF8B5CF6),
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'コミュニティ更新',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // パフォーマンス最適化: ListView.builderを使用
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: updates.length,
          itemBuilder: (context, index) => _UpdateCard(update: updates[index]),
        ),
      ],
    );
  }
}

class _UpdateCard extends StatelessWidget {
  final Map<String, dynamic> update;
  
  const _UpdateCard({required this.update});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity( 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.notifications,
              color: Color(0xFF8B5CF6),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  update['message'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(update['timestamp']),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF65676B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else {
      return '${difference.inDays}日前';
    }
  }
} 