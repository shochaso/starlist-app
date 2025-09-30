import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../src/providers/theme_provider_enhanced.dart';
import '../features/auth/screens/star_signup_screen.dart';
import '../features/auth/screens/star_email_signup_screen.dart';
import '../data/test_accounts_data.dart';
import 'test_account_switcher_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'starlist_main_screen.dart';

/// ログイン状態確認画面
class LoginStatusScreen extends ConsumerWidget {
  const LoginStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        title: Text(
          'ログイン状態確認',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(currentUser, isDark),
              const SizedBox(height: 30),
              _buildActionButtons(context, ref, isDark),
              const SizedBox(height: 30),
              _buildTestFlows(context, ref, isDark),
            ],
          ),
        ),
      ),
    );
  }

  /// ステータスカード
  Widget _buildStatusCard(UserInfo? currentUser, bool isDark) {
    return Card(
      elevation: 4,
      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  currentUser != null ? Icons.person : Icons.person_off,
                  color: currentUser != null ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '現在のログイン状態',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (currentUser != null) ...[
              _buildInfoRow('ユーザー名', currentUser.name, isDark),
              _buildInfoRow('メールアドレス', currentUser.email, isDark),
              _buildInfoRow('役割', currentUser.role.name, isDark),
              _buildInfoRow('プラン', currentUser.planDisplayName, isDark),
              _buildInfoRow('認証済み', currentUser.isVerified ? 'はい' : 'いいえ', isDark),
            ] else ...[
              Text(
                'ログインしていません',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey : Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// アクションボタン
  Widget _buildActionButtons(BuildContext context, WidgetRef ref, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '認証アクション',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionButton(
              context,
              'ログアウト',
              Icons.logout,
              Colors.red,
              () => _logout(context, ref),
              isDark,
            ),
            _buildActionButton(
              context,
              'ログイン',
              Icons.login,
              Colors.blue,
              () => _login(context, ref),
              isDark,
            ),
            _buildActionButton(
              context,
              'テストユーザー設定',
              Icons.person_add,
              Colors.blue,
              () => _showTestUserDialog(context, ref),
              isDark,
            ),
            _buildActionButton(
              context,
              '認証状態リセット',
              Icons.refresh,
              Colors.orange,
              () => _resetAuthState(ref),
              isDark,
            ),
          ],
        ),
      ],
    );
  }

  /// テストフロー
  Widget _buildTestFlows(BuildContext context, WidgetRef ref, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '認証フローテスト',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionButton(
              context,
              'スター登録',
              Icons.star,
              Colors.amber,
              () => _navigateToStarSignup(context),
              isDark,
            ),
            _buildActionButton(
              context,
              'メール登録',
              Icons.email,
              Colors.teal,
              () => _navigateToEmailSignup(context),
              isDark,
            ),
            _buildActionButton(
              context,
              'テストアカウント切り替え',
              Icons.swap_horiz,
              Colors.purple,
              () => _navigateToTestAccountSwitcher(context),
              isDark,
            ),
          ],
        ),
      ],
    );
  }

  /// 情報行
  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// アクションボタン
  Widget _buildActionButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
    bool isDark,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// ログアウト
  void _logout(BuildContext context, WidgetRef ref) {
    // 新しいStateNotifierProviderを使用してログアウト
    ref.read(currentUserProvider.notifier).logout();
    
    // ユーザーモードをリセット
    ref.read(userModeProvider.notifier).setMode(UserMode.fan);
    
    // テストプランをリセット
    ref.read(testPlanProvider.notifier).state = null;
    
    // ユーザー役割をリセット
    ref.read(userRoleToggleProvider.notifier).state = UserRole.fan;
    
    // 選択されたタブをリセット
    ref.read(selectedTabProvider.notifier).state = 0;
    ref.read(selectedDataTypeProvider.notifier).state = null;
    ref.read(selectedDrawerPageProvider.notifier).state = null;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ログアウトしました'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// ログイン
  void _login(BuildContext context, WidgetRef ref) {
    ref.read(currentUserProvider.notifier).login();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ログインしました'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// ログアウト状態を永続化
  Future<void> _saveLogoutState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_out', true);
      await prefs.setString('logout_timestamp', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('ログアウト状態の保存に失敗: $e');
    }
  }

  /// ログイン状態を永続化
  Future<void> _saveLoginState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_out', false);
      await prefs.remove('logout_timestamp');
    } catch (e) {
      debugPrint('ログイン状態の保存に失敗: $e');
    }
  }

  /// テストユーザーダイアログ
  void _showTestUserDialog(BuildContext context, WidgetRef ref) {
    final themeState = ref.read(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        title: Text(
          'テストユーザーを選択',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTestUserOption(
              context,
              ref,
              '花山瑞樹（スター）',
              const UserInfo(
                id: 'star-1',
                name: '花山瑞樹',
                email: 'mizuki@starlist.com',
                role: UserRole.star,
                isVerified: true,
              ),
              isDark,
            ),
            const SizedBox(height: 8),
            _buildTestUserOption(
              context,
              ref,
              '無料ファン',
              const UserInfo(
                id: 'fan-free',
                name: '無料ファン',
                email: 'free@example.com',
                role: UserRole.fan,
              ),
              isDark,
            ),
            const SizedBox(height: 8),
            _buildTestUserOption(
              context,
              ref,
              'プレミアムファン',
              const UserInfo(
                id: 'fan-premium',
                name: 'プレミアムファン',
                email: 'premium@example.com',
                role: UserRole.fan,
              ),
              isDark,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'キャンセル',
              style: TextStyle(color: isDark ? Colors.grey : Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  /// テストユーザーオプション
  Widget _buildTestUserOption(
    BuildContext context,
    WidgetRef ref,
    String title,
    UserInfo userInfo,
    bool isDark,
  ) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      ),
      onTap: () {
        ref.read(currentUserProvider.notifier).state = userInfo;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title に設定しました'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  /// 認証状態リセット
  void _resetAuthState(WidgetRef ref) {
    ref.read(currentUserProvider.notifier).state = const UserInfo(
      id: '',
      name: '',
      email: '',
      role: UserRole.fan,
    );
  }

  /// スター登録画面に遷移
  void _navigateToStarSignup(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const StarSignupScreen(),
      ),
    );
  }

  /// メール登録画面に遷移
  void _navigateToEmailSignup(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const StarEmailSignupScreen(),
      ),
    );
  }

  /// テストアカウント切り替え画面に遷移
  void _navigateToTestAccountSwitcher(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TestAccountSwitcherScreen(),
      ),
    );
  }
} 