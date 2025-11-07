import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ops_alert_model.dart';
import '../models/ops_metrics_model.dart';
import '../providers/ops_metrics_provider.dart';

class OpsDashboardPage extends ConsumerStatefulWidget {
  const OpsDashboardPage({super.key});

  @override
  ConsumerState<OpsDashboardPage> createState() => _OpsDashboardPageState();
}

class _OpsDashboardPageState extends ConsumerState<OpsDashboardPage> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _chartScrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    _chartScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<OpsMetric>>>(
      opsMetricsSeriesProvider,
      (prev, next) {
        next.when(
          data: (_) =>
              ref.read(opsMetricsAuthErrorProvider.notifier).state = false,
          loading: () {},
          error: (error, _) {
            final isAuthError = _isAuthorizationError(error);
            ref.read(opsMetricsAuthErrorProvider.notifier).state = isAuthError;
            final badge = _formatFilterBadge(ref.read(opsMetricsFilterProvider));
            final message = isAuthError
                ? '権限がありません $badge'
                : 'メトリクスの取得に失敗しました: $error';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                action: SnackBarAction(
                  label: '再読込',
                  onPressed: () =>
                      ref.read(opsMetricsSeriesProvider.notifier).manualRefresh(),
                ),
              ),
            );
          },
        );
      },
    );

    final metricsAsync = ref.watch(opsMetricsSeriesProvider);
    final filter = ref.watch(opsMetricsFilterProvider);
    final alerts = ref.watch(opsRecentAlertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OPS Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '再読込',
            onPressed: () =>
                ref.read(opsMetricsSeriesProvider.notifier).manualRefresh(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(opsMetricsSeriesProvider.notifier).manualRefresh();
          await Future.delayed(const Duration(milliseconds: 250));
        },
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            _FilterRow(filter: filter),
            const SizedBox(height: 12),
            _AutoRefreshIndicator(asyncValue: metricsAsync),
            const SizedBox(height: 12),
            metricsAsync.when(
              data: (metrics) =>
                  _buildDashboardContent(context, ref, metrics, alerts),
              loading: () => const _LoadingState(),
              error: (error, stackTrace) => _ErrorState(
                error: error,
                onRetry: () =>
                    ref.read(opsMetricsSeriesProvider.notifier).manualRefresh(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    WidgetRef ref,
    List<OpsMetric> metrics,
    List<OpsAlert> alerts,
  ) {
    if (metrics.isEmpty) {
      return _EmptyState(
        onReload: () =>
            ref.read(opsMetricsSeriesProvider.notifier).manualRefresh(),
      );
    }

    final summary = OpsKpiSummary.fromMetrics(metrics);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _KpiRow(summary: summary),
        const SizedBox(height: 16),
        _MetricsCharts(metrics: metrics, scrollController: _chartScrollController),
        const SizedBox(height: 16),
        _AlertsCard(alerts: alerts),
      ],
    );
  }

  bool _isAuthorizationError(Object error) {
    final lower = error.toString().toLowerCase();
    return lower.contains('401') || lower.contains('403') || lower.contains('forbidden');
  }

  String _formatFilterBadge(OpsMetricsFilter filter) {
    final env = filter.env ?? 'env:ALL';
    final app = filter.app ?? 'app:ALL';
    final event = filter.eventType ?? 'event:ALL';
    return '($env / $app / $event)';
  }
}

class _FilterRow extends ConsumerWidget {
  const _FilterRow({required this.filter});

