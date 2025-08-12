import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starlist/features/registration/application/basic_info_provider.dart';
import 'package:starlist/features/registration/presentation/widgets/registration_progress_indicator.dart';

class BasicInfoScreen extends ConsumerWidget {
  const BasicInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(basicInfoProvider);
    final notifier = ref.read(basicInfoProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('基本情報'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/follower-check');
            }
          },
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: RegistrationProgressIndicator(currentStep: 2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '基本情報を入力',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'スターとして活動するための基本情報を入力してください。',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              onChanged: notifier.updateUsername,
              decoration: const InputDecoration(
                hintText: 'ユーザーネーム（半角英数）',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: notifier.updateDisplayName,
              decoration: const InputDecoration(
                hintText: '表示名（ファンに表示されます）',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: notifier.updateEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: '連絡用メールアドレス',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: notifier.updatePassword,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'パスワード（8文字以上）',
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: state.isFormValid
                  ? () => context.go('/profile-info')
                  : null,
              child: const Text('次へ進む'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('すでにアカウントをお持ちですか？', style: TextStyle(color: Colors.grey)),
                TextButton(
                  onPressed: () {
                    // TODO: Implement login navigation
                  },
                  child: const Text('ログイン'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 