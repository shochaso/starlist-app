import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 起動時のブートストラップ画面。
/// ここで将来的に自動ログイン判定や初期化処理を行い、
/// 完了後に適切な画面へ遷移させる。
class BootstrapScreen extends StatefulWidget {
  const BootstrapScreen({super.key});

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen> {
  @override
  void initState() {
    super.initState();
    // 最小実装: フレーム確定後に /home へ遷移
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      // ここで認証チェック等を実施可能（Supabaseのセッション確認など）
      context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
} 