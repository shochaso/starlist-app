import 'package:flutter/material.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final List<Map<String, dynamic>> _helpSections = [
    {
      'title': 'はじめに',
      'icon': Icons.rocket_launch,
      'color': const Color(0xFF1E88E5),
      'items': [
        {
          'question': 'Starlistとは何ですか？',
          'answer': 'Starlistは、あなたのお気に入りのスターを発見し、深いつながりを築くためのプラットフォームです。スターのランキングデータや限定コンテンツにアクセスできます。',
        },
        {
          'question': 'アカウントの作成方法を教えてください',
          'answer': 'アプリを起動後、「新規登録」をタップして、メールアドレスまたはSNSアカウントで簡単に登録できます。',
        },
        {
          'question': 'アプリの基本的な使い方は？',
          'answer': 'ホーム画面でスターを探し、気になるスターをフォローして、ランキングデータや限定コンテンツを楽しむことができます。',
        },
      ],
    },
    {
      'title': 'サブスクリプションプランについて',
      'icon': Icons.subscriptions,
      'color': const Color(0xFF7E57C2),
      'items': [
        {
          'question': 'プランの種類と違いを教えてください',
          'answer': 'ライトプラン（¥980/月）、スタンダードプラン（¥1,980/月）、プレミアムプラン（¥2,980/月）の3つのプランがあります。上位プランほど詳細なランキングデータや限定コンテンツにアクセスできます。',
        },
        {
          'question': '無料トライアルはありますか？',
          'answer': 'ライトプランとスタンダードプランは7日間、プレミアムプランは14日間の無料トライアルをご利用いただけます。',
        },
        {
          'question': 'プランの変更はいつでもできますか？',
          'answer': 'はい、プラン管理画面からいつでも変更・キャンセルが可能です。変更は次回請求日から適用されます。',
        },
        {
          'question': '支払い方法は何がありますか？',
          'answer': 'クレジットカード、デビットカード、Apple Pay、Google Pay、PayPal、キャリア決済をご利用いただけます。',
        },
      ],
    },
    {
      'title': 'スターとランキングについて',
      'icon': Icons.star,
      'color': Colors.orange,
      'items': [
        {
          'question': 'スターをフォローするメリットは？',
          'answer': 'フォローすることで、スターの詳細なランキングデータ、限定コンテンツ、活動履歴にアクセスできます。',
        },
        {
          'question': 'スターのランクとは何ですか？',
          'answer': 'レギュラー、プラチナ、スーパーの3段階があり、フォロワー数や活動度、エンゲージメント率に応じて決定されます。',
        },
        {
          'question': 'ランキングデータとは何ですか？',
          'answer': 'スターの人気度、成長率、エンゲージメント、収益性などを数値化したデータです。有料プランでより詳細なデータにアクセスできます。',
        },
        {
          'question': 'プロフィールカスタマイズとは？',
          'answer': 'ライトプラン以上で、お気に入りスターのリストやプロフィール表示をカスタマイズできる機能です。',
        },
      ],
    },
    {
      'title': 'トラブルシューティング',
      'icon': Icons.bug_report,
      'color': const Color(0xFFE91E63),
      'items': [
        {
          'question': 'アプリがクラッシュしてしまいます',
          'answer': 'アプリを最新版に更新し、端末を再起動してみてください。問題が続く場合はサポートまでご連絡ください。',
        },
        {
          'question': '動画が再生されません',
          'answer': 'インターネット接続を確認し、アプリの再起動を試してください。Wi-Fi環境での視聴を推奨します。',
        },
        {
          'question': 'アカウントにログインできません',
          'answer': 'パスワードをお忘れの場合は「パスワードを忘れた方」から再設定してください。',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF212121)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ヘルプセンター',
          style: TextStyle(
            color: Color(0xFF212121),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF1E88E5)),
            onPressed: () {
              // TODO: 検索機能
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(),
            const SizedBox(height: 32),
            const Text(
              'よくある質問',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF212121),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'カテゴリーから探したい質問を見つけてください',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            ..._helpSections.map((section) => _buildHelpSection(section)),
            const SizedBox(height: 32),
            _buildContactSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF7E57C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.support_agent,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'お困りですか？',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'よくある質問をチェックしてみてください',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'サポート対応時間: 平日 9:00-18:00',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(Map<String, dynamic> section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (section['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            section['icon'] as IconData,
            color: section['color'] as Color,
            size: 24,
          ),
        ),
        title: Text(
          section['title'],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
        ),
        subtitle: Text(
          '${(section['items'] as List).length}件の質問',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        children: (section['items'] as List<Map<String, dynamic>>)
            .map((item) => _buildFAQItem(item))
            .toList(),
      ),
    );
  }

  Widget _buildFAQItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: Color(0xFF1E88E5),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item['question'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              item['answer'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'まだ解決しませんか？',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'お気軽にサポートチームまでお問い合わせください',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: お問い合わせ機能
                  },
                  icon: const Icon(Icons.email, size: 20),
                  label: const Text('メールで問い合わせ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: チャット機能
                  },
                  icon: const Icon(Icons.chat, size: 20),
                  label: const Text('チャットで相談'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E88E5),
                    side: const BorderSide(color: Color(0xFF1E88E5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}