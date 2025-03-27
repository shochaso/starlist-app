import '../models/legal/legal_compliance_model.dart';

/// 法的コンプライアンスリポジトリの抽象インターフェース
abstract class LegalComplianceRepository {
  /// 現在の利用規約を取得する
  Future<TermsVersion> getCurrentTerms();
  
  /// 特定バージョンの利用規約を取得する
  Future<TermsVersion> getTermsVersion(String version);
  
  /// 全ての利用規約バージョンを取得する
  Future<List<TermsVersion>> getAllTermsVersions();
  
  /// 新しい利用規約バージョンを作成する
  Future<TermsVersion> createTermsVersion(TermsVersion termsVersion);
  
  /// 現在のプライバシーポリシーを取得する
  Future<PrivacyPolicyVersion> getCurrentPrivacyPolicy();
  
  /// 特定バージョンのプライバシーポリシーを取得する
  Future<PrivacyPolicyVersion> getPrivacyPolicyVersion(String version);
  
  /// 全てのプライバシーポリシーバージョンを取得する
  Future<List<PrivacyPolicyVersion>> getAllPrivacyPolicyVersions();
  
  /// 新しいプライバシーポリシーバージョンを作成する
  Future<PrivacyPolicyVersion> createPrivacyPolicyVersion(PrivacyPolicyVersion privacyPolicyVersion);
  
  /// ユーザーの同意を記録する
  Future<UserConsent> recordUserConsent(UserConsent userConsent);
  
  /// ユーザーの同意履歴を取得する
  Future<List<UserConsent>> getUserConsentHistory(String userId);
  
  /// ユーザーが最新の利用規約に同意しているか確認する
  Future<bool> hasUserConsentedToLatestTerms(String userId);
  
  /// ユーザーが最新のプライバシーポリシーに同意しているか確認する
  Future<bool> hasUserConsentedToLatestPrivacyPolicy(String userId);
}
