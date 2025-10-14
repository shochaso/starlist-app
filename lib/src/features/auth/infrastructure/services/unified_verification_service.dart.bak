import 'package:supabase_flutter/supabase_flutter.dart';

/// 認証ステータス
enum VerificationStatus {
  newUser('new_user', '新規ユーザー'),
  awaitingTermsAgreement('awaiting_terms_agreement', '事務所規約同意待ち'),
  awaitingEkyc('awaiting_ekyc', 'eKYC実施待ち'),
  ekycCompleted('ekyc_completed', 'eKYC完了'),
  awaitingParentalConsent('awaiting_parental_consent', '親権者同意待ち'),
  parentalConsentSubmitted('parental_consent_submitted', '親権者同意書提出済み'),
  parentalEkycRequired('parental_ekyc_required', '親権者eKYC必要'),
  parentalEkycCompleted('parental_ekyc_completed', '親権者eKYC完了'),
  awaitingSnsVerification('awaiting_sns_verification', 'SNS所有権確認待ち'),
  snsVerificationCompleted('sns_verification_completed', 'SNS認証完了'),
  pendingReview('pending_review', '運営レビュー待ち'),
  approved('approved', '承認済み'),
  rejected('rejected', '拒否'),
  suspended('suspended', '停止');

  const VerificationStatus(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// 統合認証フロー管理サービス
class UnifiedVerificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// ユーザーの現在の認証ステータスを取得
  Future<VerificationStatus> getCurrentVerificationStatus(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('verification_status_final')
          .eq('id', userId)
          .single();

      final statusValue = response['verification_status_final'] as String? ?? 'new_user';
      return VerificationStatus.values.firstWhere(
        (status) => status.value == statusValue,
        orElse: () => VerificationStatus.newUser,
      );
    } catch (e) {
      throw Exception('認証ステータスの取得に失敗しました: ${e.toString()}');
    }
  }

  /// 次の認証ステップを取得
  Future<VerificationStatus?> getNextVerificationStep(String userId) async {
    final currentStatus = await getCurrentVerificationStatus(userId);
    
    switch (currentStatus) {
      case VerificationStatus.newUser:
        return VerificationStatus.awaitingTermsAgreement;
      
      case VerificationStatus.awaitingTermsAgreement:
        return VerificationStatus.awaitingEkyc;
      
      case VerificationStatus.awaitingEkyc:
        // eKYC完了後の年齢判定により分岐
        final isMinor = await _checkIfUserIsMinor(userId);
        return isMinor 
            ? VerificationStatus.awaitingParentalConsent 
            : VerificationStatus.awaitingSnsVerification;
      
      case VerificationStatus.awaitingParentalConsent:
        return VerificationStatus.awaitingSnsVerification;
      
      case VerificationStatus.awaitingSnsVerification:
        return VerificationStatus.pendingReview;
      
      case VerificationStatus.pendingReview:
        return null; // 運営審査待ち
      
      case VerificationStatus.approved:
      case VerificationStatus.rejected:
      case VerificationStatus.suspended:
        return null; // 最終状態
      
      default:
        return null;
    }
  }

