import 'dart:async';

import 'package:starlist/core/ab/ab_config.dart';
import 'package:starlist/core/prefs/local_store.dart';
import 'package:starlist/services/ad_bridge.dart';

class GachaController {
  final _store = LocalStore();
  final variant = ABConfig.currentVariant;

  int freeLeft = 0;
  int freeQuota = 0;
  int tickets = 0;

  int streakDays = 1;
  int rewardsUsedToday = 0;

  DateTime? lastRewardAt;
  String rewardHourKey = '';
  int rewardCountThisHour = 0;

  Duration rareBoostLeft = Duration.zero;

  int get rewardPerView => 1;
  bool get canWatchReward {
    if (freeLeft > 0) return false;
    if (rewardsUsedToday >= ABConfig.rewardDailyCap) return false;

    final currentHour = ABConfig.currentJstHourKey();
    if (rewardHourKey != currentHour) {
      rewardHourKey = currentHour;
      rewardCountThisHour = 0;
      _save();
    }
    if (rewardCountThisHour >= ABConfig.rewardHourlyCap) return false;

    if (lastRewardAt != null) {
      final since = DateTime.now().difference(lastRewardAt!);
      if (since.inSeconds < ABConfig.rewardCooldownSeconds) return false;
    }
    return true;
  }

  Future<void> init() async {
    _dailyResetIfNeeded();
    _load();
    _ensureQuota();
  }

  Future<bool> spin() async {
    if (freeLeft > 0) {
      freeLeft--;
      _save();
      _emit('gacha_spin_free');
      return true;
    } else if (tickets > 0) {
      tickets--;
      _save();
      _emit('gacha_spin_ticket');
      return true;
    } else {
      _emit('gacha_no_stock_watch_ad_click');
      return await watchAdAndGrant();
    }
  }

  Future<bool> watchAdAndGrant() async {
    if (!canWatchReward) return false;
    final ok = await AdBridge.showRewarded();
    if (ok) {
      tickets += rewardPerView;
      rewardsUsedToday++;

      final now = DateTime.now();
      final currentHour = ABConfig.currentJstHourKey();
      if (rewardHourKey != currentHour) {
        rewardHourKey = currentHour;
        rewardCountThisHour = 0;
      }
      rewardCountThisHour++;
      lastRewardAt = now;

      _save();
      _emit('ad_reward_complete');
      return true;
    } else {
      _emit('ad_reward_error');
      return false;
    }
  }

  void _dailyResetIfNeeded() {
    final today = ABConfig.todayJstKey();
    final last = _store.getString('sl.gacha.lastResetAt');
    if (last != today) {
      if (last == ABConfig.yesterdayJstKey()) {
        streakDays = (_store.getInt('sl.gacha.streakDays') ?? 0) + 1;
      } else {
        streakDays = 1;
      }
      rewardsUsedToday = 0;
      tickets = _store.getInt('sl.gacha.tickets') ?? 0;

      freeQuota = ABConfig.defaultFreeQuota(variant);
      freeLeft = freeQuota;

      rewardHourKey = ABConfig.currentJstHourKey();
      rewardCountThisHour = 0;
      lastRewardAt = null;

      _store.setString('sl.gacha.lastResetAt', today);
      _store.setInt('sl.gacha.streakDays', streakDays);
      _store.setInt('sl.gacha.rewardsUsedToday', rewardsUsedToday);
      _store.setInt('sl.gacha.freeLeft', freeLeft);
      _store.setInt('sl.gacha.freeQuota', freeQuota);
      _store.setString('sl.gacha.rewardHourKey', rewardHourKey);
      _store.remove('sl.gacha.lastRewardAt');
      _store.setInt('sl.gacha.rewardCountThisHour', rewardCountThisHour);
    }
  }

  void _load() {
    freeLeft = _store.getInt('sl.gacha.freeLeft') ?? 0;
    freeQuota = _store.getInt('sl.gacha.freeQuota') ??
        ABConfig.defaultFreeQuota(variant);
    tickets = _store.getInt('sl.gacha.tickets') ?? 0;

    streakDays = _store.getInt('sl.gacha.streakDays') ?? 1;
    rewardsUsedToday = _store.getInt('sl.gacha.rewardsUsedToday') ?? 0;

    rewardHourKey = _store.getString('sl.gacha.rewardHourKey') ??
        ABConfig.currentJstHourKey();
    rewardCountThisHour = _store.getInt('sl.gacha.rewardCountThisHour') ?? 0;

    final lastIso = _store.getString('sl.gacha.lastRewardAt');
    if (lastIso != null && lastIso.isNotEmpty) {
      try {
        lastRewardAt = DateTime.tryParse(lastIso);
      } catch (_) {}
    }
  }

  void _ensureQuota() {
    if (freeLeft > freeQuota) freeLeft = freeQuota;
  }

  void _save() {
    _store.setInt('sl.gacha.freeLeft', freeLeft);
    _store.setInt('sl.gacha.freeQuota', freeQuota);
    _store.setInt('sl.gacha.tickets', tickets);
    _store.setInt('sl.gacha.streakDays', streakDays);
    _store.setInt('sl.gacha.rewardsUsedToday', rewardsUsedToday);
    _store.setString('sl.gacha.rewardHourKey', rewardHourKey);
    _store.setInt('sl.gacha.rewardCountThisHour', rewardCountThisHour);
    if (lastRewardAt != null) {
      _store.setString(
          'sl.gacha.lastRewardAt', lastRewardAt!.toIso8601String());
    }
  }

  void _emit(String name) {
    print('[telemetry] $name');
  }
}
