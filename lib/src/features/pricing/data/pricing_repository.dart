// Status:: in-progress
// Source-of-Truth:: lib/src/features/pricing/data/pricing_repository.dart
// Spec-State:: 確定済み（推奨価格取得）
// Last-Updated:: 2025-11-08

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 推奨価格設定を取得するProvider
final pricingConfigProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final supabase = Supabase.instance.client;

  try {
    final res = await supabase.rpc('get_app_setting', params: {'p_key': 'pricing.recommendations'});

    if (res == null) {
      // フォールバック（同値）
      return _fallbackConfig();
    }

    return Map<String, dynamic>.from(res as Map);
  } catch (e) {
    // エラー時はフォールバックを返す
    return _fallbackConfig();
  }
});

/// フォールバック設定（デフォルト値）
Map<String, dynamic> _fallbackConfig() {
  return {
    "version": "fallback",
    "tiers": {
      "light": {"student": 100, "adult": 480},
      "standard": {"student": 200, "adult": 1980},
      "premium": {"student": 500, "adult": 4980}
    },
    "limits": {
      "student": {"min": 100, "max": 9999},
      "adult": {"min": 300, "max": 29999},
      "step": 10,
      "currency": "JPY",
      "tax_inclusive": true
    }
  };
}

