import 'package:flutter/material.dart';

import '../ui/app_button.dart';
import '../ui/app_card.dart';
import '../theme/context_ext.dart';
import 'login_screen.dart';
import 'star_registration_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text('Starlist', style: theme.textTheme.titleLarge),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: tokens.spacing.md),
            child: AppButton(
              'ログイン',
              variant: AppButtonVariant.text,
              onPressed: _openLogin,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.lg,
          vertical: tokens.spacing.section,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroSection(onRegisterStar: _openStarRegistration, onRegisterFan: _openFanRegistration),
            SizedBox(height: tokens.spacing.section),
            _InsightsStrip(),
            SizedBox(height: tokens.spacing.section),
            _FeatureGrid(onNavigate: _navigateToFeature),
            SizedBox(height: tokens.spacing.section),
            _ContentCategories(onNavigate: _navigateToFeature),
            SizedBox(height: tokens.spacing.section),
            _Footer(onLogin: _openLogin),
          ],
        ),
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

  void _openFanRegistration() {
    Navigator.pushNamed(context, '/fan_register');
  }

  void _navigateToFeature(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"$feature" については現在準備中です。')),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.onRegisterStar,
    required this.onRegisterFan,
  });

  final VoidCallback onRegisterStar;
  final VoidCallback onRegisterFan;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(tokens.spacing.section),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: tokens.radius.xxlRadius,
        border: Border.all(color: colorScheme.outlineVariant, width: tokens.border.thin),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: tokens.elevations.lg,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'スターの日常を、もっと身近に。',
            style: theme.textTheme.displaySmall,
          ),
          SizedBox(height: tokens.spacing.md),
          Text(
            'Starlistはスターとファンがストレスなく交流できるデータ連動型プラットフォームです。データ収集から配信まで、すべてが数クリックで完結します。',
            style: theme.textTheme.bodyLarge,
          ),
          SizedBox(height: tokens.spacing.lg),
          Wrap(
            spacing: tokens.spacing.sm,
            runSpacing: tokens.spacing.sm,
            children: [
              AppButton(
                'スターとして登録',
                onPressed: onRegisterStar,
                leading: const Icon(Icons.star_outline),
              ),
              AppButton(
                'ファンとして登録',
                variant: AppButtonVariant.secondary,
                onPressed: onRegisterFan,
                leading: const Icon(Icons.favorite_border),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.lg),
          Wrap(
            spacing: tokens.spacing.lg,
            runSpacing: tokens.spacing.md,
            children: const [
              _HeroStat(label: '登録スター', value: '4,820'),
              _HeroStat(label: 'アクティブファン', value: '120,000'),
              _HeroStat(label: '平均エンゲージメント', value: '18%'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: theme.textTheme.headlineMedium?.copyWith(color: colorScheme.primary)),
        SizedBox(height: tokens.spacing.xxxs),
        Text(label, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _InsightsStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final insights = [
      ('24時間以内のデータ同期', Icons.cloud_sync),
      ('AIが推奨する投稿時間', Icons.auto_awesome),
      ('有料コメントのモデレーション', Icons.shield_outlined),
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.lg,
          vertical: tokens.spacing.md,
        ),
        child: Wrap(
          spacing: tokens.spacing.lg,
          runSpacing: tokens.spacing.sm,
          alignment: WrapAlignment.spaceBetween,
          children: insights
              .map(
                (insight) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(insight.$2, color: colorScheme.primary),
                    SizedBox(width: tokens.spacing.xs),
                    Text(insight.$1, style: theme.textTheme.labelLarge),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.onNavigate});

  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final features = [
      (
        Icons.psychology_alt_outlined,
        'ストレスレスな運営',
        'AI補助と有料コメント制限でスターのメンタルを保護します。',
      ),
      (
        Icons.analytics_outlined,
        'データ視聴基盤',
        'チャンネル横断の視聴データを自動集約し、意思決定を支援。',
      ),
      (
        Icons.volunteer_activism_outlined,
        'ファンと長期的に関係構築',
        'ロイヤリティプログラムと会員ランクで健全な関係をキープ。',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final crossAxisCount = isWide ? 3 : (constraints.maxWidth > 560 ? 2 : 1);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: tokens.spacing.md,
            crossAxisSpacing: tokens.spacing.md,
            childAspectRatio: 1.15,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return AppCard(
              title: feature.$2,
              actions: [
                IconButton(
                  icon: const Icon(Icons.arrow_outward),
                  tooltip: '${feature.$2}を見る',
                  onPressed: () => onNavigate(feature.$2),
                ),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(feature.$1, size: 32, color: Theme.of(context).colorScheme.primary),
                  SizedBox(height: tokens.spacing.sm),
                  Text(feature.$3, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ContentCategories extends StatelessWidget {
  const _ContentCategories({required this.onNavigate});

  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final categories = [
      '動画',
      '音楽',
      '映画・ドラマ',
      'ゲーム',
      '書籍',
      'ショッピング',
      '飲食情報',
      'スマホアプリ',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('提供コンテンツ', style: theme.textTheme.titleLarge),
        SizedBox(height: tokens.spacing.sm),
        Wrap(
          spacing: tokens.spacing.sm,
          runSpacing: tokens.spacing.sm,
          children: categories
              .map(
                (category) => ActionChip(
                  label: Text(category),
                  onPressed: () => onNavigate(category),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: tokens.spacing.section),
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: tokens.radius.xlRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Starlistについて', style: theme.textTheme.titleLarge),
          SizedBox(height: tokens.spacing.sm),
          Text(
            'Starlistは、推し活をデータと体験の両面から支えるファンプラットフォームです。スターとファンの距離を最小化し、双方にとって安心できる場を提供します。',
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: tokens.spacing.md),
          Wrap(
            spacing: tokens.spacing.sm,
            children: [
              AppButton('ログイン', variant: AppButtonVariant.text, onPressed: onLogin),
              AppButton('お問い合わせ', variant: AppButtonVariant.secondary, onPressed: () => onNavigateSupport(context)),
            ],
          ),
        ],
      ),
    );
  }

  void onNavigateSupport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('サポートへの導線は現在準備中です。')),
    );
  }
}
