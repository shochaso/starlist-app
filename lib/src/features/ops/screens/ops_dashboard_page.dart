// Status:: in-progress
// Source-of-Truth:: lib/src/features/ops/screens/ops_dashboard_page.dart
// Spec-State:: 確定済み
// Last-Updated:: 2025-11-07

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ops_metrics_provider.dart';
import '../models/ops_metrics_model.dart';

class OpsDashboardPage extends ConsumerWidget {
  const OpsDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(opsMetricsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OPS Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(opsMetricsProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(opsMetricsProvider),
        child: metricsAsync.when(
          data: (metrics) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildAuthMetrics(context, metrics),
              const SizedBox(height: 16),
              _buildRlsMetrics(context, metrics),
              const SizedBox(height: 16),
              _buildSubscriptionMetrics(context, metrics),
              const SizedBox(height: 16),
              _buildPerformanceMetrics(context, metrics),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(opsMetricsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthMetrics(BuildContext context, OpsMetrics metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Auth Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildMetricRow(
              'Sign-in Success Rate',
              '${metrics.signInSuccessRate.toStringAsFixed(2)}%',
              metrics.signInSuccessRate >= 99.5 ? Colors.green : Colors.red,
            ),
            _buildMetricRow(
              'Reauth Success Rate',
              '${metrics.reauthSuccessRate.toStringAsFixed(2)}%',
              metrics.reauthSuccessRate >= 99.0 ? Colors.green : Colors.red,
            ),
            _buildMetricRow('Auth Failures (24h)', '${metrics.authFailures24h}'),
          ],
        ),
      ),
    );
  }

  Widget _buildRlsMetrics(BuildContext context, OpsMetrics metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RLS Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildMetricRow('RLS Denials (24h)', '${metrics.rlsDenials24h}'),
            _buildMetricRow(
              'RLS Denial Rate',
              '${metrics.rlsDenialRate.toStringAsFixed(2)}%',
              metrics.rlsDenialRate <= 1.0 ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionMetrics(BuildContext context, OpsMetrics metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Subscription Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildMetricRow('Price Set Events (24h)', '${metrics.priceSetEvents24h}'),
            _buildMetricRow('Price Denied Events (24h)', '${metrics.priceDeniedEvents24h}'),
            _buildMetricRow(
              'Price Denied Rate',
              '${metrics.priceDeniedRate.toStringAsFixed(2)}%',
              metrics.priceDeniedRate <= 5.0 ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics(BuildContext context, OpsMetrics metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildMetricRow(
              'Search SLA Missed (1h)',
              '${metrics.searchSlaMissed1h}',
              metrics.searchSlaMissed1h <= 10 ? Colors.green : Colors.red,
            ),
            _buildMetricRow('Avg Response Time', '${metrics.avgResponseTimeMs}ms'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

