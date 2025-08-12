import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starlist/features/login/application/login_provider.dart';
import 'package:starlist/core/theme/app_theme.dart'; // Assuming common styles are here
import 'package:starlist/providers/user_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginProvider);
    final notifier = ref.read(loginProvider.notifier);

    ref.listen(loginProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ログインに失敗しました: ${next.error}')),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 390,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Header
                const Text(
                  'Starlist',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                // Welcome Section
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child:
                      const Icon(Icons.star, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Starlistへようこそ',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'スターの日常をもっと身近に',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 30),

                // Form
                _buildTextField(
                  placeholder: 'メールアドレスまたはユーザー名',
                  onChanged: notifier.onEmailChanged,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  placeholder: 'パスワード',
                  obscureText: true,
                  onChanged: notifier.onPasswordChanged,
                ),
                const SizedBox(height: 20),

                // Login Button
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
                    height: 56,
                    child: ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () async {
                              if (await notifier.login()) {
                                await ref.read(currentUserProvider.notifier).loginRefreshFromSupabase();
                                context.go('/home');
                              }
                            },
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
                        child: Container(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (state.isLoading) ...[
                                const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                const Text('ログイン中...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                              ] else ...[
                                const Icon(Icons.lock_open_rounded, color: Colors.white),
                                const SizedBox(width: 8),
                                const Text('ログイン', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Forgot Password
                TextButton(
                  onPressed: () => context.go('/password-reset-request'),
                  child: const Text('パスワードをお忘れですか？'),
                ),
                const SizedBox(height: 10),

                // Create Account
                TextButton(
                  onPressed: () => context.go('/follower-check'), // Navigate to registration
                  child: const Text('アカウントを作成', style: TextStyle(fontWeight: FontWeight.bold)),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String placeholder,
    bool obscureText = false,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      onChanged: onChanged,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: placeholder,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE9E9EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE9E9EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      ),
    );
  }
} 