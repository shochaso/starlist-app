import 'package:equatable/equatable.dart';

/// 事務所利用規約同意エンティティ
class AgencyTermsAgreement extends Equatable {
  final String? id;
  final String userId;
  final String agencyName;
  final String? agencyContactEmail;
  final String? agencyContactPhone;
  final bool individualResponsibilityAcknowledged;
  final String platformTermsVersion;
  final String? agreementIpAddress;
  final String? agreementUserAgent;
  final DateTime? agreedAt;
  final DateTime? createdAt;

  const AgencyTermsAgreement({
    this.id,
    required this.userId,
    required this.agencyName,
    this.agencyContactEmail,
    this.agencyContactPhone,
    required this.individualResponsibilityAcknowledged,
    required this.platformTermsVersion,
    this.agreementIpAddress,
    this.agreementUserAgent,
    this.agreedAt,
    this.createdAt,
  });

  /// コピーファクトリメソッド
  AgencyTermsAgreement copyWith({
    String? id,
    String? userId,
    String? agencyName,
    String? agencyContactEmail,
    String? agencyContactPhone,
    bool? individualResponsibilityAcknowledged,
    String? platformTermsVersion,
    String? agreementIpAddress,
    String? agreementUserAgent,
    DateTime? agreedAt,
    DateTime? createdAt,
  }) {
    return AgencyTermsAgreement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      agencyName: agencyName ?? this.agencyName,
      agencyContactEmail: agencyContactEmail ?? this.agencyContactEmail,
      agencyContactPhone: agencyContactPhone ?? this.agencyContactPhone,
      individualResponsibilityAcknowledged: individualResponsibilityAcknowledged ?? this.individualResponsibilityAcknowledged,
      platformTermsVersion: platformTermsVersion ?? this.platformTermsVersion,
      agreementIpAddress: agreementIpAddress ?? this.agreementIpAddress,
      agreementUserAgent: agreementUserAgent ?? this.agreementUserAgent,
      agreedAt: agreedAt ?? this.agreedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// JSON変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'agency_name': agencyName,
      'agency_contact_email': agencyContactEmail,
      'agency_contact_phone': agencyContactPhone,
      'individual_responsibility_acknowledged': individualResponsibilityAcknowledged,
      'platform_terms_version': platformTermsVersion,
      'agreement_ip_address': agreementIpAddress,
      'agreement_user_agent': agreementUserAgent,
      'agreed_at': agreedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// JSONからの変換
  factory AgencyTermsAgreement.fromJson(Map<String, dynamic> json) {
    return AgencyTermsAgreement(
      id: json['id'],
      userId: json['user_id'],
      agencyName: json['agency_name'],
      agencyContactEmail: json['agency_contact_email'],
      agencyContactPhone: json['agency_contact_phone'],
      individualResponsibilityAcknowledged: json['individual_responsibility_acknowledged'] ?? false,
      platformTermsVersion: json['platform_terms_version'],
      agreementIpAddress: json['agreement_ip_address'],
      agreementUserAgent: json['agreement_user_agent'],
      agreedAt: json['agreed_at'] != null ? DateTime.parse(json['agreed_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        agencyName,
        agencyContactEmail,
        agencyContactPhone,
        individualResponsibilityAcknowledged,
        platformTermsVersion,
        agreementIpAddress,
        agreementUserAgent,
        agreedAt,
        createdAt,
      ];

  @override
  bool get stringify => true;
}

/// 事務所規約同意結果
class AgencyTermsAgreementResult extends Equatable {
  final bool isSuccess;
  final String? agreementId;
  final String? message;
  final String? error;

  const AgencyTermsAgreementResult({
    required this.isSuccess,
    this.agreementId,
    this.message,
    this.error,
  });

  const AgencyTermsAgreementResult.success({
    required String agreementId,
    String? message,
  }) : this(
          isSuccess: true,
          agreementId: agreementId,
          message: message,
        );

  const AgencyTermsAgreementResult.failure({
    required String error,
  }) : this(
          isSuccess: false,
          error: error,
        );

  @override
  List<Object?> get props => [isSuccess, agreementId, message, error];

  @override
  bool get stringify => true;
} 