import 'package:flutter/material.dart';

import 'media_gate.dart';

/// Displays an [Image] that can be globally suppressed for diagnostics.
class SampleImage extends StatelessWidget {
  const SampleImage({
    super.key,
    required this.provider,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
  });

  final ImageProvider provider;
  final BoxFit fit;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return MediaGate(
      minHeight: height,
      minWidth: width,
      child: Image(
        image: provider,
        fit: fit,
        height: height,
        width: width,
      ),
    );
  }
}