  final OpsMetricsFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(opsMetricsSeriesProvider);
    final metrics = metricsAsync.value ?? [];
    final envOptions = _collectDistinct(metrics, (m) => m.env);
    final appOptions = _collectDistinct(metrics, (m) => m.app);
    final eventOptions = _collectDistinct(metrics, (m) => m.eventType);
    final hasAuthError = ref.watch(opsMetricsAuthErrorProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: hasAuthError
            ? Border.all(color: Colors.redAccent, width: 1.5)
            : Border.all(color: Colors.transparent),
      ),
      child: Wrap(
        runSpacing: 8,
        spacing: 8,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _FilterDropdown(
            label: 'Env',
            value: filter.env,
            options: envOptions,
            onChanged: ref.read(opsMetricsFilterProvider.notifier).updateEnv,
          ),
          _FilterDropdown(
            label: 'App',
            value: filter.app,
            options: appOptions,
            onChanged: ref.read(opsMetricsFilterProvider.notifier).updateApp,
          ),
          _FilterDropdown(
            label: 'Event',
            value: filter.eventType,
            options: eventOptions,
            onChanged: ref.read(opsMetricsFilterProvider.notifier).updateEventType,
          ),
          DropdownButton<int>(
            value: filter.sinceMinutes,
            items: const [
              DropdownMenuItem(value: 30, child: Text('30分')),
              DropdownMenuItem(value: 60, child: Text('60分')),
              DropdownMenuItem(value: 120, child: Text('120分')),
            ],
            onChanged: (value) {
              if (value != null) {
                ref.read(opsMetricsFilterProvider.notifier).updateWindow(value);
              }
            },
          ),
          ElevatedButton.icon(
            onPressed: () =>
                ref.read(opsMetricsSeriesProvider.notifier).manualRefresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  static List<String> _collectDistinct(
    List<OpsMetric> metrics,
    String Function(OpsMetric metric) selector,
  ) {
    final set = <String>{for (final metric in metrics) selector(metric)};
    final list = set.toList()..sort();
    return ['ALL', ...list];
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> options;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        DropdownButton<String>(
          value: value ?? 'ALL',
          items: options
              .map(
                (option) => DropdownMenuItem(
                  value: option,
                  child: Text(option == 'ALL' ? 'All' : option),
                ),
              )
              .toList(),
          onChanged: (selected) {
            if (selected == 'ALL') {
              onChanged(null);
            } else {
              onChanged(selected);
            }
          },
        ),
      ],
    );
  }
}

class _AutoRefreshIndicator extends StatelessWidget {
  const _AutoRefreshIndicator({required this.asyncValue});

  final AsyncValue<List<OpsMetric>> asyncValue;

