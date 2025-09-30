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
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
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

      if (client.auth.currentUser != null) {
        print(
            '[AutoLogin] LoginScreen: user already logged in, redirecting to /home');
        if (mounted) context.go('/home');
        return;
      }

      final response = await client.auth.signInWithPassword(
        email: 'shochaso@gmail.com',
        password: 'password1234',
      );

      if (response.user != null) {
        print(
            '[AutoLogin] LoginScreen: auto-login successful, redirecting to /home');
        if (mounted) context.go('/home');
      } else {
        print('[AutoLogin] LoginScreen: auto-login failed - no user returned');
      }
    } catch (e) {
      print('[AutoLogin] LoginScreen: auto-login error: $e');
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final featureTags = <String>[
      'リアタイ視聴ログ',
      '推しのハマりもの',
      'スターが残すメモ',
      '気軽なチェックイン',
    ];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFE7F0FF),
                    theme.primaryColor.withOpacity(0.35),
                    const Color(0xFFF9FBFF),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -120,
            right: -40,
            child: _GradientOrb(
              diameter: 320,
              colors: [theme.primaryColor, const Color(0xFF7BD0FF)],
              opacity: 0.35,
            ),
          ),
          Positioned(
            bottom: -140,
            left: -60,
            child: _GradientOrb(
              diameter: 360,
              colors: [const Color(0xFFFFD08A), theme.primaryColor],
              opacity: 0.3,
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 1024;
                  final contentWidth = isWide ? 1100.0 : double.infinity;

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 64 : 24,
                      vertical: isWide ? 72 : 32,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentWidth),
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child:
                                          _HeroPanel(featureTags: featureTags)),
                                  const SizedBox(width: 48),
                                  Flexible(
                                      child: _buildLoginCard(
                                          theme, colorScheme, isWide)),
                                ],
                              )
                            : Column(
                                children: [
                                  _HeroPanel(featureTags: featureTags),
                                  const SizedBox(height: 32),
                                  _buildLoginCard(theme, colorScheme, isWide),
                                ],
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(
      ThemeData theme, ColorScheme colorScheme, bool isWide) {
    final surface = Colors.white.withOpacity(0.95);
    final borderColor = Colors.white.withOpacity(0.2);

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isWide ? 48 : 28, vertical: isWide ? 48 : 32),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 40,
            offset: const Offset(0, 28),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primaryColor, const Color(0xFF00B3FF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Starlist へログイン',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '推しの毎日をファンと一緒に楽しもう',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildTextField(
            controller: _emailController,
            label: 'メールアドレスまたはユーザー名',
            hint: 'star@yourgalaxy.com',
            icon: Icons.alternate_email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _passwordController,
            label: 'パスワード',
            hint: '8文字以上が安心',
            icon: Icons.lock_outline,
            obscureText: !_isPasswordVisible,
            trailing: IconButton(
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              tooltip: _isPasswordVisible ? '非表示にする' : '表示する',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primaryColor, const Color(0xFF00B3FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _isLoading
                        ? const SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.6, color: Colors.white),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.login_rounded, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                'ログイン',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('パスワードをリセット'),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('アカウント作成'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(Icons.star_outline, color: Colors.black54),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '公開したい瞬間だけを選べるから安心。ライトな日常も、ここなら推し活コンテンツに変わります。',
                    style: TextStyle(
                        fontSize: 13, color: Colors.black87, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? trailing,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: trailing,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 1.4),
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.featureTags});

  final List<String> featureTags;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 48,
            offset: const Offset(0, 32),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [theme.primaryColor, const Color(0xFF00B3FF)]),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.radar_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text('STARLIST VIBES',
                        style:
                            TextStyle(color: Colors.white, letterSpacing: 1.4)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            '推しの毎日をデータでキャッチ\nファンとの距離をショートカット',
            style: TextStyle(
              fontSize: 40,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Starlistは推しの視聴ログやお気に入りを、その瞬間の気分と一緒にシェアできるコミュニティ。ファンはリアタイで盛り上がり、スターは自分らしく価値を届けられます。',
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.white.withOpacity(0.88),
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: featureTags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withOpacity(0.14)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.brightness_low,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 8),
                        Text(tag,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13)),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 36),
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [
                          theme.primaryColor,
                          const Color(0xFFFFB457)
                        ]),
                      ),
                      child: const Icon(Icons.timeline_outlined,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 18),
                    const Expanded(
                      child: Text(
                        '今日のハイライト',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const _HighlightItem(
                  label: '星守ゆづ（Premium）',
                  content: 'Spotifyで最近ハマってる曲をシェア。コメント欄では歌詞トークが続いています。',
                ),
                const SizedBox(height: 14),
                const _HighlightItem(
                  label: 'コミュニティ速報',
                  content: '視聴タグを使ったミニ企画が盛り上がり中。今夜のウォッチパーティに参加する人も増えてきています。',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightItem extends StatelessWidget {
  const _HighlightItem({required this.label, required this.content});

  final String label;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style:
              const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
        ),
      ],
    );
  }
}

class _GradientOrb extends StatelessWidget {
  const _GradientOrb({
    required this.diameter,
    required this.colors,
    this.opacity = 0.5,
  });

  final double diameter;
  final List<Color> colors;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            colors.first.withOpacity(opacity),
            colors.last.withOpacity(opacity * 0.35),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
