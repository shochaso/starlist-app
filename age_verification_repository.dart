import 'package:flutter/foundation.dart';
import '../models/legal/legal_compliance_model.dart';

/// 年齢確認リポジトリの抽象インターフェース
abstract class AgeVerificationRepository {
  /// ユーザーの年齢確認情報を取得する
  Future<AgeVerification?> getUserAgeVerification(String userId);
  
  /// 年齢確認情報を作成する
  Future<AgeVerification> createAgeVerification(AgeVerification verification);
  
  /// 年齢確認情報を更新する
  Future<AgeVerification> updateAgeVerification(AgeVerification verification);
  
  /// 年齢確認ステータスを更新する
  Future<AgeVerification> updateVerificationStatus(String verificationId, AgeVerificationStatus status, {String? rejectionReason});
  
  /// 期限切れの年齢確認を取得する
  Future<List<AgeVerification>> getExpiredVerifications();
}
