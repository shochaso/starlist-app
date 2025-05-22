import 'package:flutter/foundation.dart';
import '../models/legal/legal_compliance_model.dart';
import '../repositories/legal/age_verification_repository.dart';
import 'notification_service.dart';

/// 年齢確認サービスクラス
class AgeVerificationService {
  final AgeVerificationRepository _repository;
  final NotificationService _notificationService;
  
  /// コンストラクタ
  AgeVerificationService({
    required AgeVerificationRepository repository,
    required NotificationService notificationService,
  }) : _repository = repository,
       _notificationService = notificationService;
  
  /// ユーザーの年齢確認情報を取得する
  Future<AgeVerification?> getUserAgeVerification(String userId) async {
    try {
      return await _repository.getUserAgeVerification(userId);
    } catch (e) {
      debugPrint('年齢確認情報取得エラー: $e');
      return null;
    }
  }
  
  /// ユーザーが年齢確認済みかどうかを確認する
  Future<bool> isUserAgeVerified(String userId) async {
    try {
      final verification = await _repository.getUserAgeVerification(userId);
      return verification != null && verification.status == AgeVerificationStatus.verified;
    } catch (e) {
      debugPrint('年齢確認状態確認エラー: $e');
      return false;
    }
  }
  
  /// 自己申告による年齢確認を作成する
  Future<AgeVerification> createSelfDeclarationVerification(String userId, DateTime birthDate) async {
    try {
      // 年齢計算
      final now = DateTime.now();
      final age = now.year - birthDate.year - (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day) ? 1 : 0);
      
      // 18歳未満の場合は拒否
      if (age < 18) {
        return AgeVerification(
          id: 'age_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          method: AgeVerificationMethod.selfDeclaration,
          status: AgeVerificationStatus.rejected,
          verificationDate: DateTime.now(),
          rejectionReason: '18歳未満のユーザーは利用できません',
        );
      }
      
      // 年齢確認情報を作成
      final verification = AgeVerification(
        id: 'age_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        method: AgeVerificationMethod.selfDeclaration,
        status: AgeVerificationStatus.verified,
        verificationDate: DateTime.now(),
        // 自己申告は1年後に期限切れ
        expirationDate: DateTime.now().add(Duration(days: 365)),
        verificationData: '{"birthDate": "${birthDate.toIso8601String()}", "age": $age}',
      );
      
      return await _repository.createAgeVerification(verification);
    } catch (e) {
      debugPrint('自己申告年齢確認作成エラー: $e');
      rethrow;
    }
  }
  
  /// クレジットカードによる年齢確認を作成する
  Future<AgeVerification> createCreditCardVerification(String userId, String cardToken) async {
    try {
      // 実際の実装ではクレジットカード検証サービスを使用
      
      // 年齢確認情報を作成
      final verification = AgeVerification(
        id: 'age_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        method: AgeVerificationMethod.creditCard,
        status: AgeVerificationStatus.pending,
        verificationData: '{"cardToken": "$cardToken"}',
      );
      
      return await _repository.createAgeVerification(verification);
    } catch (e) {
      debugPrint('クレジットカード年齢確認作成エラー: $e');
      rethrow;
    }
  }
  
  /// 身分証明書による年齢確認を作成する
  Future<AgeVerification> createIdDocumentVerification(String userId, String documentType, String documentId, String documentImageUrl) async {
    try {
      // 年齢確認情報を作成
      final verification = AgeVerification(
        id: 'age_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        method: AgeVerificationMethod.idDocument,
        status: AgeVerificationStatus.pending,
        verificationData: '{"documentType": "$documentType", "documentId": "$documentId", "documentImageUrl": "$documentImageUrl"}',
      );
      
      return await _repository.createAgeVerification(verification);
    } catch (e) {
      debugPrint('身分証明書年齢確認作成エラー: $e');
      rethrow;
    }
  }
  
  /// 携帯電話認証による年齢確認を作成する
  Future<AgeVerification> createMobileCarrierVerification(String userId, String phoneNumber, String verificationCode) async {
    try {
      // 実際の実装では携帯電話キャリア認証サービスを使用
      
      // 年齢確認情報を作成
      final verification = AgeVerification(
        id: 'age_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        method: AgeVerificationMethod.mobileCarrier,
        status: AgeVerificationStatus.pending,
        verificationData: '{"phoneNumber": "$phoneNumber", "verificationCode": "$verificationCode"}',
      );
      
      return await _repository.createAgeVerification(verification);
    } catch (e) {
      debugPrint('携帯電話認証年齢確認作成エラー: $e');
      rethrow;
    }
  }
  
  /// 第三者サービスによる年齢確認を作成する
  Future<AgeVerification> createThirdPartyVerification(String userId, String serviceName, String serviceToken) async {
    try {
      // 実際の実装では第三者認証サービスを使用
      
      // 年齢確認情報を作成
      final verification = AgeVerification(
        id: 'age_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        method: AgeVerificationMethod.thirdPartyService,
        status: AgeVerificationStatus.pending,
        verificationData: '{"serviceName": "$serviceName", "serviceToken": "$serviceToken"}',
      );
      
      return await _repository.createAgeVerification(verification);
    } catch (e) {
      debugPrint('第三者サービス年齢確認作成エラー: $e');
      rethrow;
    }
  }
  
  /// 年齢確認を承認する
  Future<AgeVerification> approveVerification(String verificationId) async {
    try {
      final verification = await _repository.updateVerificationStatus(
        verificationId,
        AgeVerificationStatus.verified,
      );
      
      // ユーザーに通知
      await _notificationService.sendNotification(
        userId: verification.userId,
        title: '年齢確認が完了しました',
        body: 'あなたの年齢確認が承認されました。すべてのコンテンツにアクセスできるようになりました。',
        data: {'action': 'age_verification_approved'},
      );
      
      return verification;
    } catch (e) {
      debugPrint('年齢確認承認エラー: $e');
      rethrow;
    }
  }
  
  /// 年齢確認を拒否する
  Future<AgeVerification> rejectVerification(String verificationId, String reason) async {
    try {
      final verification = await _repository.updateVerificationStatus(
        verificationId,
        AgeVerificationStatus.rejected,
        rejectionReason: reason,
      );
      
      // ユーザーに通知
      await _notificationService.sendNotification(
        userId: verification.userId,
        title: '年齢確認が拒否されました',
        body: '年齢確認が拒否されました。理由: $reason',
        data: {'action': 'age_verification_rejected'},
      );
      
      return verification;
    } catch (e) {
      debugPrint('年齢確認拒否エラー: $e');
      rethrow;
    }
  }
  
  /// 期限切れの年齢確認を処理する
  Future<void> processExpiredVerifications() async {
    try {
      final expiredVerifications = await _repository.getExpiredVerifications();
      
      for (final verification in expiredVerifications) {
        // ステータスを期限切れに更新
        await _repository.updateVerificationStatus(
          verification.id,
          AgeVerificationStatus.expired,
        );
        
        // ユーザーに通知
        await _notificationService.sendNotification(
          userId: verification.userId,
          title: '年齢確認の期限が切れました',
          body: 'あなたの年齢確認の期限が切れました。引き続き制限付きコンテンツにアクセスするには、再度年齢確認を行ってください。',
          data: {'action': 'age_verification_expired'},
        );
      }
    } catch (e) {
      debugPrint('期限切れ年齢確認処理エラー: $e');
    }
  }
  
  /// コンテンツの年齢制限に基づいてアクセス可能かどうかを確認する
  Future<bool> canAccessContent(String userId, ContentAgeRestriction restriction) async {
    try {
      // 全年齢コンテンツは誰でもアクセス可能
      if (restriction == ContentAgeRestriction.general) {
        return true;
      }
      
      // 年齢確認情報を取得
      final verification = await _repository.getUserAgeVerification(userId);
      
      // 年齢確認が完了していない場合
      if (verification == null || verification.status != AgeVerificationStatus.verified) {
        return false;
      }
      
      // 年齢制限に基づいてアクセス可否を判断
      switch (restriction) {
        case ContentAgeRestriction.teen:
          // 12歳以上（すべての確認済みユーザー）
          return true;
        case ContentAgeRestriction.mature:
          // 15歳以上（すべての確認済みユーザー）
          return true;
        case ContentAgeRestriction.adult:
          // 18歳以上（すべての確認済みユーザー）
          return true;
        default:
          return false;
      }
    } catch (e) {
      debugPrint('コンテンツアクセス確認エラー: $e');
      return false;
    }
  }
}
