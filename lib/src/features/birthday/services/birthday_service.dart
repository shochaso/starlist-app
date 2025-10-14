import '../../../data/repositories/birthday_repository.dart';
import '../../../data/models/birthday_models.dart';

/// 誕生日システムのビジネスロジック層
class BirthdayService {
  final BirthdayRepository _repository;

  BirthdayService({
    required BirthdayRepository repository,
  }) : _repository = repository;

  /// ユーザーの誕生日を設定
  Future<void> updateUserBirthday(
    String userId,
    DateTime? birthday,
    BirthdayVisibility visibility,
    bool notificationEnabled,
  ) async {
    // バリデーション
    if (birthday != null) {
      final now = DateTime.now();
      final age = now.year - birthday.year;
      
      if (age < 0 || age > 150) {
        throw ArgumentError('有効な誕生日を入力してください');
      }
    }

    await _repository.updateUserBirthday(
      userId,
      birthday,
      visibility,
      notificationEnabled,
    );
  }

  /// 誕生日通知設定を取得
  Future<BirthdayNotificationSetting?> getBirthdayNotificationSetting(
    String userId,
    String starId,
  ) async {
    return await _repository.getBirthdayNotificationSetting(userId, starId);
  }

  /// ユーザーのすべての誕生日通知設定を取得
  Future<List<BirthdayNotificationSetting>> getUserBirthdayNotificationSettings(
    String userId,
  ) async {
    return await _repository.getUserBirthdayNotificationSettings(userId);
  }

  /// 誕生日通知設定を更新
  Future<BirthdayNotificationResult> updateBirthdayNotificationSetting(
    String userId,
    String starId,
    bool notificationEnabled,
    String? customMessage,
    int notificationDaysBefore,
  ) async {
    // バリデーション
    if (notificationDaysBefore < 0 || notificationDaysBefore > 30) {
      throw ArgumentError('通知日数は0-30日の範囲で設定してください');
    }

    if (customMessage != null && customMessage.length > 500) {
      throw ArgumentError('カスタムメッセージは500文字以内で入力してください');
    }

    return await _repository.updateBirthdayNotificationSetting(
      userId,
      starId,
      notificationEnabled,
      customMessage,
      notificationDaysBefore,
    );
  }

  /// 誕生日通知を送信
  Future<BirthdayNotificationResult> sendBirthdayNotification(
    String starId,
    BirthdayNotificationType notificationType,
    String? customMessage,
  ) async {
    // バリデーション
    if (customMessage != null && customMessage.length > 500) {
      throw ArgumentError('カスタムメッセージは500文字以内で入力してください');
    }

    return await _repository.sendBirthdayNotification(
      starId,
      notificationType,
      customMessage,
    );
  }

  /// 今日が誕生日のスターを取得
  Future<List<BirthdayStar>> getBirthdayStarsToday() async {
    return await _repository.getBirthdayStarsToday();
  }

  /// 近日中に誕生日を迎えるスターを取得
  Future<List<BirthdayStar>> getUpcomingBirthdayStars([int daysAhead = 7]) async {
    if (daysAhead < 1 || daysAhead > 30) {
      throw ArgumentError('日数は1-30日の範囲で設定してください');
    }

    return await _repository.getUpcomingBirthdayStars(daysAhead);
  }

  /// ユーザーの誕生日通知履歴を取得
  Future<List<BirthdayNotification>> getUserBirthdayNotifications(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    return await _repository.getUserBirthdayNotifications(
      userId,
      limit: limit,
      offset: offset,
    );
  }

  /// スターの誕生日通知履歴を取得
  Future<List<BirthdayNotification>> getStarBirthdayNotifications(
    String starId, {
    int limit = 50,
    int offset = 0,
  }) async {
    return await _repository.getStarBirthdayNotifications(
      starId,
      limit: limit,
      offset: offset,
    );
  }

  /// 誕生日通知を既読にする
  Future<void> markBirthdayNotificationAsRead(String notificationId) async {
    await _repository.markBirthdayNotificationAsRead(notificationId);
  }

  /// 誕生日イベントを作成
  Future<BirthdayEvent> createBirthdayEvent({
    required String starId,
    required String title,
    String? description,
    required DateTime eventDate,
    bool isMilestone = false,
    int? age,
    Map<String, dynamic>? specialRewards,
  }) async {
    // バリデーション
    if (title.trim().isEmpty) {
      throw ArgumentError('タイトルは必須です');
    }

    if (title.length > 100) {
      throw ArgumentError('タイトルは100文字以内で入力してください');
    }

    if (description != null && description.length > 1000) {
      throw ArgumentError('説明は1000文字以内で入力してください');
    }

    final now = DateTime.now();
    if (eventDate.isBefore(DateTime(now.year, now.month, now.day))) {
      throw ArgumentError('イベント日は今日以降の日付を設定してください');
    }

    if (age != null && (age < 0 || age > 150)) {
      throw ArgumentError('有効な年齢を入力してください');
    }

    return await _repository.createBirthdayEvent(
      starId: starId,
      title: title.trim(),
      description: description?.trim(),
      eventDate: eventDate,
      isMilestone: isMilestone,
      age: age,
      specialRewards: specialRewards,
    );
  }

