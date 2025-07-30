import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/test_accounts_data.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';

class TestAccountSwitcherScreen extends ConsumerStatefulWidget {
  const TestAccountSwitcherScreen({super.key});

  @override
  ConsumerState<TestAccountSwitcherScreen> createState() =>
      _TestAccountSwitcherScreenState();
}

class _TestAccountSwitcherScreenState
    extends ConsumerState<TestAccountSwitcherScreen> {
  String? selectedUserId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('テストアカウント切り替え'),
        backgroundColor: const Color(0xFF4ECDC4),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: TestAccountsData.allTestUsers.length,
        itemBuilder: (context, index) {
          final account = TestAccountsData.allTestUsers[index];
          final isSelected = selectedUserId == account.id;

          return _buildAccountCard(account, isSelected);
        },
      ),
    );
  }

  Widget _buildAccountCard(User account, bool isSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: Color(0xFF4ECDC4), width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getAccountColor(account),
                  child: Text(
                    account.name.isNotEmpty ? account.name[0] : '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        account.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getAccountColor(account).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getAccountTypeText(account),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getAccountColor(account),
                ),
              ),
            ),
            // フォロー情報の表示
            if (account.fanPlanType != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'フォロー中: ${TestAccountsData.getFollowingListForPlan(account.fanPlanType).length}人',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.star_outline,
                    size: 16,
                    color: Colors.amber[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '花山瑞樹を含む',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedUserId =
                            selectedUserId == account.id ? null : account.id;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF4ECDC4)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isSelected ? '選択中' : '役割切り替え',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _performTestLogin(context, account),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('テストログイン'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _performTestLogin(BuildContext context, User user) {
    // User オブジェクトから UserInfo オブジェクトを生成
    final userInfo = UserInfo(
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.type == UserType.star ? UserRole.star : UserRole.fan,
      fanPlanType: user.fanPlanType,
      // その他のプロパティも必要に応じてマッピング
    );
    ref.read(currentUserProvider.notifier).state = userInfo;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${user.name}としてログインしました！'),
        backgroundColor: const Color(0xFF4ECDC4),
      ),
    );
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  Color _getAccountColor(User account) {
    if (account.type == UserType.star) {
      return Colors.amber;
    }

    switch (account.fanPlanType) {
      case FanPlanType.free:
        return Colors.grey;
      case FanPlanType.light:
        return Colors.blue;
      case FanPlanType.standard:
        return Colors.green;
      case FanPlanType.premium:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getAccountTypeText(User account) {
    if (account.type == UserType.star) {
      return 'スター';
    }

    switch (account.fanPlanType) {
      case FanPlanType.free:
        return '無料ファン';
      case FanPlanType.light:
        return 'ライトファン';
      case FanPlanType.standard:
        return 'スタンダードファン';
      case FanPlanType.premium:
        return 'プレミアムファン';
      default:
        return 'ファン';
    }
  }
}
