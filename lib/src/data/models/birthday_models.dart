import 'package:flutter/foundation.dart';

/// 誕生日の可視性設定
enum BirthdayVisibility {
  public,    // 公開
  followers, // フォロワーのみ
  private,   // 非公開
}

/// 誕生日通知タイプ
enum BirthdayNotificationType {
  birthdayToday,   // 今日が誕生日
  birthdayUpcoming, // 誕生日が近い
  custom,          // カスタム通知
}

/// 誕生日通知設定モデル
@immutable
class BirthdayNotificationSetting {
  final String id;
  final String userId;
  final String starId;
  final bool notificationEnabled;
  final String? customMessage;
  final int notificationDaysBefore;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BirthdayNotificationSetting({
    required this.id,
    required this.userId,
    required this.starId,
    required this.notificationEnabled,
    this.customMessage,
    required this.notificationDaysBefore,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSONからBirthdayNotificationSettingを作成
  factory BirthdayNotificationSetting.fromJson(Map<String, dynamic> json) {
    return BirthdayNotificationSetting(
      id: json['id'],
      userId: json['user_id'],
      starId: json['star_id'],
      notificationEnabled: json['notification_enabled'] ?? true,
      customMessage: json['custom_message'],
      notificationDaysBefore: json['notification_days_before'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// BirthdayNotificationSettingをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'star_id': starId,
      'notification_enabled': notificationEnabled,
      'custom_message': customMessage,
      'notification_days_before': notificationDaysBefore,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// コピーを作成
  BirthdayNotificationSetting copyWith({
    String? id,
    String? userId,
    String? starId,
    bool? notificationEnabled,
    String? customMessage,
    int? notificationDaysBefore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BirthdayNotificationSetting(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      starId: starId ?? this.starId,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      customMessage: customMessage ?? this.customMessage,
      notificationDaysBefore: notificationDaysBefore ?? this.notificationDaysBefore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BirthdayNotificationSetting &&
        other.id == id &&
        other.userId == userId &&
        other.starId == starId &&
        other.notificationEnabled == notificationEnabled &&
        other.customMessage == customMessage &&
        other.notificationDaysBefore == notificationDaysBefore &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        starId,
        notificationEnabled,
        customMessage,
        notificationDaysBefore,
        createdAt,
        updatedAt,
      );
}

/// 誕生日通知モデル
@immutable
class BirthdayNotification {
  final String id;
  final String starId;
  final String notifiedUserId;
  final BirthdayNotificationType notificationType;
  final String message;
  final DateTime birthdayDate;
  final DateTime sentAt;
  final bool isRead;
  final Map<String, dynamic> metadata;

  const BirthdayNotification({
    required this.id,
    required this.starId,
    required this.notifiedUserId,
    required this.notificationType,
    required this.message,
    required this.birthdayDate,
    required this.sentAt,
    required this.isRead,
    required this.metadata,
  });

  /// JSONからBirthdayNotificationを作成
  factory BirthdayNotification.fromJson(Map<String, dynamic> json) {
    return BirthdayNotification(
      id: json['id'],
      starId: json['star_id'],
      notifiedUserId: json['notified_user_id'],
      notificationType: _parseNotificationType(json['notification_type']),
      message: json['message'],
      birthdayDate: DateTime.parse(json['birthday_date']),
      sentAt: DateTime.parse(json['sent_at']),
      isRead: json['is_read'] ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  /// BirthdayNotificationをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'star_id': starId,
      'notified_user_id': notifiedUserId,
      'notification_type': _notificationTypeToString(notificationType),
      'message': message,
      'birthday_date': birthdayDate.toIso8601String().split('T')[0],
      'sent_at': sentAt.toIso8601String(),
      'is_read': isRead,
      'metadata': metadata,
    };
  }

  /// コピーを作成
  BirthdayNotification copyWith({
    String? id,
    String? starId,
    String? notifiedUserId,
    BirthdayNotificationType? notificationType,
    String? message,
    DateTime? birthdayDate,
    DateTime? sentAt,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return BirthdayNotification(
      id: id ?? this.id,
      starId: starId ?? this.starId,
      notifiedUserId: notifiedUserId ?? this.notifiedUserId,
      notificationType: notificationType ?? this.notificationType,
      message: message ?? this.message,
      birthdayDate: birthdayDate ?? this.birthdayDate,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? Map<String, dynamic>.from(this.metadata),
    );
  }

  /// 通知タイプの解析
  static BirthdayNotificationType _parseNotificationType(String type) {
    switch (type) {
      case 'birthday_today':
        return BirthdayNotificationType.birthdayToday;
      case 'birthday_upcoming':
        return BirthdayNotificationType.birthdayUpcoming;
      case 'custom':
        return BirthdayNotificationType.custom;
      default:
        return BirthdayNotificationType.custom;
    }
  }

  /// 通知タイプを文字列に変換
  static String _notificationTypeToString(BirthdayNotificationType type) {
    switch (type) {
      case BirthdayNotificationType.birthdayToday:
        return 'birthday_today';
      case BirthdayNotificationType.birthdayUpcoming:
        return 'birthday_upcoming';
      case BirthdayNotificationType.custom:
        return 'custom';
    }
  }

  /// 今日の誕生日通知かどうか
  bool get isTodayBirthday => notificationType == BirthdayNotificationType.birthdayToday;

  /// 近日中の誕生日通知かどうか
  bool get isUpcomingBirthday => notificationType == BirthdayNotificationType.birthdayUpcoming;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BirthdayNotification &&
        other.id == id &&
        other.starId == starId &&
        other.notifiedUserId == notifiedUserId &&
        other.notificationType == notificationType &&
        other.message == message &&
        other.birthdayDate == birthdayDate &&
        other.sentAt == sentAt &&
        other.isRead == isRead &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode => Object.hash(
        id,
        starId,
        notifiedUserId,
        notificationType,
        message,
        birthdayDate,
        sentAt,
        isRead,
        metadata,
      );
}

/// 誕生日イベントモデル
@immutable
class BirthdayEvent {
  final String id;
  final String starId;
  final String title;
  final String? description;
  final DateTime eventDate;
  final bool isMilestone;
  final int? age;
  final Map<String, dynamic> specialRewards;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BirthdayEvent({
    required this.id,
    required this.starId,
    required this.title,
    this.description,
    required this.eventDate,
    required this.isMilestone,
    this.age,
    required this.specialRewards,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSONからBirthdayEventを作成
  factory BirthdayEvent.fromJson(Map<String, dynamic> json) {
    return BirthdayEvent(
      id: json['id'],
      starId: json['star_id'],
      title: json['title'],
      description: json['description'],
      eventDate: DateTime.parse(json['event_date']),
      isMilestone: json['is_milestone'] ?? false,
      age: json['age'],
      specialRewards: Map<String, dynamic>.from(json['special_rewards'] ?? {}),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// BirthdayEventをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'star_id': starId,
      'title': title,
      'description': description,
      'event_date': eventDate.toIso8601String().split('T')[0],
      'is_milestone': isMilestone,
      'age': age,
      'special_rewards': specialRewards,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// コピーを作成
  BirthdayEvent copyWith({
    String? id,
    String? starId,
    String? title,
    String? description,
    DateTime? eventDate,
    bool? isMilestone,
    int? age,
    Map<String, dynamic>? specialRewards,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BirthdayEvent(
      id: id ?? this.id,
      starId: starId ?? this.starId,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      isMilestone: isMilestone ?? this.isMilestone,
      age: age ?? this.age,
      specialRewards: specialRewards ?? Map<String, dynamic>.from(this.specialRewards),
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// イベントが今日かどうか
  bool get isToday {
    final now = DateTime.now();
    return eventDate.year == now.year &&
           eventDate.month == now.month &&
           eventDate.day == now.day;
  }

  /// イベントまでの日数
  int get daysUntilEvent {
    final now = DateTime.now();
    final difference = eventDate.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }

  /// イベントが過去かどうか
  bool get isPast {
    final now = DateTime.now();
    return eventDate.isBefore(DateTime(now.year, now.month, now.day));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BirthdayEvent &&
        other.id == id &&
        other.starId == starId &&
        other.title == title &&
        other.description == description &&
        other.eventDate == eventDate &&
        other.isMilestone == isMilestone &&
        other.age == age &&
        mapEquals(other.specialRewards, specialRewards) &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        starId,
        title,
        description,
        eventDate,
        isMilestone,
        age,
        specialRewards,
        isActive,
        createdAt,
        updatedAt,
      );
}

/// 誕生日スター情報モデル
@immutable
class BirthdayStar {
  final String starId;
  final String starName;
  final DateTime? birthday;
  final int? age;
  final int? daysUntilBirthday;

  const BirthdayStar({
    required this.starId,
    required this.starName,
    this.birthday,
    this.age,
    this.daysUntilBirthday,
  });

  /// JSONからBirthdayStarを作成
  factory BirthdayStar.fromJson(Map<String, dynamic> json) {
    return BirthdayStar(
      starId: json['star_id'],
      starName: json['star_name'],
      birthday: json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
      age: json['age'],
      daysUntilBirthday: json['days_until_birthday'],
    );
  }

  /// BirthdayStarをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'star_id': starId,
      'star_name': starName,
      'birthday': birthday?.toIso8601String().split('T')[0],
      'age': age,
      'days_until_birthday': daysUntilBirthday,
    };
  }

  /// 今日が誕生日かどうか
  bool get isBirthdayToday => daysUntilBirthday == 0;

  /// 誕生日が近いかどうか（7日以内）
  bool get isBirthdayNear => daysUntilBirthday != null && daysUntilBirthday! <= 7 && daysUntilBirthday! > 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BirthdayStar &&
        other.starId == starId &&
        other.starName == starName &&
        other.birthday == birthday &&
        other.age == age &&
        other.daysUntilBirthday == daysUntilBirthday;
  }

  @override
  int get hashCode => Object.hash(
        starId,
        starName,
        birthday,
        age,
        daysUntilBirthday,
      );
}

/// 誕生日通知の結果
@immutable
class BirthdayNotificationResult {
  final bool success;
  final String message;
  final int? notificationsSent;

  const BirthdayNotificationResult({
    required this.success,
    required this.message,
    this.notificationsSent,
  });

  /// JSONからBirthdayNotificationResultを作成
  factory BirthdayNotificationResult.fromJson(Map<String, dynamic> json) {
    return BirthdayNotificationResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      notificationsSent: json['notifications_sent'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BirthdayNotificationResult &&
        other.success == success &&
        other.message == message &&
        other.notificationsSent == notificationsSent;
  }

  @override
  int get hashCode => Object.hash(success, message, notificationsSent);
}