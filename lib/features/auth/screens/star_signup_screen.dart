import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'star_email_signup_screen.dart';

class StarSignupScreen extends StatefulWidget {
  const StarSignupScreen({super.key});

  @override
  State<StarSignupScreen> createState() => _StarSignupScreenState();
}

class _StarSignupScreenState extends State<StarSignupScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildSignupButtons(),
                  const SizedBox(height: 30),
                  _buildTermsText(),
                  const SizedBox(height: 40),
                  _buildLoginSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // ロゴ
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withOpacity(0.3),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.star,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            // タイトル
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
              ).createShader(bounds),
              child: const Text(
                'Starlist',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'スターの日常をもっと身近に',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF888888),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupButtons() {
    return Column(
      children: [
        const Text(
          'スター登録',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 30),
        _buildAnimatedButton(
          delay: 100,
          child: _buildSocialButton(
            icon: Icons.email,
            text: 'メールアドレスで登録',
            backgroundColor: const Color(0xFFF5F5F5),
            textColor: const Color(0xFF333333),
            borderColor: const Color(0xFFE0E0E0),
            onTap: _signUpWithEmail,
          ),
        ),
        const SizedBox(height: 12),
        _buildAnimatedButton(
          delay: 200,
          child: _buildSocialButton(
            icon: FontAwesomeIcons.apple,
            text: 'Appleでサインアップ',
            backgroundColor: Colors.black,
            textColor: Colors.white,
            borderColor: const Color(0xFF333333),
            onTap: _signUpWithApple,
          ),
        ),
        const SizedBox(height: 12),
        _buildAnimatedButton(
          delay: 300,
          child: _buildSocialButton(
            icon: FontAwesomeIcons.google,
            text: 'Googleで登録',
            backgroundColor: Colors.white,
            textColor: const Color(0xFF333333),
            borderColor: const Color(0xFFE0E0E0),
            onTap: _signUpWithGoogle,
          ),
        ),
        const SizedBox(height: 12),
        _buildAnimatedButton(
          delay: 400,
          child: _buildSocialButton(
            icon: FontAwesomeIcons.line,
            text: 'LINEで登録',
            backgroundColor: const Color(0xFF00B900),
            textColor: Colors.white,
            onTap: _signUpWithLine,
          ),
        ),
        const SizedBox(height: 12),
        _buildAnimatedButton(
          delay: 500,
          child: _buildSocialButton(
            icon: FontAwesomeIcons.facebookF,
            text: 'Facebookで登録',
            backgroundColor: const Color(0xFF1877F2),
            textColor: Colors.white,
            onTap: _signUpWithFacebook,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedButton({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: borderColor != null
                  ? Border.all(color: borderColor, width: 1)
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: textColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF888888),
              height: 1.5,
            ),
            children: [
              TextSpan(
                text: '利用規約',
                style: TextStyle(
                  color: Color(0xFF4ECDC4),
                  decoration: TextDecoration.underline,
                ),
                // recognizer: TapGestureRecognizer()..onTap = _showTerms,
              ),
              TextSpan(text: '及び'),
              TextSpan(
                text: 'プライバシーポリシー',
                style: TextStyle(
                  color: Color(0xFF4ECDC4),
                  decoration: TextDecoration.underline,
                ),
                // recognizer: TapGestureRecognizer()..onTap = _showPrivacy,
              ),
              TextSpan(text: 'に同意の上、登録又はログインへお進みください。'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginSection() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.only(top: 30),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF333333), width: 1),
          ),
        ),
        child: Column(
          children: [
            const Text(
              'アカウントをお持ちの方',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _goToLogin();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFF6B6B),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'ログイン',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF6B6B),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ソーシャルログイン関数
  void _signUpWithEmail() {
    _showSnackBar('メール登録画面に移動します');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StarEmailSignupScreen()),
    );
  }

  void _signUpWithApple() {
    _showSnackBar('Apple認証を開始します');
    // 実際の実装では、Apple Sign-In SDKを使用
    // await SignInWithApple.getAppleIDCredential(...)
  }

  void _signUpWithGoogle() {
    _showSnackBar('Google認証を開始します');
    // 実際の実装では、Google Sign-In SDKを使用
    // await GoogleSignIn().signIn()
  }

  void _signUpWithLine() {
    _showSnackBar('LINE認証を開始します');
    // 実際の実装では、LINE Login SDKを使用
  }

  void _signUpWithFacebook() {
    _showSnackBar('Facebook認証を開始します');
    // 実際の実装では、Facebook Login SDKを使用
  }

  void _goToLogin() {
    _showSnackBar('ログイン画面に移動します');
    // 実際の実装では、ログイン画面に遷移
    // Navigator.pushNamed(context, '/login');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4ECDC4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
} 