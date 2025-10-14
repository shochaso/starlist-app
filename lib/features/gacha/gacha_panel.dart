import 'package:flutter/material.dart';
import 'package:starlist/features/gacha/gacha_controller.dart';

class GachaPanel extends StatefulWidget {
  const GachaPanel({super.key});

  @override
  State<GachaPanel> createState() => _GachaPanelState();
}

class _GachaPanelState extends State<GachaPanel> {
  late final GachaController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = GachaController()..init().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 900;
      final pad = isWide ? 24.0 : 16.0;

      final header = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '今日の無料: ${ctrl.freeLeft} / ${ctrl.freeQuota}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Wrap(
            spacing: 8,
            children: [
              _Chip(text: '回数券: ${ctrl.tickets}'),
              const _Chip(text: '視聴は無料が0の時のみ'),
            ],
          ),
        ],
      );

      final main = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              final ok = await ctrl.spin();
              if (mounted && ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ガチャ結果：★x1 を獲得！')),
                );
                setState(() {});
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14.0),
              child: Text('ガチャを回す'),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: ctrl.canWatchReward
                ? () async {
                    final ok = await ctrl.watchAdAndGrant();
                    if (mounted) setState(() {});
                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('動画の再生に失敗しました or 条件未達'),
                        ),
                      );
                    }
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text('動画視聴で +${ctrl.rewardPerView} 回'),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '未使用分は本日中に使い切ろう（持ち越し不可）',
            textAlign: TextAlign.center,
          ),
        ],
      );

      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  const Divider(height: 24),
                  main,
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(text),
    );
  }
}
