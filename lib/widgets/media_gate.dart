import 'package:flutter/material.dart';

import '../src/core/config/feature_flags.dart';

/// Conditionally suppresses media widgets while keeping layout stability.
class MediaGate extends StatelessWidget {
  const MediaGate({
    super.key,
    required this.child,
    this.minHeight,
    this.minWidth,
  });

  final Widget child;
  final double? minHeight;
  final double? minWidth;

  @override
  Widget build(BuildContext context) {
    if (FeatureFlags.hideSampleMedia) {
      return SizedBox(height: minHeight, width: minWidth);
    }
    return child;
  }
}
