import 'dart:math';
import '../models/gacha_models_simple.dart';
import 'package:flutter/material.dart';

/// ガチャのデータアクセス層抽象クラス
abstract class GachaRepository {
  Future<GachaResult> drawGacha();
}

/// ガチャリポジトリの実装クラス
class GachaRepositoryImpl implements GachaRepository {
  final Random _random;

  GachaRepositoryImpl({Random? random}) : _random = random ?? Random();

  /// Probability table tuned for ~44 EV/roll (135 rolls ≒ 1 silver via exchange)
  /// - 50%: 20pt
  /// - 30%: 40pt
  /// - 15%: 60pt
  /// - 4% : 120pt
  /// - 1% : Silver ticket direct (EV ≒ 6000 * 0.01 = 60pt equivalent)
  @override
  Future<GachaResult> drawGacha() async {
    await Future.delayed(const Duration(seconds: 2)); // keep animation timing

    final roll = _random.nextDouble() * 100;
    if (roll < 50.0) {
      return const PointResult(amount: 20);
    } else if (roll < 80.0) {
      return const PointResult(amount: 40);
    } else if (roll < 95.0) {
      return const PointResult(amount: 60);
    } else if (roll < 99.0) {
      return const PointResult(amount: 120);
    } else {
      return const TicketResult(
        ticketType: 'silver',
        displayName: 'シルバーチケット',
        color: Colors.grey,
      );
    }
  }
}
