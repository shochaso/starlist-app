import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/theme_provider.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  // 通知設定の状態管理
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  
  // カテゴリ別通知設定
  bool _newContentNotifications = true;
  bool _liveStreamNotifications = true;
  bool _messageNotifications = true;
  bool _followNotifications = true;
  bool _likeNotifications = false;
  bool _commentNotifications = true;
  bool _planUpdateNotifications = true;
  bool _paymentNotifications = true;
  bool _systemNotifications = true;
  
  // 配信時間設定
  bool _quietHoursEnabled = false;
  TimeOfDay _quietStartTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEndTime = const TimeOfDay(hour: 8, minute: 0);
  
  // 通知頻度設定
  String _notificationFrequency = 'realtime';

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '通知設定',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () => _resetToDefaults(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 通知方法設定
              _buildSection(
                '通知方法',
                [
                  _buildSwitchItem(
                    Icons.notifications_active,
                    'プッシュ通知',
                    'アプリからの通知を受け取る',
                    _pushNotifications,
                    (value) => setState(() => _pushNotifications = value),
                  ),
                  _buildSwitchItem(
                    Icons.email,
                    'メール通知',
                    '重要な更新をメールで受け取る',
                    _emailNotifications,
                    (value) => setState(() => _emailNotifications = value),
                  ),
                  _buildSwitchItem(
                    Icons.sms,
                    'SMS通知',
                    '緊急の通知をSMSで受け取る',
                    _smsNotifications,
                    (value) => setState(() => _smsNotifications = value),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // コンテンツ関連通知
              _buildSection(
                'コンテンツ通知',
                [
                  _buildSwitchItem(
                    Icons.fiber_new,
                    '新着コンテンツ',
                    'フォロー中のスターの新しいコンテンツ',
                    _newContentNotifications,
                    (value) => setState(() => _newContentNotifications = value),
                  ),
                  _buildSwitchItem(
                    Icons.live_tv,
                    'ライブ配信',
                    'ライブ配信の開始通知',
                    _liveStreamNotifications,
                    (value) => setState(() => _liveStreamNotifications = value),
                  ),
                  _buildSwitchItem(
                    Icons.chat_bubble,
                    'メッセージ',
                    'スターからの新しいメッセージ',
                    _messageNotifications,
                    (value) => setState(() => _messageNotifications = value),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // ソーシャル通知
              _buildSection(
                'ソーシャル通知',
                [
                  _buildSwitchItem(
                    Icons.person_add,
                    'フォロー',
                    '新しいフォロワーやフォロー返し',
                    _followNotifications,
                    (value) => setState(() => _followNotifications = value),
                  ),
                  _buildSwitchItem(
                    Icons.favorite,
                    'いいね',
                    'コンテンツへのいいねやリアクション',
                    _likeNotifications,
                    (value) => setState(() => _likeNotifications = value),
                  ),
                  _buildSwitchItem(
                    Icons.comment,
                    'コメント',
                    'コンテンツへのコメントや返信',
                    _commentNotifications,
                    (value) => setState(() => _commentNotifications = value),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // システム通知
              _buildSection(
                'システム通知',
                [
                  _buildSwitchItem(
                    Icons.monetization_on,
                    'プラン更新',
                    'サブスクリプションプランの更新情報',
                    _planUpdateNotifications,
                    (value) => setState(() => _planUpdateNotifications = value),
                  ),
                  _buildSwitchItem(
                    Icons.payment,
                    '支払い情報',
                    '支払いや請求に関する通知',
                    _paymentNotifications,
                    (value) => setState(() => _paymentNotifications = value),
                  ),
                  _buildSwitchItem(
                    Icons.system_update,
                    'システム更新',
                    'アプリのアップデートやメンテナンス',
                    _systemNotifications,
                    (value) => setState(() => _systemNotifications = value),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // 通知頻度設定
              _buildSection(
                '通知頻度',
                [
                  _buildDropdownItem(
                    Icons.schedule,
                    '通知頻度',
                    '通知を受け取る頻度を設定',
                    _notificationFrequency,
                    {
                      'realtime': 'リアルタイム',
                      'hourly': '1時間ごと',
                      'daily': '1日1回',
                      'weekly': '週1回',
                    },
                    (value) => setState(() => _notificationFrequency = value!),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // おやすみモード
              _buildSection(
                'おやすみモード',
                [
                  _buildSwitchItem(
                    Icons.bedtime,
                    'おやすみモード',
                    '指定した時間帯は通知を停止',
                    _quietHoursEnabled,
                    (value) => setState(() => _quietHoursEnabled = value),
                  ),
                  if (_quietHoursEnabled) ...[
                    _buildTimePickerItem(
                      Icons.bedtime,
                      '開始時刻',
                      _quietStartTime,
                      (time) => setState(() => _quietStartTime = time),
                    ),
                    _buildTimePickerItem(
                      Icons.wb_sunny,
                      '終了時刻',
                      _quietEndTime,
                      (time) => setState(() => _quietEndTime = time),
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 32),
              
              // 保存ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _saveSettings(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '設定を保存',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchItem(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4ECDC4), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF888888) : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            thumbColor: MaterialStateProperty.resolveWith<Color?>(
              (states) => states.contains(MaterialState.selected)
                  ? const Color(0xFF4ECDC4)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem(
    IconData icon,
    String title,
    String subtitle,
    String value,
    Map<String, String> options,
    Function(String?) onChanged,
  ) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4ECDC4), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF888888) : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            underline: Container(),
            items: options.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerItem(
    IconData icon,
    String title,
    TimeOfDay time,
    Function(TimeOfDay) onChanged,
  ) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4ECDC4), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _selectTime(time, onChanged),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF4ECDC4).withOpacity( 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                time.format(context),
                style: const TextStyle(
                  color: Color(0xFF4ECDC4),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(TimeOfDay currentTime, Function(TimeOfDay) onChanged) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );
    if (picked != null && picked != currentTime) {
      onChanged(picked);
    }
  }

  void _resetToDefaults() {
    setState(() {
      _pushNotifications = true;
      _emailNotifications = true;
      _smsNotifications = false;
      _newContentNotifications = true;
      _liveStreamNotifications = true;
      _messageNotifications = true;
      _followNotifications = true;
      _likeNotifications = false;
      _commentNotifications = true;
      _planUpdateNotifications = true;
      _paymentNotifications = true;
      _systemNotifications = true;
      _quietHoursEnabled = false;
      _notificationFrequency = 'realtime';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('設定をデフォルトに戻しました'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black).withOpacity( 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBottomNavItem(Icons.home, 'ホーム', () {
                context.go('/home');
              }),
              _buildBottomNavItem(Icons.search, '検索', () {
                context.go('/home');
              }),
              _buildBottomNavItem(Icons.notifications, '通知', null, isSelected: true),
              _buildBottomNavItem(Icons.star, 'マイリスト', () {
                context.go('/home');
              }),
              _buildBottomNavItem(Icons.person, 'マイページ', () {
                context.go('/home');
              }),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBottomNavItem(IconData icon, String label, VoidCallback? onTap, {bool isSelected = false}) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected 
                    ? const Color(0xFF4ECDC4) 
                    : (isDark ? Colors.white54 : const Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isSelected 
                      ? const Color(0xFF4ECDC4) 
                      : (isDark ? Colors.white54 : const Color(0xFF9CA3AF)),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSettings() {
    // ここで実際の設定保存処理を実装
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('通知設定を保存しました'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
    
    Navigator.pop(context);
  }
}