  /// アクティブな誕生日イベントを取得
  Future<List<BirthdayEvent>> getActiveBirthdayEvents({
    int limit = 20,
    int offset = 0,
  }) async {
    return await _repository.getActiveBirthdayEvents(
      limit: limit,
      offset: offset,
    );
  }

  /// 特定のスターの誕生日イベントを取得
  Future<List<BirthdayEvent>> getStarBirthdayEvents(
    String starId, {
    int limit = 20,
    int offset = 0,
  }) async {
    return await _repository.getStarBirthdayEvents(
      starId,
      limit: limit,
      offset: offset,
    );
  }

  /// 誕生日イベントを更新
  Future<BirthdayEvent> updateBirthdayEvent(
    String eventId,
    Map<String, dynamic> updates,
  ) async {
    return await _repository.updateBirthdayEvent(eventId, updates);
  }

  /// 誕生日イベントを非アクティブ化
  Future<void> deactivateBirthdayEvent(String eventId) async {
    await _repository.deactivateBirthdayEvent(eventId);
  }

  /// フォローしているスターの今日の誕生日を取得
  Future<List<BirthdayStar>> getFollowingStarsBirthdaysToday(String userId) async {
    return await _repository.getFollowingStarsBirthdaysToday(userId);
  }

  /// 日次誕生日チェック実行
  Future<void> executeDailyBirthdayCheck() async {
    await _repository.executeDailyBirthdayCheck();
  }

  /// 誕生日までの日数を計算
  int calculateDaysUntilBirthday(DateTime birthday) {
    final now = DateTime.now();
    final thisYearBirthday = DateTime(now.year, birthday.month, birthday.day);
    
    if (thisYearBirthday.isAfter(now) || 
        (thisYearBirthday.year == now.year && 
         thisYearBirthday.month == now.month && 
         thisYearBirthday.day == now.day)) {
      return thisYearBirthday.difference(now).inDays;
    } else {
      final nextYearBirthday = DateTime(now.year + 1, birthday.month, birthday.day);
      return nextYearBirthday.difference(now).inDays;
    }
  }

  /// 年齢を計算
  int calculateAge(DateTime birthday) {
    final now = DateTime.now();
    int age = now.year - birthday.year;
    
    // まだ今年の誕生日を迎えていない場合は1歳減らす
    if (now.month < birthday.month || 
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }
    
    return age;
  }

  /// マイルストーン誕生日かどうかを判定
  bool isMilestoneBirthday(int age) {
    // 10の倍数、または特別な年齢をマイルストーンとする
    return age % 10 == 0 || 
           age == 1 || age == 7 || age == 13 || age == 16 || 
           age == 18 || age == 20 || age == 25;
  }

  /// 誕生日メッセージのテンプレートを生成
  String generateBirthdayMessage(
    String starName,
    int age,
    BirthdayNotificationType type, {
    bool isMilestone = false,
  }) {
    switch (type) {
      case BirthdayNotificationType.birthdayToday:
        if (isMilestone) {
          return '$starNameさん、$age歳のお誕生日おめでとうございます！🎉✨ 素敵な一年になりますように！';
        } else {
          return '$starNameさん、お誕生日おめでとうございます！🎂 $age歳の素敵な一年をお過ごしください！';
        }
      
      case BirthdayNotificationType.birthdayUpcoming:
        return '$starNameさんの誕生日($age歳)が近づいています！🎈 お祝いの準備をしませんか？';
      
      case BirthdayNotificationType.custom:
        return '$starNameさんからのお知らせです。';
    }
  }

  /// 誕生日の特別報酬を生成
  Map<String, dynamic> generateSpecialRewards(int age, bool isMilestone) {
    final rewards = <String, dynamic>{};
    
    if (isMilestone) {
      rewards['s_points'] = age * 10; // マイルストーンの場合、年齢×10のSポイント
      rewards['special_badge'] = 'milestone_$age';
      rewards['exclusive_content'] = true;
    } else {
      rewards['s_points'] = 50; // 通常の誕生日は50Sポイント
    }
    
    return rewards;
  }
}

// プロバイダーは birthday_providers.dart に移動