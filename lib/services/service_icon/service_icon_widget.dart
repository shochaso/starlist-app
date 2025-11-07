import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../config/ui_flags.dart';
import '../../utils/key_normalizer.dart';
import '../../widgets/icon_diag_hud.dart';
import 'service_icon_cache.dart';
import 'service_icon_registry.dart' as registry;
import 'service_icon_sources.dart' show ServiceIconResolution;

class ServiceIcon extends StatelessWidget {
  const ServiceIcon.forKey(
    this._keyName, {
    super.key,
    this.size = 24,
    this.fallback,
    this.fit = BoxFit.contain,
  }) : assetPath = null;

  const ServiceIcon.asset(
    this.assetPath, {
    super.key,
    this.size = 24,
    this.fallback,
    this.fit = BoxFit.contain,
  }) : _keyName = null;

  final String? _keyName;
  final String? assetPath;
  final double size;
  final IconData? fallback;
  final BoxFit fit;

  bool get _shouldHideImportImages => kHideImportImages && _keyName != null;

  @override
  Widget build(BuildContext context) {
    if (_shouldHideImportImages) {
      return SizedBox.square(dimension: size);
    }
    if (assetPath != null) {
      return _buildAssetIcon(assetPath!);
    }
    return _buildDynamicIcon();
  }

  Widget _buildDynamicIcon() {
    final requestedKey = _keyName!;
    final normalized = KeyNormalizer.normalize(requestedKey);
    final future = registry.ServiceIconRegistry.instance.resolve(requestedKey);

    return FutureBuilder<ServiceIconResolution?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildPlaceholder();
        }

        if (snapshot.hasError) {
          recordIconDiag(
            IconDiagEvent(
              key: normalized,
              origin: 'error:${snapshot.error}',
              source: ServiceIconSourceType.fallback,
              duration: Duration.zero,
              fallback: true,
            ),
          );
          return _buildFallbackIcon();
        }

        final resolution = snapshot.data;
        if (resolution == null ||
            resolution.payload.bytes.isEmpty ||
            resolution.sourceType == ServiceIconSourceType.fallback) {
          recordIconDiag(
            IconDiagEvent(
              key: normalized,
              origin: resolution?.originPath ?? 'missing',
              source: resolution?.sourceType ?? ServiceIconSourceType.fallback,
              duration: resolution?.duration ?? Duration.zero,
              cacheHit: resolution?.cacheHit ?? false,
              fallback: true,
            ),
          );
          return _buildFallbackIcon();
        }

        final effectiveSource = resolution.cacheHit
            ? (resolution.originalSource ?? resolution.sourceType)
            : resolution.sourceType;
        recordIconDiag(
          IconDiagEvent(
            key: normalized,
            origin: resolution.originPath,
            source: effectiveSource,
            duration: resolution.duration,
            cacheHit: resolution.cacheHit,
            fallback: false,
          ),
        );

        final payload = resolution.payload;
        try {
          return _buildAnimated(
            payload.isSvg
                ? SvgPicture.memory(
                    payload.bytes,
                    width: size,
                    height: size,
                    fit: fit,
                    colorFilter: null,
                    clipBehavior: Clip.antiAlias,
                    placeholderBuilder: (_) => _buildPlaceholder(),
                  )
                : Image.memory(
                    payload.bytes,
                    width: size,
                    height: size,
                    fit: fit,
                    filterQuality: FilterQuality.high,
                  ),
          );
        } catch (error) {
          if (payload.isSvg) {
            ServiceIconCache.clear();
          }
          recordIconDiag(
            IconDiagEvent(
              key: normalized,
              origin: resolution.originPath,
              source: ServiceIconSourceType.fallback,
              duration: resolution.duration,
              cacheHit: resolution.cacheHit,
              fallback: true,
            ),
          );
          return _buildFallbackIcon();
        }
      },
    );
  }

  Widget _buildAssetIcon(String path) {
    final isSvg = path.toLowerCase().endsWith('.svg');
    final normalized =
        _keyName != null ? KeyNormalizer.normalize(_keyName) : path;

    try {
      final widget = isSvg
          ? SvgPicture.asset(
              path,
              width: size,
              height: size,
              fit: fit,
              clipBehavior: Clip.antiAlias,
            )
          : Image.asset(
              path,
              width: size,
              height: size,
              fit: fit,
              filterQuality: FilterQuality.high,
            );
      recordIconDiag(
        IconDiagEvent(
          key: normalized,
          origin: path,
          source: isSvg
              ? ServiceIconSourceType.assetSvg
              : ServiceIconSourceType.assetPng,
          duration: Duration.zero,
        ),
      );
      return _buildAnimated(widget);
    } catch (_) {
      recordIconDiag(
        IconDiagEvent(
          key: normalized,
          origin: path,
          source: ServiceIconSourceType.fallback,
          duration: Duration.zero,
          fallback: true,
        ),
      );
      return _buildFallbackIcon();
    }
  }

  Widget _buildAnimated(Widget child) {
    return SizedBox.square(
      dimension: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        builder: (context, value, _) => Opacity(opacity: value, child: child),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.12),
          borderRadius: BorderRadius.circular(size * 0.2),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    final icon = fallback ?? Icons.image_not_supported_outlined;
    return SizedBox.square(
      dimension: size,
      child: Icon(icon, size: size * 0.7),
    );
  }
}
