import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/services/unified_verification_service.dart';
import '../../../core/presentation/widgets/loading_overlay.dart';
import '../../../core/presentation/widgets/custom_button.dart';
import 'terms_agreement_screen.dart';

/// 統合認証フロー画面
class UnifiedVerificationFlowScreen extends ConsumerStatefulWidget {
  final String userId;
  final String userName;

  const UnifiedVerificationFlowScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  ConsumerState<UnifiedVerificationFlowScreen> createState() => _UnifiedVerificationFlowScreenState();
}

class _UnifiedVerificationFlowScreenState extends ConsumerState<UnifiedVerificationFlowScreen> {
  final UnifiedVerificationService _verificationService = UnifiedVerificationService();
  
  VerificationStatus? _currentStatus;
  VerificationStatus? _nextStatus;
  double _progressPercentage = 0.0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVerificationStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スター認証フロー'),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
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

    if (_currentStatus == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressHeader(),
          const SizedBox(height: 30),
          _buildCurrentStepCard(),
          const SizedBox(height: 20),
          _buildNextStepCard(),
          const SizedBox(height: 30),
          _buildActionButton(),
        ],
      ),
    );
  }

  /// 進捗ヘッダー
  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[50]!, Colors.blue[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.verified_user, color: Colors.indigo[600], size: 28),
              const SizedBox(width: 12),
              Text(
                '認証進捗',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _progressPercentage / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo[600]!),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '${_progressPercentage.toStringAsFixed(1)}% 完了',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  /// 現在のステップカード
  Widget _buildCurrentStepCard() {
    if (_currentStatus == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(_currentStatus!),
                  color: _getStatusColor(_currentStatus!),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '現在のステップ',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _currentStatus!.displayName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _getStatusDescription(_currentStatus!),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// 次のステップカード
  Widget _buildNextStepCard() {
    if (_nextStatus == null) {
      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    '認証完了',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '全ての認証ステップが完了しました',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                '運営による最終審査をお待ちください',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.arrow_forward, color: Colors.blue[600], size: 24),
                const SizedBox(width: 12),
                const Text(
                  '次のステップ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _nextStatus!.displayName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _getStatusDescription(_nextStatus!),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// アクションボタン
  Widget _buildActionButton() {
    if (_currentStatus == VerificationStatus.approved) {
      return SizedBox(
        width: double.infinity,
        child: CustomButton(
          text: 'ホームに戻る',
          onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
          icon: Icons.home,
        ),
      );
    }

    if (_currentStatus == VerificationStatus.rejected) {
      return SizedBox(
        width: double.infinity,
        child: CustomButton(
          text: '再申請',
          onPressed: _restartVerification,
          icon: Icons.refresh,
          backgroundColor: Colors.orange,
        ),
      );
    }

    if (_nextStatus == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: _getActionButtonText(_nextStatus!),
        onPressed: _proceedToNextStep,
        icon: Icons.arrow_forward,
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
              onPressed: _loadVerificationStatus,
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  /// 認証ステータスを読み込み
  Future<void> _loadVerificationStatus() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currentStatus = await _verificationService.getCurrentVerificationStatus(widget.userId);
      final nextStatus = await _verificationService.getNextVerificationStep(widget.userId);
      final progressPercentage = await _verificationService.getVerificationProgressPercentage(widget.userId);

      setState(() {
        _currentStatus = currentStatus;
        _nextStatus = nextStatus;
        _progressPercentage = progressPercentage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '認証ステータスの取得に失敗しました: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// 次のステップに進む
  void _proceedToNextStep() {
    if (_nextStatus == null) return;

    switch (_nextStatus!) {
      case VerificationStatus.awaitingTermsAgreement:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TermsAgreementScreen(
              userId: widget.userId,
              userName: widget.userName,
            ),
          ),
        );
        break;
      
      case VerificationStatus.awaitingEkyc:
        // eKYC画面に遷移（実装予定）
        Navigator.of(context).pushNamed(
          '/ekyc-start',
          arguments: {
            'userId': widget.userId,
            'userName': widget.userName,
          },
        );
        break;
      
      case VerificationStatus.awaitingParentalConsent:
        // 親権者同意画面に遷移（実装済み）
        Navigator.of(context).pushNamed(
          '/parental-consent',
          arguments: {
            'userId': widget.userId,
            'userName': widget.userName,
          },
        );
        break;
      
      case VerificationStatus.awaitingSnsVerification:
        // SNS認証画面に遷移（実装済み）
        Navigator.of(context).pushNamed(
          '/sns-verification',
          arguments: {
            'userId': widget.userId,
            'userName': widget.userName,
          },
        );
        break;
      
      default:
        break;
    }
  }

  /// 認証を再開
  void _restartVerification() async {
    try {
      await _verificationService.updateVerificationStatus(
        widget.userId,
        VerificationStatus.newUser,
      );
      await _loadVerificationStatus();
    } catch (e) {
      setState(() {
        _error = '認証の再開に失敗しました: ${e.toString()}';
      });
    }
  }

  /// ステータスアイコンを取得
  IconData _getStatusIcon(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.newUser:
        return Icons.person_add;
      case VerificationStatus.awaitingTermsAgreement:
        return Icons.description;
      case VerificationStatus.awaitingEkyc:
        return Icons.verified_user;
      case VerificationStatus.ekycCompleted:
        return Icons.check_circle;
      case VerificationStatus.awaitingParentalConsent:
        return Icons.family_restroom;
      case VerificationStatus.parentalConsentSubmitted:
        return Icons.check_circle;
      case VerificationStatus.awaitingSnsVerification:
        return Icons.share;
      case VerificationStatus.snsVerificationCompleted:
        return Icons.check_circle;
      case VerificationStatus.pendingReview:
        return Icons.pending;
      case VerificationStatus.approved:
        return Icons.check_circle;
      case VerificationStatus.rejected:
        return Icons.cancel;
      case VerificationStatus.suspended:
        return Icons.block;
      default:
        return Icons.info;
    }
  }

  /// ステータス色を取得
  Color _getStatusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.approved:
        return Colors.green;
      case VerificationStatus.rejected:
      case VerificationStatus.suspended:
        return Colors.red;
      case VerificationStatus.pendingReview:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  /// ステータス説明を取得
  String _getStatusDescription(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.newUser:
        return '新規ユーザーとして登録されました';
      case VerificationStatus.awaitingTermsAgreement:
        return '事務所利用規約への同意が必要です';
      case VerificationStatus.awaitingEkyc:
        return '本人確認（eKYC）を実施してください';
      case VerificationStatus.ekycCompleted:
        return '本人確認が完了しました';
      case VerificationStatus.awaitingParentalConsent:
        return '親権者の同意が必要です（未成年者の場合）';
      case VerificationStatus.parentalConsentSubmitted:
        return '親権者同意書が提出されました';
      case VerificationStatus.awaitingSnsVerification:
        return 'SNSアカウントの所有権確認が必要です';
      case VerificationStatus.snsVerificationCompleted:
        return 'SNS認証が完了しました';
      case VerificationStatus.pendingReview:
        return '運営による最終審査をお待ちください';
      case VerificationStatus.approved:
        return '認証が完了し、スターとして活動できます';
      case VerificationStatus.rejected:
        return '認証が拒否されました';
      case VerificationStatus.suspended:
        return 'アカウントが停止されています';
      default:
        return '';
    }
  }

  /// アクションボタンテキストを取得
  String _getActionButtonText(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.awaitingTermsAgreement:
        return '規約同意へ進む';
      case VerificationStatus.awaitingEkyc:
        return '本人確認へ進む';
      case VerificationStatus.awaitingParentalConsent:
        return '親権者同意へ進む';
      case VerificationStatus.awaitingSnsVerification:
        return 'SNS認証へ進む';
      default:
        return '次へ進む';
    }
  }
} 