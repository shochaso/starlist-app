import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starlist/features/login/application/password_reset_provider.dart';

class PasswordResetRequestScreen extends ConsumerWidget {
  const PasswordResetRequestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(passwordResetProvider);
    final notifier = ref.read(passwordResetProvider.notifier);

    ref.listen(passwordResetProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: ${next.error}')),
        );
      }
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('パスワード再設定のメールを送信しました。')),
        );
        context.go('/login');
      }
    });

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 96,
        leading: TextButton(
          onPressed: () => context.pop(),
          child: Text(
            'キャンセル',
            style: TextStyle(color: theme.colorScheme.primary),
          ),
        ),
        title: const Text('パスワード再設定'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ステップ 1/2', style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey)),
                const SizedBox(height: 8),
                Text('メールアドレス確認', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(
                  'アカウントに登録したメールアドレスを入力してください。パスワード再設定のための確認コードを送信します。',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                TextField(
                  onChanged: notifier.onEmailChanged,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: '登録済みのメールアドレス',
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: state.isLoading ? null : notifier.sendResetLink,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: const StadiumBorder(),
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: state.isLoading
                                ? [const Color(0xFF9CA3AF), const Color(0xFF9CA3AF)]
                                : [const Color(0xFF4ECDC4), const Color(0xFF44A08D)],
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Center(
                          child: state.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                                )
                              : const Text('確認コードを送信',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 