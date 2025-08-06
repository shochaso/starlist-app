import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/agency_terms_agreement.dart';
import '../../infrastructure/services/terms_agreement_service.dart';

part 'terms_agreement_provider.g.dart';

/// 事務所規約同意状態
class TermsAgreementState {
  final bool isLoading;
  final AgencyTermsAgreement? agreement;
  final String? error;

  const TermsAgreementState({
    this.isLoading = false,
    this.agreement,
    this.error,
  });

  TermsAgreementState copyWith({
    bool? isLoading,
    AgencyTermsAgreement? agreement,
    String? error,
  }) {
    return TermsAgreementState(
      isLoading: isLoading ?? this.isLoading,
      agreement: agreement ?? this.agreement,
      error: error,
    );
  }
}

/// 事務所規約同意プロバイダー
@riverpod
class TermsAgreement extends _$TermsAgreement {
  @override
  TermsAgreementState build() {
    return const TermsAgreementState();
  }

  /// 規約同意を送信
  Future<AgencyTermsAgreementResult> submitAgreement(
    AgencyTermsAgreement agreement,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(termsAgreementServiceProvider);
      final result = await service.submitAgreement(agreement);

      if (result.isSuccess) {
        // 成功時は新しい同意情報でステートを更新
        final updatedAgreement = agreement.copyWith(
          id: result.agreementId,
          agreedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );
        
        state = state.copyWith(
          isLoading: false,
          agreement: updatedAgreement,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error,
        );
      }

      return result;
    } catch (e) {
      final errorMessage = 'エラーが発生しました: ${e.toString()}';
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      
      return AgencyTermsAgreementResult.failure(error: errorMessage);
    }
  }

  /// ユーザーの規約同意状況を取得
  Future<void> loadUserAgreement(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(termsAgreementServiceProvider);
      final agreement = await service.getUserAgreement(userId);

      state = state.copyWith(
        isLoading: false,
        agreement: agreement,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'データの読み込みに失敗しました: ${e.toString()}',
      );
    }
  }

  /// エラーをクリア
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// ステートをリセット
  void reset() {
    state = const TermsAgreementState();
  }
}

/// 事務所規約同意サービスプロバイダー
@riverpod
TermsAgreementService termsAgreementService(TermsAgreementServiceRef ref) {
  return TermsAgreementService();
} 