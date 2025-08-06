import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/sns_verification_service.dart';
import '../../../models/sns_verification.dart';
import '../../../widgets/loading_overlay.dart';

/// SNS認証画面
class SNSVerificationScreen extends ConsumerStatefulWidget {
  final String userId;
  final String userName;

  const SNSVerificationScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  ConsumerState<SNSVerificationScreen> createState() => _SNSVerificationScreenState();
}

class _SNSVerificationScreenState extends ConsumerState<SNSVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountHandleController = TextEditingController();
  final _accountUrlController = TextEditingController();
  
  SNSPlatform _selectedPlatform = SNSPlatform.youtube;
  bool _isLoading = false;
  List<SNSVerification> _userVerifications = [];
  SNSVerificationResult? _currentVerificationResult;

  @override
  void initState() {
    super.initState();
    _loadUserVerifications();
  }

  @override
  void dispose() {
    _accountHandleController.dispose();
    _accountUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SNSアカウント認証'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIntroSection(),
                const SizedBox(height: 30),
                _buildSNSSelectionSection(),
                const SizedBox(height: 30),
                _buildAccountInputSection(),
                const SizedBox(height: 30),
                if (_currentVerificationResult != null) ...[
                  _buildVerificationStatusSection(),
                  const SizedBox(height: 30),
                ],
                _buildExistingVerificationsSection(),
                const SizedBox(height: 40),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 説明セクション
  Widget _buildIntroSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user, color: Colors.blue[600]),
              const SizedBox(width: 8),
              Text(
                'SNSアカウント認証',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.userName}様のSNSアカウントの所有権を確認します。',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          const Text(
            '手順：',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildStepList([
            'SNSプラットフォームを選択',
            'アカウント情報を入力',
            '認証コードを取得',
            'SNSプロフィールに認証コードを追加',
            '所有権確認を実行',
          ]),
        ],
      ),
    );
  }

  /// 手順リスト
  Widget _buildStepList(List<String> steps) {
    return Column(
      children: steps.map((step) {
        final index = steps.indexOf(step) + 1;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  step,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// SNSプラットフォーム選択セクション
  Widget _buildSNSSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. SNSプラットフォーム選択',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: SNSPlatform.values.length,
          itemBuilder: (context, index) {
            final platform = SNSPlatform.values[index];
            final isSelected = _selectedPlatform == platform;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPlatform = platform;
                  _accountUrlController.text = platform.urlPrefix;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Color(platform.primaryColor).withOpacity(0.1) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Color(platform.primaryColor) : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Color(platform.primaryColor),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        platform.displayName,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Color(platform.primaryColor) : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// アカウント入力セクション
  Widget _buildAccountInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. アカウント情報入力',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // アカウントハンドル
        TextFormField(
          controller: _accountHandleController,
          decoration: InputDecoration(
            labelText: 'アカウントハンドル *',
            hintText: _getHandleHint(),
            prefixText: _getHandlePrefix(),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: _showHandleHelp,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'アカウントハンドルを入力してください';
            }
            return null;
          },
          onChanged: (value) {
            _accountUrlController.text = _selectedPlatform.urlPrefix + value;
          },
        ),
        const SizedBox(height: 16),
        
        // アカウントURL
        TextFormField(
          controller: _accountUrlController,
          decoration: const InputDecoration(
            labelText: 'アカウントURL *',
            hintText: 'https://...',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.link),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'アカウントURLを入力してください';
            }
            if (!Uri.tryParse(value)?.hasAbsolutePath == true) {
              return '正しいURLを入力してください';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 認証ステータスセクション
  Widget _buildVerificationStatusSection() {
    final result = _currentVerificationResult!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: result.success ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result.success ? Colors.green[300]! : Colors.orange[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.success ? Icons.check_circle : Icons.schedule,
                color: result.success ? Colors.green[600] : Colors.orange[600],
              ),
              const SizedBox(width: 8),
              Text(
                result.success ? '認証完了' : '認証コード取得完了',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: result.success ? Colors.green[600] : Colors.orange[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (!result.success && result.verificationCode != null) ...[
            Text(
              result.message ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            
            // 認証コード表示
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '認証コード:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          result.verificationCode!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: result.verificationCode!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('認証コードをコピーしました')),
                          );
                        },
                        icon: const Icon(Icons.copy),
                        iconSize: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // プロフィール編集手順
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '次の手順:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. ${_selectedPlatform.displayName}のプロフィール説明欄に上記の認証コードを追加してください',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '2. 保存後、下の「所有権確認」ボタンをクリックしてください',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _openSNSProfile(),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: Text('${_selectedPlatform.displayName}を開く'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(_selectedPlatform.primaryColor),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else if (result.success) ...[
            Text(
              result.message ?? 'SNSアカウントの所有権が確認されました',
              style: const TextStyle(fontSize: 14),
            ),
            if (result.followerCount != null) ...[
              const SizedBox(height: 8),
              Text(
                '${_selectedPlatform.followerLabel}: ${_formatNumber(result.followerCount!)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// 既存認証一覧セクション
  Widget _buildExistingVerificationsSection() {
    if (_userVerifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '認証済みアカウント',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        ...(_userVerifications.map((verification) => _buildVerificationCard(verification)).toList()),
      ],
    );
  }

  /// 認証カード
  Widget _buildVerificationCard(SNSVerification verification) {
    final isVerified = verification.ownershipVerified;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isVerified ? Colors.green[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isVerified ? Colors.green[300]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(verification.platform.primaryColor),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  verification.platform.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  verification.accountHandle,
                  style: const TextStyle(fontSize: 13),
                ),
                if (verification.followerCount != null)
                  Text(
                    '${verification.platform.followerLabel}: ${_formatNumber(verification.followerCount!)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
          Icon(
            isVerified ? Icons.verified : Icons.schedule,
            color: isVerified ? Colors.green[600] : Colors.orange[600],
          ),
        ],
      ),
    );
  }

  /// アクションボタン
  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_currentVerificationResult == null || !_currentVerificationResult!.success) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canStartVerification() ? _startSNSVerification : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _currentVerificationResult == null ? 'SNS連携を開始' : '別のアカウントを追加',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
        
        if (_currentVerificationResult != null && !_currentVerificationResult!.success) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _verifyOwnership,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '所有権確認',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// ハンドルヒント取得
  String _getHandleHint() {
    switch (_selectedPlatform) {
      case SNSPlatform.youtube:
        return 'channel_name';
      case SNSPlatform.instagram:
        return 'username';
      case SNSPlatform.tiktok:
        return 'username';
      case SNSPlatform.twitter:
        return 'username';
    }
  }

  /// ハンドルプレフィックス取得
  String _getHandlePrefix() {
    switch (_selectedPlatform) {
      case SNSPlatform.youtube:
        return '@';
      case SNSPlatform.instagram:
        return '';
      case SNSPlatform.tiktok:
        return '@';
      case SNSPlatform.twitter:
        return '@';
    }
  }

  /// ハンドルヘルプ表示
  void _showHandleHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_selectedPlatform.displayName} アカウントハンドル'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_selectedPlatform.displayName}のアカウントハンドルまたはユーザー名を入力してください。'),
            const SizedBox(height: 12),
            const Text('例:'),
            Text('URL: ${_selectedPlatform.urlPrefix}example'),
            const Text('ハンドル: example'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  /// SNSプロフィールを開く
  Future<void> _openSNSProfile() async {
    final url = _accountUrlController.text.trim();
    if (url.isNotEmpty && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  /// 数値フォーマット
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  /// 認証開始可能かチェック
  bool _canStartVerification() {
    return !_isLoading && 
           _accountHandleController.text.isNotEmpty &&
           _accountUrlController.text.isNotEmpty;
  }

  /// ユーザーの認証一覧を読み込み
  Future<void> _loadUserVerifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final verifications = await SNSVerificationService.getUserSNSVerifications(widget.userId);
      setState(() {
        _userVerifications = verifications;
      });
    } catch (e) {
      _showErrorSnackBar('認証一覧の読み込みに失敗しました');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// SNS認証を開始
  Future<void> _startSNSVerification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await SNSVerificationService.startSNSVerification(
        userId: widget.userId,
        platform: _selectedPlatform,
        accountHandle: _accountHandleController.text.trim(),
        accountUrl: _accountUrlController.text.trim(),
      );

      setState(() {
        _currentVerificationResult = result;
      });

      if (result.success) {
        _showSuccessSnackBar(result.message ?? 'SNS連携を開始しました');
      } else {
        _showErrorSnackBar(result.error ?? 'SNS連携の開始に失敗しました');
      }
    } catch (e) {
      _showErrorSnackBar('エラーが発生しました: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 所有権確認
  Future<void> _verifyOwnership() async {
    if (_currentVerificationResult?.verificationId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await SNSVerificationService.verifyOwnership(
        _currentVerificationResult!.verificationId!,
      );

      setState(() {
        _currentVerificationResult = result;
      });

      if (result.success) {
        _showSuccessSnackBar(result.message ?? '所有権確認が完了しました');
        await _loadUserVerifications(); // 一覧を更新
      } else {
        _showErrorSnackBar(result.error ?? '所有権確認に失敗しました');
      }
    } catch (e) {
      _showErrorSnackBar('エラーが発生しました: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 成功スナックバー
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// エラースナックバー
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
} 