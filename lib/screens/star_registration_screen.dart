import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:starlist_app/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class StarRegistrationScreen extends StatefulWidget {
  const StarRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<StarRegistrationScreen> createState() => _StarRegistrationScreenState();
}

class _StarRegistrationScreenState extends State<StarRegistrationScreen> {
  int _currentStep = 0;
  final TextEditingController _snsUrlController = TextEditingController();
  final TextEditingController _snsIdController = TextEditingController();
  final TextEditingController _followerCountController = TextEditingController();
  String? _selectedSNSPlatform;
  final bool _isProcessing = false;
  final double _processingProgress = 0.7; // デモのための仮の進捗

  final List<String> _stepTitles = [
    'Starlistへようこそ',
    'SNSアカウント連携',
    'アカウント認証中',
    '審査完了',
    '次のステップ'
  ];

  // SNSプラットフォームリスト
  final List<Map<String, dynamic>> _snsPlatforms = [
    {'name': 'YouTube', 'icon': FontAwesomeIcons.youtube, 'color': const Color(0xFFFF0000)},
    {'name': 'Instagram', 'icon': FontAwesomeIcons.instagram, 'color': const Color(0xFFC13584)},
    {'name': 'Twitter', 'icon': FontAwesomeIcons.twitter, 'color': const Color(0xFF1DA1F2)},
    {'name': 'TikTok', 'icon': FontAwesomeIcons.tiktok, 'color': Colors.black},
  ];

  @override
  void dispose() {
    _snsUrlController.dispose();
    _snsIdController.dispose();
    _followerCountController.dispose();
    super.dispose();
  }

  void _nextStep() {
    // デモ用に全てのバリデーションをスキップ
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
    }
    
    // 以下の元のバリデーションコードはデモのためコメントアウト
    /*
    // SNS認証ステップでの入力チェック
    if (_currentStep == 1) {
      // SNSプラットフォームの選択チェック
      if (_selectedSNSPlatform.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'SNSプラットフォームを選択してください',
              style: TextStyle(fontFamily: GoogleFonts.notoSans().fontFamily),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // SNS URL またはID のいずれかは入力必須
      if (_snsUrlController.text.isEmpty && _snsIdController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'SNS URLまたはIDを入力してください',
              style: TextStyle(fontFamily: GoogleFonts.notoSans().fontFamily),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // フォロワー数の入力チェック
      if (_followerCountController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'フォロワー数を入力してください',
              style: TextStyle(fontFamily: GoogleFonts.notoSans().fontFamily),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // フォロワー数の妥当性チェック
      try {
        final followerCount = int.parse(_followerCountController.text);
        if (followerCount < 1000) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'スター登録には1,000人以上のフォロワーが必要です',
                style: TextStyle(fontFamily: GoogleFonts.notoSans().fontFamily),
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '有効なフォロワー数を入力してください',
              style: TextStyle(fontFamily: GoogleFonts.notoSans().fontFamily),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
    }
    */
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  // SNSプラットフォームを選択した時の処理
  void _selectSNSPlatform(String platform) {
    setState(() {
      _selectedSNSPlatform = platform;
    });
  }

