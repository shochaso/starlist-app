enum GachaVariant { variant1, variant2, variant3 }

class ABConfig {
  static GachaVariant get currentVariant => GachaVariant.variant2;

  static int get rewardDailyCap => 3;
  static int get rewardCooldownSeconds => 300;
  static int get rewardHourlyCap => 2;

  static int defaultFreeQuota(GachaVariant _) => 3;

  static String todayJstKey() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 9));
    return '${now.year}-${_2(now.month)}-${_2(now.day)}';
  }

  static String yesterdayJstKey() {
    final now = DateTime.now()
        .toUtc()
        .add(const Duration(hours: 9))
        .subtract(const Duration(days: 1));
    return '${now.year}-${_2(now.month)}-${_2(now.day)}';
  }

  static String currentJstHourKey() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 9));
    return '${now.year}-${_2(now.month)}-${_2(now.day)} ${_2(now.hour)}:00';
  }

  static String _2(int n) => n.toString().padLeft(2, '0');
}
