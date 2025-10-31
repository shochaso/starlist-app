import 'package:flutter/material.dart';
import 'package:starlist_app/config/ui_flags.dart';
import '../services/asset_image_index.dart';
import '../services/service_icon_registry.dart';
import 'service_icon.dart';

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
    _imagesFuture =
        kHideImportImages ? Future.value(const <String>[]) : _loadImages();
  }

  Future<List<String>> _loadImages() async {
    await ServiceIconRegistry.init();
    final mapped = ServiceIconRegistry.icons.values.toList(growable: false);
    if (mapped.isNotEmpty) {
      return mapped;
    }
    return AssetIconIndex.listImages();
  }

  @override
  Widget build(BuildContext context) {
    if (kHideImportImages) {
      return const Center(
        child: Text('サービスアイコンギャラリーは非表示設定のため利用できません'),
      );
    }
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
            childAspectRatio: 1.0,
          ),
          itemCount: images.length,
          itemBuilder: (_, index) {
            final path = images[index];
            final child = ServiceIcon.asset(
              path,
              size: 72,
              fallback: Icons.error_outline,
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
