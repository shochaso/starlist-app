import '../models/admin/content_moderation_model.dart';

/// コンテンツモデレーションリポジトリの抽象インターフェース
abstract class ContentModerationRepository {
  /// 報告されたコンテンツを取得する
  Future<List<ContentReport>> getReportedContent({ContentModerationStatus? status, int limit = 20, int offset = 0});
  
  /// 報告数を取得する
  Future<int> countReports({ContentModerationStatus? status});
  
  /// コンテンツ報告を作成する
  Future<ContentReport> createContentReport(ContentReport report);
  
  /// コンテンツ報告のステータスを更新する
  Future<ModerationResult> updateReportStatus(String reportId, ContentModerationStatus status, String moderatorId, String? note);
  
  /// モデレーションアクションを実行する
  Future<ModerationResult> performModerationAction(String contentId, ModerationAction action, String moderatorId, String? reason);
  
  /// モデレーションログを取得する
  Future<List<ModerationLog>> getModerationLogs(String contentId, {int limit = 20, int offset = 0});
  
  /// モデレーションログを記録する
  Future<ModerationLog> logModerationAction(ModerationLog log);
}
