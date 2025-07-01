
/// コンテンツモデレーションステータスを表すenum
enum ContentModerationStatus {
  /// 審査待ち
  pending,
  
  /// 承認済み
  approved,
  
  /// 拒否
  rejected,
  
  /// 削除済み
  removed,
  
  /// 自動フラグ付け
  autoFlagged,
}

/// コンテンツ報告理由を表すenum
enum ContentReportReason {
  /// 不適切なコンテンツ
  inappropriate,
  
  /// スパム
  spam,
  
  /// ハラスメント
  harassment,
  
  /// 暴力
  violence,
  
  /// 著作権侵害
  copyright,
  
  /// その他
  other,
}

/// コンテンツ報告を表すクラス
class ContentReport {
  final String id;
  final String contentId;
  final String reporterId;
  final ContentReportReason reason;
  final String? description;
  final List<String>? evidenceUrls;
  final ContentModerationStatus status;
  final String? moderatorId;
  final String? moderatorNote;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  
  /// コンストラクタ
  ContentReport({
    required this.id,
    required this.contentId,
    required this.reporterId,
    required this.reason,
    this.description,
    this.evidenceUrls,
    required this.status,
    this.moderatorId,
    this.moderatorNote,
    required this.createdAt,
    this.resolvedAt,
  });
  
  /// JSONからContentReportを生成するファクトリメソッド
  factory ContentReport.fromJson(Map<String, dynamic> json) {
    return ContentReport(
      id: json['id'],
      contentId: json['contentId'],
      reporterId: json['reporterId'],
      reason: ContentReportReason.values.firstWhere(
        (e) => e.toString() == 'ContentReportReason.${json['reason']}',
        orElse: () => ContentReportReason.other,
      ),
      description: json['description'],
      evidenceUrls: json['evidenceUrls'] != null 
          ? List<String>.from(json['evidenceUrls']) 
          : null,
      status: ContentModerationStatus.values.firstWhere(
        (e) => e.toString() == 'ContentModerationStatus.${json['status']}',
        orElse: () => ContentModerationStatus.pending,
      ),
      moderatorId: json['moderatorId'],
      moderatorNote: json['moderatorNote'],
      createdAt: DateTime.parse(json['createdAt']),
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
    );
  }
  
  /// ContentReportをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentId': contentId,
      'reporterId': reporterId,
      'reason': reason.toString().split('.').last,
      'description': description,
      'evidenceUrls': evidenceUrls,
      'status': status.toString().split('.').last,
      'moderatorId': moderatorId,
      'moderatorNote': moderatorNote,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }
  
  /// 属性を変更した新しいインスタンスを作成するメソッド
  ContentReport copyWith({
    String? id,
    String? contentId,
    String? reporterId,
    ContentReportReason? reason,
    String? description,
    List<String>? evidenceUrls,
    ContentModerationStatus? status,
    String? moderatorId,
    String? moderatorNote,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return ContentReport(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      reporterId: reporterId ?? this.reporterId,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      evidenceUrls: evidenceUrls ?? this.evidenceUrls,
      status: status ?? this.status,
      moderatorId: moderatorId ?? this.moderatorId,
      moderatorNote: moderatorNote ?? this.moderatorNote,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}

/// モデレーションアクションを表すenum
enum ModerationAction {
  /// 承認
  approve,
  
  /// 拒否
  reject,
  
  /// 削除
  remove,
  
  /// 警告
  warn,
  
  /// 一時停止
  suspend,
  
  /// 永久停止
  ban,
}

/// モデレーションログを表すクラス
class ModerationLog {
  final String id;
  final String contentId;
  final String? reportId;
  final String moderatorId;
  final ModerationAction action;
  final String? reason;
  final DateTime timestamp;
  
  /// コンストラクタ
  ModerationLog({
    required this.id,
    required this.contentId,
    this.reportId,
    required this.moderatorId,
    required this.action,
    this.reason,
    required this.timestamp,
  });
  
  /// JSONからModerationLogを生成するファクトリメソッド
  factory ModerationLog.fromJson(Map<String, dynamic> json) {
    return ModerationLog(
      id: json['id'],
      contentId: json['contentId'],
      reportId: json['reportId'],
      moderatorId: json['moderatorId'],
      action: ModerationAction.values.firstWhere(
        (e) => e.toString() == 'ModerationAction.${json['action']}',
        orElse: () => ModerationAction.approve,
      ),
      reason: json['reason'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
  
  /// ModerationLogをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentId': contentId,
      'reportId': reportId,
      'moderatorId': moderatorId,
      'action': action.toString().split('.').last,
      'reason': reason,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  /// 属性を変更した新しいインスタンスを作成するメソッド
  ModerationLog copyWith({
    String? id,
    String? contentId,
    String? reportId,
    String? moderatorId,
    ModerationAction? action,
    String? reason,
    DateTime? timestamp,
  }) {
    return ModerationLog(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      reportId: reportId ?? this.reportId,
      moderatorId: moderatorId ?? this.moderatorId,
      action: action ?? this.action,
      reason: reason ?? this.reason,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// コンテンツモデレーション結果を表すクラス
class ModerationResult {
  final bool success;
  final String? errorMessage;
  final ContentReport? report;
  final ModerationLog? log;
  
  /// コンストラクタ
  ModerationResult({
    required this.success,
    this.errorMessage,
    this.report,
    this.log,
  });
  
  /// 成功結果を作成するファクトリメソッド
  factory ModerationResult.success({ContentReport? report, ModerationLog? log}) {
    return ModerationResult(
      success: true,
      report: report,
      log: log,
    );
  }
  
  /// 失敗結果を作成するファクトリメソッド
  factory ModerationResult.failure(String errorMessage) {
    return ModerationResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}
