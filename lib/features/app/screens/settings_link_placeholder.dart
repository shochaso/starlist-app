import 'package:flutter/material.dart';

class SettingsPlaceholderScreen extends StatelessWidget {
  const SettingsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')), // TODO: 実際の設定画面が用意されたら差し替え
      body: const Center(
        child: Text('設定画面は現在準備中です。'),
      ),
    );
  }
}
