// Status:: in-progress
// Source-of-Truth:: lib/src/features/ops/providers/ops_metrics_provider.dart
// Spec-State:: 確定済み
// Last-Updated:: 2025-11-07

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/supabase_client_provider.dart';
import '../models/ops_metrics_model.dart';
import '../models/ops_metrics_series_model.dart';
import '../models/ops_alert_model.dart';

/// Filter state provider
final opsMetricsFilterProvider = StateProvider<OpsMetricsFilter>((ref) {
  return const OpsMetricsFilter(sinceMinutes: 30);
});

/// Time series data provider (from v_ops_5min view)
final opsMetricsSeriesProvider = FutureProvider<List<OpsMetricsSeriesPoint>>((ref) async {
  final client = ref.read(supabaseClientProvider);
  final filter = ref.watch(opsMetricsFilterProvider);
  final now = DateTime.now();
  final since = now.subtract(Duration(minutes: filter.sinceMinutes));

  var query = client
      .from('v_ops_5min')
      .select()
      .gte('bucket_5m', since.toUtc().toIso8601String());

  if (filter.env != null && filter.env!.isNotEmpty) {
    query = query.eq('env', filter.env!);
  }
  if (filter.app != null && filter.app!.isNotEmpty) {
    query = query.eq('app', filter.app!);
  }
  if (filter.eventType != null && filter.eventType!.isNotEmpty) {
    query = query.eq('event', filter.eventType!);
  }

  // order()は最後に呼び出す
  final response = await query.order('bucket_5m', ascending: true);
  
  final data = (response ?? []) as List<dynamic>;
  
  return data.map((json) => OpsMetricsSeriesPoint.fromJson(json as Map<String, dynamic>)).toList();
});

/// KPI metrics provider (aggregated from series)
final opsMetricsKpiProvider = Provider<OpsMetricsKpi>((ref) {
  final seriesAsync = ref.watch(opsMetricsSeriesProvider);
  return seriesAsync.when(
    data: (series) => OpsMetricsKpi.fromSeries(series),
    loading: () => OpsMetricsKpi(
      totalRequests: 0,
      errorCount: 0,
      errorRate: 0.0,
      p95LatencyMs: null,
    ),
    error: (_, __) => OpsMetricsKpi(
      totalRequests: 0,
      errorCount: 0,
      errorRate: 0.0,
      p95LatencyMs: null,
    ),
  );
});

/// Auto-refresh timer provider (30 seconds)
final opsMetricsAutoRefreshProvider = StreamProvider<void>((ref) {
  return Stream.periodic(const Duration(seconds: 30), (_) {});
});

/// Recent alerts provider (from ops-alert Edge Function)
final opsRecentAlertsProvider = FutureProvider<List<OpsAlert>>((ref) async {
  final client = ref.read(supabaseClientProvider);
  
  try {
    // Call ops-alert Edge Function with dryRun=false to get current alerts
    final response = await client.functions.invoke(
      'ops-alert',
      body: {
        'dry_run': false,
        'minutes': 60, // Check last 60 minutes
      },
    );

    if (response.data == null) {
      return [];
    }

    final data = response.data as Map<String, dynamic>;
    final alerts = data['alerts'] as List<dynamic>?;
    
    if (alerts == null || alerts.isEmpty) {
      return [];
    }

    // Convert to OpsAlert objects with current timestamp
    final now = DateTime.now().toLocal();
    return alerts.map((alertJson) {
      final alert = alertJson as Map<String, dynamic>;
      return OpsAlert(
        type: alert['type'] as String,
        message: alert['message'] as String,
        value: (alert['value'] as num).toDouble(),
        threshold: (alert['threshold'] as num).toDouble(),
        alertedAt: now, // Use current time since Edge Function doesn't return timestamp
      );
    }).toList();
  } catch (e) {
    // If Edge Function call fails, return empty list
    print('[opsRecentAlertsProvider] Error: $e');
    return [];
  }
});

/// Provider for OPS metrics (legacy - kept for backward compatibility)
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

  final authLoginMetrics = (authLoginResponse ?? []) as List<dynamic>;
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

  final reauthMetrics = (reauthResponse ?? []) as List<dynamic>;
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

  final rlsDenials24h = ((rlsResponse ?? []) as List<dynamic>).length;

  // Total requests for RLS denial rate calculation
  final totalRequestsResponse = await client
      .from('ops_metrics')
      .select()
      .gte('ts_ingested', last24h.toIso8601String());

  final totalRequests = ((totalRequestsResponse ?? []) as List<dynamic>).length;
  final rlsDenialRate = totalRequests > 0
      ? (rlsDenials24h / totalRequests) * 100
      : 0.0;

  // Subscription metrics: ops.subscription.price_* events
  final priceSetResponse = await client
      .from('ops_metrics')
      .select()
      .gte('ts_ingested', last24h.toIso8601String())
      .eq('event', 'ops.subscription.price_set');

  final priceSetEvents24h = ((priceSetResponse ?? []) as List<dynamic>).length;

  final priceDeniedResponse = await client
      .from('ops_metrics')
      .select()
      .gte('ts_ingested', last24h.toIso8601String())
      .eq('event', 'ops.subscription.price_denied');

  final priceDeniedEvents24h = ((priceDeniedResponse ?? []) as List<dynamic>).length;

  final priceDeniedRate = (priceSetEvents24h + priceDeniedEvents24h) > 0
      ? (priceDeniedEvents24h / (priceSetEvents24h + priceDeniedEvents24h)) * 100
      : 0.0;

  // Performance metrics: search.sla_missed events
  final searchSlaResponse = await client
      .from('ops_metrics')
      .select()
      .gte('ts_ingested', last1h.toIso8601String())
      .eq('event', 'search.sla_missed');

  final searchSlaMissed1h = ((searchSlaResponse ?? []) as List<dynamic>).length;

  // Average response time (from latency_ms)
  final latencyResponse = await client
      .from('ops_metrics')
      .select('latency_ms')
      .gte('ts_ingested', last24h.toIso8601String())
      .not('latency_ms', 'is', null);

  final latencies = ((latencyResponse ?? []) as List<dynamic>)
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

