// Status:: in-progress
// Source-of-Truth:: lib/core/telemetry/prod_search_telemetry.dart
// Spec-State:: 確定済み
// Last-Updated:: 2025-11-07

import 'dart:math';
import '../telemetry/search_telemetry.dart';
import '../../src/features/ops/ops_telemetry.dart';

/// Production implementation of SearchTelemetry that sends events to Edge Functions
class ProdSearchTelemetry implements SearchTelemetry {
  final OpsTelemetry _opsTelemetry;
  final Random _random = Random();

  ProdSearchTelemetry({
    OpsTelemetry? opsTelemetry,
  }) : _opsTelemetry = opsTelemetry ?? OpsTelemetry.prod();

  @override
  void searchSlaMissed(int elapsedMs) {
    // SLA超過時は100%サンプリング（全件送信）
    _opsTelemetry.send(
      event: 'search.sla_missed',
      ok: false,
      latencyMs: elapsedMs,
      errCode: 'SLA_EXCEEDED',
    );
  }

  @override
  void tagOnlyDedupHit(int removedCount) {
    // 重複検出時は10%サンプリング
    if (_random.nextDouble() < 0.1) {
      _opsTelemetry.send(
        event: 'search.tag_only_dedup',
        ok: true,
        extra: {'removed_count': removedCount},
      );
    }
  }
}

