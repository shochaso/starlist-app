import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/auth_view_model.dart';
import '../state/auth_state.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 登録画面
class RegisterScreen extends ConsumerStatefulWidget {
  /// コンストラクタ
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final authViewModel = ref.watch(authViewModelProvider);

    // エラーメッセージがある場合は表示
    if (authState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        authViewModel.clearError();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('新規登録'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ロゴ
                const SizedBox(
                  height: 80,
                  child: Center(
                    child: Text(
                      'Starlist',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // フォーム
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // メールアドレス入力
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'メールアドレス',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'メールアドレスを入力してください';
                          }
                          if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                              .hasMatch(value)) {
                            return '有効なメールアドレスを入力してください';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ユーザー名入力
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'ユーザー名',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                          helperText: '3文字以上の英数字（後から変更できません）',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'ユーザー名を入力してください';
                          }
                          if (value.length < 3) {
                            return 'ユーザー名は3文字以上である必要があります';
                          }
                          if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                            return 'ユーザー名は英数字とアンダースコアのみ使用できます';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 表示名入力
                      TextFormField(
                        controller: _displayNameController,
                        decoration: const InputDecoration(
                          labelText: '表示名',
                          prefixIcon: Icon(Icons.badge),
                          border: OutlineInputBorder(),
                          helperText: 'プロフィールに表示される名前（後から変更可能）',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '表示名を入力してください';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // パスワード入力
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'パスワード',
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          helperText: '8文字以上の英数字と記号を含むパスワード',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_isPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'パスワードを入力してください';
                          }
                          if (value.length < 8) {
                            return 'パスワードは8文字以上である必要があります';
                          }
                          // 文字、数字、特殊文字を含むかチェック
                          final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
                          final hasDigit = RegExp(r'[0-9]').hasMatch(value);
                          final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
                          
                          if (!(hasLetter && hasDigit && hasSpecial)) {
                            return 'パスワードには文字、数字、特殊文字を含める必要があります';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // パスワード確認入力
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'パスワード（確認）',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_isConfirmPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'パスワード（確認）を入力してください';
                          }
                          if (value != _passwordController.text) {
                            return 'パスワードが一致しません';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // 利用規約同意チェックボックス
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptTerms,
                            onChanged: (value) {
                              setState(() {
                                _acceptTerms = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  const TextSpan(text: '私は'),
                                  TextSpan(
                                    text: '利用規約',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // 利用規約画面に遷移
                                        Navigator.pushNamed(context, '/terms');
                                      },
                                  ),
                                  const TextSpan(text: 'と'),
                                  TextSpan(
                                    text: 'プライバシーポリシー',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // プライバシーポリシー画面に遷移
                                        Navigator.pushNamed(context, '/privacy');
                                      },
                                  ),
                                  const TextSpan(text: 'に同意します'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // 登録ボタン
                      authState.isLoading
                          ? const LoadingIndicator()
                          : CustomButton(
                              text: '登録',
                              onPressed: _acceptTerms
                                  ? () async {
                                      if (_formKey.currentState!.validate()) {
                                        await authViewModel.signUpWithEmailAndPassword(
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text,
                                          username: _usernameController.text.trim(),
                                          displayName: _displayNameController.text.trim(),
                                        );
                                      }
                                    }
                                  : null,
                            ),
                      const SizedBox(height: 16),

                      // ログインリンク
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('すでにアカウントをお持ちですか？'),
                          TextButton(
                            onPressed: () {
                              // ログイン画面に遷移
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: const Text('ログイン'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // または
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('または'),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // ソーシャルログインボタン
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Googleログイン
                          _buildSocialLoginButton(
                            icon: Icons.g_mobiledata,
                            color: Colors.red,
                            onPressed: () async {
                              await authViewModel.signInWithGoogle();
                            },
                          ),

                          // Appleログイン
                          _buildSocialLoginButton(
                            icon: Icons.apple,
                            color: Colors.black,
                            onPressed: () async {
                              await authViewModel.signInWithApple();
                            },
                          ),

                          // Twitterログイン
                          _buildSocialLoginButton(
                            icon: Icons.flutter_dash,
                            color: Colors.blue,
                            onPressed: () async {
                              await authViewModel.signInWithTwitter();
                            },
                          ),

                          // Instagramログイン
                          _buildSocialLoginButton(
                            icon: Icons.camera_alt,
                            color: Colors.purple,
                            onPressed: () async {
                              await authViewModel.signInWithInstagram();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ソーシャルログインボタンを構築
  Widget _buildSocialLoginButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadi<response clipped><NOTE>To save on context only part of this file has been shown to you. You should retry this tool after you have searched inside the file with `grep -n` in order to find the line numbers of what you are looking for.</NOTE>