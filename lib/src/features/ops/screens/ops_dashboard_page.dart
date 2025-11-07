// Status:: in-progress
// Source-of-Truth:: lib/src/features/ops/screens/ops_dashboard_page.dart
// Spec-State:: 確定済み
// Last-Updated:: 2025-11-07

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/ops_metrics_provider.dart';
import '../models/ops_metrics_model.dart';
import '../models/ops_metrics_series_model.dart';

class OpsDashboardPage extends ConsumerStatefulWidget {
  const OpsDashboardPage({super.key});

  @override
  ConsumerState<OpsDashboardPage> createState() => _OpsDashboardPageState();
}

class _OpsDashboardPageState extends ConsumerState<OpsDashboardPage> {
  String? _selectedEnv;
  String? _selectedApp;
  String? _selectedEvent;
  int _selectedMinutes = 30;

  @override
  void initState() {
    super.initState();
    // Initialize filter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Auto-refresh trigger (30 seconds)
    ref.listen(opsMetricsAutoRefreshProvider, (previous, next) {
      next.whenData((_) {
        ref.refresh(opsMetricsSeriesProvider);
      });
    });

    final seriesAsync = ref.watch(opsMetricsSeriesProvider);
    final kpi = ref.watch(opsMetricsKpiProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OPS Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(opsMetricsSeriesProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(opsMetricsSeriesProvider);
        },
        child: seriesAsync.when(
          data: (series) {
            if (series.isEmpty) {
              return _buildEmptyState(context);
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildFilterRow(context),
                const SizedBox(height: 16),
                _buildKpiCards(context, kpi),
                const SizedBox(height: 16),
                _buildP95Chart(context, series),
                const SizedBox(height: 16),
                _buildStackedBarChart(context, series),
                const SizedBox(height: 16),
                _buildRecentAlerts(context),
              ],
            );
          },
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(context, error),
        ),
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filters',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedEnv,
                    decoration: const InputDecoration(
                      labelText: 'Environment',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(value: 'dev', child: Text('Dev')),
                      DropdownMenuItem(value: 'stg', child: Text('Staging')),
                      DropdownMenuItem(value: 'prod', child: Text('Production')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedEnv = value;
                      });
                      _updateFilter();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedApp,
                    decoration: const InputDecoration(
                      labelText: 'App',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(value: 'starlist', child: Text('Starlist')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedApp = value;
                      });
                      _updateFilter();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedEvent,
                    decoration: const InputDecoration(
                      labelText: 'Event',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(value: 'search.sla_missed', child: Text('Search SLA')),
                      DropdownMenuItem(value: 'auth.login.success', child: Text('Auth Login')),
                      DropdownMenuItem(value: 'rls.access.denied', child: Text('RLS Denied')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedEvent = value;
                      });
                      _updateFilter();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedMinutes,
                    decoration: const InputDecoration(
                      labelText: 'Period',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 30, child: Text('30 min')),
                      DropdownMenuItem(value: 60, child: Text('60 min')),
                      DropdownMenuItem(value: 120, child: Text('120 min')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedMinutes = value ?? 30;
                      });
                      _updateFilter();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateFilter() {
    final filter = OpsMetricsFilter(
      env: _selectedEnv,
      app: _selectedApp,
      eventType: _selectedEvent,
      sinceMinutes: _selectedMinutes,
    );
    ref.read(opsMetricsFilterProvider.notifier).state = filter;
  }

  Widget _buildKpiCards(BuildContext context, OpsMetricsKpi kpi) {
    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            context,
            'Total Requests',
            '${kpi.totalRequests}',
            Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            context,
            'Error Rate',
            '${(kpi.errorRate * 100).toStringAsFixed(2)}%',
            kpi.errorRate > 0.1 ? Colors.red : Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            context,
            'P95 Latency',
            kpi.p95LatencyMs != null ? '${kpi.p95LatencyMs}ms' : 'N/A',
            kpi.p95LatencyMs != null && kpi.p95LatencyMs! > 500 ? Colors.orange : Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            context,
            'Errors',
            '${kpi.errorCount}',
            kpi.errorCount > 0 ? Colors.red : Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard(BuildContext context, String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildP95Chart(BuildContext context, List<OpsMetricsSeriesPoint> series) {
    if (series.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = series
        .where((p) => p.p95LatencyMs != null)
        .map((p) => FlSpot(
              p.bucketStart.millisecondsSinceEpoch.toDouble(),
              p.p95LatencyMs!.toDouble(),
            ))
        .toList();

    if (spots.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No latency data available')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'P95 Latency (ms)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                          return Text(DateFormat('HH:mm').format(date));
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStackedBarChart(BuildContext context, List<OpsMetricsSeriesPoint> series) {
    if (series.isEmpty) {
      return const SizedBox.shrink();
    }

    // Safe max calculation: handle empty series
    final maxValue = series.isEmpty
        ? 0
        : series.map((p) => p.total).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Request Volume (Success / Error)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue.toDouble() * 1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= series.length) return const Text('');
                          final date = series[value.toInt()].bucketStart;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('HH:mm').format(date),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: List.generate(
                    series.length,
                    (index) {
                      final point = series[index];
                      return BarChartGroupData(
                        x: index,
                        groupVertically: true,
                        barRods: [
                          BarChartRodData(
                            toY: point.successCount.toDouble(),
                            color: Colors.green,
                            width: 12,
                          ),
                          BarChartRodData(
                            fromY: point.successCount.toDouble(),
                            toY: point.total.toDouble(),
                            color: Colors.red,
                            width: 12,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAlerts(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Alerts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Alert data will be integrated with ops-alert function',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bar_chart, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No data available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting filters or extending the time period',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedEnv = null;
                _selectedApp = null;
                _selectedEvent = null;
                _selectedMinutes = 120;
              });
              _updateFilter();
            },
            child: const Text('Reset Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading metrics...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.refresh(opsMetricsSeriesProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
