import 'package:flutter/foundation.dart';

/// 利用規約バージョンを表すクラス
class TermsVersion {
  final String id;
  final String version;
  final DateTime effectiveDate;
  final String content;
  final bool isCurrent;
  
  /// コンストラクタ
  TermsVersion({
    required this.id,
    required this.version,
    required this.effectiveDate,
    required this.content,
    required this.isCurrent,
  });
  
  /// JSONからTermsVersionを生成するファクトリメソッド
  factory TermsVersion.fromJson(Map<String, dynamic> json) {
    return TermsVersion(
      id: json['id'],
      version: json['version'],
      effectiveDate: DateTime.parse(json['effectiveDate']),
      content: json['content'],
      isCurrent: json['isCurrent'],
    );
  }
  
  /// TermsVersionをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'effectiveDate': effectiveDate.toIso8601String(),
      'content': content,
      'isCurrent': isCurrent,
    };
  }
}

/// プライバシーポリシーバージョンを表すクラス
class PrivacyPolicyVersion {
  final String id;
  final String version;
  final DateTime effectiveDate;
  final String content;
  final bool isCurrent;
  
  /// コンストラクタ
  PrivacyPolicyVersion({
    required this.id,
    required this.version,
    required this.effectiveDate,
    required this.content,
    required this.isCurrent,
  });
  
  /// JSONからPrivacyPolicyVersionを生成するファクトリメソッド
  factory PrivacyPolicyVersion.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyVersion(
      id: json['id'],
      version: json['version'],
      effectiveDate: DateTime.parse(json['effectiveDate']),
      content: json['content'],
      isCurrent: json['isCurrent'],
    );
  }
  
  /// PrivacyPolicyVersionをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'effectiveDate': effectiveDate.toIso8601String(),
      'content': content,
      'isCurrent': isCurrent,
    };
  }
}

/// ユーザー同意を表すクラス
class UserConsent {
  final String id;
  final String userId;
  final String documentId;
  final String documentType;
  final String documentVersion;
  final DateTime consentDate;
  final String? ipAddress;
  final String? deviceInfo;
  
  /// コンストラクタ
  UserConsent({
    required this.id,
    required this.userId,
    required this.documentId,
    required this.documentType,
    required this.documentVersion,
    required this.consentDate,
    this.ipAddress,
    this.deviceInfo,
  });
  
  /// JSONからUserConsentを生成するファクトリメソッド
  factory UserConsent.fromJson(Map<String, dynamic> json) {
    return UserConsent(
      id: json['id'],
      userId: json['userId'],
      documentId: json['documentId'],
      documentType: json['documentType'],
      documentVersion: json['documentVersion'],
      consentDate: DateTime.parse(json['consentDate']),
      ipAddress: json['ipAddress'],
      deviceInfo: json['deviceInfo'],
    );
  }
  
  /// UserConsentをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': json['userId'],
      'documentId': documentId,
      'documentType': documentType,
      'documentVersion': documentVersion,
      'consentDate': consentDate.toIso8601String(),
      'ipAddress': ipAddress,
      'deviceInfo': deviceInfo,
    };
  }
}

/// 年齢確認方法を表すenum
enum AgeVerificationMethod {
  /// 自己申告
  selfDeclaration,
  
  /// クレジットカード確認
  creditCard,
  
  /// 身分証明書
  idDocument,
  
  /// 携帯電話認証
  mobileCarrier,
  
  /// 第三者サービス
  thirdPartyService,
}

/// 年齢確認ステータスを表すenum
enum AgeVerificationStatus {
  /// 未確認
  unverified,
  
  /// 確認中
  pending,
  
  /// 確認済み
  verified,
  
  /// 拒否
  rejected,
  
  /// 期限切れ
  expired,
}

/// 年齢確認を表すクラス
class AgeVerification {
  final String id;
  final String userId;
  final AgeVerificationMethod method;
  final AgeVerificationStatus status;
  final DateTime? verificationDate;
  final DateTime? expirationDate;
  final String? verificationData;
  final String? rejectionReason;
  
  /// コンストラクタ
  AgeVerification({
    required this.id,
    required this.userId,
    required this.method,
    required this.status,
    this.verificationDate,
    this.expirationDate,
    this.verificationData,
    this.rejectionReason,
  });
  
