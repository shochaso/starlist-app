import 'package:flutter_test/flutter_test.dart';
import 'package:starlist_app/utils/key_normalizer.dart';

void main() {
  group('KeyNormalizer.normalize', () {
    test('normalizes video service variations', () {
      expect(KeyNormalizer.normalize('u_next'), equals('unext'));
      expect(KeyNormalizer.normalize('U-NEXT'), equals('unext'));
      expect(KeyNormalizer.normalize('  prime video  '), equals('prime_video'));
      expect(KeyNormalizer.normalize('Amazon-Prime-Video'), equals('prime_video'));
    });

    test('normalizes shopping aliases', () {
      expect(KeyNormalizer.normalize('SHEIN_JP'), equals('shein'));
      expect(KeyNormalizer.normalize('シーイン'), equals('shein'));
    });

    test('normalizes delivery services', () {
      expect(KeyNormalizer.normalize('UberEats'), equals('uber_eats'));
      expect(KeyNormalizer.normalize('ウーバーイーツ'), equals('uber_eats'));
    });

    test('strips extra separators and casing', () {
      expect(KeyNormalizer.normalize('  Foo---Bar  '), equals('foo_bar'));
      expect(KeyNormalizer.normalize('FOO__bar'), equals('foo_bar'));
    });
  });
}
