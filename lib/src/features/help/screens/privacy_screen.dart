import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../privacy/services/privacy_service.dart';

class PrivacyScreen extends ConsumerStatefulWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends ConsumerState<PrivacyScreen> {
  Map<String, dynamic> privacySettings = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    try {
      final privacyService = ref.read(privacyServiceProvider);
      final userId = 'current_user_id'; // 実際のユーザーIDに置き換え
      
      final settings = await privacyService.getPrivacySettings(userId);
      setState(() {
        privacySettings = settings;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('プライバシー設定の読み込みに失敗しました: $e')),
      );
    }
  }

  Future<void> _updatePrivacySetting(String key, dynamic value) async {
    try {
      final privacyService = ref.read(privacyServiceProvider);
      final userId = 'current_user_id'; // 実際のユーザーIDに置き換え
      
      final updatedSettings = Map<String, dynamic>.from(privacySettings);
      updatedSettings[key] = value;
      
      await privacyService.updatePrivacySettings(userId, updatedSettings);
      
      setState(() {
        privacySettings = updatedSettings;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('プライバシー設定を更新しました')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('設定の更新に失敗しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プライバシー'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // プライバシーポリシー
                  _buildPrivacyPolicySection(),
                  const SizedBox(height: 32),

                  // プライバシー設定
                  _buildPrivacySettingsSection(),
                  const SizedBox(height: 32),

                  // データ管理
                  _buildDataManagementSection(),
                  const SizedBox(height: 32),

                  // 同意管理
                  _buildConsentManagementSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildPrivacyPolicySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.privacy_tip, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'プライバシーポリシー',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Starlistは、ユーザーのプライバシーを最優先に考えています。',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              '収集する情報：',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              '• プロフィール情報（ユーザー名、メールアドレス、プロフィール画像）\n'
              '• コンテンツ情報（投稿、いいね、コメント）\n'
              '• 利用状況（アクセスログ、操作履歴）\n'
              '• 決済情報（サブスクリプション、購入履歴）',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              '情報の利用目的：',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              '• サービスの提供・改善\n'
              '• カスタマーサポート\n'
              '• セキュリティの維持\n'
              '• 法的要件への対応',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 詳細なプライバシーポリシーを表示
                _showFullPrivacyPolicy();
              },
              child: const Text('詳細なプライバシーポリシーを見る'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.settings_outlined, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'プライバシー設定',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // プロフィール公開設定
            SwitchListTile(
              title: const Text('プロフィールを公開'),
              subtitle: const Text('他のユーザーがあなたのプロフィールを見ることができます'),
              value: privacySettings['profile_visibility'] == 'public',
              onChanged: (value) {
                _updatePrivacySetting('profile_visibility', value ? 'public' : 'private');
              },
            ),
            
            const Divider(),
            
            // データ収集設定
            SwitchListTile(
              title: const Text('データ収集を許可'),
              subtitle: const Text('サービス改善のための匿名データ収集'),
              value: privacySettings['allow_data_collection'] ?? true,
              onChanged: (value) {
                _updatePrivacySetting('allow_data_collection', value);
              },
            ),
            
            const Divider(),
            
            // 分析データ
            SwitchListTile(
              title: const Text('分析データの使用を許可'),
              subtitle: const Text('利用状況の分析とパーソナライズ'),
              value: privacySettings['allow_analytics'] ?? true,
              onChanged: (value) {
                _updatePrivacySetting('allow_analytics', value);
              },
            ),
            
            const Divider(),
            
            // マーケティングメール
            SwitchListTile(
              title: const Text('マーケティングメールを受信'),
              subtitle: const Text('新機能やキャンペーンの情報'),
              value: privacySettings['allow_marketing_emails'] ?? false,
              onChanged: (value) {
                _updatePrivacySetting('allow_marketing_emails', value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagementSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.storage, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'データ管理',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // データエクスポート
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('データをエクスポート'),
              subtitle: const Text('あなたのデータをダウンロード'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _exportUserData(),
            ),
            
            const Divider(),
            
            // データ処理活動
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('データ処理活動'),
              subtitle: const Text('データの処理履歴を確認'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showDataProcessingActivities(),
            ),
            
            const Divider(),
            
            // アカウント削除
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('アカウントを削除', style: TextStyle(color: Colors.red)),
              subtitle: const Text('すべてのデータが削除されます'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showDeleteAccountDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentManagementSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  '同意管理',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'データ処理に関する同意状況：',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            _buildConsentItem('必須データ処理', '同意済み', true, false),
            _buildConsentItem('分析データ', '同意済み', privacySettings['allow_analytics'] ?? true, true),
            _buildConsentItem('マーケティング', privacySettings['allow_marketing_emails'] ?? false ? '同意済み' : '未同意', privacySettings['allow_marketing_emails'] ?? false, true),
            
            const SizedBox(height: 16),
            const Text(
              'GDPR権利：',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              '• アクセス権：あなたのデータにアクセスする権利\n'
              '• 修正権：不正確なデータを修正する権利\n'
              '• 削除権：データの削除を要求する権利\n'
              '• ポータビリティ権：データを移転する権利',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentItem(String title, String status, bool isConsented, bool canChange) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(status, style: TextStyle(color: isConsented ? Colors.green : Colors.grey)),
              ],
            ),
          ),
          if (canChange)
            Switch(
              value: isConsented,
              onChanged: (value) {
                if (title == '分析データ') {
                  _updatePrivacySetting('allow_analytics', value);
                } else if (title == 'マーケティング') {
                  _updatePrivacySetting('allow_marketing_emails', value);
                }
              },
            ),
        ],
      ),
    );
  }

  void _showFullPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('プライバシーポリシー'),
        content: const SingleChildScrollView(
          child: Text(
            '詳細なプライバシーポリシーの内容がここに表示されます。\n\n'
            '実際の実装では、WebViewまたは詳細なテキストを表示します。',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportUserData() async {
    try {
      final privacyService = ref.read(privacyServiceProvider);
      final userId = 'current_user_id'; // 実際のユーザーIDに置き換え
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('データをエクスポート中...'),
            ],
          ),
        ),
      );
      
      final downloadUrl = await privacyService.exportUserData(userId);
      
      Navigator.pop(context); // ローディングダイアログを閉じる
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('エクスポート完了'),
          content: Text('データのエクスポートが完了しました。\n\nダウンロードURL: $downloadUrl'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context); // ローディングダイアログを閉じる
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エクスポートに失敗しました: $e')),
      );
    }
  }

  void _showDataProcessingActivities() {
    // データ処理活動を表示
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('データ処理活動'),
        content: const Text('最近のデータ処理活動がここに表示されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('アカウント削除'),
        content: const Text(
          'アカウントを削除すると、すべてのデータが完全に削除されます。\n\n'
          'この操作は取り消すことができません。本当に削除しますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除する'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      final privacyService = ref.read(privacyServiceProvider);
      final userId = 'current_user_id'; // 実際のユーザーIDに置き換え
      
      await privacyService.requestDataDeletion(userId, 'ユーザーからの削除要求');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('アカウント削除リクエストを送信しました')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('削除リクエストの送信に失敗しました: $e')),
      );
    }
  }
}
