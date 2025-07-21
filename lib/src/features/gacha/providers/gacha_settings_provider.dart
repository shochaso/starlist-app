import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ガチャの設定を管理するクラス
class GachaSettings {
  final bool soundEnabled;
  final bool hapticEnabled;
  final bool animationEnabled;
  final double animationSpeed; // 1.0が標準速度
  
  const GachaSettings({
    this.soundEnabled = true,
    this.hapticEnabled = true,
    this.animationEnabled = true,
    this.animationSpeed = 1.0,
  });
  
  GachaSettings copyWith({
    bool? soundEnabled,
    bool? hapticEnabled,
    bool? animationEnabled,
    double? animationSpeed,
  }) {
    return GachaSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      animationEnabled: animationEnabled ?? this.animationEnabled,
      animationSpeed: animationSpeed ?? this.animationSpeed,
    );
  }
}

/// ガチャ設定のStateNotifier
class GachaSettingsNotifier extends StateNotifier<GachaSettings> {
  GachaSettingsNotifier() : super(const GachaSettings());
  
  /// 音効果の有効/無効を切り替え
  void toggleSound() {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
  }
  
  /// ハプティックフィードバックの有効/無効を切り替え
  void toggleHaptic() {
    state = state.copyWith(hapticEnabled: !state.hapticEnabled);
  }
  
  /// アニメーションの有効/無効を切り替え
  void toggleAnimation() {
    state = state.copyWith(animationEnabled: !state.animationEnabled);
  }
  
  /// アニメーション速度を設定
  void setAnimationSpeed(double speed) {
    state = state.copyWith(animationSpeed: speed.clamp(0.5, 2.0));
  }
  
  /// 設定をリセット
  void reset() {
    state = const GachaSettings();
  }
}

/// ガチャ設定プロバイダー
final gachaSettingsProvider = StateNotifierProvider<GachaSettingsNotifier, GachaSettings>((ref) {
  return GachaSettingsNotifier();
});

/// ガチャ統計情報を管理するクラス
class GachaStats {
  final int totalDraws;
  final int pointsEarned;
  final Map<String, int> ticketsEarned;
  final DateTime? lastDrawTime;
  
  const GachaStats({
    this.totalDraws = 0,
    this.pointsEarned = 0,
    this.ticketsEarned = const {},
    this.lastDrawTime,
  });
  
  GachaStats copyWith({
    int? totalDraws,
    int? pointsEarned,
    Map<String, int>? ticketsEarned,
    DateTime? lastDrawTime,
  }) {
    return GachaStats(
      totalDraws: totalDraws ?? this.totalDraws,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      ticketsEarned: ticketsEarned ?? this.ticketsEarned,
      lastDrawTime: lastDrawTime ?? this.lastDrawTime,
    );
  }
}

/// ガチャ統計のStateNotifier
class GachaStatsNotifier extends StateNotifier<GachaStats> {
  GachaStatsNotifier() : super(const GachaStats());
  
  /// ガチャ実行時の統計更新
  void recordDraw({
    int? pointsEarned,
    String? ticketType,
  }) {
    final newTicketsEarned = Map<String, int>.from(state.ticketsEarned);
    
    if (ticketType != null) {
      newTicketsEarned[ticketType] = (newTicketsEarned[ticketType] ?? 0) + 1;
    }
    
    state = state.copyWith(
      totalDraws: state.totalDraws + 1,
      pointsEarned: state.pointsEarned + (pointsEarned ?? 0),
      ticketsEarned: newTicketsEarned,
      lastDrawTime: DateTime.now(),
    );
  }
  
  /// 統計をリセット
  void reset() {
    state = const GachaStats();
  }
}

/// ガチャ統計プロバイダー
final gachaStatsProvider = StateNotifierProvider<GachaStatsNotifier, GachaStats>((ref) {
  return GachaStatsNotifier();
});