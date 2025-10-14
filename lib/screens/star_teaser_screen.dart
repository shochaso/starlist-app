import 'package:flutter/material.dart';
import 'dart:ui';
import '../ui/app_button.dart';
import '../theme/context_ext.dart';
import 'star_registration_screen.dart';
import 'login_screen.dart';

/// モダンでおしゃれなスター専用ティザーサイト
/// グラスモルフィズム、大胆なタイポグラフィ、洗練されたアニメーション
class StarTeaserScreen extends StatefulWidget {
  const StarTeaserScreen({super.key});

  @override
  State<StarTeaserScreen> createState() => _StarTeaserScreenState();
}

class _StarTeaserScreenState extends State<StarTeaserScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _scrollController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scrollController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _heroController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _heroController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _heroController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _heroController.forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 1024;
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              colorScheme.primary.withOpacity(0.15),
              const Color(0xFF0A0A0F),
              const Color(0xFF050508),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Floating orbs background
            ..._buildFloatingOrbs(),
            
            // Content
            CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  floating: true,
                  pinned: true,
                  flexibleSpace: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.auto_awesome, size: 20, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Starlist',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: _openLogin,
                      child: Text(
                        'ログイン',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),

                // Hero Section
                SliverToBoxAdapter(
                  child: _buildHeroSection(context, isWide, isMobile),
                ),

                // Features
                SliverToBoxAdapter(
                  child: _buildFeatures(context, isWide, isMobile),
                ),

                // Revenue
                SliverToBoxAdapter(
                  child: _buildRevenue(context, isWide, isMobile),
                ),

                // How it Works
                SliverToBoxAdapter(
                  child: _buildHowItWorks(context, isWide, isMobile),
                ),

                // Final CTA
                SliverToBoxAdapter(
                  child: _buildFinalCTA(context, isWide, isMobile),
                ),

                // Footer
                SliverToBoxAdapter(
                  child: _buildFooter(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingOrbs() {
    return [
      Positioned(
        top: 100,
        right: -50,
        child: _FloatingOrb(size: 300, color: Colors.blue.withOpacity(0.1)),
      ),
      Positioned(
        bottom: 200,
        left: -100,
        child: _FloatingOrb(size: 400, color: Colors.purple.withOpacity(0.08)),
      ),
    ];
  }

  Widget _buildHeroSection(BuildContext context, bool isWide, bool isMobile) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : (isWide ? 120 : 60),
        vertical: isWide ? 180 : (isMobile ? 120 : 140),
      ),
      child: AnimatedBuilder(
        animation: _heroController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Column(
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withOpacity(0.2),
                            colorScheme.secondary.withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary,
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '2025年春、先行登録受付開始',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isWide ? 60 : 40),

                    // Main Headline
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.8),
                              ],
                            ).createShader(bounds),
                            child: Text(
                              'あなたの"日常データ"が、',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isMobile ? 36 : (isWide ? 72 : 56),
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                                letterSpacing: -2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.secondary,
                              ],
                            ).createShader(bounds),
                            child: Text(
                              'ファンのいちばん好きな',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isMobile ? 36 : (isWide ? 72 : 56),
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                                letterSpacing: -2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.8),
                              ],
                            ).createShader(bounds),
                            child: Text(
                              'コンテンツになる。',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isMobile ? 36 : (isWide ? 72 : 56),
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                                letterSpacing: -2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isWide ? 40 : 32),

                    // Subheadline
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Text(
                        '視聴履歴・レシート・プレイリストをワンタップ投稿。\nモザイクで安全に。ファンは応援購買とサブスクで支えてくれる。',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 20,
                          height: 1.8,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    SizedBox(height: isWide ? 60 : 48),

                    // CTA Button
                    _ModernButton(
                      label: '先行登録する（無料）',
                      icon: Icons.arrow_forward,
                      onPressed: _openStarRegistration,
                      large: true,
                    ),
                    const SizedBox(height: 24),

                    // Trust
                    Text(
                      'クレジットカード不要  •  いつでもキャンセル可能',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.5),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatures(BuildContext context, bool isWide, bool isMobile) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final features = [
      (
        Icons.video_library_outlined,
        '動画にできない"生活の裏側"',
        'Netflix履歴、Amazonレシート、Spotifyプレイリスト。普段なら見せられない日常が、モザイク付きで安全に投稿できます。',
      ),
      (
        Icons.flash_on_outlined,
        '3分で投稿完了',
        'スクショを選ぶだけ。AIが自動でタグ付け、モザイク候補を提案。編集不要で、サクッと投稿完了。',
      ),
      (
        Icons.security_outlined,
        '後から編集OK',
        '個人情報は自動検出してモザイク。投稿範囲は会員ランクで制御。後から見せたくない部分だけ編集できます。',
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : (isWide ? 120 : 60),
        vertical: isWide ? 120 : 80,
      ),
      child: Column(
        children: [
          Text(
            'なぜ、Starlistなのか',
            style: TextStyle(
              fontSize: isMobile ? 32 : 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isWide ? 80 : 60),
          ...features.asMap().entries.map((entry) {
            final index = entry.key;
            final feature = entry.value;
            
            return Container(
              margin: EdgeInsets.only(bottom: isWide ? 32 : 24),
              child: _GlassCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: isMobile ? 48 : 64,
                      height: isMobile ? 48 : 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withOpacity(0.3),
                            colorScheme.secondary.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Icon(
                        feature.$1,
                        size: isMobile ? 24 : 32,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature.$2,
                            style: TextStyle(
                              fontSize: isMobile ? 20 : 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            feature.$3,
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              height: 1.7,
                              color: Colors.white.withOpacity(0.7),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRevenue(BuildContext context, bool isWide, bool isMobile) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final revenue = [
      (Icons.workspace_premium_outlined, 'サブスク', 'Entry/Standard/Premium', '¥500~/月から'),
      (Icons.shopping_bag_outlined, '応援購入', 'アフィリエイト連動', '購入が可視化'),
      (Icons.casino_outlined, '広告（任意）', 'ガチャ/ホーム枠', '追加収益'),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : (isWide ? 120 : 60),
        vertical: isWide ? 120 : 80,
      ),
      child: Column(
        children: [
          Text(
            'フォロワーを"ファン"に変える',
            style: TextStyle(
              fontSize: isMobile ? 32 : 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '3つの収益源',
            style: TextStyle(
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isWide ? 60 : 48),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 3 : (isMobile ? 1 : 2),
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              childAspectRatio: isMobile ? 1.3 : 1.1,
            ),
            itemCount: revenue.length,
            itemBuilder: (context, index) {
              final item = revenue[index];
              return _GlassCard(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.$1, size: 48, color: colorScheme.primary),
                    const SizedBox(height: 20),
                    Text(
                      item.$2,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.$3,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.$4,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks(BuildContext context, bool isWide, bool isMobile) {
    final steps = [
      ('スクショを選ぶ', 'Netflix・Amazon・Spotifyなど'),
      ('モザイク確認', 'AIが自動で個人情報を検出'),
      ('投稿', 'ワンタップで完了、3分以内'),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : (isWide ? 120 : 60),
        vertical: isWide ? 120 : 80,
      ),
      child: Column(
        children: [
          Text(
            '使い方は、たったの3ステップ',
            style: TextStyle(
              fontSize: isMobile ? 28 : 40,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isWide ? 60 : 48),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          step.$1,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          step.$2,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.6),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFinalCTA(BuildContext context, bool isWide, bool isMobile) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : (isWide ? 120 : 60),
        vertical: isWide ? 80 : 60,
      ),
      padding: EdgeInsets.all(isMobile ? 40 : 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.5),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '先行登録で、',
            style: TextStyle(
              fontSize: isMobile ? 32 : 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '初月サブスク無料',
            style: TextStyle(
              fontSize: isMobile ? 32 : 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 24 : 32),
          Text(
            '2025年春のリリースまで、メールで最新情報をお届けします。',
            style: TextStyle(
              fontSize: isMobile ? 15 : 18,
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 40 : 48),
          _ModernButton(
            label: '先行登録する',
            icon: Icons.mail_outline,
            onPressed: _openStarRegistration,
            isSecondary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            '© 2025 Starlist. All rights reserved.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            children: [
              TextButton(
                onPressed: () {},
                child: Text(
                  '利用規約',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'プライバシーポリシー',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'お問い合わせ',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _openStarRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StarRegistrationScreen()),
    );
  }
}

/// ガラスモルフィズムカード
class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// モダンなボタン
class _ModernButton extends StatelessWidget {
  const _ModernButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isSecondary = false,
    this.large = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isSecondary;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: large ? 40 : 32,
            vertical: large ? 20 : 16,
          ),
          decoration: BoxDecoration(
            color: isSecondary ? Colors.white : null,
            gradient: isSecondary
                ? null
                : LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                  ),
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: (isSecondary ? Colors.white : colorScheme.primary)
                    .withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSecondary ? colorScheme.primary : Colors.white,
                size: large ? 24 : 20,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: large ? 18 : 16,
                  fontWeight: FontWeight.w700,
                  color: isSecondary ? colorScheme.primary : Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// フローティングオーブ
class _FloatingOrb extends StatefulWidget {
  const _FloatingOrb({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  State<_FloatingOrb> createState() => _FloatingOrbState();
}

class _FloatingOrbState extends State<_FloatingOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            20 * (0.5 - ((_controller.value * 2) % 1 - 0.5).abs()),
          ),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.color,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
