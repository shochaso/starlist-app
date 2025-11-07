// Status:: in-progress
// Source-of-Truth:: lib/src/features/ops/providers/ops_metrics_provider.dart
// Spec-State:: 確定済み
// Last-Updated:: 2025-11-07

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/supabase_client_provider.dart';
import '../models/ops_metrics_model.dart';

/// Provider for OPS metrics
final opsMetricsProvider = FutureProvider<OpsMetrics>((ref) async {
  final client = ref.read(supabaseClientProvider);
  final now = DateTime.now();
  final last24h = now.subtract(const Duration(hours: 24));
  final last1h = now.subtract(const Duration(hours: 1));

  // Auth metrics: auth.login.* events
  final authLoginResponse = await client
      .from('ops_metrics')
      .select()
      .gte('ts_ingested', last24h.toIso8601String())
      .like('event', 'auth.login.%');

  final authLoginMetrics = (authLoginResponse.data ?? []) as List<dynamic>;
  final authLoginSuccess = authLoginMetrics.where((m) => m['ok'] == true).length;
  final authLoginTotal = authLoginMetrics.length;
  final signInSuccessRate = authLoginTotal > 0
      ? (authLoginSuccess / authLoginTotal) * 100
      : 100.0;
  final authFailures24h = authLoginMetrics.where((m) => m['ok'] == false).length;

  // Reauth metrics: auth.reauth.* events
  final reauthResponse = await client
      .from('ops_metrics')
      .select()
      .gte('ts_ingested', last24h.toIso8601String())
      .like('event', 'auth.reauth.%');

  final reauthMetrics = (reauthResponse.data ?? []) as List<dynamic>;
  final reauthSuccess = reauthMetrics.where((m) => m['ok'] == true).length;
  final reauthTotal = reauthMetrics.length;
  final reauthSuccessRate = reauthTotal > 0
      ? (reauthSuccess / reauthTotal) * 100
      : 100.0;

  // RLS metrics: rls.access.denied events
  final rlsResponse = await client
      .from('ops_metrics')
      .select()
      .gte('ts_ingested', last24h.toIso8601String())
      .eq('event', 'rls.access.denied');

  final rlsDenials24h = ((rlsResponse.data ?? []) as List<dynamic>).length;

  // Total requests for RLS denial rate calculation
  final totalRequestsResponse = await client
      .from('ops_metrics')
      .select()
      .gte('ts_ingested', last24h.toIso8601String());

  final totalRequests = ((totalRequestsResponse.data ?? []) as List<dynamic>).length;
  final rlsDenialRate = totalRequests > 0
      ? (rlsDenials24h / totalRequests) * 100
      : 0.0;

  // Subscription metrics: ops.subscription.price_* events
  final priceSetResponse = await client
      .from('ops_metrics')
      .select()
      .gte('ts_ingested', last24h.toIso8601String())
      .eq('event', 'ops.subscription.price_set');

  final priceSetEvents24h = ((priceSetResponse.data ?? []) as List<dynamic>).length;

  final priceDeniedResponse = await client
      .from('ops_metrics')
      .select()
      .gte('ts_ingested', last24h.toIso8601String())
      .eq('event', 'ops.subscription.price_denied');

  final priceDeniedEvents24h = ((priceDeniedResponse.data ?? []) as List<dynamic>).length;

  final priceDeniedRate = (priceSetEvents24h + priceDeniedEvents24h) > 0
      ? (priceDeniedEvents24h / (priceSetEvents24h + priceDeniedEvents24h)) * 100
      : 0.0;

  // Performance metrics: search.sla_missed events
  final searchSlaResponse = await client
      .from('ops_metrics')
      .select()
      .gte('ts_ingested', last1h.toIso8601String())
      .eq('event', 'search.sla_missed');

  final searchSlaMissed1h = ((searchSlaResponse.data ?? []) as List<dynamic>).length;

  // Average response time (from latency_ms)
  final latencyResponse = await client
      .from('ops_metrics')
      .select('latency_ms')
      .gte('ts_ingested', last24h.toIso8601String())
      .not('latency_ms', 'is', null);

  final latencies = ((latencyResponse.data ?? []) as List<dynamic>)
      .map((m) => m['latency_ms'] as int?)
      .whereType<int>()
      .toList();
  final avgResponseTimeMs = latencies.isNotEmpty
      ? (latencies.reduce((a, b) => a + b) / latencies.length).round()
      : 0;

  return OpsMetrics(
    signInSuccessRate: signInSuccessRate,
    reauthSuccessRate: reauthSuccessRate,
    authFailures24h: authFailures24h,
    rlsDenials24h: rlsDenials24h,
    rlsDenialRate: rlsDenialRate,
    priceSetEvents24h: priceSetEvents24h,
    priceDeniedEvents24h: priceDeniedEvents24h,
    priceDeniedRate: priceDeniedRate,
    searchSlaMissed1h: searchSlaMissed1h,
    avgResponseTimeMs: avgResponseTimeMs,
  );
});

