import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart' show supabaseClientProvider;
import '../../../data/repositories/birthday_repository.dart';
import '../../../data/models/birthday_models.dart';
import '../services/birthday_service.dart';

/// BirthdayRepositoryのプロバイダー
final birthdayRepositoryProvider = Provider<BirthdayRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return BirthdayRepository(supabase: supabaseClient);
});

/// BirthdayServiceのプロバイダー
final birthdayServiceProvider = Provider<BirthdayService>((ref) {
  final repository = ref.watch(birthdayRepositoryProvider);
  return BirthdayService(repository: repository);
});

/// 今日が誕生日のスタープロバイダー
final birthdayStarsTodayProvider = FutureProvider.autoDispose<List<BirthdayStar>>((ref) async {
  final service = ref.watch(birthdayServiceProvider);
  try {
    return await service.getBirthdayStarsToday();
  } catch (e) {
    print('今日の誕生日スター取得エラー: $e');
    return [];
  }
});

/// 近日中に誕生日を迎えるスタープロバイダー
final upcomingBirthdayStarsProvider = FutureProvider.family.autoDispose<List<BirthdayStar>, int>((ref, daysAhead) async {
  final service = ref.watch(birthdayServiceProvider);
  try {
    return await service.getUpcomingBirthdayStars(daysAhead);
  } catch (e) {
    print('近日誕生日スター取得エラー: $e');
    return [];
  }
});

/// フォロー中のスターの今日の誕生日プロバイダー
final followingStarsBirthdaysTodayProvider = FutureProvider.family.autoDispose<List<BirthdayStar>, String>((ref, userId) async {
  final service = ref.watch(birthdayServiceProvider);
  try {
    return await service.getFollowingStarsBirthdaysToday(userId);
  } catch (e) {
    print('フォロー中スターの誕生日取得エラー: $e');
    return [];
  }
});

/// ユーザーの誕生日通知履歴プロバイダー
final userBirthdayNotificationsProvider = FutureProvider.family.autoDispose<List<BirthdayNotification>, String>((ref, userId) async {
  final service = ref.watch(birthdayServiceProvider);
  try {
    return await service.getUserBirthdayNotifications(userId);
  } catch (e) {
    print('誕生日通知履歴取得エラー: $e');
    return [];
  }
});

/// スターの誕生日通知履歴プロバイダー
final starBirthdayNotificationsProvider = FutureProvider.family.autoDispose<List<BirthdayNotification>, String>((ref, starId) async {
  final service = ref.watch(birthdayServiceProvider);
  try {
    return await service.getStarBirthdayNotifications(starId);
  } catch (e) {
    print('スター誕生日通知履歴取得エラー: $e');
    return [];
  }
});

/// ユーザーの誕生日通知設定プロバイダー
final userBirthdayNotificationSettingsProvider = FutureProvider.family.autoDispose<List<BirthdayNotificationSetting>, String>((ref, userId) async {
  final service = ref.watch(birthdayServiceProvider);
  try {
    return await service.getUserBirthdayNotificationSettings(userId);
  } catch (e) {
    print('誕生日通知設定取得エラー: $e');
    return [];
  }
});

/// 特定の誕生日通知設定プロバイダー
final birthdayNotificationSettingProvider = FutureProvider.family.autoDispose<BirthdayNotificationSetting?, BirthdayNotificationQuery>((ref, query) async {
  final service = ref.watch(birthdayServiceProvider);
  try {
    return await service.getBirthdayNotificationSetting(query.userId, query.starId);
  } catch (e) {
    print('誕生日通知設定取得エラー: $e');
    return null;
  }
});

/// アクティブな誕生日イベントプロバイダー
final activeBirthdayEventsProvider = FutureProvider.autoDispose<List<BirthdayEvent>>((ref) async {
  final service = ref.watch(birthdayServiceProvider);
  try {
    return await service.getActiveBirthdayEvents();
  } catch (e) {
    print('アクティブ誕生日イベント取得エラー: $e');
    return [];
  }
});

/// スターの誕生日イベントプロバイダー
final starBirthdayEventsProvider = FutureProvider.family.autoDispose<List<BirthdayEvent>, String>((ref, starId) async {
  final service = ref.watch(birthdayServiceProvider);
  try {
    return await service.getStarBirthdayEvents(starId);
  } catch (e) {
    print('スター誕生日イベント取得エラー: $e');
    return [];
  }
});

