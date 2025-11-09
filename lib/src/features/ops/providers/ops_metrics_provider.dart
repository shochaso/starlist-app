// Status:: in-progress
// Source-of-Truth:: lib/src/features/ops/providers/ops_metrics_provider.dart
// Spec-State:: 確定済み
// Last-Updated:: 2025-11-07

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/supabase_client_provider.dart';
import '../models/ops_alert_model.dart';
import '../models/ops_health_model.dart';
import '../models/ops_metrics_model.dart';
import '../models/ops_metrics_series_model.dart';

const bool _opsMockEnabled =
    bool.fromEnvironment('OPS_MOCK', defaultValue: false);
const Duration _autoRefreshInterval = Duration(seconds: 30);
const Duration _dedupeWindow = Duration(seconds: 5);

final opsMetricsAuthErrorProvider = StateProvider<bool>((ref) => false);

/// Filter state provider backed by a StateNotifier for richer mutations.
final opsMetricsFilterProvider =
    StateNotifierProvider<OpsMetricsFilterNotifier, OpsMetricsFilter>(
  (ref) => OpsMetricsFilterNotifier(),
);

class OpsMetricsFilterNotifier extends StateNotifier<OpsMetricsFilter> {
  OpsMetricsFilterNotifier() : super(const OpsMetricsFilter(sinceMinutes: 30));

  void updateEnv(String? env) {
    state = state.copyWith(env: _normalizeFilterValue(env));
  }

  void updateApp(String? app) {
    state = state.copyWith(app: _normalizeFilterValue(app));
  }

  void updateEventType(String? event) {
    state = state.copyWith(eventType: _normalizeFilterValue(event));
  }

  void updateWindow(int minutes) {
    final safeMinutes = max(5, minutes);
    state = state.copyWith(sinceMinutes: safeMinutes);
  }

  void setFilter(OpsMetricsFilter filter) {
    state = filter;
  }

  void reset() {
    state = const OpsMetricsFilter(sinceMinutes: 30);
  }

  String? _normalizeFilterValue(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == 'ALL') {
      return null;
    }
    return trimmed;
  }
}

/// Time series data provider (from v_ops_5min view)
final opsMetricsSeriesProvider = AutoDisposeAsyncNotifierProvider<
    OpsMetricsSeriesNotifier, List<OpsMetricsSeriesPoint>>(
  OpsMetricsSeriesNotifier.new,
);

class OpsMetricsSeriesNotifier
    extends AutoDisposeAsyncNotifier<List<OpsMetricsSeriesPoint>> {
  Timer? _autoRefreshTimer;
  Future<List<OpsMetricsSeriesPoint>>? _inFlight;
  DateTime? _lastFetchAt;
  int? _lastFilterHash;

  @override
  Future<List<OpsMetricsSeriesPoint>> build() async {
    ref.onDispose(_cancelTimer);
    _scheduleRefresh();
    final filter = ref.watch(opsMetricsFilterProvider);
    return _refreshWithFilter(filter);
  }

  Future<void> manualRefresh() async {
    final filter = ref.read(opsMetricsFilterProvider);
    debugPrint(
        '[opsMetricsSeries] manual refresh triggered for ${_filterLabel(filter)}');
    state = const AsyncLoading();
    final nextState =
        await AsyncValue.guard(() => _refreshWithFilter(filter, force: true));
    debugPrint(
        '[opsMetricsSeries] manual refresh completed for ${_filterLabel(filter)}');
    state = nextState;
  }

  void _scheduleRefresh() {
    _autoRefreshTimer ??= Timer.periodic(_autoRefreshInterval, (_) {
      _triggerAutoRefresh();
    });
  }

  void _cancelTimer() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  Future<void> _triggerAutoRefresh() async {
    final filter = ref.read(opsMetricsFilterProvider);
    debugPrint(
        '[opsMetricsSeries] auto-refresh triggered for ${_filterLabel(filter)}');
    final nextState = await AsyncValue.guard(() => _refreshWithFilter(filter));
    state = nextState;
  }

  Future<List<OpsMetricsSeriesPoint>> _refreshWithFilter(
    OpsMetricsFilter filter, {
    bool force = false,
  }) async {
    final now = DateTime.now();
    final filterHash = _hashFilter(filter);
    final recentlyFetched = !force &&
        _lastFetchAt != null &&
        _lastFilterHash == filterHash &&
        now.difference(_lastFetchAt!) < _dedupeWindow;

    if (recentlyFetched) {
      debugPrint(
          '[opsMetricsSeries] dedupe skip for ${_filterLabel(filter)} (cached within $_dedupeWindow)');
      final cached = state.value;
      if (cached != null) {
        return cached;
      }
    }

    if (!force && _inFlight != null) {
      return _inFlight!;
    }

    final future = _loadSeries(filter);
    _inFlight = future;

    try {
      final data = await future;
      _lastFetchAt = DateTime.now();
      _lastFilterHash = filterHash;
      return data;
    } finally {
      if (identical(_inFlight, future)) {
        _inFlight = null;
      }
    }
  }

  Future<List<OpsMetricsSeriesPoint>> _loadSeries(
      OpsMetricsFilter filter) async {
    if (_opsMockEnabled) {
      return _generateMockSeries(filter);
    }

    final client = ref.read(supabaseClientProvider);
    final since =
        DateTime.now().subtract(Duration(minutes: max(filter.sinceMinutes, 5)));
    debugPrint(
        '[opsMetricsSeries] loading ${_filterLabel(filter)} since ${since.toIso8601String()}');

    var query = client
        .from('v_ops_5min')
        .select()
        .gte('bucket_5m', since.toUtc().toIso8601String());

    if (_hasValue(filter.env)) {
      query = query.eq('env', filter.env!);
    }
    if (_hasValue(filter.app)) {
      query = query.eq('app', filter.app!);
    }
    if (_hasValue(filter.eventType)) {
      query = query.eq('event', filter.eventType!);
    }

    final response = await query.order('bucket_5m', ascending: true);
    final data = _asList(response);
    debugPrint(
        '[opsMetricsSeries] loaded ${data.length} points for ${_filterLabel(filter)}');
    return data
        .whereType<Map<String, dynamic>>()
        .map(OpsMetricsSeriesPoint.fromJson)
        .toList();
  }
}

