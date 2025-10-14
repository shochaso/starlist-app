import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/user_provider.dart';
import '../../voting/providers/voting_providers.dart';

class StarPointsPurchaseScreen extends ConsumerWidget {
  const StarPointsPurchaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = <_PointsPlan>[
      const _PointsPlan(points: 10, priceYen: 100),
      const _PointsPlan(points: 50, priceYen: 500),
      const _PointsPlan(points: 100, priceYen: 1000),
      const _PointsPlan(points: 550, priceYen: 5000),
      const _PointsPlan(points: 1200, priceYen: 10000),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('スターポイント購入'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          ...plans.map((p) => _PointsPlanCard(plan: p, onPurchase: () => _purchase(ref, context, p.points, p.priceYen))),
          const SizedBox(height: 8),
          _CustomPurchase(onPurchase: (points, price) => _purchase(ref, context, points, price, isCustom: true)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ポイントプラン', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('購入時のボーナス: カスタム購入は金額に対して+20%のボーナスが付与されます'),
        ],
      ),
    );
  }

  Future<void> _purchase(WidgetRef ref, BuildContext context, int points, int price, {bool isCustom = false}) async {
    final user = ref.read(currentUserProvider);
    final userId = user.id;
    final repo = ref.read(votingRepositoryProvider);

    final bonus = isCustom ? (points * 0.2).round() : 0;
    final total = points + bonus;

    await repo.grantSPointsWithSource(userId, total, 'スターポイント購入（¥$price）', 'purchase');
    ref.invalidate(userStarPointBalanceProvider(userId));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¥$price の購入で $total ポイント付与されました（ボーナス+$bonus）')),
      );
    }
  }
}

class _PointsPlan {
  final int points;
  final int priceYen;
  const _PointsPlan({required this.points, required this.priceYen});
}

class _PointsPlanCard extends StatelessWidget {
  final _PointsPlan plan;
  final VoidCallback onPurchase;
  const _PointsPlanCard({required this.plan, required this.onPurchase});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('${plan.points} スターポイント'),
        subtitle: Text('¥${_formatYen(plan.priceYen)}'),
        trailing: ElevatedButton(
          onPressed: onPurchase,
          child: const Text('購入'),
        ),
      ),
    );
  }

  String _formatYen(int value) => value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

class _CustomPurchase extends StatefulWidget {
  final void Function(int points, int priceYen) onPurchase;
  const _CustomPurchase({required this.onPurchase});

  @override
  State<_CustomPurchase> createState() => _CustomPurchaseState();
}

class _CustomPurchaseState extends State<_CustomPurchase> {
  final TextEditingController _yenController = TextEditingController();

  @override
  void dispose() {
    _yenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('カスタム購入（+20%ボーナス）', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _yenController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '金額（円）',
                      hintText: '例: 2000',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final price = int.tryParse(_yenController.text.trim()) ?? 0;
                    if (price <= 0) return;
                    final points = price ~/ 10; // 基本: 10円=1P
                    widget.onPurchase(points, price);
                  },
                  child: const Text('購入'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text('レート: 10円=1ポイント。入力金額に対して+20%ボーナス付与。'),
          ],
        ),
      ),
    );
  }
} 