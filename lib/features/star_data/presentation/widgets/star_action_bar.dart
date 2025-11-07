import 'package:flutter/material.dart';

class StarActionBar extends StatelessWidget {
  const StarActionBar({
    super.key,
    required this.onFollow,
    required this.onShare,
    required this.onReport,
    required this.enableActions,
  });

  final VoidCallback? onFollow;
  final VoidCallback? onShare;
  final VoidCallback? onReport;
  final bool enableActions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: enableActions ? onFollow : null,
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('フォロー'),
            ),
            OutlinedButton.icon(
              onPressed: enableActions ? onShare : null,
              icon: const Icon(Icons.share_outlined),
              label: const Text('シェア'),
            ),
            TextButton.icon(
              onPressed: enableActions ? onReport : null,
              icon: const Icon(Icons.flag_outlined),
              label: const Text('報告'),
            ),
          ],
        ),
      ),
    );
  }
}
