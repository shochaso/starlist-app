import '../models/sns_verification.dart';

/// Minimal stub for SNS verification flows so that admin UI can compile.
/// Replace with the real implementation that talks to Supabase once ready.
class SNSVerificationService {
  const SNSVerificationService._();

  static Future<List<SNSVerification>> getSNSVerificationsForAdmin({
    String? status,
    SNSPlatform? platform,
    int limit = 50,
    int offset = 0,
  }) async {
    // TODO: Wire up Supabase queries.
    return <SNSVerification>[];
  }

  static Future<SNSVerificationResult> verifyOwnership(
    String verificationId,
  ) async {
    // TODO: Implement API call and ownership verification.
    return SNSVerificationResult(
      success: false,
      verificationId: verificationId,
      error: 'SNS ownership verification is not implemented yet.',
    );
  }
}

class SNSVerificationResult {
  const SNSVerificationResult({
    required this.success,
    this.verificationId,
    this.verificationCode,
    this.followerCount,
    this.message,
    this.error,
  });

  final bool success;
  final String? verificationId;
  final String? verificationCode;
  final int? followerCount;
  final String? message;
  final String? error;
}
