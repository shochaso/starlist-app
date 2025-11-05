import 'package:flutter/material.dart';

/// SNS認証画面のプレースホルダー。
/// 本実装が揃うまでビルドを通す目的で簡易 UI を提供する。
class SNSVerificationScreen extends StatelessWidget {
  const SNSVerificationScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  final String userId;
  final String userName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SNS認証（準備中）')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ユーザーID: $userId'),
            const SizedBox(height: 8),
            Text('ユーザー名: $userName'),
            const SizedBox(height: 24),
            const Text(
              'SNS認証フローは現在準備中です。\n実装完了まではスターリスト運営へお問い合わせください。',
            ),
          ],
        ),
      ),
    );
  }
}

/// eKYC 認証種別
enum EKYCVerificationType {
  user,
  parent,
}

/// eKYC 呼び出し結果の簡易モデル
class EKYCVerificationResult {
  const EKYCVerificationResult({
    required this.success,
    this.verificationId,
    this.verificationUrl,
    this.message,
    this.error,
  });

  final bool success;
  final String? verificationId;
  final String? verificationUrl;
  final String? message;
  final String? error;
}

/// eKYC サービスのプレースホルダー
class EKYCService {
  static bool get isConfigured => false;

  static Future<EKYCVerificationResult> startVerification({
    required String userId,
    required EKYCVerificationType type,
    String? parentalConsentId,
  }) async {
    return const EKYCVerificationResult(
      success: false,
      error: 'eKYC サービスが未設定のため開始できません。',
    );
  }
}

/// 認証ステータス
enum VerificationStatus {
  newUser('新規ユーザー'),
  awaitingSnsVerification('SNS認証待ち'),
  pendingReview('審査待ち'),
  approved('承認済み');

  const VerificationStatus(this.displayName);
  final String displayName;
}

/// 統合認証サービスのプレースホルダー
class UnifiedVerificationService {
  Future<VerificationStatus> getCurrentVerificationStatus(String userId) async {
    return VerificationStatus.newUser;
  }

  Future<VerificationStatus?> getNextVerificationStep(String userId) async {
    return null;
  }

  Future<double> getVerificationProgressPercentage(String userId) async {
    return 0;
  }

  Future<bool> checkAllRequirementsMet(String userId) async {
    return false;
  }
}
