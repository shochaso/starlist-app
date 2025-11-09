// Status:: in-progress
// Source-of-Truth:: lib/src/features/ops/screens/ops_dashboard_page.dart
// Spec-State:: 確定済み
// Last-Updated:: 2025-11-07

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/ops_metrics_provider.dart';
import '../models/ops_metrics_series_model.dart';
import '../models/ops_health_model.dart';

class OpsDashboardPage extends ConsumerStatefulWidget {
  const OpsDashboardPage({super.key});

  @override
  ConsumerState<OpsDashboardPage> createState() => _OpsDashboardPageState();
}

class _OpsDashboardPageState extends ConsumerState<OpsDashboardPage> with SingleTickerProviderStateMixin {
  String? _selectedEnv;
  String? _selectedApp;
  String? _selectedEvent;
  int _selectedMinutes = 30;
  bool _autoRefreshListenerRegistered = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initialize filter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFilter();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Auto-refresh trigger (30 seconds) - register once
    // Note: ref.listen() automatically cancels previous listeners on rebuild
    if (!_autoRefreshListenerRegistered) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.listen(opsMetricsAutoRefreshProvider, (previous, next) {
          next.whenData((_) {
            ref.refresh(opsMetricsSeriesProvider); // ignore: unused_result
          });
        });
        _autoRefreshListenerRegistered = true;
      });
    }

    final seriesAsync = ref.watch(opsMetricsSeriesProvider);
    final kpi = ref.watch(opsMetricsKpiProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OPS Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(opsMetricsSeriesProvider); // ignore: unused_result
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Metrics'),
            Tab(text: 'Health'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
            onRefresh: () async {
              ref.refresh(opsMetricsSeriesProvider); // ignore: unused_result
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
          _buildHealthTab(context),
        ],
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    final seriesAsync = ref.watch(opsMetricsSeriesProvider);
    final hasAuthError = seriesAsync.hasError && 
        (seriesAsync.error.toString().contains('401') || 
         seriesAsync.error.toString().contains('403'));
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Filters',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                if (hasAuthError) ...[
                  Semantics(
                    label: 'Authentication error badge: 401 or 403 error detected',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Auth Error',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Semantics(
                    label: 'Reload button: Click to retry loading metrics',
                    button: true,
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.red),
                      onPressed: () {
                        ref.refresh(opsMetricsSeriesProvider);
                      },
                      tooltip: 'Reload',
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _selectedEnv,
                    decoration: const InputDecoration(
                      labelText: 'Environment',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem<String?>(value: null, child: Text('All')),
                      DropdownMenuItem<String?>(value: 'dev', child: Text('Dev')),
                      DropdownMenuItem<String?>(value: 'stg', child: Text('Staging')),
                      DropdownMenuItem<String?>(value: 'prod', child: Text('Production')),
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
                  child: DropdownButtonFormField<String?>(
                    value: _selectedApp,
                    decoration: const InputDecoration(
                      labelText: 'App',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem<String?>(value: null, child: Text('All')),
                      DropdownMenuItem<String?>(value: 'starlist', child: Text('Starlist')),
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
                  child: DropdownButtonFormField<String?>(
                    value: _selectedEvent,
                    decoration: const InputDecoration(
                      labelText: 'Event',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem<String?>(value: null, child: Text('All')),
                      DropdownMenuItem<String?>(value: 'search.sla_missed', child: Text('Search SLA')),
                      DropdownMenuItem<String?>(value: 'auth.login.success', child: Text('Auth Login')),
                      DropdownMenuItem<String?>(value: 'rls.access.denied', child: Text('RLS Denied')),
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
              kpi.p95LatencyMs != null ? '${kpi.p95LatencyMs}ms' : 'Gap',
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
    return Semantics(
      label: '$label: $value',
      child: Card(
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
      ),
    );
  }

  Widget _buildP95Chart(BuildContext context, List<OpsMetricsSeriesPoint> series) {
    if (series.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show gaps for null values instead of interpolating
    final spots = <FlSpot>[];
    for (final p in series) {
      if (p.p95LatencyMs != null) {
        spots.add(FlSpot(
          p.bucketStart.millisecondsSinceEpoch.toDouble(),
          p.p95LatencyMs!.toDouble(),
        ));
      } else {
        // Add gap marker (use NaN to create visual gap)
        spots.add(FlSpot(
          p.bucketStart.millisecondsSinceEpoch.toDouble(),
          double.nan,
        ));
      }
    }

    if (spots.isEmpty || spots.every((s) => s.y.isNaN)) {
      return Semantics(
        label: 'P95 Latency chart: No latency data available',
        child: const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('No latency data available')),
          ),
        ),
      );
    }

    return Semantics(
      label: 'P95 Latency chart showing ${spots.where((s) => !s.y.isNaN).length} data points with gaps for missing values',
      child: Card(
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
                        spots: spots.where((s) => !s.y.isNaN).toList(),
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
    final alertsAsync = ref.watch(opsRecentAlertsProvider);
    
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
            alertsAsync.when(
              data: (alerts) {
                if (alerts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No alerts in the last 60 minutes',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    return ListTile(
                      leading: Icon(
                        alert.type == 'failure_rate' ? Icons.error : Icons.timer,
                        color: Colors.red,
                      ),
                      title: Text(alert.message),
                      subtitle: Text(
                        'Value: ${alert.value.toStringAsFixed(2)}${alert.type == 'failure_rate' ? '%' : 'ms'} | Threshold: ${alert.threshold.toStringAsFixed(2)}${alert.type == 'failure_rate' ? '%' : 'ms'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Text(
                        DateFormat('HH:mm').format(alert.alertedAt),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    );
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading alerts: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
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

  Widget _buildHealthTab(BuildContext context) {
    final healthAsync = ref.watch(opsHealthProvider);
    
    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(opsHealthProvider); // ignore: unused_result
      },
      child: healthAsync.when(
        data: (health) {
          if (health.aggregations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.health_and_safety, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No health data available',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Try adjusting the time period',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHealthPeriodSelector(context),
              const SizedBox(height: 16),
              _buildUptimeChart(context, health),
              const SizedBox(height: 16),
              _buildMeanP95Chart(context, health),
              const SizedBox(height: 16),
              _buildAlertTrendChart(context, health),
            ],
          );
        },
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(context, error),
      ),
    );
  }

  Widget _buildHealthPeriodSelector(BuildContext context) {
    final period = ref.watch(opsHealthPeriodProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Period',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: '1h', label: Text('1h')),
                ButtonSegment(value: '6h', label: Text('6h')),
                ButtonSegment(value: '24h', label: Text('24h')),
                ButtonSegment(value: '7d', label: Text('7d')),
              ],
              selected: {period},
              onSelectionChanged: (Set<String> newSelection) {
                ref.read(opsHealthPeriodProvider.notifier).state = newSelection.first;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUptimeChart(BuildContext context, OpsHealthData health) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Uptime %',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: health.aggregations.isEmpty
                  ? const Center(child: Text('No data'))
                  : BarChart(
                      BarChartData(
                        barGroups: health.aggregations.map((agg) {
                          final index = health.aggregations.indexOf(agg);
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: agg.uptimePercent,
                                color: agg.uptimePercent >= 99.0 ? Colors.green : Colors.orange,
                                width: 20,
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text('${value.toInt()}%', style: const TextStyle(fontSize: 10));
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= health.aggregations.length) return const SizedBox.shrink();
                                final agg = health.aggregations[value.toInt()];
                                return Text(
                                  '${agg.app ?? 'N/A'}\n${agg.env ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeanP95Chart(BuildContext context, OpsHealthData health) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mean P95 Latency (ms)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: health.aggregations.isEmpty
                  ? const Center(child: Text('No data'))
                  : BarChart(
                      BarChartData(
                        barGroups: health.aggregations.map((agg) {
                          final index = health.aggregations.indexOf(agg);
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: agg.meanP95Ms?.toDouble() ?? 0,
                                color: (agg.meanP95Ms ?? 0) < 500 ? Colors.green : Colors.red,
                                width: 20,
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text('${value.toInt()}ms', style: const TextStyle(fontSize: 10));
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= health.aggregations.length) return const SizedBox.shrink();
                                final agg = health.aggregations[value.toInt()];
                                return Text(
                                  '${agg.app ?? 'N/A'}\n${agg.env ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertTrendChart(BuildContext context, OpsHealthData health) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alert Trend',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: health.aggregations.isEmpty
                  ? const Center(child: Text('No data'))
                  : BarChart(
                      BarChartData(
                        barGroups: health.aggregations.map((agg) {
                          final index = health.aggregations.indexOf(agg);
                          Color color;
                          if (agg.alertTrend == 'increasing') {
                            color = Colors.red;
                          } else if (agg.alertTrend == 'decreasing') {
                            color = Colors.green;
                          } else {
                            color = Colors.orange;
                          }
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: agg.alertCount.toDouble(),
                                color: color,
                                width: 20,
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text('${value.toInt()}', style: const TextStyle(fontSize: 10));
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= health.aggregations.length) return const SizedBox.shrink();
                                final agg = health.aggregations[value.toInt()];
                                return Text(
                                  '${agg.app ?? 'N/A'}\n${agg.env ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
