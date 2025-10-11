import 'package:flutter/material.dart';

import '../widgets/services_icon_gallery.dart';

class DevPreviewPage extends StatelessWidget {
  const DevPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: ServicesIconGallery(),
      ),
    );
  }
}
