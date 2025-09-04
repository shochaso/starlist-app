import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starlist_app/providers/user_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _autoLoginAttempted = false;

  @override
  void initState() {
    super.initState();
    // 自動ログインを一度だけ試行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_autoLoginAttempted) {
        _autoLoginAttempted = true;
        _tryAutoLogin();
      }
    });
  }

  Future<void> _tryAutoLogin() async {
    try {
      print('[AutoLogin] LoginScreen: attempting auto-login');
      final client = Supabase.instance.client;
      
      // 現在のユーザーをチェック
      if (client.auth.currentUser != null) {
        print('[AutoLogin] LoginScreen: user already logged in, redirecting to /home');
        if (mounted) context.go('/home');
        return;
      }

      // テストユーザーで自動ログイン
      final response = await client.auth.signInWithPassword(
        email: 'shochaso@gmail.com',
        password: 'password1234',
      );

      if (response.user != null) {
        print('[AutoLogin] LoginScreen: auto-login successful, redirecting to /home');
        if (mounted) context.go('/home');
      } else {
        print('[AutoLogin] LoginScreen: auto-login failed - no user returned');
      }
    } catch (e) {
      print('[AutoLogin] LoginScreen: auto-login error: $e');
      // エラーの場合は通常のログイン画面を表示
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('メールアドレスとパスワードを入力してください')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response.user != null) {
        // ユーザープロバイダーを更新
        await ref.read(currentUserProvider.notifier).loginRefreshFromSupabase();
        
        if (mounted) {
          context.go('/home');
        }
      } else {
        throw Exception('ログインに失敗しました');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ログインに失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ロゴ
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 32),
                // タイトル
                const Text(
                  'Starlist',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'スターの日常をもっと身近に',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 48),
                // メールアドレス入力
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'メールアドレスまたはユーザー名',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // パスワード入力
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'パスワード',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                // ログインボタン
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock),
                              SizedBox(width: 8),
                              Text('ログイン'),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // パスワード忘れ
                TextButton(
                  onPressed: () {},
                  child: const Text('パスワードをお忘れですか？'),
                ),
                const SizedBox(height: 16),
                // アカウント作成
                TextButton(
                  onPressed: () {},
                  child: const Text('アカウントを作成'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 