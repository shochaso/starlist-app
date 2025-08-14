import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:starlist_app/src/features/auth/domain/entities/agency_terms_agreement.dart';
import 'package:starlist_app/src/features/auth/infrastructure/services/terms_agreement_service.dart';

import 'terms_agreement_test.mocks.dart';

@GenerateMocks([TermsAgreementService])
void main() {
  group('AgencyTermsAgreement', () {
    test('should create agreement with required fields', () {
      final agreement = AgencyTermsAgreement(
        userId: 'test-user-id',
        agencyName: 'テスト事務所',
        individualResponsibilityAcknowledged: true,
        platformTermsVersion: '1.0.0',
      );

      expect(agreement.userId, 'test-user-id');
      expect(agreement.agencyName, 'テスト事務所');
      expect(agreement.individualResponsibilityAcknowledged, true);
      expect(agreement.platformTermsVersion, '1.0.0');
    });

    test('should convert to JSON correctly', () {
      final agreement = AgencyTermsAgreement(
        userId: 'test-user-id',
        agencyName: 'テスト事務所',
        agencyContactEmail: 'test@agency.com',
        agencyContactPhone: '03-1234-5678',
        individualResponsibilityAcknowledged: true,
        platformTermsVersion: '1.0.0',
        agreedAt: DateTime(2025, 1, 1),
        createdAt: DateTime(2025, 1, 1),
      );

      final json = agreement.toJson();

      expect(json['user_id'], 'test-user-id');
      expect(json['agency_name'], 'テスト事務所');
      expect(json['agency_contact_email'], 'test@agency.com');
      expect(json['agency_contact_phone'], '03-1234-5678');
      expect(json['individual_responsibility_acknowledged'], true);
      expect(json['platform_terms_version'], '1.0.0');
    });

    test('should create from JSON correctly', () {
      final json = {
        'id': 'test-id',
        'user_id': 'test-user-id',
        'agency_name': 'テスト事務所',
        'agency_contact_email': 'test@agency.com',
        'agency_contact_phone': '03-1234-5678',
        'individual_responsibility_acknowledged': true,
        'platform_terms_version': '1.0.0',
        'agreed_at': '2025-01-01T00:00:00.000Z',
        'created_at': '2025-01-01T00:00:00.000Z',
      };

      final agreement = AgencyTermsAgreement.fromJson(json);

      expect(agreement.id, 'test-id');
      expect(agreement.userId, 'test-user-id');
      expect(agreement.agencyName, 'テスト事務所');
      expect(agreement.agencyContactEmail, 'test@agency.com');
      expect(agreement.agencyContactPhone, '03-1234-5678');
      expect(agreement.individualResponsibilityAcknowledged, true);
      expect(agreement.platformTermsVersion, '1.0.0');
    });

    test('should copy with new values', () {
      final original = AgencyTermsAgreement(
        userId: 'test-user-id',
        agencyName: 'テスト事務所',
        individualResponsibilityAcknowledged: true,
        platformTermsVersion: '1.0.0',
      );

      final copied = original.copyWith(
        agencyName: '新しい事務所',
        agencyContactEmail: 'new@agency.com',
      );

      expect(copied.userId, original.userId);
      expect(copied.agencyName, '新しい事務所');
      expect(copied.agencyContactEmail, 'new@agency.com');
      expect(copied.individualResponsibilityAcknowledged, original.individualResponsibilityAcknowledged);
    });
  });

  group('AgencyTermsAgreementResult', () {
    test('should create success result', () {
      final result = AgencyTermsAgreementResult.success(
        agreementId: 'test-id',
        message: '成功しました',
      );

      expect(result.isSuccess, true);
      expect(result.agreementId, 'test-id');
      expect(result.message, '成功しました');
      expect(result.error, null);
    });

    test('should create failure result', () {
      final result = AgencyTermsAgreementResult.failure(
        error: 'エラーが発生しました',
      );

      expect(result.isSuccess, false);
      expect(result.agreementId, null);
      expect(result.message, null);
      expect(result.error, 'エラーが発生しました');
    });
  });

  group('TermsAgreementService', () {
    late MockTermsAgreementService mockService;

    setUp(() {
      mockService = MockTermsAgreementService();
    });

    test('should submit agreement successfully', () async {
      final agreement = AgencyTermsAgreement(
        userId: 'test-user-id',
        agencyName: 'テスト事務所',
        individualResponsibilityAcknowledged: true,
        platformTermsVersion: '1.0.0',
      );

      final expectedResult = AgencyTermsAgreementResult.success(
        agreementId: 'test-id',
        message: '事務所利用規約への同意が完了しました',
      );

      when(mockService.submitAgreement(agreement))
          .thenAnswer((_) async => expectedResult);

      final result = await mockService.submitAgreement(agreement);

      expect(result.isSuccess, true);
      expect(result.agreementId, 'test-id');
      expect(result.message, '事務所利用規約への同意が完了しました');
      verify(mockService.submitAgreement(agreement)).called(1);
    });

    test('should handle submission failure', () async {
      final agreement = AgencyTermsAgreement(
        userId: 'test-user-id',
        agencyName: 'テスト事務所',
        individualResponsibilityAcknowledged: true,
        platformTermsVersion: '1.0.0',
      );

      final expectedResult = AgencyTermsAgreementResult.failure(
        error: '既に規約同意が完了しています',
      );

      when(mockService.submitAgreement(agreement))
          .thenAnswer((_) async => expectedResult);

      final result = await mockService.submitAgreement(agreement);

      expect(result.isSuccess, false);
      expect(result.error, '既に規約同意が完了しています');
      verify(mockService.submitAgreement(agreement)).called(1);
    });

    test('should get user agreement', () async {
      final expectedAgreement = AgencyTermsAgreement(
        id: 'test-id',
        userId: 'test-user-id',
        agencyName: 'テスト事務所',
        individualResponsibilityAcknowledged: true,
        platformTermsVersion: '1.0.0',
      );

      when(mockService.getUserAgreement('test-user-id'))
          .thenAnswer((_) async => expectedAgreement);

      final result = await mockService.getUserAgreement('test-user-id');

      expect(result, isNotNull);
      expect(result!.id, 'test-id');
      expect(result.userId, 'test-user-id');
      expect(result.agencyName, 'テスト事務所');
      verify(mockService.getUserAgreement('test-user-id')).called(1);
    });

    test('should return null when user agreement not found', () async {
      when(mockService.getUserAgreement('non-existent-user'))
          .thenAnswer((_) async => null);

      final result = await mockService.getUserAgreement('non-existent-user');

      expect(result, isNull);
      verify(mockService.getUserAgreement('non-existent-user')).called(1);
    });
  });
} 