import 'package:file_picker/file_picker.dart';

/// 親権者同意情報
class ParentalConsent {
  final String id;
  final String userId;
  final String parentFullName;
  final String parentEmail;
  final String? parentPhone;
  final String parentAddress;
  final String relationshipToMinor;
  final String? consentDocumentUrl;
  final DateTime consentSubmittedAt;
  final String? parentEKYCProvider;
  final String? parentEKYCVerificationId;
  final DateTime? parentEKYCVerifiedAt;
  final String? parentLegalName;
  final String verificationStatus;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ParentalConsent({
    required this.id,
    required this.userId,
    required this.parentFullName,
    required this.parentEmail,
    this.parentPhone,
    required this.parentAddress,
    required this.relationshipToMinor,
    this.consentDocumentUrl,
    required this.consentSubmittedAt,
    this.parentEKYCProvider,
    this.parentEKYCVerificationId,
    this.parentEKYCVerifiedAt,
    this.parentLegalName,
    required this.verificationStatus,
    this.adminNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ParentalConsent.fromJson(Map<String, dynamic> json) {
    return ParentalConsent(
      id: json['id'],
      userId: json['user_id'],
      parentFullName: json['parent_full_name'],
      parentEmail: json['parent_email'],
      parentPhone: json['parent_phone'],
      parentAddress: json['parent_address'],
      relationshipToMinor: json['relationship_to_minor'],
      consentDocumentUrl: json['consent_document_url'],
      consentSubmittedAt: DateTime.parse(json['consent_submitted_at']),
      parentEKYCProvider: json['parent_ekyc_provider'],
      parentEKYCVerificationId: json['parent_ekyc_verification_id'],
      parentEKYCVerifiedAt: json['parent_ekyc_verified_at'] != null
          ? DateTime.parse(json['parent_ekyc_verified_at'])
          : null,
      parentLegalName: json['parent_legal_name'],
      verificationStatus: json['verification_status'],
      adminNotes: json['admin_notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'parent_full_name': parentFullName,
      'parent_email': parentEmail,
      'parent_phone': parentPhone,
      'parent_address': parentAddress,
      'relationship_to_minor': relationshipToMinor,
      'consent_document_url': consentDocumentUrl,
      'consent_submitted_at': consentSubmittedAt.toIso8601String(),
      'parent_ekyc_provider': parentEKYCProvider,
      'parent_ekyc_verification_id': parentEKYCVerificationId,
      'parent_ekyc_verified_at': parentEKYCVerifiedAt?.toIso8601String(),
      'parent_legal_name': parentLegalName,
      'verification_status': verificationStatus,
      'admin_notes': adminNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// 親権者同意リクエスト
class ParentalConsentRequest {
  final String userId;
  final String parentFullName;
  final String parentEmail;
  final String? parentPhone;
  final String parentAddress;
  final String relationshipToMinor;
  final PlatformFile? consentDocument;

  ParentalConsentRequest({
    required this.userId,
    required this.parentFullName,
    required this.parentEmail,
    this.parentPhone,
    required this.parentAddress,
    required this.relationshipToMinor,
    this.consentDocument,
  });
}

/// 親権者同意ステータス
enum ParentalConsentStatus {
  parentalConsentSubmitted('parental_consent_submitted'),
  parentalEKYCRequired('parental_ekyc_required'),
  parentalEKYCCompleted('parental_ekyc_completed'),
  approved('approved'),
  rejected('rejected');

  const ParentalConsentStatus(this.value);
  final String value;

  static ParentalConsentStatus fromString(String value) {
    return ParentalConsentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ParentalConsentStatus.parentalConsentSubmitted,
    );
  }
}

/// 親権者同意ステップ
enum ParentalConsentStep {
  parentInfo(1, '親権者情報'),
  consentDocument(2, '同意書'),
  ekyc(3, 'eKYC認証'),
  review(4, '審査中'),
  completed(5, '完了');

  const ParentalConsentStep(this.order, this.label);
  final int order;
  final String label;

  static ParentalConsentStep fromStatus(ParentalConsentStatus status) {
    switch (status) {
      case ParentalConsentStatus.parentalConsentSubmitted:
        return ParentalConsentStep.review;
      case ParentalConsentStatus.parentalEKYCRequired:
        return ParentalConsentStep.ekyc;
      case ParentalConsentStatus.parentalEKYCCompleted:
        return ParentalConsentStep.review;
      case ParentalConsentStatus.approved:
        return ParentalConsentStep.completed;
      case ParentalConsentStatus.rejected:
        return ParentalConsentStep.review;
    }
  }
} 