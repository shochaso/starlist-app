import '../../auth/supabase_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;import '../models/gacha_limits_models.dart';

/// ガチャ回数管理のリポジトリ
class GachaLimitsRepository {
  final SupabaseClient _supabaseService;

  GachaLimitsRepository(SupabaseClient supabaseService) : _supabaseService = supabaseService;

  /// ガチャ回数の統計情報を取得
  Future<GachaAttemptsStats> getGachaAttemptsStats(String userId) async {
    try {
      final result = await _supabaseService
          .rpc('get_available_gacha_attempts', params: {
            'user_id_param': userId,
          });

      if (result != null) {
        final map = result as Map<String, dynamic>;
        int base = (map['base_attempts'] ?? map['baseAttempts'] ?? 0) as int;
        int bonus = (map['bonus_attempts'] ?? map['bonusAttempts'] ?? 0) as int;
        int used = (map['used_attempts'] ?? map['usedAttempts'] ?? 0) as int;
        int available = (map['available_attempts'] ?? map['availableAttempts']) as int? ?? (base + bonus - used);
        final dateStr = (map['date'] as String?) ?? DateTime.now().toIso8601String();
        final date = DateTime.tryParse(dateStr) ?? DateTime.now();
        return GachaAttemptsStats(
          baseAttempts: base,
          bonusAttempts: bonus,
          usedAttempts: used,
          availableAttempts: available,
          date: date,
        );
      }

      // RPCがnullを返した場合、テーブル参照にフォールバック
      return await _getStatsFromTable(userId);
    } catch (_) {
      // 例外時もテーブル参照にフォールバック
      try {
        return await _getStatsFromTable(userId);
      } catch (e) {
        // どうしても取得できない場合は0回
        return GachaAttemptsStats(
          baseAttempts: 0,
          bonusAttempts: 0,
          usedAttempts: 0,
          availableAttempts: 0,
          date: DateTime.now(),
        );
      }
    }
  }

  Future<GachaAttemptsStats> _getStatsFromTable(String userId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final rows = await _supabaseService
        .from('gacha_attempts')
        .select('base_attempts, bonus_attempts, used_attempts, date')
        .eq('user_id', userId)
        .eq('date', today)
        .limit(1);

    if (rows is List && rows.isNotEmpty) {
      final r = rows.first as Map<String, dynamic>;
      final base = (r['base_attempts'] as int?) ?? 0;
      final bonus = (r['bonus_attempts'] as int?) ?? 0;
      final used = (r['used_attempts'] as int?) ?? 0;
      final date = DateTime.tryParse((r['date'] as String?) ?? today) ?? DateTime.now();
      return GachaAttemptsStats(
        baseAttempts: base,
        bonusAttempts: bonus,
        usedAttempts: used,
        availableAttempts: base + bonus - used,
        date: date,
      );
    }

    // 行が無ければ0回（別レイヤーで初期化/upsertする）
    return GachaAttemptsStats(
      baseAttempts: 0,
      bonusAttempts: 0,
      usedAttempts: 0,
      availableAttempts: 0,
      date: DateTime.now(),
    );
  }

  /// ガチャ回数を消費
  Future<bool> consumeGachaAttempt(String userId) async {
    try {
      final result = await _supabaseService
          .rpc('consume_gacha_attempt', params: {
            'user_id_param': userId,
          });

      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 最近の広告視聴記録を取得
  Future<List<AdView>> getRecentAdViews(String userId, {int limit = 10}) async {
    try {
      final result = await _supabaseService
          .from('ad_views')
          .select()
          .eq('user_id', userId)
          .order('viewed_at', ascending: false)
          .limit(limit);

      return (result as List)
          .map((json) => AdView.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 最近のガチャ履歴を取得
  Future<List<GachaHistory>> getRecentGachaHistory(String userId, {int limit = 20}) async {
    try {
      final result = await _supabaseService
          .from('gacha_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (result as List)
          .map((json) => GachaHistory.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// ガチャ結果を履歴に記録
  Future<void> recordGachaResult(
    String userId,
    Map<String, dynamic> gachaResult,
    int attemptsUsed,
    String source,
  ) async {
    try {
      await _supabaseService.from('gacha_history').insert({
        'user_id': userId,
        'gacha_result': gachaResult,
        'attempts_used': attemptsUsed,
        'source': source,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // エラー時はログ出力のみ（アプリの動作を止めたくない）
      print('Failed to record gacha history: $e');
    }
  }

  /// 今日のガチャ回数をリセット（デバッグ用）
  Future<void> resetTodayAttempts(String userId) async {
    try {
      await _supabaseService
          .from('gacha_attempts')
          .update({
            'used_attempts': 0,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('date', DateTime.now().toIso8601String().split('T')[0]);
    } catch (e) {
      print('Failed to reset gacha attempts: $e');
    }
  }

  /// 本日分の基本回数を設定（テスト用）
  Future<void> setTodayBaseAttempts(String userId, int baseAttempts) async {
    try {
      // 行が無ければ作成
      await _supabaseService.rpc('initialize_daily_gacha_attempts', params: {
        'user_id_param': userId,
      });
      // 本日分のbase_attemptsを更新（無ければupsert）
      await _supabaseService
          .from('gacha_attempts')
          .upsert({
            'user_id': userId,
            'date': DateTime.now().toIso8601String().split('T')[0],
            'base_attempts': baseAttempts,
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'user_id,date');
    } catch (e) {
      // テスト用ユーティリティなので失敗しても致命的にしない
      print('setTodayBaseAttempts failed: $e');
    }
  }
}
