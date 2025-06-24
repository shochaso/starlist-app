import 'package:flutter/material.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
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
          'プライバシーポリシー',
          style: TextStyle(
            color: Color(0xFF212121),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(),
            const SizedBox(height: 32),
            _buildPolicySection(),
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
                  Icons.privacy_tip,
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
                      'プライバシーについて',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'あなたのデータを安全に保護します',
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
                  Icons.shield,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '最終更新日: 2024年6月22日',
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

  Widget _buildPolicySection() {
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
            'プライバシーポリシー',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF212121),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildPolicyItem(
            '1. 個人情報の収集について',
            'Starlistでは、サービス提供のために必要最小限の個人情報を収集いたします。収集する情報には以下が含まれます：\n\n• アカウント情報（メールアドレス、ユーザー名）\n• プロフィール情報（任意で設定いただく情報）\n• アプリの利用状況や行動履歴\n• デバイス情報（OS、機種名など）',
          ),
          
          _buildPolicyItem(
            '2. 個人情報の利用目的',
            '収集した個人情報は以下の目的で利用いたします：\n\n• サービスの提供・運営・改善\n• ユーザーサポートの提供\n• 新機能やキャンペーンのご案内\n• 利用規約違反や不正利用の防止\n• 法令に基づく対応',
          ),
          
          _buildPolicyItem(
            '3. 個人情報の第三者提供',
            'ユーザーの同意なく個人情報を第三者に提供することはありません。ただし、以下の場合は例外とします：\n\n• 法令に基づく場合\n• 人の生命、身体または財産の保護のために必要な場合\n• 公衆衛生の向上または児童の健全な育成の推進のため必要な場合',
          ),
          
          _buildPolicyItem(
            '4. データのセキュリティ',
            'お客様の個人情報を保護するため、以下のセキュリティ対策を実施しています：\n\n• データの暗号化\n• アクセス制御の実施\n• 定期的なセキュリティ監査\n• 従業員への教育・研修',
          ),
          
          _buildPolicyItem(
            '5. Cookie等の技術について',
            'Starlistでは、サービス向上のためCookieやその他の技術を使用する場合があります。これらは以下の目的で使用されます：\n\n• ログイン状態の維持\n• 設定の保存\n• 利用状況の分析\n• パーソナライズされたコンテンツの提供',
          ),
          
          _buildPolicyItem(
            '6. お客様の権利',
            'お客様は自身の個人情報について以下の権利を有します：\n\n• 個人情報の開示請求\n• 個人情報の訂正・削除請求\n• 個人情報の利用停止請求\n• アカウントの削除',
          ),
          
          _buildPolicyItem(
            '7. お問い合わせ',
            'プライバシーポリシーに関するご質問やご意見がございましたら、以下の連絡先までお問い合わせください：\n\nメール: privacy@starlist.app\n受付時間: 平日 9:00-18:00',
          ),
          
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF1E88E5),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'このプライバシーポリシーは予告なく変更される場合があります。重要な変更がある場合は、アプリ内でお知らせいたします。',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
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

  Widget _buildPolicyItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}