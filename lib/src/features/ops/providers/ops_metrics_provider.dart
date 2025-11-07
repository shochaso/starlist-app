import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/providers.dart';
import '../models/ops_alert_model.dart';
import '../models/ops_metrics_model.dart';

const bool kUseOpsMockDefault =
    !kReleaseMode && bool.fromEnvironment('OPS_MOCK', defaultValue: false);

final useOpsMetricsMockProvider = Provider<bool>((_) => kUseOpsMockDefault);

class OpsMetricsFilter {
  final String? env;
  final String? app;
  final String? eventType;
  final int sinceMinutes;

  const OpsMetricsFilter({
    this.env,
    this.app,
    this.eventType,
    this.sinceMinutes = 30,
  });

  OpsMetricsFilter copyWith({
    String? env,
    String? app,
    String? eventType,
    int? sinceMinutes,
  }) {
    return OpsMetricsFilter(
      env: env ?? this.env,
      app: app ?? this.app,
      eventType: eventType ?? this.eventType,
      sinceMinutes: sinceMinutes ?? this.sinceMinutes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpsMetricsFilter &&
        other.env == env &&
        other.app == app &&
        other.eventType == eventType &&
        other.sinceMinutes == sinceMinutes;
  }

  @override
  int get hashCode => Object.hash(env, app, eventType, sinceMinutes);
}

class OpsMetricsFilterNotifier extends StateNotifier<OpsMetricsFilter> {
  OpsMetricsFilterNotifier() : super(const OpsMetricsFilter());

  void updateEnv(String? value) {
    state = state.copyWith(env: value?.isEmpty == true ? null : value);
  }

  void updateApp(String? value) {
    state = state.copyWith(app: value?.isEmpty == true ? null : value);
  }

  void updateEventType(String? value) {
    state = state.copyWith(eventType: value?.isEmpty == true ? null : value);
  }

