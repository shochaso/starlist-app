import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starlist_app/features/registration/application/verification_provider.dart';
import 'package:starlist_app/features/registration/presentation/widgets/registration_progress_indicator.dart';

class VerificationScreen extends ConsumerWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(verificationProvider);
    final notifier = ref.read(verificationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('本人確認'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile-info');
            }
          },
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: RegistrationProgressIndicator(currentStep: 4),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'ご本人様確認',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'なりすましを防ぎ、プラットフォームの安全性を保つため、ご本人様確認にご協力ください。',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const Text(
              '1. 下の認証コードをコピーします。\n'
              '2. あなたのメインのSNS（X, Instagram等）のプロフィール欄（自己紹介文など）に、コピーしたコードを一時的に貼り付けます。\n'
              '3. コードを貼り付けたSNSプロフィールのURLを下の欄に入力してください。',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('あなたの認証コード', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      Text(
                        state.verificationCode,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {
                      notifier.copyCodeToClipboard();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('認証コードをコピーしました')),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('コピー'),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: state.snsUrl)..selection = TextSelection.fromPosition(TextPosition(offset: state.snsUrl.length)),
              decoration: const InputDecoration(
                labelText: 'SNS投稿のリンク',
                hintText: '例: https://x.com/your_id/status/12345',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => notifier.updateSnsUrl(value),
            ),
             const SizedBox(height: 16),
             Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '例：Xのプロフィール欄に「Starlist認証コード: Starlist-A8C1E9」と記載。\n確認後、プロフィールから認証コードは削除していただいて構いません。',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: state.isFormValid
                  ? () => context.go('/sns-link')
                  : null,
              child: const Text('確認して次へ'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
} 