import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/birthday_providers.dart';
import '../widgets/birthday_star_card.dart';
import '../widgets/upcoming_birthday_widget.dart';
import '../widgets/birthday_notification_card.dart';
import '../../auth/providers/user_provider.dart';
import 'birthday_settings_screen.dart';

/// 誕生日システムのホーム画面
class BirthdayHomeScreen extends ConsumerStatefulWidget {
  const BirthdayHomeScreen({super.key});

  @override
  ConsumerState<BirthdayHomeScreen> createState() => _BirthdayHomeScreenState();
}

class _BirthdayHomeScreenState extends ConsumerState<BirthdayHomeScreen> 
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
    final userAsync = ref.watch(userProvider);
    
    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('ログインが必要です')),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF1A1A1A),
          appBar: AppBar(
            title: const Text('🎂 誕生日'),
            backgroundColor: const Color(0xFF2A2A2A),
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () => _navigateToSettings(),
                icon: const Icon(Icons.settings),
                tooltip: '設定',
              ),
              IconButton(
                onPressed: () => _showInfoDialog(),
                icon: const Icon(Icons.info_outline),
                tooltip: 'ヘルプ',
              ),
              const SizedBox(width: 8),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF4ECDC4),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF4ECDC4),
              tabs: const [
                Tab(text: '今日'),
                Tab(text: '今後'),
                Tab(text: '通知'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildTodayTab(user.id),
              _buildUpcomingTab(),
              _buildNotificationsTab(user.id),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('エラー: $error')),
      ),
    );
  }

  /// 今日の誕生日タブ
  Widget _buildTodayTab(String userId) {
    final todayStarsAsync = ref.watch(birthdayStarsTodayProvider);
    final followingTodayAsync = ref.watch(followingStarsBirthdaysTodayProvider(userId));
    
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(birthdayStarsTodayProvider);
        ref.invalidate(followingStarsBirthdaysTodayProvider(userId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTodayHeader(),
            const SizedBox(height: 20),
            
            // フォロー中のスターの誕生日
            followingTodayAsync.when(
              data: (followingStars) {
                if (followingStars.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.favorite, color: Color(0xFF4ECDC4), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'フォロー中のスターの誕生日',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...followingStars.map((star) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: BirthdayStarCard(
                          star: star,
                          isFollowing: true,
                          showCelebration: true,
                        ),
                      )),
                      const SizedBox(height: 24),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => _buildLoadingSection('フォロー中のスターの誕生日'),
              error: (_, __) => const SizedBox.shrink(),
            ),
            
            // 全スターの誕生日
            todayStarsAsync.when(
              data: (todayStars) {
                if (todayStars.isEmpty) {
                  return _buildEmptyTodayState();
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cake, color: Color(0xFF4ECDC4), size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          '今日が誕生日のスター',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ECDC4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${todayStars.length}人',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...todayStars.map((star) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BirthdayStarCard(
                        star: star,
                        showCelebration: true,
                      ),
                    )),
                  ],
                );
              },
              loading: () => _buildLoadingSection('今日が誕生日のスター'),
              error: (error, _) => _buildErrorSection('データの読み込みに失敗しました'),
            ),
          ],
        ),
      ),
    );
  }

  /// 今後の誕生日タブ
  Widget _buildUpcomingTab() {
    final upcomingStarsAsync = ref.watch(upcomingBirthdayStarsProvider(30));
    
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(upcomingBirthdayStarsProvider(30));
      },
      child: upcomingStarsAsync.when(
        data: (upcomingStars) {
          if (upcomingStars.isEmpty) {
            return _buildEmptyUpcomingState();
          }
          
          // 日付でグループ化
          final groupedStars = _groupStarsByDate(upcomingStars);
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedStars.length,
            itemBuilder: (context, index) {
              final entry = groupedStars.entries.elementAt(index);
              final date = entry.key;
              final stars = entry.value;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateHeader(date),
                  const SizedBox(height: 12),
                  ...stars.map((star) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: UpcomingBirthdayWidget(star: star),
                  )),
                  const SizedBox(height: 24),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorSection('データの読み込みに失敗しました'),
      ),
    );
  }

  /// 通知タブ
  Widget _buildNotificationsTab(String userId) {
    final notificationsAsync = ref.watch(userBirthdayNotificationsProvider(userId));
    
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(userBirthdayNotificationsProvider(userId));
      },
      child: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return _buildEmptyNotificationsState();
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BirthdayNotificationCard(
                  notification: notification,
                  onTap: () => _handleNotificationTap(notification),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorSection('通知の読み込みに失敗しました'),
      ),
    );
  }

  /// 今日のヘッダー
  Widget _buildTodayHeader() {
    final today = DateTime.now();
    final formattedDate = DateFormat('M月d日(E)', 'ja_JP').format(today);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.today, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '今日は',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 日付ヘッダー
  Widget _buildDateHeader(DateTime date) {
    final formattedDate = DateFormat('M月d日(E)', 'ja_JP').format(date);
    final daysUntil = date.difference(DateTime.now()).inDays;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            formattedDate,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'あと$daysUntil日',
            style: const TextStyle(
              color: Color(0xFF4ECDC4),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// ローディングセクション
  Widget _buildLoadingSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        const Center(child: CircularProgressIndicator()),
        const SizedBox(height: 24),
      ],
    );
  }

  /// エラーセクション
  Widget _buildErrorSection(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(birthdayStarsTodayProvider);
              ref.invalidate(upcomingBirthdayStarsProvider(30));
            },
            child: const Text('再試行'),
          ),
        ],
      ),
    );
  }

  /// 空の今日状態
  Widget _buildEmptyTodayState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.cake_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  '今日誕生日のスターはいません',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '明日以降の誕生日をチェックしてみましょう！',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 空の今後状態
  Widget _buildEmptyUpcomingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.event_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  '今後30日間に誕生日のスターはいません',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'もっと多くのスターをフォローしてみませんか？',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 空の通知状態
  Widget _buildEmptyNotificationsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  '誕生日通知はありません',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'スターの誕生日通知が届くとここに表示されます',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 日付でスターをグループ化
  Map<DateTime, List<BirthdayStar>> _groupStarsByDate(List<BirthdayStar> stars) {
    final Map<DateTime, List<BirthdayStar>> grouped = {};
    
    for (final star in stars) {
      final birthdayThisYear = DateTime(
        DateTime.now().year,
        star.birthday.month,
        star.birthday.day,
      );
      
      final date = birthdayThisYear.isBefore(DateTime.now())
          ? DateTime(DateTime.now().year + 1, star.birthday.month, star.birthday.day)
          : birthdayThisYear;
      
      grouped.putIfAbsent(date, () => []).add(star);
    }
    
    // 日付順にソート
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    return Map.fromEntries(sortedEntries);
  }

  /// 設定画面への遷移
  void _navigateToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BirthdaySettingsScreen(),
      ),
    );
  }

  /// 通知タップ処理
  void _handleNotificationTap(BirthdayNotification notification) {
    // 通知を既読にする
    ref.read(birthdayNotificationActionProvider).markAsRead(notification.id);
    
    // 詳細を表示（今後実装）
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(notification.message),
        backgroundColor: const Color(0xFF4ECDC4),
      ),
    );
  }

  /// 情報ダイアログ
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          '誕生日システムについて',
          style: TextStyle(color: Colors.white),
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '誕生日機能',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '・フォロー中のスターの誕生日を確認できます\n'
                '・誕生日通知を受け取ることができます\n'
                '・お祝いメッセージを送ることができます',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16),
              Text(
                '通知設定',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '・個別にスターの通知設定を変更できます\n'
                '・事前通知（1-30日前）を設定できます\n'
                '・カスタムメッセージを設定できます',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '閉じる',
              style: TextStyle(color: Color(0xFF4ECDC4)),
            ),
          ),
        ],
      ),
    );
  }
}