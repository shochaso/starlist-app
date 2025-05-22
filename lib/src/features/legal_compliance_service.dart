import 'package:flutter/foundation.dart';
import '../models/legal/legal_compliance_model.dart';
import '../repositories/legal/legal_compliance_repository.dart';
import 'notification_service.dart';

/// 法的コンプライアンスサービスクラス
class LegalComplianceService {
  final LegalComplianceRepository _repository;
  final NotificationService _notificationService;
  
  /// コンストラクタ
  LegalComplianceService({
    required LegalComplianceRepository repository,
    required NotificationService notificationService,
  }) : _repository = repository,
       _notificationService = notificationService;
  
  /// 現在の利用規約を取得する
  Future<TermsVersion> getCurrentTerms() async {
    try {
      return await _repository.getCurrentTerms();
    } catch (e) {
      debugPrint('利用規約取得エラー: $e');
      rethrow;
    }
  }
  
  /// 特定バージョンの利用規約を取得する
  Future<TermsVersion> getTermsVersion(String version) async {
    try {
      return await _repository.getTermsVersion(version);
    } catch (e) {
      debugPrint('利用規約バージョン取得エラー: $e');
      rethrow;
    }
  }
  
  /// 全ての利用規約バージョンを取得する
  Future<List<TermsVersion>> getAllTermsVersions() async {
    try {
      return await _repository.getAllTermsVersions();
    } catch (e) {
      debugPrint('全利用規約バージョン取得エラー: $e');
      rethrow;
    }
  }
  
  /// 新しい利用規約バージョンを作成する
  Future<TermsVersion> createTermsVersion(String version, String content, DateTime effectiveDate) async {
    try {
      // 既存の利用規約を全て非アクティブにする処理は実際の実装ではリポジトリ内で行う
      
      final termsVersion = TermsVersion(
        id: 'terms_${DateTime.now().millisecondsSinceEpoch}',
        version: version,
        effectiveDate: effectiveDate,
        content: content,
        isCurrent: true,
      );
      
      final createdTerms = await _repository.createTermsVersion(termsVersion);
      
      // 全ユーザーに通知
      // 実際の実装では全ユーザーに通知を送信する処理を実装
      debugPrint('新しい利用規約バージョンが作成されました: $version');
      
      return createdTerms;
    } catch (e) {
      debugPrint('利用規約バージョン作成エラー: $e');
      rethrow;
    }
  }
  
  /// 現在のプライバシーポリシーを取得する
  Future<PrivacyPolicyVersion> getCurrentPrivacyPolicy() async {
    try {
      return await _repository.getCurrentPrivacyPolicy();
    } catch (e) {
      debugPrint('プライバシーポリシー取得エラー: $e');
      rethrow;
    }
  }
  
  /// 特定バージョンのプライバシーポリシーを取得する
  Future<PrivacyPolicyVersion> getPrivacyPolicyVersion(String version) async {
    try {
      return await _repository.getPrivacyPolicyVersion(version);
    } catch (e) {
      debugPrint('プライバシーポリシーバージョン取得エラー: $e');
      rethrow;
    }
  }
  
  /// 全てのプライバシーポリシーバージョンを取得する
  Future<List<PrivacyPolicyVersion>> getAllPrivacyPolicyVersions() async {
    try {
      return await _repository.getAllPrivacyPolicyVersions();
    } catch (e) {
      debugPrint('全プライバシーポリシーバージョン取得エラー: $e');
      rethrow;
    }
  }
  
