import 'package:flutter/material.dart';

void main() {
  runApp(const StarlistWebApp());
}

class StarlistWebApp extends StatelessWidget {
  const StarlistWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Starlist',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Noto Sans JP',
        useMaterial3: true,
      ),
      home: const StarlistWebHomePage(),
    );
  }
}

class StarlistWebHomePage extends StatelessWidget {
  const StarlistWebHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildNavBar(context),
            _buildHeroSection(context),
            _buildPopularStarsSection(context),
            _buildLatestActivitiesSection(context),
            _buildDataImportSection(context),
            _buildMembershipPlansSection(context),
            _buildAIRecommendationSection(context),
            _buildBadgeAndLoyaltySection(context),
            _buildCommentManagementSection(context),
            _buildFooterSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          const Text(
            'Starlist',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const Spacer(),
          _buildNavItem('ホーム', isSelected: true),
          _buildNavItem('スターを探す'),
          _buildNavItem('メンバーシップ'),
          _buildNavItem('データインポート'),
          _buildNavItem('マイページ'),
          const SizedBox(width: 20),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.indigo,
              side: const BorderSide(color: Colors.indigo),
            ),
            child: const Text('ログイン'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            child: const Text('無料登録'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String text, {bool isSelected = false}) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        foregroundColor: isSelected ? Colors.indigo : Colors.black87,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade50, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '日常をファンと共有しよう',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Starlistは、スターとファンをつなぐプラットフォームです。日常生活のシーンを共有し、より深いつながりを築きましょう。',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      child: const Text(
                        'スターとして登録',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.indigo,
                        side: const BorderSide(color: Colors.indigo),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      child: const Text(
                        'ファンとして登録',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 60),
          Expanded(
            child: Image.network(
              'https://picsum.photos/id/1068/500/400',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularStarsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '人気のスター',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPopularStarCard(
                '佐藤ユウタ',
                'YouTuber / 料理家',
                'プラチナ会員: 358人',
                'https://picsum.photos/id/1005/150/150',
              ),
              _buildPopularStarCard(
                '鈴木アンナ',
                'モデル / ファッションブロガー',
                'ゴールド会員: 245人',
                'https://picsum.photos/id/1011/150/150',
              ),
              _buildPopularStarCard(
                '高橋ケンジ',
                'ゲームストリーマー',
                'プラチナ会員: 412人',
                'https://picsum.photos/id/1012/150/150',
              ),
              _buildPopularStarCard(
                '山田ミク',
                'VTuber / シンガー',
                'シルバー会員: 178人',
                'https://picsum.photos/id/1027/150/150',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPopularStarCard(String name, String category, String membership, String imageUrl) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(imageUrl),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              membership,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: const Size(150, 36),
              ),
              child: const Text('フォロー'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestActivitiesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '最新アクティビティ',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 30),
          Column(
            children: [
              _buildActivityCard(
                '佐藤ユウタ',
                '2時間前',
                '最近視聴した動画',
                'プロが教える簡単パスタレシピ3選',
                '料理研究家チャンネル',
                'https://picsum.photos/id/1005/150/150',
                'https://picsum.photos/id/292/300/150',
                126,
                38,
                '動画を見る',
              ),
              const SizedBox(height: 20),
              _buildActivityCard(
                '鈴木アンナ',
                '3時間前',
                '最近の購入品',
                'オーガニックコットンTシャツ',
                'ECOMODE ブランド',
                'https://picsum.photos/id/1011/150/150',
                'https://picsum.photos/id/0/300/150',
                89,
                24,
                '商品を見る',
              ),
              const SizedBox(height: 20),
              _buildActivityCard(
                '高橋ケンジ',
                '5時間前',
                '最近聴いた音楽',
                'Dark Side of the Moon',
                'Pink Floyd',
                'https://picsum.photos/id/1012/150/150',
                'https://picsum.photos/id/1028/300/150',
                145,
                52,
                '音楽を聴く',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
      String starName,
      String time,
      String activityType,
      String contentTitle,
      String contentSubtitle,
      String starImageUrl,
      String contentImageUrl,
      int likes,
      int comments,
      String actionText) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(starImageUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        starName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    activityType,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          contentImageUrl,
                          width: 120,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contentTitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              contentSubtitle,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.favorite, color: Colors.red.shade300, size: 20),
                                const SizedBox(width: 4),
                                Text('$likes'),
                                const SizedBox(width: 16),
                                Icon(Icons.comment, color: Colors.blue.shade300, size: 20),
                                const SizedBox(width: 4),
                                Text('$comments'),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    actionText,
                                    style: const TextStyle(color: Colors.indigo),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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

  Widget _buildDataImportSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '簡単データ取り込み',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'YouTube視聴履歴、Spotify再生履歴、レシートなどをスマートフォンで撮影するだけで、あなたの日常データを簡単に取り込むことができます。プライバシーに配慮し、共有したい情報だけを選んで公開できます。',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 40),
          _buildImportSteps(),
          const SizedBox(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildYouTubeImportSection()),
              const SizedBox(width: 20),
              Expanded(child: _buildSpotifyImportSection()),
              const SizedBox(width: 20),
              Expanded(child: _buildReceiptImportSection()),
            ],
          ),
          const SizedBox(height: 40),
          _buildPrivacySettingsSection(),
        ],
      ),
    );
  }

  Widget _buildImportSteps() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStepItem('1', '撮影/選択', '画像を撮影またはギャラリーから選択'),
        _buildStepItem('2', 'OCR分析', 'AIがデータを自動抽出'),
        _buildStepItem('3', '確認/編集', '抽出されたデータを確認・編集'),
        _buildStepItem('4', '公開設定', '共有範囲を設定'),
        _buildStepItem('5', '完了', 'プロフィールに追加'),
      ],
    );
  }

  Widget _buildStepItem(String number, String title, String description) {
    return SizedBox(
      width: 150,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.indigo,
            radius: 25,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYouTubeImportSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'YouTube視聴履歴',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '視聴履歴のスクリーンショットからチャンネル名、動画タイトル、再生時間などを自動抽出。あなたの好みのコンテンツをファンに共有できます。',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            _buildExtractedDataItem('動画タイトル:', 'プロが教える簡単パスタレシピ3選'),
            _buildExtractedDataItem('チャンネル名:', '料理研究家チャンネル'),
            _buildExtractedDataItem('視聴時間:', '15:42'),
            _buildExtractedDataItem('視聴日時:', '2023/4/3 21:15 (非公開)'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('取り込む'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpotifyImportSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spotify再生履歴',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Spotifyアプリのスクリーンショットから曲名、アーティスト名、アルバム名などを自動抽出。あなたの音楽の好みをファンに共有できます。',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            _buildExtractedDataItem('曲名:', 'Bohemian Rhapsody'),
            _buildExtractedDataItem('アーティスト:', 'Queen'),
            _buildExtractedDataItem('アルバム:', 'A Night At The Opera'),
            _buildExtractedDataItem('再生日時:', '2023/4/3 18:30 (非公開)'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('取り込む'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptImportSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'レシート読み取り',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '買い物レシートの写真から商品名、価格、店舗名などを自動抽出。あなたのライフスタイルをファンに共有できます。位置情報などプライバシーに関わる情報は自動的に除外されます。',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            _buildExtractedDataItem('店舗名:', 'オーガニックマーケット'),
            _buildExtractedDataItem('商品:', 'オーガニック野菜セット ¥1,280'),
            _buildExtractedDataItem('商品:', '無添加パン ¥320'),
            _buildExtractedDataItem('店舗住所:', '東京都〇〇区... (非公開)'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('取り込む'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtractedDataItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildPrivacySettingsSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'コメント設定',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'コメントの表示やフィルタリングの設定を行えます。',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 30),
            _buildSettingItem('コメント許可', '全ユーザー', true),
            _buildSettingItem('自動モデレーション', 'オン', true),
            _buildSettingItem('NGワードフィルター', 'カスタム', true),
            _buildSettingItem('返信通知', 'オン', true),
            _buildSettingItem('コメント承認', 'オフ', false),
            const SizedBox(height: 20),
            const Text(
              '優先コメント表示',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildPriorityToggle('プレミアムメンバー', true),
            _buildPriorityToggle('常連ファン', true),
            _buildPriorityToggle('新規ファン', false),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                child: const Text('設定を保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, String value, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isEnabled ? Colors.green.shade100 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: isEnabled ? Colors.green.shade800 : Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityToggle(String title, bool isSelected) {
    return SizedBox(
      width: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (value) {},
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipPlansSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      color: Colors.indigo.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '多層的な会員プラン',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'あなたのニーズに合わせた多層的な会員プランをご用意しています。スターの活動をより身近に感じたい方は、より上位のプランをお選びください。',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildMembershipPlanCard(
                  'ライト会員',
                  '気軽にスターを応援',
                  '¥1,500',
                  [
                    '一般コンテンツの閲覧',
                    'ライト限定コメント機能',
                    '月1回のプレゼント応募権',
                  ],
                  [
                    'スターの基本的な日常データへのアクセス',
                    'シルバーバッジ付与（アプリ内表示）',
                    '月に1回のプレゼント企画参加権',
                    '投票権（一般投票のみ）',
                  ],
                  Colors.blue.shade100,
                  false,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildMembershipPlanCard(
                  'スタンダード会員',
                  'より深くスターを知る',
                  '¥3,000',
                  [
                    'ライト会員特典のすべて',
                    'プレミアムコンテンツ閲覧',
                    '月3回のプレゼント応募権',
                    '限定イベント参加権',
                  ],
                  [
                    'スターの詳細な日常データへのアクセス',
                    'ゴールドバッジ付与（アプリ内表示）',
                    '月に3回のプレゼント企画参加権',
                    '投票権（プレミアム投票含む）',
                    'スターからの月1回のメッセージ',
                  ],
                  Colors.amber.shade100,
                  true,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildMembershipPlanCard(
                  'プレミアム会員',
                  'スターとの特別な関係',
                  '¥10,000',
                  [
                    'スタンダード会員特典のすべて',
                    'VIPルームアクセス',
                    '優先コメント表示',
                    '限定グッズ先行販売',
                    '年2回のビデオ通話機会',
                  ],
                  [
                    'スターの完全な日常データへのアクセス',
                    'プラチナバッジ付与（アプリ内表示）',
                    'プレゼント企画の優先参加権',
                    'スターとの年2回の20分ビデオ通話',
                    'バースデーメッセージ',
                    'クローズドイベントへの招待',
                  ],
                  Colors.purple.shade100,
                  false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipPlanCard(
    String title,
    String subtitle,
    String price,
    List<String> features,
    List<String> detailedFeatures,
    Color backgroundColor,
    bool isPopular,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isPopular
              ? Border.all(color: Colors.amber, width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPopular)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '人気',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$price /月',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ...features.map((feature) => _buildFeatureItem(feature)).toList(),
            const SizedBox(height: 24),
            const Text(
              '特典詳細',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...detailedFeatures.map((feature) => _buildDetailedFeatureItem(feature)).toList(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('選択する'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIRecommendationSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AIレコメンド',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'あなたの閲覧履歴と好みに基づいて、パーソナライズされたレコメンデーションを提供します。新しいスターやコンテンツの発見をお手伝いします。',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildRecommendationContent(),
              ),
              const SizedBox(width: 30),
              Expanded(
                flex: 1,
                child: _buildAIPrivacySettings(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInterestBasedSection(),
        const SizedBox(height: 30),
        _buildRecentActivitySection(),
      ],
    );
  }

  Widget _buildInterestBasedSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '興味に基づくレコメンド',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'あなたの過去の視聴傾向から、以下のスターやコンテンツをおすすめします：',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            const Text(
              'おすすめのスター',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildRecommendedStarItem('田中シェフ', '料理家', 'https://picsum.photos/id/1005/100/100'),
                const SizedBox(width: 16),
                _buildRecommendedStarItem('山下ヒロシ', 'フードブロガー', 'https://picsum.photos/id/1012/100/100'),
                const SizedBox(width: 16),
                _buildRecommendedStarItem('鈴木アヤカ', '栄養士', 'https://picsum.photos/id/1027/100/100'),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'おすすめ商品',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '佐藤ユウタさんの最近の購入品に基づいたおすすめ:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildRecommendedProductItem('セラミックフライパン', '¥6,800', 'https://picsum.photos/id/26/100/100'),
                const SizedBox(width: 16),
                _buildRecommendedProductItem('スパイスセット', '¥3,200', 'https://picsum.photos/id/42/100/100'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedStarItem(String name, String category, String imageUrl) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            category,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: () {},
            child: const Text('フォロー'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedProductItem(String name, String price, String imageUrl) {
    return SizedBox(
      width: 150,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  height: 80,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.indigo,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('詳細'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'おすすめコンテンツ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'あなたの閲覧履歴に基づいたおすすめ:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            _buildContentRecommendationItem(
              'プロが教える包丁の使い方基礎講座',
              '佐藤ユウタ',
              '視聴率 98%マッチ',
            ),
            const SizedBox(height: 12),
            _buildContentRecommendationItem(
              '料理中に聴きたいクラシック集',
              '高橋ケンジ推薦',
              'マッチ度 95%',
            ),
            const SizedBox(height: 12),
            _buildContentRecommendationItem(
              '科学的に考える家庭料理の技術',
              '佐藤ユウタ愛読書',
              'マッチ度 92%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentRecommendationItem(String title, String source, String matchRate) {
    return Row(
      children: [
        const Icon(Icons.play_circle_filled, color: Colors.indigo),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    source,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      matchRate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAIPrivacySettings() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AIプライバシー設定',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'AIの学習に使用されるデータの範囲を設定できます。プライバシーを守りながら、パーソナライズされた体験を楽しみましょう。',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            _buildSettingItem('視聴履歴の分析', 'YouTube、Netflixなどの視聴データ', true),
            _buildSettingItem('音楽データの分析', 'Spotify、Apple Musicなどの再生データ', true),
            _buildSettingItem('購入履歴の分析', 'コンビニ、スーパー、ECサイトなどの購入データ', false),
            _buildSettingItem('アプリ使用状況の分析', 'スマホのアプリ使用時間、頻度など', false),
            _buildSettingItem('類似ユーザーとの比較分析', '似た嗜好を持つユーザーとの匿名比較', true),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                child: const Text('設定を保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeAndLoyaltySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'バッジと忠誠度システム',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'スターとのエンゲージメントに対して報酬を獲得しましょう。バッジを集めてステータスを上げ、特別な特典を得られます。',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildBadgesSection(),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: _buildLoyaltySection(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'バッジコレクション',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'スターとの活動に基づいてバッジを獲得できます。各バッジは特別な意味を持ち、あなたのプロフィールを豊かにします。',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            const Text(
              'あなたの獲得バッジ（8/24）',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBadgeItem('ファースト視聴', 'はじめてビデオを視聴', Colors.blue, Icons.play_circle_filled, true),
                _buildBadgeItem('コメンター', '10件のコメントを投稿', Colors.green, Icons.comment, true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoyaltySection() {
    // Implementation of _buildLoyaltySection
    return Container(); // Placeholder return, actual implementation needed
  }

  Widget _buildCommentManagementSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'コメント管理',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'スターはコメントを管理し、ファンとの交流を円滑に行うことができます。ファンはスターへの思いをコメントで伝えましょう。',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildCommentFeaturesSection(),
              ),
              const SizedBox(width: 30),
              Expanded(
                flex: 1,
                child: _buildCommentSettingsSection(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'コメント機能',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'スターとファンがより良いコミュニケーションを取るための様々な機能を提供しています。',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: _buildFeatureCard(
                        'リアルタイムコメント',
                        'ライブ配信中に即時反応できるコメント機能。スターはハイライトやピン留めができます。',
                        Icons.quickreply,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildFeatureCard(
                        'AI支援モデレーション',
                        '不適切なコメントを自動的に検出し、安全な環境を維持します。',
                        Icons.security,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildFeatureCard(
                        'コメント統計分析',
                        'スターは人気のコメントやトレンドを分析して、ファンの興味を把握できます。',
                        Icons.bar_chart,
                        Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildFeatureCard(
                        'プライオリティコメント',
                        'プレミアムメンバーのコメントは優先的に表示され、スターに届きやすくなります。',
                        Icons.priority_high,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        _buildCommentExampleSection(),
      ],
    );
  }

  Widget _buildCommentExampleSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'コメント例',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 20),
            _buildCommentItem(
              'https://picsum.photos/id/1005/50/50',
              '田中ハルカ',
              '最近の料理動画すごく参考になります！特に和食の出汁の取り方が勉強になりました。次回も楽しみにしています！',
              '2時間前',
              28,
              true,
            ),
            const Divider(),
            _buildCommentItem(
              'https://picsum.photos/id/1012/50/50',
              '佐藤リョウタ',
              '昨日のライブ配信で紹介されたキッチングッズを早速購入しました！使いやすくて大満足です。おすすめありがとうございます。',
              '4時間前',
              42,
              false,
            ),
            const Divider(),
            _buildCommentItem(
              'https://picsum.photos/id/1027/50/50',
              '山本アキラ',
              'スパイスの使い方講座をぜひ開催してください！インド料理に挑戦したいのですが、どのスパイスをどう組み合わせるか悩んでいます。',
              '昨日',
              15,
              false,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage('https://picsum.photos/id/1025/40/40'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'コメントを入力...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('送信'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(String avatarUrl, String name, String comment, String time, int likes, bool isPinned) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (comment == 'プレミアム')
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 12, color: Colors.amber.shade800),
                            const SizedBox(width: 2),
                            Text(
                              'プレミアム',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    if (isPinned)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        child: const Icon(Icons.push_pin, size: 14, color: Colors.indigo),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                if (comment != 'プレミアム')
                  Text(
                    comment,
                    style: const TextStyle(fontSize: 14),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite_border, size: 16),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      likes.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.reply, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text(
                      '返信',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSettingsSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'コメント設定',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'コメントの表示やフィルタリングの設定を行えます。',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 30),
            _buildSettingItem('コメント許可', '全ユーザー', true),
            _buildSettingItem('自動モデレーション', 'オン', true),
            _buildSettingItem('NGワードフィルター', 'カスタム', true),
            _buildSettingItem('返信通知', 'オン', true),
            _buildSettingItem('コメント承認', 'オフ', false),
            const SizedBox(height: 20),
            const Text(
              '優先コメント表示',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildPriorityToggle('プレミアムメンバー', true),
            _buildPriorityToggle('常連ファン', true),
            _buildPriorityToggle('新規ファン', false),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                child: const Text('設定を保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      color: Colors.indigo.shade900,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Starlist',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'ファンとスターをつなぐプラットフォーム。日常をシェアして、ファンとの絆を深めましょう。',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildSocialIcon(Icons.facebook),
                        const SizedBox(width: 16),
                        _buildSocialIcon(Icons.webhook),
                        const SizedBox(width: 16),
                        _buildSocialIcon(Icons.photo_camera),
                        const SizedBox(width: 16),
                        _buildSocialIcon(Icons.ondemand_video),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'サービス',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildFooterLink('スターになる'),
                    _buildFooterLink('ファン登録'),
                    _buildFooterLink('メンバーシップ'),
                    _buildFooterLink('データインポート'),
                    _buildFooterLink('ポイント交換'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'サポート',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildFooterLink('ヘルプセンター'),
                    _buildFooterLink('よくある質問'),
                    _buildFooterLink('お問い合わせ'),
                    _buildFooterLink('セキュリティ'),
                    _buildFooterLink('利用規約'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'リソース',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildFooterLink('スターガイド'),
                    _buildFooterLink('ファンガイド'),
                    _buildFooterLink('ブログ'),
                    _buildFooterLink('ニュース'),
                    _buildFooterLink('パートナー'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),
          const Divider(color: Colors.indigo),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '© 2023 Starlist. All rights reserved.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                ),
              ),
              Row(
                children: [
                  _buildFooterSmallLink('プライバシーポリシー'),
                  const SizedBox(width: 20),
                  _buildFooterSmallLink('Cookie設定'),
                  const SizedBox(width: 20),
                  _buildFooterSmallLink('アクセシビリティ'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(String title, String description, Color color, IconData icon, bool isAchieved) {
    return SizedBox(
      width: 90,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isAchieved ? color : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isAchieved ? Colors.white : Colors.grey.shade500,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isAchieved ? Colors.black87 : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            description,
            style: TextStyle(
              fontSize: 10,
              color: isAchieved ? Colors.black54 : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildFooterSmallLink(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.white60,
      ),
    );
  }
} 