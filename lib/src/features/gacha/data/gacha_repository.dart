import 'dart:math';
import '../models/gacha_models_simple.dart';
import 'package:flutter/material.dart';

/// ガチャのデータアクセス層抽象クラス
abstract class GachaRepository {
  Future<GachaResult> drawGacha();
}

/// Expected Value Calculation (目標: 135回で1シルバーチケット相当)
/// - 50% -> 20pt = 0.50 * 20 = 10pt
/// - 30% -> 40pt = 0.30 * 40 = 12pt
/// - 15% -> 60pt = 0.15 * 60 = 9pt
/// - 4%  -> 120pt = 0.04 * 120 = 4.8pt
/// - 1%  -> silver ticket (direct) = 0.01 * 1 = 0.01 tickets
/// Total expected per draw: 35.8pt + 0.01 tickets
/// 135 draws: 4,833pt + 1.35 silver tickets
/// (Note: Assumes silver ticket equivalent value; adjust as needed for game balance)
///
/// ガチャリポジトリの実装クラス
class GachaRepositoryImpl implements GachaRepository {
  final Random _random = Random();

  @override
  Future<GachaResult> drawGacha() async {
    // 意図的な遅延でアニメーション時間を確保
    await Future.delayed(const Duration(seconds: 2));

    // 確率による抽選処理
    final randomValue = _random.nextDouble() * 100; // 0-100の範囲

    if (randomValue < 50.0) {
      // 20ポイント (50%)
      return const PointResult(amount: 20);
    } else if (randomValue < 80.0) {
      // 40ポイント (30%)
      return const PointResult(amount: 40);
    } else if (randomValue < 95.0) {
      // 60ポイント (15%)
      return const PointResult(amount: 60);
    } else if (randomValue < 99.0) {
      // 120ポイント (4%)
      return const PointResult(amount: 120);
    } else {
      // シルバーチケット (1%)
      return const TicketResult(
        ticketType: 'silver',
        displayName: 'シルバーチケット',
        color: Colors.grey,
      );
    }
  }
}