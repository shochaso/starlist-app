import '../models/legal/legal_compliance_model.dart';

/// 著作権保護リポジトリの抽象インターフェース
abstract class CopyrightProtectionRepository {
  /// コンテンツの著作権保護情報を取得する
  Future<CopyrightProtection?> getContentCopyrightProtection(String contentId);
  
  /// 著作権保護情報を作成する
  Future<CopyrightProtection> createCopyrightProtection(CopyrightProtection protection);
  
  /// 著作権保護情報を更新する
  Future<CopyrightProtection> updateCopyrightProtection(CopyrightProtection protection);
  
  /// コンテンツのフィンガープリントを検索する
  Future<List<String>> findContentByFingerprint(String fingerprint, {double similarityThreshold = 0.9});
  
  /// 著作権侵害報告を作成する
  Future<Map<String, dynamic>> createCopyrightInfringementReport(String contentId, String reporterId, String originalContentId, String reason);
  
  /// 著作権侵害報告を取得する
  Future<List<Map<String, dynamic>>> getCopyrightInfringementReports({String? contentId, String? reporterId, String? status});
  
  /// 著作権侵害報告のステータスを更新する
  Future<Map<String, dynamic>> updateInfringementReportStatus(String reportId, String status, String? resolution);
}