bool _hasValue(String? value) => value != null && value.isNotEmpty;

int _hashFilter(OpsMetricsFilter filter) => Object.hash(
      filter.env ?? '',
      filter.app ?? '',
      filter.eventType ?? '',
      filter.sinceMinutes,
    );

List<OpsMetricsSeriesPoint> _generateMockSeries(OpsMetricsFilter filter) {
  final random = Random(filter.hashCode);
  final buckets = <OpsMetricsSeriesPoint>[];
  final minutes = max(filter.sinceMinutes, 30);
  final bucketCount = max(1, (minutes / 5).ceil());
  final now = DateTime.now();
  const envs = ['dev', 'stg', 'prod'];
  const apps = ['flutter_web', 'admin', 'ops'];
  const events = [
    'auth.login.success',
    'auth.login.failure',
    'search.sla_missed'
  ];

  for (int i = bucketCount - 1; i >= 0; i--) {
    final bucketStart = now.subtract(Duration(minutes: i * 5));
    final total = 80 + random.nextInt(80);
    final failureRate = (random.nextDouble() * 0.08).clamp(0.0, 0.15);
    final latency = 180 + random.nextInt(420);

    buckets.add(
      OpsMetricsSeriesPoint(
        bucketStart: bucketStart,
        env: filter.env ?? envs[random.nextInt(envs.length)],
        app: filter.app ?? apps[random.nextInt(apps.length)],
        event: filter.eventType ?? events[random.nextInt(events.length)],
        total: total,
        failureRate: double.parse(failureRate.toStringAsFixed(3)),
        p95LatencyMs: latency,
      ),
    );
  }

  debugPrint(
      '[opsMetricsSeries] mock data produced (${buckets.length} points) for ${_filterLabel(filter)}');
  return buckets;
}

List<OpsAlert> _mockAlerts() {
  final now = DateTime.now();
  return [
    OpsAlert(
      type: 'failure_rate',
      message: 'Failure rate exceeded 8% in prod',
      value: 8.2,
      threshold: 5.0,
      alertedAt: now.subtract(const Duration(minutes: 4)),
    ),
    OpsAlert(
      type: 'p95_latency',
      message: 'p95 latency reached 620ms (ops service)',
      value: 620,
      threshold: 500,
      alertedAt: now.subtract(const Duration(minutes: 12)),
    ),
  ];
}

List<dynamic> _asList(dynamic response) {
  if (response is List) {
    return response.cast<dynamic>();
  }
  return <dynamic>[];
}

String _filterLabel(OpsMetricsFilter filter) {
  final env = filter.env?.trim().isEmpty ?? true ? 'ALL' : filter.env;
  final app = filter.app?.trim().isEmpty ?? true ? 'ALL' : filter.app;
  final event =
      filter.eventType?.trim().isEmpty ?? true ? 'ALL' : filter.eventType;
  return 'env=${env ?? 'ALL'} app=${app ?? 'ALL'} event=${event ?? 'ALL'} window=${filter.sinceMinutes}m';
}

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

