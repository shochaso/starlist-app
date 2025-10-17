import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Displays a service icon inside a fixed square, keeping aspect ratio via [BoxFit.contain].
class ServiceIcon extends StatelessWidget {
  const ServiceIcon(
    this.assetPath, {
    super.key,
    this.size = 56,
    this.colorFilter,
    this.onImageError,
  });

  final String assetPath;
  final double size;
  final ColorFilter? colorFilter;
  final ImageErrorWidgetBuilder? onImageError;

  bool get _isSvg => assetPath.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    if (assetPath.isEmpty) {
      return const SizedBox.shrink();
    }
    final child = _isSvg
        ? SvgPicture.asset(
            assetPath,
            fit: BoxFit.contain,
            colorFilter: colorFilter,
            clipBehavior: Clip.antiAlias,
            allowDrawingOutsideViewBox: false,
            width: size,
            height: size,
          )
        : Image.asset(
            assetPath,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            isAntiAlias: true,
            errorBuilder: onImageError,
            width: size,
            height: size,
          );

    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: size, height: size),
      child: Center(child: child),
    );
  }
}
