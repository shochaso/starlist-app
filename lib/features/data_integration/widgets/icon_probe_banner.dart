import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:starlist_app/config/ui_flags.dart';
import 'package:starlist_app/consts/debug_flags.dart';
import 'package:starlist_app/services/service_icon_registry.dart';
import 'package:starlist_app/widgets/service_icon.dart';

class IconProbeBanner extends StatefulWidget {
  const IconProbeBanner({super.key});

  @override
  State<IconProbeBanner> createState() => _IconProbeBannerState();
}

class _IconProbeBannerState extends State<IconProbeBanner> {
  String _status = '診断中...';

  @override
  void initState() {
    super.initState();
    if (!kHideImportImages) {
      _runDiag();
    }
  }

  Future<void> _runDiag() async {
    try {
      await rootBundle.load(kIconProbeAsset);
      final manifest = await rootBundle.loadString('AssetManifest.json');
      final inManifest = manifest.contains(kIconProbeAsset);
      setState(() {
        _status = inManifest
            ? '✅ assets OK / seven_eleven.png 参照可'
            : '⚠️ AssetManifestに seven_eleven.png が見当たりません';
      });
    } catch (e) {
      setState(() => _status = '❌ assets 読み込み失敗: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kHideImportImages) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.yellow.withOpacity(.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ICON PROBE (1枚テスト)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              const ServiceIcon(kIconProbeAsset, size: 28),
              const SizedBox(width: 12),
              ServiceIconRegistry.iconFor(kIconProbeKey, size: 28),
              const SizedBox(width: 12),
              const Icon(Icons.check_circle_outline, size: 22),
            ],
          ),
          const SizedBox(height: 6),
          Text('診断: $_status', style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 2),
          const Text(
            'A=assets直読み / B=Registry経由（key一致検証）',
            style: TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
