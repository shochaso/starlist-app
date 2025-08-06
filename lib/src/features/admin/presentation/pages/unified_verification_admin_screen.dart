import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/services/unified_verification_service.dart';
import '../../../core/presentation/widgets/loading_overlay.dart';
import '../../../core/presentation/widgets/custom_button.dart';

/// 統合認証管理画面
class UnifiedVerificationAdminScreen extends ConsumerStatefulWidget {
  const UnifiedVerificationAdminScreen({super.key});

  @override
  ConsumerState<UnifiedVerificationAdminScreen> createState() => _UnifiedVerificationAdminScreenState();
}

class _UnifiedVerificationAdminScreenState extends ConsumerState<UnifiedVerificationAdminScreen> {
  final UnifiedVerificationService _verificationService = UnifiedVerificationService();
  
  List<Map<String, dynamic>> _pendingVerifications = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadPendingVerifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('統合認証管理'),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingVerifications,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return _buildErrorContent();
    }

    return Column(
      children: [
        _buildFilterSection(),
        Expanded(
          child: _buildVerificationList(),
        ),
      ],
    );
  }

  /// フィルターセクション
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          const Text('フィルター: ', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: _selectedFilter,
            onChanged: (value) {
              setState(() {
                _selectedFilter = value!;
              });
            },
            items: const [
              DropdownMenuItem(value: 'all', child: Text('全て')),
              DropdownMenuItem(value: 'pending_review', child: Text('審査待ち')),
              DropdownMenuItem(value: 'awaiting_ekyc', child: Text('eKYC待ち')),
              DropdownMenuItem(value: 'awaiting_parental_consent', child: Text('親権者同意待ち')),
              DropdownMenuItem(value: 'awaiting_sns_verification', child: Text('SNS認証待ち')),
            ],
          ),
          const Spacer(),
          Text('${_getFilteredVerifications().length}件'),
        ],
      ),
    );
  }

  /// 認証一覧
  Widget _buildVerificationList() {
    final filteredVerifications = _getFilteredVerifications();

    if (filteredVerifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '認証待ちのユーザーはいません',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredVerifications.length,
      itemBuilder: (context, index) {
        final verification = filteredVerifications[index];
        return _buildVerificationCard(verification);
      },
    );
  }

  /// 認証カード
  Widget _buildVerificationCard(Map<String, dynamic> verification) {
    final userId = verification['user_id'] as String;
    final userName = verification['name'] as String? ?? '不明';
    final userEmail = verification['email'] as String? ?? '';
    final legalName = verification['legal_name'] as String? ?? '';
    final birthDate = verification['birth_date'] as String?;
    final isMinor = verification['is_minor'] as bool? ?? false;
    final status = verification['verification_status_final'] as String? ?? '';
    final registrationDate = verification['registration_date'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: ExpansionTile(
        title: Text(
          userName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('ステータス: ${_getStatusDisplayName(status)}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfoSection(verification),
                const SizedBox(height: 16),
                _buildProgressSection(verification),
                const SizedBox(height: 16),
                _buildActionSection(userId, status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ユーザー情報セクション
  Widget _buildUserInfoSection(Map<String, dynamic> verification) {
    final legalName = verification['legal_name'] as String? ?? '';
    final birthDate = verification['birth_date'] as String?;
    final isMinor = verification['is_minor'] as bool? ?? false;
    final agencyName = verification['agency_name'] as String? ?? '';
    final termsAgreedAt = verification['terms_agreed_at'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ユーザー情報',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('法的氏名', legalName.isNotEmpty ? legalName : '未設定'),
        if (birthDate != null) _buildInfoRow('生年月日', birthDate),
        _buildInfoRow('未成年者', isMinor ? 'はい' : 'いいえ'),
        if (agencyName.isNotEmpty) _buildInfoRow('事務所名', agencyName),
        if (termsAgreedAt != null) _buildInfoRow('規約同意日', termsAgreedAt),
      ],
    );
  }

  /// 進捗セクション
  Widget _buildProgressSection(Map<String, dynamic> verification) {
    final termsAgreed = verification['terms_agreement_completed'] as bool? ?? false;
    final ekycCompleted = verification['ekyc_completed'] as bool? ?? false;
    final parentalConsentRequired = verification['parental_consent_required'] as bool? ?? false;
    final parentalConsentCompleted = verification['parental_consent_completed'] as bool? ?? false;
    final snsCompleted = verification['sns_verification_completed'] as bool? ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '認証進捗',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildProgressRow('事務所規約同意', termsAgreed),
        _buildProgressRow('eKYC', ekycCompleted),
        if (parentalConsentRequired) _buildProgressRow('親権者同意', parentalConsentCompleted),
        _buildProgressRow('SNS認証', snsCompleted),
      ],
    );
  }

  /// アクションセクション
  Widget _buildActionSection(String userId, String status) {
    if (status == 'pending_review') {
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              text: '承認',
              onPressed: () => _approveUser(userId),
              backgroundColor: Colors.green,
              icon: Icons.check,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              text: '拒否',
              onPressed: () => _rejectUser(userId),
              backgroundColor: Colors.red,
              icon: Icons.close,
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  /// 情報行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  /// 進捗行
  Widget _buildProgressRow(String label, bool completed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: completed ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          Text(
            completed ? '完了' : '未完了',
            style: TextStyle(
              color: completed ? Colors.green : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// エラーコンテンツ
  Widget _buildErrorContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'エラーが発生しました',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: '再試行',
              onPressed: _loadPendingVerifications,
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  /// 認証待ちユーザーを読み込み
  Future<void> _loadPendingVerifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final verifications = await _verificationService.getPendingVerifications();
      setState(() {
        _pendingVerifications = verifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '認証データの取得に失敗しました: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// フィルター適用済み認証一覧を取得
  List<Map<String, dynamic>> _getFilteredVerifications() {
    if (_selectedFilter == 'all') {
      return _pendingVerifications;
    }

    return _pendingVerifications.where((verification) {
      final status = verification['verification_status_final'] as String? ?? '';
      return status == _selectedFilter;
    }).toList();
  }

  /// ステータス表示名を取得
  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'pending_review':
        return '審査待ち';
      case 'awaiting_ekyc':
        return 'eKYC待ち';
      case 'awaiting_parental_consent':
        return '親権者同意待ち';
      case 'awaiting_sns_verification':
        return 'SNS認証待ち';
      default:
        return status;
    }
  }

  /// ユーザーを承認
  Future<void> _approveUser(String userId) async {
    try {
      await _verificationService.updateVerificationStatus(
        userId,
        VerificationStatus.approved,
      );
      
      // 成功メッセージを表示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ユーザーを承認しました'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // リストを再読み込み
      await _loadPendingVerifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('承認に失敗しました: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// ユーザーを拒否
  Future<void> _rejectUser(String userId) async {
    // 拒否理由を入力するダイアログを表示
    final reason = await _showRejectionDialog();
    if (reason == null) return;

    try {
      await _verificationService.updateVerificationStatus(
        userId,
        VerificationStatus.rejected,
      );
      
      // 拒否理由を保存（実装予定）
      
      // 成功メッセージを表示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ユーザーを拒否しました'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      // リストを再読み込み
      await _loadPendingVerifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('拒否に失敗しました: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 拒否理由入力ダイアログ
  Future<String?> _showRejectionDialog() async {
    final reasonController = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('拒否理由'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: '拒否理由を入力してください',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(reasonController.text),
            child: const Text('拒否'),
          ),
        ],
      ),
    );
  }
} 