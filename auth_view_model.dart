import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/auth_state.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 認証ビューモデルクラス
///
/// 認証画面のUIロジックを担当します。
class AuthViewModel {
  /// 認証状態通知
  final AuthNotifier _authNotifier;

  /// コンストラクタ
  AuthViewModel(this._authNotifier);

  /// メールアドレスとパスワードでサインアップ
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    await _authNotifier.signUpWithEmailAndPassword(
      email: email,
      password: password,
      username: username,
      displayName: displayName,
    );
  }

  /// メールアドレスとパスワードでサインイン
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _authNotifier.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Googleでサインイン
  Future<void> signInWithGoogle() async {
    await _authNotifier.signInWithGoogle();
  }

  /// Appleでサインイン
  Future<void> signInWithApple() async {
    await _authNotifier.signInWithApple();
  }

  /// Twitterでサインイン
  Future<void> signInWithTwitter() async {
    await _authNotifier.signInWithTwitter();
  }

  /// Instagramでサインイン
  Future<void> signInWithInstagram() async {
    await _authNotifier.signInWithInstagram();
  }

  /// サインアウト
  Future<void> signOut() async {
    await _authNotifier.signOut();
  }

  /// パスワードリセットメールを送信
  Future<void> sendPasswordResetEmail(String email) async {
    await _authNotifier.sendPasswordResetEmail(email);
  }

  /// エラーメッセージをクリア
  void clearError() {
    _authNotifier.clearError();
  }
}

/// 認証ビューモデルプロバイダー
final authViewModelProvider = Provider<AuthViewModel>((ref) {
  final authNotifier = ref.watch(authStateProvider.notifier);
  return AuthViewModel(authNotifier);
});

/// ログイン画面
class LoginScreen extends ConsumerStatefulWidget {
  /// コンストラクタ
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                  height: 120,
                  child: Center(
                    child: Text(
                      'Starlist',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),

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

                      // パスワード入力
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'パスワード',
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
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
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // パスワードを忘れた場合
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // パスワードリセット画面に遷移
                            _showPasswordResetDialog(context, authViewModel);
                          },
                          child: const Text('パスワードをお忘れですか？'),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ログインボタン
                      authState.isLoading
                          ? const LoadingIndicator()
                          : CustomButton(
                              text: 'ログイン',
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  await authViewModel.signInWithEmailAndPassword(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
                                  );
                                }
                              },
                            ),
                      const SizedBox(height: 16),

                      // 新規登録リンク
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('アカウントをお持ちでないですか？'),
                          TextButton(
                            onPressed: () {
                              // 新規登録画面に遷移
                              Navigator.pushReplacementNamed(context, '/register');
                            },
                            child: const Text('新規登録'),
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
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(
          icon,
          color: color,
          size: 30,
        ),
      ),
    );
  }

  /// パスワードリセットダイアログを表示
  void _showPasswordResetDialog(BuildContext context, AuthViewModel authViewModel) {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('パスワードリセット'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: emailController,
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
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  await authViewModel.sendPasswordResetEmail(
                    emailController.text.trim(),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('パスワードリセットメールを送信しました'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              child: const Text('送信'),
            ),
          ],
        );
      },
    );
  }
}
