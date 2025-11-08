// Status:: in-progress
// Source-of-Truth:: test/src/features/pricing/domain/pricing_validator_test.dart
// Spec-State:: 確定済み（価格バリデーションテスト）
// Last-Updated:: 2025-11-08

import 'package:flutter_test/flutter_test.dart';
import 'package:starlist/src/features/pricing/domain/pricing_validator.dart';

void main() {
  group('PricingLimits', () {
    test('should create with valid values', () {
      const limits = PricingLimits(min: 100, max: 1000, step: 10);
      expect(limits.min, 100);
      expect(limits.max, 1000);
      expect(limits.step, 10);
    });
  });

  group('validatePrice', () {
    const limits = PricingLimits(min: 100, max: 1000, step: 10);

    test('should return null for valid price', () {
      expect(validatePrice(value: 500, limits: limits), isNull);
      expect(validatePrice(value: 100, limits: limits), isNull);
      expect(validatePrice(value: 1000, limits: limits), isNull);
    });

    test('should return error for price below min', () {
      final result = validatePrice(value: 50, limits: limits);
      expect(result, isNotNull);
      expect(result, contains('最低100円以上'));
    });

    test('should return error for price above max', () {
      final result = validatePrice(value: 1500, limits: limits);
      expect(result, isNotNull);
      expect(result, contains('最大1000円まで'));
    });

    test('should return error for price not matching step', () {
      final result = validatePrice(value: 105, limits: limits);
      expect(result, isNotNull);
      expect(result, contains('10円刻み'));
    });
  });

  group('limitsFromConfig', () {
    final config = {
      'limits': {
        'student': {'min': 100, 'max': 9999},
        'adult': {'min': 300, 'max': 29999},
        'step': 10,
      }
    };

    test('should return student limits', () {
      final limits = limitsFromConfig(config, isAdult: false);
      expect(limits.min, 100);
      expect(limits.max, 9999);
      expect(limits.step, 10);
    });

    test('should return adult limits', () {
      final limits = limitsFromConfig(config, isAdult: true);
      expect(limits.min, 300);
      expect(limits.max, 29999);
      expect(limits.step, 10);
    });
  });

  group('recommendedFor', () {
    final config = {
      'tiers': {
        'light': {'student': 100, 'adult': 480},
        'standard': {'student': 200, 'adult': 1980},
        'premium': {'student': 500, 'adult': 4980},
      }
    };

    test('should return student recommended price', () {
      expect(recommendedFor(config, tier: 'light', isAdult: false), 100);
      expect(recommendedFor(config, tier: 'standard', isAdult: false), 200);
      expect(recommendedFor(config, tier: 'premium', isAdult: false), 500);
    });

    test('should return adult recommended price', () {
      expect(recommendedFor(config, tier: 'light', isAdult: true), 480);
      expect(recommendedFor(config, tier: 'standard', isAdult: true), 1980);
      expect(recommendedFor(config, tier: 'premium', isAdult: true), 4980);
    });
  });

  group('price limits & step', () {
    test('should validate price limits and step correctly', () {
      final limits = PricingLimits(min: 300, max: 29999, step: 10);

      expect(validatePrice(value: 290, limits: limits), isNotNull); // 下限違反
      expect(validatePrice(value: 300, limits: limits), isNull); // OK
      expect(validatePrice(value: 305, limits: limits), isNotNull); // 刻み違反
      expect(validatePrice(value: 30000, limits: limits), isNotNull); // 上限違反
      expect(validatePrice(value: 310, limits: limits), isNull); // OK（刻み一致）
    });
  });

  group('recommended value read', () {
    test('should read recommended value correctly', () {
      final cfg = {
        "tiers": {"light": {"student": 100, "adult": 480}},
        "limits": {
          "student": {"min": 100, "max": 9999},
          "adult": {"min": 300, "max": 29999},
          "step": 10
        }
      };

      expect(recommendedFor(cfg, tier: 'light', isAdult: true), 480);
      expect(recommendedFor(cfg, tier: 'light', isAdult: false), 100);
    });
  });
}