  bool _isPasswordValid(String password) {
    // 最低8文字、大文字小文字を含み、記号は任意
    return password.length >= 8 && 
           password.contains(RegExp(r'[A-Z]')) && 
           password.contains(RegExp(r'[a-z]')) && 
           password.contains(RegExp(r'[0-9]'));
    // 記号の要件を削除
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                // ステップインジケーター
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Container(
                        width: index == _currentStep ? 20 : 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: index == _currentStep ? AppTheme.primaryColor : const Color(0xFFD1D1D6),
                          borderRadius: BorderRadius.circular(index == _currentStep ? 5 : 5),
                        ),
                      );
                    }),
                  ),
                ),
                
                // メインコンテンツ
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildCurrentStep(),
                    ),
                  ),
                ),
                
                // iOSスタイルの下部インジケーター
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildSNSAuthStep();
      case 2:
        return _buildVerificationStep();
      case 3:
        return _buildApprovalStep();
      case 4:
        return _buildNextStepsStep();
      default:
        return _buildWelcomeStep();
    }
  }

  // ステップ1: ウェルカムページ
  Widget _buildWelcomeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ヘッダー
        Center(
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue.shade500,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Starlistへようこそ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.notoSans().fontFamily,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'あなたの日常をファンとつなげる新しい形',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontFamily: GoogleFonts.notoSans().fontFamily,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // スター登録条件
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'スター登録条件:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontFamily: GoogleFonts.notoSans().fontFamily,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'スターとして登録するには、いずれかのSNSプラットフォームで1,000人以上のフォロワーが必要です。',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: GoogleFonts.notoSans().fontFamily,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'フォロワー数に応じたスターランク:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  fontFamily: GoogleFonts.notoSans().fontFamily,
                ),
              ),
              const SizedBox(height: 8),
              // スターランクを横並びに
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildRankItem('レギュラー', '1,000〜9,999人')),
                  const SizedBox(width: 4),
                  Expanded(child: _buildRankItem('プラチナ', '1万〜9.9万人')),
                  const SizedBox(width: 4),
                  Expanded(child: _buildRankItem('スーパー', '10万人以上')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 次へボタン
        ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'スター登録を始める',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              fontFamily: GoogleFonts.notoSans().fontFamily,
            ),
          ),
        ),
      ],
    );
  }

  // スターランク項目
  Widget _buildRankItem(String rank, String followerRange) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 4.0, left: 4.0),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: rank == 'レギュラー' ? Colors.blue.shade100 :
                 rank == 'プラチナ' ? Colors.purple.shade100 : Colors.amber.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: rank == 'レギュラー' ? Colors.blue.shade500 :
                   rank == 'プラチナ' ? Colors.purple.shade500 : Colors.amber.shade500,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: rank == 'レギュラー' ? Colors.blue.shade500 :
                       rank == 'プラチナ' ? Colors.purple.shade500 : Colors.amber.shade500,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                rank,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.notoSans().fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              followerRange,
              style: TextStyle(
                fontSize: 10,
                fontFamily: GoogleFonts.notoSans().fontFamily,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ステップ2: SNSアカウント連携
  Widget _buildSNSAuthStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ヘッダー
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SNSアカウント連携',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.notoSans().fontFamily,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '本人確認のため、あなたのSNSアカウントを連携してください',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: GoogleFonts.notoSans().fontFamily,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
          ],
        ),
        const SizedBox(height: 16),

        // SNS選択
        Text(
          '認証に使用するSNSを選択:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            fontFamily: GoogleFonts.notoSans().fontFamily,
          ),
        ),
        const SizedBox(height: 12),
        
        // SNSボタン - 横並びレイアウトに変更
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _snsPlatforms.map((platform) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _buildSNSIconButton(
                  platform['name'],
                  platform['icon'],
                  platform['color'],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // アカウント情報の入力
        const Text(
          'アカウント情報の入力:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        
        // SNS URL入力フィールド
        TextField(
          controller: _snsUrlController,
          decoration: InputDecoration(
            labelText: 'SNSアカウントURL',
            hintText: 'https://www.youtube.com/c/yourchannelname',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: const Color(0xFFF2F2F7),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            errorStyle: TextStyle(
              color: Colors.red.shade700,
              fontFamily: GoogleFonts.notoSans().fontFamily,
            ),
          ),
          style: TextStyle(
            fontFamily: GoogleFonts.notoSans().fontFamily,
          ),
          onChanged: (value) {
            // 入力時に状態を更新して再描画を促す
            setState(() {});
          },
        ),
        const SizedBox(height: 12),
        
        // SNS ID入力フィールド
        TextField(
          controller: _snsIdController,
          decoration: InputDecoration(
            labelText: 'アカウントID（URLがない場合）',
            hintText: '@youraccountname',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: const Color(0xFFF2F2F7),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            errorStyle: TextStyle(
              color: Colors.red.shade700,
              fontFamily: GoogleFonts.notoSans().fontFamily,
            ),
          ),
          style: TextStyle(
            fontFamily: GoogleFonts.notoSans().fontFamily,
          ),
          onChanged: (value) {
            // 入力時に状態を更新して再描画を促す
            setState(() {});
          },
        ),
        const SizedBox(height: 12),

        // フォロワー数入力フィールド（追加）
        TextField(
          controller: _followerCountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'フォロワー数（自己申告）',
            hintText: '10000',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: const Color(0xFFF2F2F7),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixText: '人',
            errorStyle: TextStyle(
              color: Colors.red.shade700,
              fontFamily: GoogleFonts.notoSans().fontFamily,
            ),
          ),
          style: TextStyle(
            fontFamily: GoogleFonts.notoSans().fontFamily,
          ),
          onChanged: (value) {
            // 入力時に状態を更新して再描画を促す
            setState(() {});
          },
        ),
        const SizedBox(height: 24),

        // 認証プロセスについての説明
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '認証プロセスについて:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  fontFamily: GoogleFonts.notoSans().fontFamily,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '申請内容は運営チームによって確認されます。フォロワー数に応じて適切なスターランクが設定されます。',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: GoogleFonts.notoSans().fontFamily,
                ),
              ),
              const SizedBox(height: 8),
              _buildSmallCheckItem('フォロワー数の確認（1,000人以上必須）'),
              _buildSmallCheckItem('アカウントの真正性とアクティビティの確認'),
              _buildSmallCheckItem('申請後、数日以内に結果をご連絡します'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ボタン
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFE5E5EA)),
                  foregroundColor: Colors.grey.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  '戻る',
                  style: TextStyle(fontFamily: GoogleFonts.notoSans().fontFamily),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  '申請する',
                  style: TextStyle(
                    fontFamily: GoogleFonts.notoSans().fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // SNSアイコンボタン（小さく）
  Widget _buildSNSIconButton(String platform, IconData icon, Color color) {
    final isSelected = _selectedSNSPlatform == platform;
    
    return InkWell(
      onTap: () => _selectSNSPlatform(platform),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : const Color(0xFFE5E5EA),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? Colors.grey.shade100 : Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                platform,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontFamily: GoogleFonts.notoSans().fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ステップ3: 認証中
  Widget _buildVerificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ヘッダー
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'アカウント審査中',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.notoSans().fontFamily,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '運営チームがアカウントを確認しています',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: GoogleFonts.notoSans().fontFamily,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
          ],
        ),
        const SizedBox(height: 16),

        // 進捗バー
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '申請状況:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                fontFamily: GoogleFonts.notoSans().fontFamily,
              ),
            ),
            Text(
              '申請受付完了',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontFamily: GoogleFonts.notoSans().fontFamily,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 分析ステータス
        Column(
          children: [
            _buildStatusItem('申請情報の受付', 'completed', '完了'),
            _buildStatusItem('審査担当者への割り当て', 'completed', '完了'),
            _buildStatusItem('アカウント確認', 'processing', '処理中...'),
          ],
        ),
        const SizedBox(height: 24),

        // 申請中の登録案内
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'お知らせ:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '審査結果を待たずに、Starlistの機能を利用することができます。審査完了後にスター機能が有効になります。',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 待機メッセージ
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              '審査には数日かかる場合があります。\n結果はメールでお知らせします。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ボタン
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFE5E5EA)),
                  foregroundColor: Colors.grey.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('戻る'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('続けて登録する'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ステップ4: 審査完了
  Widget _buildApprovalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 承認アイコン
        Center(
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade500,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '審査完了',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'おめでとうございます！スター登録が承認されました',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 審査結果
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '審査結果:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              _buildResultItem('アカウントステータス:', '承認済み', isSuccess: true),
              _buildResultItem('スターランク:', 'プラチナ'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 注意事項
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.yellow.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '注意事項:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              _buildWarningItem('Starlistのコミュニティガイドラインを遵守してください'),
              _buildWarningItem('アカウントの真正性を維持するため、SNS連携を継続してください'),
              _buildWarningItem('定期的なコンテンツ投稿が推奨されます'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 次へボタン
        ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'プロフィール設定に進む',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  // ステップ5: 次のステップ
  Widget _buildNextStepsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ヘッダー
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '次のステップ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'スターとしての活動を始めましょう',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16),
            Divider(),
          ],
        ),
        const SizedBox(height: 16),

        // 次のステップリスト
        _buildNextStepItem(
          icon: Icons.person_outline,
          color: Colors.blue,
          title: 'プロフィールを設定する',
          description: 'プロフィール写真、自己紹介、興味のあるジャンルを設定しましょう',
        ),
        _buildNextStepItem(
          icon: Icons.camera_alt_outlined,
          color: Colors.purple,
          title: '最初の投稿を作成する',
          description: 'OCR機能を使って、お気に入りのコンテンツを共有しましょう',
        ),
        _buildNextStepItem(
          icon: Icons.attach_money_outlined,
          color: Colors.green,
          title: '会員プランを設定する',
          description: 'ファンに提供する特典と会員価格を設定しましょう',
        ),
        _buildNextStepItem(
          icon: Icons.share_outlined,
          color: Colors.red,
          title: 'SNSで告知する',
          description: '既存のSNSでStarlistを始めたことをファンに伝えましょう',
        ),
        const SizedBox(height: 24),

        // 初めての投稿のヒント
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '初めての投稿のヒント:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              _buildTipItem('最近見たYouTube動画のスクリーンショットをOCRで取り込んでみましょう'),
              _buildTipItem('お気に入りの音楽プレイリストを共有してみましょう'),
              _buildTipItem('最近購入したお気に入りの商品を紹介してみましょう'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ホーム画面へボタン
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'ホーム画面へ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  // ヘルパーウィジェット
  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.blue.shade500,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 14,
            color: Colors.green.shade600,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade800,
                fontFamily: GoogleFonts.notoSans().fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBlueCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check,
            color: Colors.blue.shade500,
            size: 14,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedItem(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blue.shade500,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String title, String status, String statusText) {
    final isCompleted = status == 'completed';
    final isProcessing = status == 'processing';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green.shade100 : 
                     isProcessing ? Colors.blue.shade100 : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                isCompleted ? Icons.check : 
                isProcessing ? Icons.sync : Icons.circle_outlined,
                size: 16,
                color: isCompleted ? Colors.green : 
                       isProcessing ? Colors.blue : Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    fontFamily: GoogleFonts.notoSans().fontFamily,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: isCompleted ? Colors.green.shade700 : 
                           isProcessing ? Colors.blue.shade700 : Colors.grey.shade600,
                    fontWeight: isProcessing ? FontWeight.w500 : FontWeight.normal,
                    fontFamily: GoogleFonts.notoSans().fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(String label, String value, {bool isSuccess = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSuccess ? Colors.green.shade600 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber.shade500,
            size: 14,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Colors.amber.shade500,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 