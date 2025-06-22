import 'package:flutter/material.dart';

/// Super Chatイベントタイプ
enum SuperChatEventType {
  liveStream,   // ライブ配信
  specialEvent, // 特別イベント
  milestone,    // マイルストーン
  qaSession,    // Q&Aセッション
}

/// Super Chat通貨タイプ
enum SuperChatCurrency {
  spt, // スターP
  jpy, // 日本円
  usd, // 米ドル
}

/// Super Chatメッセージモデル
@immutable
class SuperChatMessage {
  final String id;
  final String senderId;
  final String starId;
  final String? contentId;
  final String message;
  final int amount;
  final SuperChatCurrency currency;
  final int tierLevel;
  final Color backgroundColor;
  final Color textColor;
  final bool isPinned;
  final int pinDurationMinutes;
  final DateTime? pinnedUntil;
  final bool isHighlighted;
  final int visibilityDurationMinutes;
  final DateTime visibleUntil;
  final String? starReply;
  final DateTime? starRepliedAt;
  final bool isFeatured;
  final int starPointsSpent;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SuperChatMessage({
    required this.id,
    required this.senderId,
    required this.starId,
    this.contentId,
    required this.message,
    required this.amount,
    required this.currency,
    required this.tierLevel,
    required this.backgroundColor,
    required this.textColor,
    required this.isPinned,
    required this.pinDurationMinutes,
    this.pinnedUntil,
    required this.isHighlighted,
    required this.visibilityDurationMinutes,
    required this.visibleUntil,
    this.starReply,
    this.starRepliedAt,
    required this.isFeatured,
    required this.starPointsSpent,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSONからSuperChatMessageを作成
  factory SuperChatMessage.fromJson(Map<String, dynamic> json) {
    return SuperChatMessage(
      id: json['id'],
      senderId: json['sender_id'],
      starId: json['star_id'],
      contentId: json['content_id'],
      message: json['message'],
      amount: json['amount'],
      currency: _parseCurrency(json['currency']),
      tierLevel: json['tier_level'],
      backgroundColor: _parseColor(json['background_color']),
      textColor: _parseColor(json['text_color']),
      isPinned: json['is_pinned'] ?? false,
      pinDurationMinutes: json['pin_duration_minutes'] ?? 5,
      pinnedUntil: json['pinned_until'] != null ? DateTime.parse(json['pinned_until']) : null,
      isHighlighted: json['is_highlighted'] ?? true,
      visibilityDurationMinutes: json['visibility_duration_minutes'] ?? 60,
      visibleUntil: DateTime.parse(json['visible_until']),
      starReply: json['star_reply'],
      starRepliedAt: json['star_replied_at'] != null ? DateTime.parse(json['star_replied_at']) : null,
      isFeatured: json['is_featured'] ?? false,
      starPointsSpent: json['s_points_spent'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// SuperChatMessageをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'star_id': starId,
      'content_id': contentId,
      'message': message,
      'amount': amount,
      'currency': _currencyToString(currency),
      'tier_level': tierLevel,
      'background_color': _colorToString(backgroundColor),
      'text_color': _colorToString(textColor),
      'is_pinned': isPinned,
      'pin_duration_minutes': pinDurationMinutes,
      'pinned_until': pinnedUntil?.toIso8601String(),
      'is_highlighted': isHighlighted,
      'visibility_duration_minutes': visibilityDurationMinutes,
      'visible_until': visibleUntil.toIso8601String(),
      'star_reply': starReply,
      'star_replied_at': starRepliedAt?.toIso8601String(),
      'is_featured': isFeatured,
      's_points_spent': starPointsSpent,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// コピーを作成
  SuperChatMessage copyWith({
    String? id,
    String? senderId,
    String? starId,
    String? contentId,
    String? message,
    int? amount,
    SuperChatCurrency? currency,
    int? tierLevel,
    Color? backgroundColor,
    Color? textColor,
    bool? isPinned,
    int? pinDurationMinutes,
    DateTime? pinnedUntil,
    bool? isHighlighted,
    int? visibilityDurationMinutes,
    DateTime? visibleUntil,
    String? starReply,
    DateTime? starRepliedAt,
    bool? isFeatured,
    int? starPointsSpent,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SuperChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      starId: starId ?? this.starId,
      contentId: contentId ?? this.contentId,
      message: message ?? this.message,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      tierLevel: tierLevel ?? this.tierLevel,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      isPinned: isPinned ?? this.isPinned,
      pinDurationMinutes: pinDurationMinutes ?? this.pinDurationMinutes,
      pinnedUntil: pinnedUntil ?? this.pinnedUntil,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      visibilityDurationMinutes: visibilityDurationMinutes ?? this.visibilityDurationMinutes,
      visibleUntil: visibleUntil ?? this.visibleUntil,
      starReply: starReply ?? this.starReply,
      starRepliedAt: starRepliedAt ?? this.starRepliedAt,
      isFeatured: isFeatured ?? this.isFeatured,
      starPointsSpent: starPointsSpent ?? this.starPointsSpent,
      metadata: metadata ?? Map<String, dynamic>.from(this.metadata),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 通貨の解析
  static SuperChatCurrency _parseCurrency(String currency) {
    switch (currency.toUpperCase()) {
      case 'SPT':
        return SuperChatCurrency.spt;
      case 'JPY':
        return SuperChatCurrency.jpy;
      case 'USD':
        return SuperChatCurrency.usd;
      default:
        return SuperChatCurrency.spt;
    }
  }

  /// 通貨を文字列に変換
  static String _currencyToString(SuperChatCurrency currency) {
    switch (currency) {
      case SuperChatCurrency.spt:
        return 'SPT';
      case SuperChatCurrency.jpy:
        return 'JPY';
      case SuperChatCurrency.usd:
        return 'USD';
    }
  }

  /// 色の解析
  static Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue; // デフォルト色
    }
  }

  /// 色を文字列に変換
  static String _colorToString(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  /// メッセージが現在表示中かどうか
  bool get isCurrentlyVisible => DateTime.now().isBefore(visibleUntil);

  /// メッセージが現在ピン留めされているかどうか
  bool get isCurrentlyPinned => isPinned && (pinnedUntil == null || DateTime.now().isBefore(pinnedUntil!));

  /// スターが返信済みかどうか
  bool get hasStarReply => starReply != null && starReply!.isNotEmpty;

  /// ティアレベルに基づく表示優先度
  int get displayPriority => tierLevel * 1000 + (isPinned ? 100 : 0);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SuperChatMessage &&
        other.id == id &&
        other.senderId == senderId &&
        other.starId == starId &&
        other.contentId == contentId &&
        other.message == message &&
        other.amount == amount &&
        other.currency == currency &&
        other.tierLevel == tierLevel &&
        other.backgroundColor == backgroundColor &&
        other.textColor == textColor &&
        other.isPinned == isPinned &&
        other.pinDurationMinutes == pinDurationMinutes &&
        other.pinnedUntil == pinnedUntil &&
        other.isHighlighted == isHighlighted &&
        other.visibilityDurationMinutes == visibilityDurationMinutes &&
        other.visibleUntil == visibleUntil &&
        other.starReply == starReply &&
        other.starRepliedAt == starRepliedAt &&
        other.isFeatured == isFeatured &&
        other.starPointsSpent == starPointsSpent;
  }

  @override
  int get hashCode => Object.hash(
        id,
        senderId,
        starId,
        contentId,
        message,
        amount,
        currency,
        tierLevel,
        backgroundColor,
        textColor,
        isPinned,
        pinDurationMinutes,
        pinnedUntil,
        isHighlighted,
        visibilityDurationMinutes,
        visibleUntil,
        starReply,
        starRepliedAt,
        isFeatured,
        starPointsSpent,
      );
}

/// Super Chat料金設定モデル
@immutable
class SuperChatPricing {
  final String id;
  final String starId;
  final bool isEnabled;
  final int minAmount;
  final int maxAmount;
  final List<SuperChatTier> tiers;
  final double revenueShareRate;
  final bool autoReplyEnabled;
  final String? autoReplyMessage;
  final bool moderationEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SuperChatPricing({
    required this.id,
    required this.starId,
    required this.isEnabled,
    required this.minAmount,
    required this.maxAmount,
    required this.tiers,
    required this.revenueShareRate,
    required this.autoReplyEnabled,
    this.autoReplyMessage,
    required this.moderationEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSONからSuperChatPricingを作成
  factory SuperChatPricing.fromJson(Map<String, dynamic> json) {
    final tiers = [
      SuperChatTier(
        level: 1,
        threshold: json['tier_1_threshold'] ?? 100,
        duration: json['tier_1_duration'] ?? 5,
        color: SuperChatMessage._parseColor(json['tier_1_color'] ?? '#1976D2'),
      ),
      SuperChatTier(
        level: 2,
        threshold: json['tier_2_threshold'] ?? 500,
        duration: json['tier_2_duration'] ?? 15,
        color: SuperChatMessage._parseColor(json['tier_2_color'] ?? '#9C27B0'),
      ),
      SuperChatTier(
        level: 3,
        threshold: json['tier_3_threshold'] ?? 1000,
        duration: json['tier_3_duration'] ?? 30,
        color: SuperChatMessage._parseColor(json['tier_3_color'] ?? '#FF9800'),
      ),
      SuperChatTier(
        level: 4,
        threshold: json['tier_4_threshold'] ?? 2500,
        duration: json['tier_4_duration'] ?? 60,
        color: SuperChatMessage._parseColor(json['tier_4_color'] ?? '#F44336'),
      ),
      SuperChatTier(
        level: 5,
        threshold: json['tier_5_threshold'] ?? 5000,
        duration: json['tier_5_duration'] ?? 120,
        color: SuperChatMessage._parseColor(json['tier_5_color'] ?? '#FFD700'),
      ),
    ];

    return SuperChatPricing(
      id: json['id'],
      starId: json['star_id'],
      isEnabled: json['is_enabled'] ?? true,
      minAmount: json['min_amount'] ?? 100,
      maxAmount: json['max_amount'] ?? 10000,
      tiers: tiers,
      revenueShareRate: (json['revenue_share_rate'] ?? 80.0).toDouble(),
      autoReplyEnabled: json['auto_reply_enabled'] ?? false,
      autoReplyMessage: json['auto_reply_message'],
      moderationEnabled: json['moderation_enabled'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// SuperChatPricingをJSONに変換
  Map<String, dynamic> toJson() {
    final tiersJson = <String, dynamic>{};
    for (final tier in tiers) {
      tiersJson['tier_${tier.level}_threshold'] = tier.threshold;
      tiersJson['tier_${tier.level}_duration'] = tier.duration;
      tiersJson['tier_${tier.level}_color'] = SuperChatMessage._colorToString(tier.color);
    }

    return {
      'id': id,
      'star_id': starId,
      'is_enabled': isEnabled,
      'min_amount': minAmount,
      'max_amount': maxAmount,
      ...tiersJson,
      'revenue_share_rate': revenueShareRate,
      'auto_reply_enabled': autoReplyEnabled,
      'auto_reply_message': autoReplyMessage,
      'moderation_enabled': moderationEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 金額に基づいてティアを取得
  SuperChatTier getTierForAmount(int amount) {
    for (int i = tiers.length - 1; i >= 0; i--) {
      if (amount >= tiers[i].threshold) {
        return tiers[i];
      }
    }
    return tiers.first;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SuperChatPricing &&
        other.id == id &&
        other.starId == starId &&
        other.isEnabled == isEnabled &&
        other.minAmount == minAmount &&
        other.maxAmount == maxAmount &&
        listEquals(other.tiers, tiers) &&
        other.revenueShareRate == revenueShareRate &&
        other.autoReplyEnabled == autoReplyEnabled &&
        other.autoReplyMessage == autoReplyMessage &&
        other.moderationEnabled == moderationEnabled;
  }

  @override
  int get hashCode => Object.hash(
        id,
        starId,
        isEnabled,
        minAmount,
        maxAmount,
        tiers,
        revenueShareRate,
        autoReplyEnabled,
        autoReplyMessage,
        moderationEnabled,
      );
}

/// Super Chatティア情報
@immutable
class SuperChatTier {
  final int level;
  final int threshold;
  final int duration;
  final Color color;

  const SuperChatTier({
    required this.level,
    required this.threshold,
    required this.duration,
    required this.color,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SuperChatTier &&
        other.level == level &&
        other.threshold == threshold &&
        other.duration == duration &&
        other.color == color;
  }

  @override
  int get hashCode => Object.hash(level, threshold, duration, color);
}

/// Super Chatイベントモデル
@immutable
class SuperChatEvent {
  final String id;
  final String starId;
  final String title;
  final String? description;
  final SuperChatEventType eventType;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isActive;
  final int totalEarnings;
  final int messageCount;
  final String? topSupporterId;
  final int topSupportAmount;
  final double specialMultiplier;
  final int? goalAmount;
  final String? goalDescription;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SuperChatEvent({
    required this.id,
    required this.starId,
    required this.title,
    this.description,
    required this.eventType,
    required this.startTime,
    this.endTime,
    required this.isActive,
    required this.totalEarnings,
    required this.messageCount,
    this.topSupporterId,
    required this.topSupportAmount,
    required this.specialMultiplier,
    this.goalAmount,
    this.goalDescription,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSONからSuperChatEventを作成
  factory SuperChatEvent.fromJson(Map<String, dynamic> json) {
    return SuperChatEvent(
      id: json['id'],
      starId: json['star_id'],
      title: json['title'],
      description: json['description'],
      eventType: _parseEventType(json['event_type']),
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      isActive: json['is_active'] ?? true,
      totalEarnings: json['total_earnings'] ?? 0,
      messageCount: json['message_count'] ?? 0,
      topSupporterId: json['top_supporter_id'],
      topSupportAmount: json['top_support_amount'] ?? 0,
      specialMultiplier: (json['special_multiplier'] ?? 1.0).toDouble(),
      goalAmount: json['goal_amount'],
      goalDescription: json['goal_description'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// SuperChatEventをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'star_id': starId,
      'title': title,
      'description': description,
      'event_type': _eventTypeToString(eventType),
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'is_active': isActive,
      'total_earnings': totalEarnings,
      'message_count': messageCount,
      'top_supporter_id': topSupporterId,
      'top_support_amount': topSupportAmount,
      'special_multiplier': specialMultiplier,
      'goal_amount': goalAmount,
      'goal_description': goalDescription,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// イベントタイプの解析
  static SuperChatEventType _parseEventType(String type) {
    switch (type) {
      case 'live_stream':
        return SuperChatEventType.liveStream;
      case 'special_event':
        return SuperChatEventType.specialEvent;
      case 'milestone':
        return SuperChatEventType.milestone;
      case 'qa_session':
        return SuperChatEventType.qaSession;
      default:
        return SuperChatEventType.liveStream;
    }
  }

  /// イベントタイプを文字列に変換
  static String _eventTypeToString(SuperChatEventType type) {
    switch (type) {
      case SuperChatEventType.liveStream:
        return 'live_stream';
      case SuperChatEventType.specialEvent:
        return 'special_event';
      case SuperChatEventType.milestone:
        return 'milestone';
      case SuperChatEventType.qaSession:
        return 'qa_session';
    }
  }

  /// イベントが現在アクティブかどうか
  bool get isCurrentlyActive => isActive && (endTime == null || DateTime.now().isBefore(endTime!));

  /// ゴール達成率（0.0-1.0）
  double get goalProgress {
    if (goalAmount == null || goalAmount == 0) return 0.0;
    return (totalEarnings / goalAmount!).clamp(0.0, 1.0);
  }

  /// ゴール達成かどうか
  bool get isGoalAchieved => goalAmount != null && totalEarnings >= goalAmount!;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SuperChatEvent &&
        other.id == id &&
        other.starId == starId &&
        other.title == title &&
        other.description == description &&
        other.eventType == eventType &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.isActive == isActive &&
        other.totalEarnings == totalEarnings &&
        other.messageCount == messageCount &&
        other.topSupporterId == topSupporterId &&
        other.topSupportAmount == topSupportAmount &&
        other.specialMultiplier == specialMultiplier &&
        other.goalAmount == goalAmount &&
        other.goalDescription == goalDescription;
  }

  @override
  int get hashCode => Object.hash(
        id,
        starId,
        title,
        description,
        eventType,
        startTime,
        endTime,
        isActive,
        totalEarnings,
        messageCount,
        topSupporterId,
        topSupportAmount,
        specialMultiplier,
        goalAmount,
        goalDescription,
      );
}

/// Super Chat結果
@immutable
class SuperChatResult {
  final bool success;
  final String message;
  final String? messageId;
  final int? tierLevel;
  final int? amountSpent;
  final int? pinDuration;
  final Color? backgroundColor;

  const SuperChatResult({
    required this.success,
    required this.message,
    this.messageId,
    this.tierLevel,
    this.amountSpent,
    this.pinDuration,
    this.backgroundColor,
  });

  /// JSONからSuperChatResultを作成
  factory SuperChatResult.fromJson(Map<String, dynamic> json) {
    return SuperChatResult(
      success: json['success'] ?? false,
      message: json['message'] ?? json['error'] ?? '',
      messageId: json['message_id'],
      tierLevel: json['tier_level'],
      amountSpent: json['amount_spent'],
      pinDuration: json['pin_duration'],
      backgroundColor: json['background_color'] != null 
          ? SuperChatMessage._parseColor(json['background_color'])
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SuperChatResult &&
        other.success == success &&
        other.message == message &&
        other.messageId == messageId &&
        other.tierLevel == tierLevel &&
        other.amountSpent == amountSpent &&
        other.pinDuration == pinDuration &&
        other.backgroundColor == backgroundColor;
  }

  @override
  int get hashCode => Object.hash(
        success,
        message,
        messageId,
        tierLevel,
        amountSpent,
        pinDuration,
        backgroundColor,
      );
}