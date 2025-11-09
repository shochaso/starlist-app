// Status:: in-progress
// Source-of-Truth:: lib/src/features/pricing/domain/pricing_validator.dart
// Spec-State:: 確定済み（価格バリデーション）
// Last-Updated:: 2025-11-08

/// 価格制限（下限/上限/刻み）
class PricingLimits {
  final int min;
  final int max;
  final int step;

  const PricingLimits({
    required this.min,
    required this.max,
    required this.step,
  });
}

/// 価格バリデーション
String? validatePrice({
  required int value,
  required PricingLimits limits,
}) {
  if (value % limits.step != 0) {
    return '価格は${limits.step}円刻みで入力してください';
  }

  if (value < limits.min) {
    return '価格は最低${limits.min}円以上で設定してください';
  }

  if (value > limits.max) {
    return '価格は最大${limits.max}円までです';
  }

  return null; // OK
}

/// 設定から学生/成人の制限を取得
PricingLimits limitsFromConfig(
  Map<String, dynamic> cfg, {
  required bool isAdult,
}) {
  final limits = cfg['limits'] as Map<String, dynamic>;
  final group = (isAdult ? limits['adult'] : limits['student']) as Map<String, dynamic>;

  return PricingLimits(
    min: (group['min'] as num).toInt(),
    max: (group['max'] as num).toInt(),
    step: (limits['step'] as num).toInt(),
  );
}

/// 推奨額の取得
int recommendedFor(
  Map<String, dynamic> cfg, {
  required String tier,
  required bool isAdult,
}) {
  final tiers = cfg['tiers'] as Map<String, dynamic>;
  final t = tiers[tier] as Map<String, dynamic>;
  return ((isAdult ? t['adult'] : t['student']) as num).toInt();
}


// Source-of-Truth:: lib/src/features/pricing/domain/pricing_validator.dart
// Spec-State:: 確定済み（価格バリデーション）
// Last-Updated:: 2025-11-08

/// 価格制限（下限/上限/刻み）
class PricingLimits {
  final int min;
  final int max;
  final int step;

  const PricingLimits({
    required this.min,
    required this.max,
    required this.step,
  });
}

/// 価格バリデーション
String? validatePrice({
  required int value,
  required PricingLimits limits,
}) {
  if (value % limits.step != 0) {
    return '価格は${limits.step}円刻みで入力してください';
  }

  if (value < limits.min) {
    return '価格は最低${limits.min}円以上で設定してください';
  }

  if (value > limits.max) {
    return '価格は最大${limits.max}円までです';
  }

  return null; // OK
}

/// 設定から学生/成人の制限を取得
PricingLimits limitsFromConfig(
  Map<String, dynamic> cfg, {
  required bool isAdult,
}) {
  final limits = cfg['limits'] as Map<String, dynamic>;
  final group = (isAdult ? limits['adult'] : limits['student']) as Map<String, dynamic>;

  return PricingLimits(
    min: (group['min'] as num).toInt(),
    max: (group['max'] as num).toInt(),
    step: (limits['step'] as num).toInt(),
  );
}

/// 推奨額の取得
int recommendedFor(
  Map<String, dynamic> cfg, {
  required String tier,
  required bool isAdult,
}) {
  final tiers = cfg['tiers'] as Map<String, dynamic>;
  final t = tiers[tier] as Map<String, dynamic>;
  return ((isAdult ? t['adult'] : t['student']) as num).toInt();
}