  /// 認証ステータスを更新
  Future<void> updateVerificationStatus(
    String userId,
    VerificationStatus newStatus,
  ) async {
    try {
      await _supabase
          .from('users')
          .update({
            'verification_status_final': newStatus.value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      // 認証進捗も更新
      await _updateVerificationProgress(userId, newStatus);
    } catch (e) {
      throw Exception('認証ステータスの更新に失敗しました: ${e.toString()}');
    }
  }

  /// ユーザーが未成年者かチェック
  Future<bool> _checkIfUserIsMinor(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('birth_date, is_minor')
          .eq('id', userId)
          .single();

      final birthDate = response['birth_date'] as String?;
      final isMinor = response['is_minor'] as bool? ?? false;

      if (birthDate != null) {
        final birth = DateTime.parse(birthDate);
        final today = DateTime.now();
        final age = today.year - birth.year;
        
        // 誕生日が今年まだ来ていない場合は1歳引く
        if (today.month < birth.month || 
            (today.month == birth.month && today.day < birth.day)) {
          return age - 1 < 18;
        }
        
        return age < 18;
      }

      return isMinor;
    } catch (e) {
      throw Exception('年齢確認に失敗しました: ${e.toString()}');
    }
  }

  /// 認証進捗を更新
  Future<void> _updateVerificationProgress(
    String userId,
    VerificationStatus status,
  ) async {
    try {
      final progressData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      switch (status) {
        case VerificationStatus.awaitingTermsAgreement:
          progressData['terms_agreement_completed'] = false;
          break;
        
        case VerificationStatus.awaitingEkyc:
          progressData['terms_agreement_completed'] = true;
          progressData['terms_agreement_completed_at'] = DateTime.now().toIso8601String();
          break;
        
        case VerificationStatus.ekycCompleted:
          progressData['ekyc_completed'] = true;
          progressData['ekyc_completed_at'] = DateTime.now().toIso8601String();
          break;
        
        case VerificationStatus.awaitingParentalConsent:
          progressData['parental_consent_required'] = true;
          break;
        
        case VerificationStatus.awaitingSnsVerification:
          progressData['parental_consent_completed'] = true;
          progressData['parental_consent_completed_at'] = DateTime.now().toIso8601String();
          break;
        
        case VerificationStatus.pendingReview:
          progressData['sns_verification_completed'] = true;
          progressData['sns_verification_completed_at'] = DateTime.now().toIso8601String();
          progressData['all_requirements_met'] = true;
          progressData['submitted_for_review'] = true;
          progressData['submitted_for_review_at'] = DateTime.now().toIso8601String();
          break;
        
        default:
          break;
      }

      // 既存の進捗レコードを取得
      final existingProgress = await _supabase
          .from('verification_progress')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (existingProgress != null) {
        await _supabase
            .from('verification_progress')
            .update(progressData)
            .eq('user_id', userId);
      } else {
        progressData['user_id'] = userId;
        progressData['created_at'] = DateTime.now().toIso8601String();
        
        await _supabase
            .from('verification_progress')
            .insert(progressData);
      }
    } catch (e) {
      throw Exception('認証進捗の更新に失敗しました: ${e.toString()}');
    }
  }

  /// 全認証要件の完了状況をチェック
  Future<bool> checkAllRequirementsMet(String userId) async {
    try {
      final response = await _supabase
          .from('verification_progress')
          .select()
          .eq('user_id', userId)
          .single();

      final termsAgreed = response['terms_agreement_completed'] as bool? ?? false;
      final ekycCompleted = response['ekyc_completed'] as bool? ?? false;
      final parentalConsentRequired = response['parental_consent_required'] as bool? ?? false;
      final parentalConsentCompleted = response['parental_consent_completed'] as bool? ?? false;
      final snsCompleted = response['sns_verification_completed'] as bool? ?? false;

      // 親権者同意が必要な場合は、その完了もチェック
      final parentalConsentOk = !parentalConsentRequired || parentalConsentCompleted;

      return termsAgreed && ekycCompleted && parentalConsentOk && snsCompleted;
    } catch (e) {
      return false;
    }
  }

  /// 認証フローの完了率を取得
  Future<double> getVerificationProgressPercentage(String userId) async {
    try {
      final response = await _supabase
          .from('verification_progress')
          .select()
          .eq('user_id', userId)
          .single();

      int completedSteps = 0;
      int totalSteps = 3; // 基本ステップ数

      // 事務所規約同意
      if (response['terms_agreement_completed'] == true) {
        completedSteps++;
      }

      // eKYC
      if (response['ekyc_completed'] == true) {
        completedSteps++;
      }

      // SNS認証
      if (response['sns_verification_completed'] == true) {
        completedSteps++;
      }

      // 親権者同意が必要な場合
      if (response['parental_consent_required'] == true) {
        totalSteps++;
        if (response['parental_consent_completed'] == true) {
          completedSteps++;
        }
      }

      return totalSteps > 0 ? (completedSteps / totalSteps) * 100 : 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// 管理者用：認証待ちユーザー一覧を取得
  Future<List<Map<String, dynamic>>> getPendingVerifications() async {
    try {
      final response = await _supabase
          .from('admin_verification_dashboard')
          .select()
          .in_('verification_status_final', [
            'pending_review',
            'awaiting_ekyc',
            'awaiting_parental_consent',
            'awaiting_sns_verification'
          ])
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('認証待ちユーザーの取得に失敗しました: ${e.toString()}');
    }
  }
} 