  /// 新しいプライバシーポリシーバージョンを作成する
  Future<PrivacyPolicyVersion> createPrivacyPolicyVersion(String version, String content, DateTime effectiveDate) async {
    try {
      // 既存のプライバシーポリシーを全て非アクティブにする処理は実際の実装ではリポジトリ内で行う
      
      final privacyPolicyVersion = PrivacyPolicyVersion(
        id: 'privacy_${DateTime.now().millisecondsSinceEpoch}',
        version: version,
        effectiveDate: effectiveDate,
        content: content,
        isCurrent: true,
      );
      
      final createdPrivacyPolicy = await _repository.createPrivacyPolicyVersion(privacyPolicyVersion);
      
      // 全ユーザーに通知
      // 実際の実装では全ユーザーに通知を送信する処理を実装
      debugPrint('新しいプライバシーポリシーバージョンが作成されました: $version');
      
      return createdPrivacyPolicy;
    } catch (e) {
      debugPrint('プライバシーポリシーバージョン作成エラー: $e');
      rethrow;
    }
  }
  
  /// ユーザーの同意を記録する
  Future<UserConsent> recordUserConsent(String userId, String documentId, String documentType, String documentVersion, String? ipAddress, String? deviceInfo) async {
    try {
      final userConsent = UserConsent(
        id: 'consent_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        documentId: documentId,
        documentType: documentType,
        documentVersion: documentVersion,
        consentDate: DateTime.now(),
        ipAddress: ipAddress,
        deviceInfo: deviceInfo,
      );
      
      return await _repository.recordUserConsent(userConsent);
    } catch (e) {
      debugPrint('ユーザー同意記録エラー: $e');
      rethrow;
    }
  }
  
  /// ユーザーの同意履歴を取得する
  Future<List<UserConsent>> getUserConsentHistory(String userId) async {
    try {
      return await _repository.getUserConsentHistory(userId);
    } catch (e) {
      debugPrint('ユーザー同意履歴取得エラー: $e');
      rethrow;
    }
  }
  
  /// ユーザーが最新の利用規約に同意しているか確認する
  Future<bool> hasUserConsentedToLatestTerms(String userId) async {
    try {
      return await _repository.hasUserConsentedToLatestTerms(userId);
    } catch (e) {
      debugPrint('ユーザー利用規約同意確認エラー: $e');
      return false;
    }
  }
  
  /// ユーザーが最新のプライバシーポリシーに同意しているか確認する
  Future<bool> hasUserConsentedToLatestPrivacyPolicy(String userId) async {
    try {
      return await _repository.hasUserConsentedToLatestPrivacyPolicy(userId);
    } catch (e) {
      debugPrint('ユーザープライバシーポリシー同意確認エラー: $e');
      return false;
    }
  }
  
  /// ユーザーに利用規約の同意を要求する
  Future<void> requestTermsConsent(String userId) async {
    try {
      final hasConsented = await hasUserConsentedToLatestTerms(userId);
      
      if (!hasConsented) {
        // ユーザーに通知
        await _notificationService.sendNotification(
          userId: userId,
          title: '利用規約の更新',
          body: '利用規約が更新されました。続けて利用するには、新しい利用規約に同意してください。',
          data: {'action': 'terms_consent_required'},
        );
      }
    } catch (e) {
      debugPrint('利用規約同意要求エラー: $e');
    }
  }
  
  /// ユーザーにプライバシーポリシーの同意を要求する
  Future<void> requestPrivacyPolicyConsent(String userId) async {
    try {
      final hasConsented = await hasUserConsentedToLatestPrivacyPolicy(userId);
      
      if (!hasConsented) {
        // ユーザーに通知
        await _notificationService.sendNotification(
          userId: userId,
          title: 'プライバシーポリシーの更新',
          body: 'プライバシーポリシーが更新されました。続けて利用するには、新しいプライバシーポリシーに同意してください。',
          data: {'action': 'privacy_policy_consent_required'},
        );
      }
    } catch (e) {
      debugPrint('プライバシーポリシー同意要求エラー: $e');
    }
  }
  
  /// 地域に基づいた法的要件を取得する
  Future<Map<String, dynamic>> getLegalRequirementsByRegion(String region) async {
    try {
      // 実際の実装では地域ごとの法的要件をデータベースから取得
      
      // このサンプルでは未実装
      throw UnimplementedError('地域ごとの法的要件取得機能は未実装です');
    } catch (e) {
      debugPrint('地域法的要件取得エラー: $e');
      rethrow;
    }
  }
}
