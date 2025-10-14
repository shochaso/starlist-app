import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/birthday_providers.dart';
import '../widgets/birthday_setting_card.dart';
import '../../auth/providers/user_provider.dart';

/// 誕生日設定画面
class BirthdaySettingsScreen extends ConsumerStatefulWidget {
  const BirthdaySettingsScreen({super.key});

  @override
  ConsumerState<BirthdaySettingsScreen> createState() => _BirthdaySettingsScreenState();
}

class _BirthdaySettingsScreenState extends ConsumerState<BirthdaySettingsScreen> {
  DateTime? _selectedBirthday;
  bool _notificationsEnabled = true;
  
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

        final settingsAsync = ref.watch(userBirthdayNotificationSettingsProvider(user.id));

        return Scaffold(
          backgroundColor: const Color(0xFF1A1A1A),
          appBar: AppBar(
            title: const Text('誕生日設定'),
            backgroundColor: const Color(0xFF2A2A2A),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: settingsAsync.when(
            data: (settings) => _buildSettingsContent(user.id, settings),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _buildErrorContent(),
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

  Widget _buildSettingsContent(String userId, List<BirthdayNotificationSetting> settings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 自分の誕生日設定
          _buildPersonalBirthdaySection(userId),
          const SizedBox(height: 32),
          
          // フォロー中のスターの通知設定
          _buildFollowingStarsSection(settings),
          const SizedBox(height: 32),
          
          // 全体設定
          _buildGlobalSettingsSection(),
        ],
      ),
    );
  }

  /// 個人の誕生日設定セクション
  Widget _buildPersonalBirthdaySection(String userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🎂 あなたの誕生日',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: Column(
            children: [
              // 誕生日選択
              InkWell(
                onTap: () => _selectBirthday(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF333333)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cake,
                        color: Color(0xFF4ECDC4),
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '誕生日',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedBirthday != null
                                  ? '${_selectedBirthday!.month}月${_selectedBirthday!.day}日'
                                  : '未設定',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 通知設定
              Row(
                children: [
                  const Icon(
                    Icons.notifications,
                    color: Color(0xFF4ECDC4),
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '誕生日通知を受け取る',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'フォロー中のスターの誕生日通知',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    activeThumbColor: const Color(0xFF4ECDC4),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // 保存ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _saveBirthdaySettings(userId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '設定を保存',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// フォロー中のスター設定セクション
  Widget _buildFollowingStarsSection(List<BirthdayNotificationSetting> settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '⭐ フォロー中のスター',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (settings.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'フォロー中のスターがいません',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'スターをフォローして誕生日通知を受け取りましょう',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...settings.map((setting) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: BirthdaySettingCard(
              setting: setting,
              onSettingChanged: (newSetting) => _updateNotificationSetting(newSetting),
            ),
          )),
      ],
    );
  }

  /// 全体設定セクション
  Widget _buildGlobalSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '⚙️ 全体設定',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: Column(
            children: [
              _buildSettingItem(
                icon: Icons.schedule,
                title: '事前通知',
                subtitle: '誕生日の何日前に通知するか',
                onTap: () => _showAdvanceNotificationDialog(),
              ),
              const SizedBox(height: 16),
              _buildSettingItem(
                icon: Icons.volume_up,
                title: '通知音',
                subtitle: '誕生日通知の音設定',
                onTap: () => _showSoundSettings(),
              ),
              const SizedBox(height: 16),
              _buildSettingItem(
                icon: Icons.help_outline,
                title: 'ヘルプ',
                subtitle: '誕生日機能の使い方',
                onTap: () => _showHelpDialog(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 設定項目ウィジェット
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF4ECDC4),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// エラーコンテンツ
  Widget _buildErrorContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            '設定の読み込みに失敗しました',
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// 誕生日選択
  Future<void> _selectBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4ECDC4),
              surface: Color(0xFF2A2A2A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  /// 誕生日設定保存
  Future<void> _saveBirthdaySettings(String userId) async {
    if (_selectedBirthday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('誕生日を選択してください'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await ref.read(birthdaySettingActionProvider).updateUserBirthday(
        userId,
        _selectedBirthday,
        BirthdayVisibility.followers,
        _notificationsEnabled,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('設定を保存しました'),
            backgroundColor: Color(0xFF4ECDC4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 通知設定更新
  Future<void> _updateNotificationSetting(BirthdayNotificationSetting setting) async {
    // 実装予定: 個別スターの通知設定更新
  }

  /// 事前通知ダイアログ
  void _showAdvanceNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          '事前通知設定',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '誕生日の何日前に通知を受け取りますか？',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'キャンセル',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '設定',
              style: TextStyle(color: Color(0xFF4ECDC4)),
            ),
          ),
        ],
      ),
    );
  }

  /// 音設定
  void _showSoundSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('音設定は開発中です'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  /// ヘルプダイアログ
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          '誕生日機能について',
          style: TextStyle(color: Colors.white),
        ),
        content: const SingleChildScrollView(
          child: Text(
            '• フォロー中のスターの誕生日を確認できます\n'
            '• 誕生日当日や事前に通知を受け取れます\n'
            '• 個別にスターごとの通知設定が可能です\n'
            '• カスタムメッセージを設定できます',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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