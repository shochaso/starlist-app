import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starlist/src/features/gacha/data/gacha_repository.dart';
import 'package:starlist/src/features/gacha/models/gacha_models_simple.dart';

void main() {
  test('gacha repository returns expected reward set with seeded random', () async {
    final repo = GachaRepositoryImpl(random: Random(42));

    // First few rolls with seed 42 should hit known branches deterministically
    final results = <GachaResult>[];
    for (int i = 0; i < 5; i++) {
      results.add(await repo.drawGacha());
    }

    expect(results.length, 5);
    expect(results[0].when(point: (amt) => amt, ticket: (_, __, ___) => -1), anyOf(20, 40, 60, 120));
    expect(results[4], isA<GachaResult>());
  });

  test('gacha ticket result carries silver metadata', () async {
    // Force roll to silver by patching Random to return >99
    final fakeRandom = _FixedRandom(99.5);
    final repo = GachaRepositoryImpl(random: fakeRandom);
    final result = await repo.drawGacha();
    result.when(
      point: (_) => fail('expected ticket'),
      ticket: (type, name, color) {
        expect(type, 'silver');
        expect(name, 'シルバーチケット');
        expect(color, Colors.grey);
      },
    );
  });
}

class _FixedRandom extends Random {
  _FixedRandom(this.value);
  final double value;

  @override
  double nextDouble() => value / 100;

  @override
  int nextInt(int max) => (value % max).floor();
}