  void updateWindow(int minutes) {
    state = state.copyWith(sinceMinutes: minutes);
  }
}

final opsMetricsFilterProvider =
    StateNotifierProvider<OpsMetricsFilterNotifier, OpsMetricsFilter>((ref) {
  return OpsMetricsFilterNotifier();
});

final opsMetricsSeriesProvider = AutoDisposeAsyncNotifierProvider<
    OpsMetricsSeriesNotifier, List<OpsMetric>>(
  OpsMetricsSeriesNotifier.new,
);

class OpsMetricsSeriesNotifier
    extends AutoDisposeAsyncNotifier<List<OpsMetric>> {
  Timer? _timer;
  bool _isFetching = false;
  List<OpsMetric> _lastMetrics = const [];
  int? _lastHash;
  OpsMetricsFilter? _lastFilter;
  DateTime? _lastFetchAt;
  static const _minRefreshGap = Duration(seconds: 5);

  @override
  Future<List<OpsMetric>> build() async {
    final filter = ref.watch(opsMetricsFilterProvider);
    _timer ??= Timer.periodic(const Duration(seconds: 30), (_) {
      _scheduleRefresh();
    });
    ref.onDispose(() {
      _timer?.cancel();
    });
    return _refreshWithFilter(filter);
  }

  Future<void> manualRefresh() async {
    final previous = state;
    state = AsyncValue.loading(previous: previous);
    state = await AsyncValue.guard(
      () => _refreshWithFilter(
        ref.read(opsMetricsFilterProvider),
        force: true,
      ),
    );
  }

  void _scheduleRefresh() {
    if (!ref.mounted) return;
    final previous = state;
    state = AsyncValue.loading(previous: previous);
    _refreshWithFilter(ref.read(opsMetricsFilterProvider)).then((value) {
      if (!ref.mounted) return;
      state = AsyncValue.data(value);
    }).catchError((error, stackTrace) {
      if (!ref.mounted) return;
      state = AsyncValue.error(error, stackTrace, previous: previous);
    });
  }

  Future<List<OpsMetric>> _refreshWithFilter(
    OpsMetricsFilter filter, {
    bool force = false,
  }) async {
    final now = DateTime.now();
    final sameFilter = _lastFilter == filter;
    final withinGap =
        _lastFetchAt != null && now.difference(_lastFetchAt!) < _minRefreshGap;
    if (!force && sameFilter && withinGap) {
      return _lastMetrics;
    }

    if (_isFetching) {
      // Avoid re-entrant fetches; return cached data.
      return _lastMetrics;
    }
    _isFetching = true;
    try {
      final useMock = ref.read(useOpsMetricsMockProvider);
      final data =
          useMock ? _buildMockSeries(filter) : await _fetchFromSupabase(filter);
      final nextHash = _hashMetrics(data);
      if (_lastHash != nextHash) {
        _lastHash = nextHash;
        _lastMetrics = data;
      }
      _lastFilter = filter;
      _lastFetchAt = now;
      return _lastMetrics;
    } finally {
      _isFetching = false;
    }
  }

  Future<List<OpsMetric>> _fetchFromSupabase(OpsMetricsFilter filter) async {
    final supabase = ref.read(supabaseClientProvider);
    final since = DateTime.now()
        .toUtc()
        .subtract(Duration(minutes: filter.sinceMinutes))
        .toIso8601String();

    var query = supabase
        .from('v_ops_5min')
        .select()
        .gte('bucket_start', since)
        .order('bucket_start');

    if (filter.env != null && filter.env!.isNotEmpty) {
      query = query.eq('env', filter.env);
    }
    if (filter.app != null && filter.app!.isNotEmpty) {
      query = query.eq('app', filter.app);
    }
    if (filter.eventType != null && filter.eventType!.isNotEmpty) {
      query = query.eq('event_type', filter.eventType);
    }

    final response = await query;
    if (response is! List) {
      throw StateError('Unexpected response from v_ops_5min');
    }

    return response
        .whereType<Map<String, dynamic>>()
        .map(OpsMetric.fromMap)
        .toList();
  }

  List<OpsMetric> _buildMockSeries(OpsMetricsFilter filter) {
    final now = DateTime.now().toUtc();
    final bucketCount = (filter.sinceMinutes / 5).ceil();
    final start = now.subtract(Duration(minutes: bucketCount * 5));
    final random = math.Random(42);
    return List.generate(bucketCount, (index) {
      final bucketStart = start.add(Duration(minutes: index * 5));
      final base = 80 + (20 * math.sin(index / 3)).round();
      final errorBump = (index % 9 == 0) ? 20 : 0;
      final success = math.max(0, base - errorBump) + random.nextInt(10);
      final error = (errorBump + random.nextInt(6));
      final p95 = index % 7 == 0 ? null : (600 + (math.sin(index / 4) * 200)).abs().round();
      return OpsMetric(
        bucketStart: bucketStart,
        env: filter.env ?? 'prod',
        app: filter.app ?? 'flutter_web',
        eventType: filter.eventType ?? 'search',
        successCount: success,
        errorCount: error,
        p95Ms: p95,
      );
    });
  }

  int _hashMetrics(List<OpsMetric> metrics) {
    return Object.hashAll(
      metrics.map(
        (m) => Object.hash(
          m.bucketStart.millisecondsSinceEpoch,
          m.env,
          m.app,
          m.eventType,
          m.successCount,
          m.errorCount,
          m.p95Ms,
        ),
      ),
    );
  }
}

final opsRecentAlertsProvider = Provider<List<OpsAlert>>((ref) {
  // Placeholder alerts until ops-alert data is wired up.
  final now = DateTime.now().toUtc();
  return [
    OpsAlert(
      id: 'alert-critical',
      title: 'Import error surge',
      severity: 'critical',
      createdAt: now.subtract(const Duration(minutes: 5)),
      description: 'Error rate exceeded 15% for import on prod/flutter_web.',
    ),
    OpsAlert(
      id: 'alert-warning',
      title: 'Search latency spike',
      severity: 'warning',
      createdAt: now.subtract(const Duration(minutes: 18)),
      description: 'p95 latency > 4s for search events in staging.',
    ),
  ];
});

final opsMetricsAuthErrorProvider = StateProvider<bool>((_) => false);