/// 誕生日設定アクションプロバイダー
final birthdaySettingActionProvider = Provider<BirthdaySettingNotifier>((ref) {
  final service = ref.watch(birthdayServiceProvider);
  return BirthdaySettingNotifier(service);
});

/// 誕生日通知送信アクションプロバイダー
final birthdayNotificationActionProvider = Provider<BirthdayNotificationNotifier>((ref) {
  final service = ref.watch(birthdayServiceProvider);
  return BirthdayNotificationNotifier(service);
});

/// 誕生日イベント作成アクションプロバイダー
final birthdayEventActionProvider = Provider<BirthdayEventNotifier>((ref) {
  final service = ref.watch(birthdayServiceProvider);
  return BirthdayEventNotifier(service);
});

// === ヘルパークラス ===

/// 誕生日通知クエリクラス
class BirthdayNotificationQuery {
  final String userId;
  final String starId;

  BirthdayNotificationQuery({
    required this.userId,
    required this.starId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BirthdayNotificationQuery &&
        other.userId == userId &&
        other.starId == starId;
  }

  @override
  int get hashCode => Object.hash(userId, starId);
}

// === Notifierクラス群 ===

/// 誕生日設定ノーティファイア
class BirthdaySettingNotifier extends StateNotifier<AsyncValue<bool?>> {
  final BirthdayService _service;

  BirthdaySettingNotifier(this._service) : super(const AsyncValue.data(null));

  /// ユーザーの誕生日を設定
  Future<void> updateUserBirthday(
    String userId,
    DateTime? birthday,
    BirthdayVisibility visibility,
    bool notificationEnabled,
  ) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.updateUserBirthday(userId, birthday, visibility, notificationEnabled);
      state = const AsyncValue.data(true);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 誕生日通知設定を更新
  Future<void> updateNotificationSetting(
    String userId,
    String starId,
    bool notificationEnabled,
    String? customMessage,
    int notificationDaysBefore,
  ) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await _service.updateBirthdayNotificationSetting(
        userId,
        starId,
        notificationEnabled,
        customMessage,
        notificationDaysBefore,
      );
      
      state = AsyncValue.data(result.success);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 状態をリセット
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// 誕生日通知ノーティファイア
class BirthdayNotificationNotifier extends StateNotifier<AsyncValue<BirthdayNotificationResult?>> {
  final BirthdayService _service;

  BirthdayNotificationNotifier(this._service) : super(const AsyncValue.data(null));

  /// 誕生日通知を送信
  Future<void> sendBirthdayNotification(
    String starId,
    BirthdayNotificationType notificationType,
    String? customMessage,
  ) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await _service.sendBirthdayNotification(
        starId,
        notificationType,
        customMessage,
      );
      state = AsyncValue.data(result);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 誕生日通知を既読にする
  Future<void> markAsRead(String notificationId) async {
    try {
      await _service.markBirthdayNotificationAsRead(notificationId);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 状態をリセット
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// 誕生日イベントノーティファイア
class BirthdayEventNotifier extends StateNotifier<AsyncValue<BirthdayEvent?>> {
  final BirthdayService _service;

  BirthdayEventNotifier(this._service) : super(const AsyncValue.data(null));

  /// 誕生日イベントを作成
  Future<void> createBirthdayEvent({
    required String starId,
    required String title,
    String? description,
    required DateTime eventDate,
    bool isMilestone = false,
    int? age,
    Map<String, dynamic>? specialRewards,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final event = await _service.createBirthdayEvent(
        starId: starId,
        title: title,
        description: description,
        eventDate: eventDate,
        isMilestone: isMilestone,
        age: age,
        specialRewards: specialRewards,
      );
      state = AsyncValue.data(event);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 誕生日イベントを更新
  Future<void> updateBirthdayEvent(
    String eventId,
    Map<String, dynamic> updates,
  ) async {
    state = const AsyncValue.loading();
    
    try {
      final event = await _service.updateBirthdayEvent(eventId, updates);
      state = AsyncValue.data(event);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 誕生日イベントを非アクティブ化
  Future<void> deactivateBirthdayEvent(String eventId) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.deactivateBirthdayEvent(eventId);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 状態をリセット
  void reset() {
    state = const AsyncValue.data(null);
  }
}