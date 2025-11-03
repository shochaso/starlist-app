import 'package:flutter/widgets.dart';

/// Shared empty placeholder used when import flows must avoid rendering images.
class BlankAvatar extends StatelessWidget {
  const BlankAvatar({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size);
}

Widget buildBlankAvatar({double size = 56}) => BlankAvatar(size: size);
