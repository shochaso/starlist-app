import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HelpCenterScreen extends ConsumerWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ヘルプセンター'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 検索バー
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'ヘルプを検索...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // よくある質問
            _buildHelpSection(
              title: 'よくある質問',
              icon: Icons.help_outline,
              items: [
                _HelpItem(
                  title: 'スターポイントとは何ですか？',
                  content: 'スターポイント（スターP）は、Starlistプラットフォーム内で使用できるポイントシステムです。コンテンツの投稿、いいね、シェアなどの活動で獲得できます。',
                ),
                _HelpItem(
                  title: 'サブスクリプションの変更方法',
                  content: '設定 > サブスクリプション管理から、いつでもプランの変更やキャンセルが可能です。変更は次回請求日から適用されます。',
                ),
                _HelpItem(
                  title: 'コンテンツのアップロード制限',
                  content: '画像は最大10MB、動画は最大100MBまでアップロード可能です。対応形式：JPG, PNG, MP4, MOV',
                ),
                _HelpItem(
                  title: '収益分配について',
                  content: 'アフィリエイト収益はスター70%、運営30%で分配されます。広告収益は100%運営に帰属します。',
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 機能ガイド
            _buildHelpSection(
              title: '機能ガイド',
              icon: Icons.menu_book,
              items: [
                _HelpItem(
                  title: 'プロフィール設定',
                  content: 'プロフィール画像、自己紹介、SNSリンクなどを設定して、フォロワーとのつながりを深めましょう。',
                ),
                _HelpItem(
                  title: 'コンテンツ管理',
                  content: '投稿したコンテンツの編集、削除、公開設定の変更が可能です。下書き保存機能もご利用ください。',
                ),
                _HelpItem(
                  title: 'フォロー機能',
                  content: 'お気に入りのスターをフォローして、最新のコンテンツを見逃さないようにしましょう。',
                ),
              ],
            ),

            const SizedBox(height: 32),

            // サポート
            _buildHelpSection(
              title: 'サポート',
              icon: Icons.support_agent,
              items: [
                _HelpItem(
                  title: 'お問い合わせ',
                  content: 'ご不明な点がございましたら、support@starlist.jpまでお気軽にお問い合わせください。',
                ),
                _HelpItem(
                  title: '利用規約',
                  content: 'Starlistの利用規約をご確認いただけます。',
                ),
                _HelpItem(
                  title: 'コミュニティガイドライン',
                  content: '安全で楽しいコミュニティを維持するためのガイドラインです。',
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 連絡先情報
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'さらにサポートが必要ですか？',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('お気軽にお問い合わせください。'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // メール送信機能
                        },
                        icon: const Icon(Icons.email),
                        label: const Text('メールで問い合わせ'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          // チャット機能
                        },
                        icon: const Icon(Icons.chat),
                        label: const Text('チャットサポート'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection({
    required String title,
    required IconData icon,
    required List<_HelpItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...items.map((item) => _buildHelpItemTile(item)),
      ],
    );
  }

  Widget _buildHelpItemTile(_HelpItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              item.content,
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpItem {
  final String title;
  final String content;

  _HelpItem({
    required this.title,
    required this.content,
  });
}
