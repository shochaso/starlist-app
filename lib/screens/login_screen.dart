import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import 'starlist_main_screen.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Starlistへようこそ',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // ログイン処理を実行
                ref.read(currentUserProvider.notifier).login();

                // メイン画面に遷移
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const StarlistMainScreen()),
                );
              },
              child: const Text('田中太郎としてログイン'),
            ),
             const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // ここで新規登録画面に遷移するロジックを実装
              },
              child: const Text('新規登録はこちら'),
            )
          ],
        ),
      ),
    );
  }
} 