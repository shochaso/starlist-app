import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;

import '../services/asset_image_index.dart';
import '../services/service_icon_registry.dart';

class ServicesIconGallery extends StatefulWidget {
  const ServicesIconGallery({super.key});

  @override
  State<ServicesIconGallery> createState() => _ServicesIconGalleryState();
}

class _ServicesIconGalleryState extends State<ServicesIconGallery> {
  late final Future<List<String>> _imagesFuture;

  @override
  void initState() {
    super.initState();
    _imagesFuture = _loadImages();
  }

  Future<List<String>> _loadImages() async {
    await ServiceIconRegistry.init();
    final mapped = ServiceIconRegistry.icons.values.toList(growable: false);
    if (mapped.isNotEmpty) {
      return mapped;
    }
    return AssetImageIndex.listImages();
  }

  bool _isSvg(String assetPath) => assetPath.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _imagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('読み込み中にエラーが発生しました: ${snapshot.error}'));
        }
        final images = snapshot.data ?? const <String>[];
        if (images.isEmpty) {
          return const Center(child: Text('画像が見つかりません'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: images.length,
          itemBuilder: (_, index) {
            final path = images[index];
            final child = _isSvg(path)
                ? _SvgOrFallback(assetPath: path)
                : Image.asset(
                    path,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _errorBox('読み込み失敗'),
                  );
            return DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(blurRadius: 8, color: Colors.black12),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: child,
              ),
            );
          },
        );
      },
    );
  }

  Widget _errorBox(String message) {
    return Container(
      color: Colors.black12,
      alignment: Alignment.center,
      child: Text(message, style: const TextStyle(fontSize: 12)),
    );
  }
}

class _SvgOrFallback extends StatelessWidget {
  const _SvgOrFallback({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    try {
      return svg.SvgPicture.asset(assetPath, fit: BoxFit.contain);
    } catch (_) {
      return Container(
        color: Colors.black12,
        alignment: Alignment.center,
        child: const Text('SVG対応が無効です', style: TextStyle(fontSize: 12)),
      );
    }
  }
}