  /// JSONからAgeVerificationを生成するファクトリメソッド
  factory AgeVerification.fromJson(Map<String, dynamic> json) {
    return AgeVerification(
      id: json['id'],
      userId: json['userId'],
      method: AgeVerificationMethod.values.firstWhere(
        (e) => e.toString() == 'AgeVerificationMethod.${json['method']}',
        orElse: () => AgeVerificationMethod.selfDeclaration,
      ),
      status: AgeVerificationStatus.values.firstWhere(
        (e) => e.toString() == 'AgeVerificationStatus.${json['status']}',
        orElse: () => AgeVerificationStatus.unverified,
      ),
      verificationDate: json['verificationDate'] != null ? DateTime.parse(json['verificationDate']) : null,
      expirationDate: json['expirationDate'] != null ? DateTime.parse(json['expirationDate']) : null,
      verificationData: json['verificationData'],
      rejectionReason: json['rejectionReason'],
    );
  }
  
  /// AgeVerificationをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'method': method.toString().split('.').last,
      'status': status.toString().split('.').last,
      'verificationDate': verificationDate?.toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
      'verificationData': verificationData,
      'rejectionReason': rejectionReason,
    };
  }
  
  /// 属性を変更した新しいインスタンスを作成するメソッド
  AgeVerification copyWith({
    String? id,
    String? userId,
    AgeVerificationMethod? method,
    AgeVerificationStatus? status,
    DateTime? verificationDate,
    DateTime? expirationDate,
    String? verificationData,
    String? rejectionReason,
  }) {
    return AgeVerification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      method: method ?? this.method,
      status: status ?? this.status,
      verificationDate: verificationDate ?? this.verificationDate,
      expirationDate: expirationDate ?? this.expirationDate,
      verificationData: verificationData ?? this.verificationData,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

/// コンテンツ年齢制限を表すenum
enum ContentAgeRestriction {
  /// 全年齢
  general,
  
  /// 12歳以上
  teen,
  
  /// 15歳以上
  mature,
  
  /// 18歳以上
  adult,
}

/// 著作権保護タイプを表すenum
enum CopyrightProtectionType {
  /// 通常著作権
  standard,
  
  /// クリエイティブコモンズ
  creativeCommons,
  
  /// 独自ライセンス
  customLicense,
}

/// 著作権保護を表すクラス
class CopyrightProtection {
  final String id;
  final String contentId;
  final String ownerId;
  final CopyrightProtectionType protectionType;
  final String? licenseDetails;
  final String? fingerprint;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  /// コンストラクタ
  CopyrightProtection({
    required this.id,
    required this.contentId,
    required this.ownerId,
    required this.protectionType,
    this.licenseDetails,
    this.fingerprint,
    required this.createdAt,
    this.updatedAt,
  });
  
  /// JSONからCopyrightProtectionを生成するファクトリメソッド
  factory CopyrightProtection.fromJson(Map<String, dynamic> json) {
    return CopyrightProtection(
      id: json['id'],
      contentId: json['contentId'],
      ownerId: json['ownerId'],
      protectionType: CopyrightProtectionType.values.firstWhere(
        (e) => e.toString() == 'CopyrightProtectionType.${json['protectionType']}',
        orElse: () => CopyrightProtectionType.standard,
      ),
      licenseDetails: json['licenseDetails'],
      fingerprint: json['fingerprint'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
  
  /// CopyrightProtectionをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentId': contentId,
      'ownerId': ownerId,
      'protectionType': protectionType.toString().split('.').last,
      'licenseDetails': licenseDetails,
      'fingerprint': fingerprint,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
  
  /// 属性を変更した新しいインスタンスを作成するメソッド
  CopyrightProtection copyWith({
    String? id,
    String? contentId,
    String? ownerId,
    CopyrightProtectionType? protectionType,
    String? licenseDetails,
    String? fingerprint,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CopyrightProtection(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      ownerId: ownerId ?? this.ownerId,
      protectionType: protectionType ?? this.protectionType,
      licenseDetails: licenseDetails ?? this.licenseDetails,
      fingerprint: fingerprint ?? this.fingerprint,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
