import 'package:flutter/foundation.dart';

/// プレミアム質問のステータス
enum PremiumQuestionStatus {
  pending,  // 回答待ち
  answered, // 回答済み
  expired,  // 期限切れ
  refunded, // 返金済み
}

/// プレミアム質問通知タイプ
enum PremiumQuestionNotificationType {
  questionReceived, // 質問受信
  answerPosted,     // 回答投稿
  expiryWarning,    // 期限警告
  refundProcessed,  // 返金処理
}

/// プレミアム質問料金設定モデル
@immutable
class PremiumQuestionPricing {
  final String id;
  final String starId;
  final int basePrice;
  final double priorityMultiplier;
  final int maxQuestionsPerDay;
  final bool isAcceptingQuestions;
  final bool autoAnswerEnabled;
  final int responseTimeHours;
  final String refundPolicy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PremiumQuestionPricing({
    required this.id,
    required this.starId,
    required this.basePrice,
    required this.priorityMultiplier,
    required this.maxQuestionsPerDay,
    required this.isAcceptingQuestions,
    required this.autoAnswerEnabled,
    required this.responseTimeHours,
    required this.refundPolicy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSONからPremiumQuestionPricingを作成
  factory PremiumQuestionPricing.fromJson(Map<String, dynamic> json) {
    return PremiumQuestionPricing(
      id: json['id'],
      starId: json['star_id'],
      basePrice: json['base_price'] ?? 100,
      priorityMultiplier: (json['priority_multiplier'] ?? 1.0).toDouble(),
      maxQuestionsPerDay: json['max_questions_per_day'] ?? 5,
      isAcceptingQuestions: json['is_accepting_questions'] ?? true,
      autoAnswerEnabled: json['auto_answer_enabled'] ?? false,
      responseTimeHours: json['response_time_hours'] ?? 72,
      refundPolicy: json['refund_policy'] ?? 'auto_refund_after_expiry',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// PremiumQuestionPricingをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'star_id': starId,
      'base_price': basePrice,
      'priority_multiplier': priorityMultiplier,
      'max_questions_per_day': maxQuestionsPerDay,
      'is_accepting_questions': isAcceptingQuestions,
      'auto_answer_enabled': autoAnswerEnabled,
      'response_time_hours': responseTimeHours,
      'refund_policy': refundPolicy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// コピーを作成
  PremiumQuestionPricing copyWith({
    String? id,
    String? starId,
    int? basePrice,
    double? priorityMultiplier,
    int? maxQuestionsPerDay,
    bool? isAcceptingQuestions,
    bool? autoAnswerEnabled,
    int? responseTimeHours,
    String? refundPolicy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PremiumQuestionPricing(
      id: id ?? this.id,
      starId: starId ?? this.starId,
      basePrice: basePrice ?? this.basePrice,
      priorityMultiplier: priorityMultiplier ?? this.priorityMultiplier,
      maxQuestionsPerDay: maxQuestionsPerDay ?? this.maxQuestionsPerDay,
      isAcceptingQuestions: isAcceptingQuestions ?? this.isAcceptingQuestions,
      autoAnswerEnabled: autoAnswerEnabled ?? this.autoAnswerEnabled,
      responseTimeHours: responseTimeHours ?? this.responseTimeHours,
      refundPolicy: refundPolicy ?? this.refundPolicy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 計算された質問料金
  int get calculatedPrice => (basePrice * priorityMultiplier).round();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PremiumQuestionPricing &&
        other.id == id &&
        other.starId == starId &&
        other.basePrice == basePrice &&
        other.priorityMultiplier == priorityMultiplier &&
        other.maxQuestionsPerDay == maxQuestionsPerDay &&
        other.isAcceptingQuestions == isAcceptingQuestions &&
        other.autoAnswerEnabled == autoAnswerEnabled &&
        other.responseTimeHours == responseTimeHours &&
        other.refundPolicy == refundPolicy &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        starId,
        basePrice,
        priorityMultiplier,
        maxQuestionsPerDay,
        isAcceptingQuestions,
        autoAnswerEnabled,
        responseTimeHours,
        refundPolicy,
        createdAt,
        updatedAt,
      );
}

/// プレミアム質問モデル
@immutable
class PremiumQuestion {
  final String id;
  final String questionerId;
  final String starId;
  final String questionText;
  final String optionA;
  final String optionB;
  final int questionCost;
  final DateTime expiresAt;
  final PremiumQuestionStatus status;
  final String? starAnswer; // 'A', 'B', または null
  final String? answerExplanation;
  final DateTime? answeredAt;
  final bool isPublic;
  final int sPointsSpent;
  final int sPointsRefunded;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PremiumQuestion({
    required this.id,
    required this.questionerId,
    required this.starId,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.questionCost,
    required this.expiresAt,
    required this.status,
    this.starAnswer,
    this.answerExplanation,
    this.answeredAt,
    required this.isPublic,
    required this.sPointsSpent,
    required this.sPointsRefunded,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSONからPremiumQuestionを作成
  factory PremiumQuestion.fromJson(Map<String, dynamic> json) {
    return PremiumQuestion(
      id: json['id'],
      questionerId: json['questioner_id'],
      starId: json['star_id'],
      questionText: json['question_text'],
      optionA: json['option_a'],
      optionB: json['option_b'],
      questionCost: json['question_cost'],
      expiresAt: DateTime.parse(json['expires_at']),
      status: _parseStatus(json['status']),
      starAnswer: json['star_answer'],
      answerExplanation: json['answer_explanation'],
      answeredAt: json['answered_at'] != null ? DateTime.parse(json['answered_at']) : null,
      isPublic: json['is_public'] ?? false,
      sPointsSpent: json['s_points_spent'],
      sPointsRefunded: json['s_points_refunded'] ?? 0,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// PremiumQuestionをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questioner_id': questionerId,
      'star_id': starId,
      'question_text': questionText,
      'option_a': optionA,
      'option_b': optionB,
      'question_cost': questionCost,
      'expires_at': expiresAt.toIso8601String(),
      'status': _statusToString(status),
      'star_answer': starAnswer,
      'answer_explanation': answerExplanation,
      'answered_at': answeredAt?.toIso8601String(),
      'is_public': isPublic,
      's_points_spent': sPointsSpent,
      's_points_refunded': sPointsRefunded,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// コピーを作成
  PremiumQuestion copyWith({
    String? id,
    String? questionerId,
    String? starId,
    String? questionText,
    String? optionA,
    String? optionB,
    int? questionCost,
    DateTime? expiresAt,
    PremiumQuestionStatus? status,
    String? starAnswer,
    String? answerExplanation,
    DateTime? answeredAt,
    bool? isPublic,
    int? sPointsSpent,
    int? sPointsRefunded,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PremiumQuestion(
      id: id ?? this.id,
      questionerId: questionerId ?? this.questionerId,
      starId: starId ?? this.starId,
      questionText: questionText ?? this.questionText,
      optionA: optionA ?? this.optionA,
      optionB: optionB ?? this.optionB,
      questionCost: questionCost ?? this.questionCost,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      starAnswer: starAnswer ?? this.starAnswer,
      answerExplanation: answerExplanation ?? this.answerExplanation,
      answeredAt: answeredAt ?? this.answeredAt,
      isPublic: isPublic ?? this.isPublic,
      sPointsSpent: sPointsSpent ?? this.sPointsSpent,
      sPointsRefunded: sPointsRefunded ?? this.sPointsRefunded,
      metadata: metadata ?? Map<String, dynamic>.from(this.metadata),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// ステータス解析
  static PremiumQuestionStatus _parseStatus(String status) {
    switch (status) {
      case 'pending':
        return PremiumQuestionStatus.pending;
      case 'answered':
        return PremiumQuestionStatus.answered;
      case 'expired':
        return PremiumQuestionStatus.expired;
      case 'refunded':
        return PremiumQuestionStatus.refunded;
      default:
        return PremiumQuestionStatus.pending;
    }
  }

  /// ステータスを文字列に変換
  static String _statusToString(PremiumQuestionStatus status) {
    switch (status) {
      case PremiumQuestionStatus.pending:
        return 'pending';
      case PremiumQuestionStatus.answered:
        return 'answered';
      case PremiumQuestionStatus.expired:
        return 'expired';
      case PremiumQuestionStatus.refunded:
        return 'refunded';
    }
  }

  /// 期限切れかどうか
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// 回答待ちかどうか
  bool get isPending => status == PremiumQuestionStatus.pending && !isExpired;

  /// 回答済みかどうか
  bool get isAnswered => status == PremiumQuestionStatus.answered;

  /// 返金済みかどうか
  bool get isRefunded => status == PremiumQuestionStatus.refunded || sPointsRefunded > 0;

  /// 期限までの残り時間
  Duration? get timeRemaining {
    if (isExpired) return null;
    return expiresAt.difference(DateTime.now());
  }

  /// 期限までの時間（時間単位）
  int? get hoursRemaining {
    final remaining = timeRemaining;
    if (remaining == null) return null;
    return remaining.inHours;
  }

  /// 回答選択肢Aかどうか
  bool get isAnswerA => starAnswer == 'A';

  /// 回答選択肢Bかどうか
  bool get isAnswerB => starAnswer == 'B';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PremiumQuestion &&
        other.id == id &&
        other.questionerId == questionerId &&
        other.starId == starId &&
        other.questionText == questionText &&
        other.optionA == optionA &&
        other.optionB == optionB &&
        other.questionCost == questionCost &&
        other.expiresAt == expiresAt &&
        other.status == status &&
        other.starAnswer == starAnswer &&
        other.answerExplanation == answerExplanation &&
        other.answeredAt == answeredAt &&
        other.isPublic == isPublic &&
        other.sPointsSpent == sPointsSpent &&
        other.sPointsRefunded == sPointsRefunded &&
        mapEquals(other.metadata, metadata) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        questionerId,
        starId,
        questionText,
        optionA,
        optionB,
        questionCost,
        expiresAt,
        status,
        starAnswer,
        answerExplanation,
        answeredAt,
        isPublic,
        sPointsSpent,
        sPointsRefunded,
        metadata,
        createdAt,
        updatedAt,
      );
}

/// プレミアム質問通知モデル
@immutable
class PremiumQuestionNotification {
  final String id;
  final String questionId;
  final String userId;
  final PremiumQuestionNotificationType notificationType;
  final String message;
  final bool isRead;
  final DateTime sentAt;

  const PremiumQuestionNotification({
    required this.id,
    required this.questionId,
    required this.userId,
    required this.notificationType,
    required this.message,
    required this.isRead,
    required this.sentAt,
  });

  /// JSONからPremiumQuestionNotificationを作成
  factory PremiumQuestionNotification.fromJson(Map<String, dynamic> json) {
    return PremiumQuestionNotification(
      id: json['id'],
      questionId: json['question_id'],
      userId: json['user_id'],
      notificationType: _parseNotificationType(json['notification_type']),
      message: json['message'],
      isRead: json['is_read'] ?? false,
      sentAt: DateTime.parse(json['sent_at']),
    );
  }

  /// PremiumQuestionNotificationをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'user_id': userId,
      'notification_type': _notificationTypeToString(notificationType),
      'message': message,
      'is_read': isRead,
      'sent_at': sentAt.toIso8601String(),
    };
  }

  /// 通知タイプの解析
  static PremiumQuestionNotificationType _parseNotificationType(String type) {
    switch (type) {
      case 'question_received':
        return PremiumQuestionNotificationType.questionReceived;
      case 'answer_posted':
        return PremiumQuestionNotificationType.answerPosted;
      case 'expiry_warning':
        return PremiumQuestionNotificationType.expiryWarning;
      case 'refund_processed':
        return PremiumQuestionNotificationType.refundProcessed;
      default:
        return PremiumQuestionNotificationType.questionReceived;
    }
  }

  /// 通知タイプを文字列に変換
  static String _notificationTypeToString(PremiumQuestionNotificationType type) {
    switch (type) {
      case PremiumQuestionNotificationType.questionReceived:
        return 'question_received';
      case PremiumQuestionNotificationType.answerPosted:
        return 'answer_posted';
      case PremiumQuestionNotificationType.expiryWarning:
        return 'expiry_warning';
      case PremiumQuestionNotificationType.refundProcessed:
        return 'refund_processed';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PremiumQuestionNotification &&
        other.id == id &&
        other.questionId == questionId &&
        other.userId == userId &&
        other.notificationType == notificationType &&
        other.message == message &&
        other.isRead == isRead &&
        other.sentAt == sentAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        questionId,
        userId,
        notificationType,
        message,
        isRead,
        sentAt,
      );
}

/// プレミアム質問の結果
@immutable
class PremiumQuestionResult {
  final bool success;
  final String message;
  final String? questionId;
  final int? cost;
  final DateTime? expiresAt;
  final int? refundedQuestions;

  const PremiumQuestionResult({
    required this.success,
    required this.message,
    this.questionId,
    this.cost,
    this.expiresAt,
    this.refundedQuestions,
  });

  /// JSONからPremiumQuestionResultを作成
  factory PremiumQuestionResult.fromJson(Map<String, dynamic> json) {
    return PremiumQuestionResult(
      success: json['success'] ?? false,
      message: json['message'] ?? json['error'] ?? '',
      questionId: json['question_id'],
      cost: json['cost'],
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
      refundedQuestions: json['refunded_questions'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PremiumQuestionResult &&
        other.success == success &&
        other.message == message &&
        other.questionId == questionId &&
        other.cost == cost &&
        other.expiresAt == expiresAt &&
        other.refundedQuestions == refundedQuestions;
  }

  @override
  int get hashCode => Object.hash(
        success,
        message,
        questionId,
        cost,
        expiresAt,
        refundedQuestions,
      );
}

/// プレミアム質問統計モデル
@immutable
class PremiumQuestionStatistics {
  final String starId;
  final int totalQuestions;
  final int answeredQuestions;
  final int pendingQuestions;
  final int expiredQuestions;
  final double answerRate;
  final Duration averageResponseTime;
  final int totalEarnings;

  const PremiumQuestionStatistics({
    required this.starId,
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.pendingQuestions,
    required this.expiredQuestions,
    required this.answerRate,
    required this.averageResponseTime,
    required this.totalEarnings,
  });

  /// 統計を計算
  factory PremiumQuestionStatistics.calculate(List<PremiumQuestion> questions) {
    if (questions.isEmpty) {
      return PremiumQuestionStatistics(
        starId: '',
        totalQuestions: 0,
        answeredQuestions: 0,
        pendingQuestions: 0,
        expiredQuestions: 0,
        answerRate: 0.0,
        averageResponseTime: Duration.zero,
        totalEarnings: 0,
      );
    }

    final starId = questions.first.starId;
    final totalQuestions = questions.length;
    final answeredQuestions = questions.where((q) => q.isAnswered).length;
    final pendingQuestions = questions.where((q) => q.isPending).length;
    final expiredQuestions = questions.where((q) => q.status == PremiumQuestionStatus.expired).length;
    
    final answerRate = totalQuestions > 0 ? answeredQuestions / totalQuestions : 0.0;
    
    // 平均回答時間を計算
    final answeredWithTime = questions.where((q) => q.isAnswered && q.answeredAt != null);
    Duration totalResponseTime = Duration.zero;
    
    for (final question in answeredWithTime) {
      final responseTime = question.answeredAt!.difference(question.createdAt);
      totalResponseTime += responseTime;
    }
    
    final averageResponseTime = answeredWithTime.isNotEmpty
        ? Duration(milliseconds: totalResponseTime.inMilliseconds ~/ answeredWithTime.length)
        : Duration.zero;
    
    // 総収益を計算（返金分を除く）
    final totalEarnings = questions
        .where((q) => q.isAnswered)
        .map((q) => q.sPointsSpent - q.sPointsRefunded)
        .fold(0, (sum, earnings) => sum + earnings);

    return PremiumQuestionStatistics(
      starId: starId,
      totalQuestions: totalQuestions,
      answeredQuestions: answeredQuestions,
      pendingQuestions: pendingQuestions,
      expiredQuestions: expiredQuestions,
      answerRate: answerRate,
      averageResponseTime: averageResponseTime,
      totalEarnings: totalEarnings,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PremiumQuestionStatistics &&
        other.starId == starId &&
        other.totalQuestions == totalQuestions &&
        other.answeredQuestions == answeredQuestions &&
        other.pendingQuestions == pendingQuestions &&
        other.expiredQuestions == expiredQuestions &&
        other.answerRate == answerRate &&
        other.averageResponseTime == averageResponseTime &&
        other.totalEarnings == totalEarnings;
  }

  @override
  int get hashCode => Object.hash(
        starId,
        totalQuestions,
        answeredQuestions,
        pendingQuestions,
        expiredQuestions,
        answerRate,
        averageResponseTime,
        totalEarnings,
      );
}