import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ops_metrics_provider.dart';

class OpsMockDashboardPage extends ConsumerWidget {
  const OpsMockDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(opsMetricsSeriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('OPS Mock Dashboard')),
      body: switch (series) {
        AsyncData(:final data) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mock rows: ${data.length}'),
                  const SizedBox(height: 12),
                  Text(
                    'First bucket: ${data.isEmpty ? '—' : data.first.bucketStart}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Env sample: ${data.isNotEmpty ? data.first.env : '—'}',
                  ),
                ],
              ),
            ),
        AsyncError(:final error) => Center(child: Text('Error: $error')),
        _ => const Center(child: CircularProgressIndicator()),
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            ref.read(opsMetricsSeriesProvider.notifier).manualRefresh(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