/// Recent alerts provider (from ops-alert Edge Function)
final opsRecentAlertsProvider = FutureProvider<List<OpsAlert>>((ref) async {
  if (_opsMockEnabled) {
    return _mockAlerts();
  }

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
        alertedAt:
            now, // Use current time since Edge Function doesn't return timestamp
      );
    }).toList();
  } catch (e) {
    // If Edge Function call fails, return empty list
    debugPrint('[opsRecentAlertsProvider] Error: $e');
    return [];
  }
});

/// Health period provider
final opsHealthPeriodProvider = StateProvider<String>((ref) => '24h');

/// Health data provider (from ops-health Edge Function)
final opsHealthProvider = FutureProvider<OpsHealthData>((ref) async {
  final client = ref.read(supabaseClientProvider);
  final period = ref.watch(opsHealthPeriodProvider);

  try {
    final response = await client.functions.invoke(
      'ops-health',
      body: {
        'period': period,
      },
    );

    if (response.data == null) {
      return OpsHealthData.empty();
    }

    return OpsHealthData.fromJson(response.data as Map<String, dynamic>);
  } catch (e) {
    debugPrint('[opsHealthProvider] Error: $e');
    return OpsHealthData.empty();
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

  final authLoginMetrics = _asList(authLoginResponse);
  final authLoginSuccess =
      authLoginMetrics.where((m) => m['ok'] == true).length;
  final authLoginTotal = authLoginMetrics.length;
  final signInSuccessRate =
      authLoginTotal > 0 ? (authLoginSuccess / authLoginTotal) * 100 : 100.0;
  final authFailures24h =
      authLoginMetrics.where((m) => m['ok'] == false).length;

  // Reauth metrics: auth.reauth.* events
  final reauthResponse = await client
      .from('ops_metrics')
      .select()
      .gte('ts_ingested', last24h.toIso8601String())
      .like('event', 'auth.reauth.%');

  final reauthMetrics = _asList(reauthResponse);
  final reauthSuccess = reauthMetrics.where((m) => m['ok'] == true).length;
  final reauthTotal = reauthMetrics.length;
  final reauthSuccessRate =
      reauthTotal > 0 ? (reauthSuccess / reauthTotal) * 100 : 100.0;

  // RLS metrics: rls.access.denied events
  final rlsResponse = await client
      .from('ops_metrics')
      .select()
      .gte('ts_ingested', last24h.toIso8601String())
      .eq('event', 'rls.access.denied');

  final rlsDenials24h = _asList(rlsResponse).length;

  // Total requests for RLS denial rate calculation
  final totalRequestsResponse = await client
      .from('ops_metrics')
      .select()
      .gte('ts_ingested', last24h.toIso8601String());

  final totalRequests = _asList(totalRequestsResponse).length;
  final rlsDenialRate =
      totalRequests > 0 ? (rlsDenials24h / totalRequests) * 100 : 0.0;

  // Subscription metrics: ops.subscription.price_* events
  final priceSetResponse = await client
      .from('ops_metrics')
      .select()
      .gte('ts_ingested', last24h.toIso8601String())
      .eq('event', 'ops.subscription.price_set');

  final priceSetEvents24h = _asList(priceSetResponse).length;

  final priceDeniedResponse = await client
      .from('ops_metrics')
      .select()
      .gte('ts_ingested', last24h.toIso8601String())
      .eq('event', 'ops.subscription.price_denied');

  final priceDeniedEvents24h = _asList(priceDeniedResponse).length;

  final priceDeniedRate = (priceSetEvents24h + priceDeniedEvents24h) > 0
      ? (priceDeniedEvents24h / (priceSetEvents24h + priceDeniedEvents24h)) *
          100
      : 0.0;

  // Performance metrics: search.sla_missed events
  final searchSlaResponse = await client
      .from('ops_metrics')
      .select()
      .gte('ts_ingested', last1h.toIso8601String())
      .eq('event', 'search.sla_missed');

  final searchSlaMissed1h = _asList(searchSlaResponse).length;

  // Average response time (from latency_ms)
  final latencyResponse = await client
      .from('ops_metrics')
      .select('latency_ms')
      .gte('ts_ingested', last24h.toIso8601String())
      .not('latency_ms', 'is', null);

  final latencies = _asList(latencyResponse)
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