  @override
  Widget build(BuildContext context) {
    final isRefreshing = asyncValue.isRefreshing || asyncValue.isLoading;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedRotation(
          duration: const Duration(milliseconds: 600),
          turns: isRefreshing ? 1 : 0,
          child: Icon(
            Icons.autorenew,
            color: isRefreshing ? Colors.blue : Colors.grey,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Auto refresh 30s',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.summary});

  final OpsKpiSummary summary;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _KpiCard(
        title: '総リクエスト',
        value: summary.total.toString(),
        subtitle: '直近30分',
        tooltip: '直近30分に処理したリクエストの総数',
      ),
      _KpiCard(
        title: 'エラー率',
        value: '${(summary.errorRate * 100).toStringAsFixed(1)}%',
        subtitle: '失敗/総数',
        tooltip: '直近30分のエラー率（小数1桁）',
      ),
      _KpiCard(
        title: 'p95 (ms)',
        value: summary.latestP95Ms?.toString() ?? '—',
        subtitle: '直近計測',
        tooltip: '直近測定のp95応答時間（欠損時は—）',
      ),
      _KpiCard(
        title: '失敗件数',
        value: summary.errorCount.toString(),
        subtitle: '直近30分',
        tooltip: '直近30分で失敗と記録された総数',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: cards
                .map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: card,
                  ),
                )
                .toList(),
          );
        }
        return Row(
          children: cards
              .map(
                (card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: card,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.tooltip,
  });

  final String title;
  final String value;
  final String subtitle;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title: $value ($subtitle)',
      child: Tooltip(
        message: tooltip,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricsCharts extends StatelessWidget {
  const _MetricsCharts({
    required this.metrics,
    required this.scrollController,
  });

  final List<OpsMetric> metrics;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final width = math.max(metrics.length * 32.0, MediaQuery.of(context).size.width - 32);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'メトリクス推移',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                child: Column(
                  children: [
                    SizedBox(
                      height: 220,
                      child: _P95LineChart(metrics: metrics),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 260,
                      child: _SuccessErrorBarChart(metrics: metrics),
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
}

class _P95LineChart extends StatelessWidget {
  const _P95LineChart({required this.metrics});

  final List<OpsMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final segments = <List<FlSpot>>[];
    var current = <FlSpot>[];
    for (var i = 0; i < metrics.length; i++) {
      final p95 = metrics[i].p95Ms;
      if (p95 == null) {
        if (current.isNotEmpty) {
          segments.add(current);
          current = <FlSpot>[];
        }
        continue;
      }
      current.add(FlSpot(i.toDouble(), p95.toDouble()));
    }
    if (current.isNotEmpty) {
      segments.add(current);
    }

    final allPoints = segments.expand((segment) => segment).toList();
    if (allPoints.isEmpty) {
      return const Center(child: Text('p95データがまだありません'));
    }

    final maxY =
        allPoints.fold<double>(0, (max, spot) => math.max(max, spot.y)) * 1.2;
    final minX = 0.0;
    final maxX = math.max(0, metrics.length - 1).toDouble();
    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: 0,
        maxY: maxY == 0 ? 1000 : maxY,
        gridData: FlGridData(
          show: true,
          horizontalInterval: math.max(1, (maxY == 0 ? 1000 : maxY) / 5),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: math.max(1, metrics.length ~/ 6).toDouble(),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < metrics.length) {
                  return Transform.rotate(
                    angle: -0.6,
                    child: Text(
                      metrics[index].jstAxisLabel,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text('${value.toInt()} ms'),
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: segments
            .map(
              (segment) => LineChartBarData(
                spots: segment,
                isCurved: true,
                color: Colors.blue,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [Colors.blue.withOpacity(0.3), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SuccessErrorBarChart extends StatelessWidget {
  const _SuccessErrorBarChart({required this.metrics});

  final List<OpsMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final groups = List.generate(metrics.length, (index) {
      final success = metrics[index].successCount.toDouble();
      final error = metrics[index].errorCount.toDouble();
      final total = success + error;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: total,
            rodStackItems: [
              BarChartRodStackItem(0, success, Colors.greenAccent.shade400),
              BarChartRodStackItem(success, total, Colors.redAccent.shade200),
            ],
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });

    final maxTotal = groups.fold<double>(
        0, (previousValue, element) => math.max(previousValue, element.barRods.first.toY));

    return BarChart(
      BarChartData(
        maxY: maxTotal == 0 ? 10 : maxTotal * 1.2,
        barGroups: groups,
        gridData: FlGridData(show: true, horizontalInterval: (maxTotal / 5).clamp(1, double.infinity)),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: math.max(1, metrics.length ~/ 6).toDouble(),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < metrics.length) {
                  return Transform.rotate(
                    angle: -0.6,
                    child: Text(
                      metrics[index].jstAxisLabel,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString()),
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _AlertsCard extends StatelessWidget {
  const _AlertsCard({required this.alerts});

  final List<OpsAlert> alerts;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('直近アラート', style: Theme.of(context).textTheme.titleMedium),
                TextButton(onPressed: () {}, child: const Text('ops-alertログ')),
              ],
            ),
            if (alerts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('現在アラートはありません')),
              )
            else
              ...alerts.map(
                (alert) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    alert.isCritical
                        ? Icons.error
                        : alert.isWarning
                            ? Icons.warning
                            : Icons.info,
                    color: alert.isCritical
                        ? Colors.red
                        : alert.isWarning
                            ? Colors.orange
                            : Colors.blue,
                  ),
                  title: Text(alert.title),
                  subtitle: Text(alert.description),
                  trailing: Text(
                    '${alert.createdAt.toLocal().hour.toString().padLeft(2, '0')}:${alert.createdAt.toLocal().minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onReload});

  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.analytics_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'まだデータがありません',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('フィルタを緩めるか、期間を延長してください'),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onReload,
              icon: const Icon(Icons.refresh),
              label: const Text('再読込'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _LoadingCard(height: 90 + (index * 20)),
        ),
      ),
    );
  }
}

class _LoadingCard extends StatefulWidget {
  const _LoadingCard({required this.height});

  final double height;

  @override
  State<_LoadingCard> createState() => _LoadingCardState();
}

class _LoadingCardState extends State<_LoadingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final color = Color.lerp(
          Colors.grey.shade200,
          Colors.grey.shade300,
          _controller.value,
        );
        return Card(
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              '読み込み時に問題が発生しました',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('リトライ'),
            ),
          ],
        ),
      ),
    );
  }
}
