import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:starlist_app/theme/app_theme.dart';

class FanRegisterScreen extends StatefulWidget {
  const FanRegisterScreen({Key? key}) : super(key: key);

  @override
  State<FanRegisterScreen> createState() => _FanRegisterScreenState();
}

class _FanRegisterScreenState extends State<FanRegisterScreen> {
  // ステップ管理
  int _currentStep = 0;
  final _totalSteps = 5;

  // フォームコントローラー
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // 同意フラグ
  bool _termsAccepted = false;
  bool _privacyPolicyAccepted = false;
  bool _receiveNotifications = false;

  // 年齢選択
  String? _selectedAgeGroup;
  final List<String> _ageGroups = ['10代', '20代', '30代', '40代', '50代', '60代', '70代+', '回答しない'];

  // SNS選択
  final Map<String, bool> _selectedSnsServices = {
    'X': false,
    'Facebook': false,
    'BeReal': false,
    'Threads': false,
  };

  final Map<String, bool> _selectedVideoServices = {
    'YouTube': false,
    'Instagram': false,
    'TikTok': false,
    'Twitch': false,
    'ツイキャス': false,
    'ふわっち': false,
    'Palmu': false,
    'TwitCasting': false,
    'SHOWROOM': false,
    '17LIVE': false,
    'ニコニコ': false,
    'LINE LIVE': false,
    'Mildom': false,
    'OPENREC': false,
    'Mirrativ': false,
    'REALITY': false,
    'IRIAM': false,
    'BIGO LIVE': false,
    'Spoon': false,
    'Pococha': false,
    'TangoMe': false,
  };

  int get _selectedServicesCount {
    return _selectedSnsServices.values.where((selected) => selected).length +
        _selectedVideoServices.values.where((selected) => selected).length;
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ステップインジケーター
                    Row(
                      children: List.generate(
                        _totalSteps,
                        (index) => Expanded(
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: index <= _currentStep ? AppTheme.primaryColor : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // ステップタイトル
                    Text(
                      'アカウント作成',
                      style: GoogleFonts.mPlusRounded1c(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ステップ ${_currentStep + 1}/$_totalSteps',
                      style: GoogleFonts.mPlusRounded1c(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // 現在のステップの内容
                    _buildCurrentStep(),
                    
                    const SizedBox(height: 32),
                    
                    // ナビゲーションボタン
                    _buildNavigationButtons(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildAgeVerificationStep();
      case 2:
        return _buildTermsStep();
      case 3:
        return _buildServicesSelectionStep();
      case 4:
        return _buildCompletionStep();
      default:
        return _buildBasicInfoStep();
    }
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: _prevStep,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                '戻る',
                style: GoogleFonts.mPlusRounded1c(),
              ),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _getNextButtonAction(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _currentStep == _totalSteps - 1 ? 'ホームに進む' : '次へ',
              style: GoogleFonts.mPlusRounded1c(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  VoidCallback? _getNextButtonAction() {
    if (_currentStep == 0) {
      // 基本情報ステップ - デモモードのためにバリデーションを無効化
      return _nextStep;
    } else if (_currentStep == 1) {
      // 年齢確認ステップ - デモモードのためにバリデーションを無効化 
      return _nextStep;
    } else if (_currentStep == 2) {
      // 利用規約ステップ - デモモードのためにバリデーションを無効化
      return _nextStep;
    } else if (_currentStep == 3) {
      // サービス選択ステップ
      return _nextStep;
    } else if (_currentStep == 4) {
      // 完了ステップ
      return () {
        // TODO: 実際のホーム画面への遷移
        Navigator.pushReplacementNamed(context, '/home');
      };
    }
    return _nextStep;
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '基本情報を入力',
          style: GoogleFonts.mPlusRounded1c(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Starlistアカウントを作成するために必要な情報を入力してください。',
          style: GoogleFonts.mPlusRounded1c(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 24),
        
        // 入力フォーム
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: 'ユーザー名',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 16),
        
        TextField(
          controller: _displayNameController,
          decoration: InputDecoration(
            labelText: '表示名',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 16),
        
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'メールアドレス',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 16),
        
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'パスワード',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 16),
        
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'パスワード（確認）',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 24),
        
        // 通知設定
        CheckboxListTile(
          title: Text(
            'Starlistからのお知らせやキャンペーン情報を受け取る',
            style: GoogleFonts.mPlusRounded1c(
              fontSize: 14,
            ),
          ),
          value: _receiveNotifications,
          onChanged: (value) {
            setState(() {
              _receiveNotifications = value ?? false;
            });
          },
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
        ),
        const SizedBox(height: 16),
        
        // ログインリンク
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'すでにアカウントをお持ちですか？',
              style: GoogleFonts.mPlusRounded1c(
                color: Colors.grey.shade600,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text(
                'ログイン',
                style: GoogleFonts.mPlusRounded1c(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAgeVerificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '年齢確認',
          style: GoogleFonts.mPlusRounded1c(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'あなたの年齢層を教えてください。より良いコンテンツをお届けするために使用されます。',
          style: GoogleFonts.mPlusRounded1c(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 32),
        
        // 年齢選択
        ..._ageGroups.map((age) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedAgeGroup = age;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedAgeGroup == age 
                      ? AppTheme.primaryColor 
                      : Colors.grey.shade300,
                  width: _selectedAgeGroup == age ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: _selectedAgeGroup == age 
                    ? AppTheme.primaryColor.withOpacity(0.05) 
                    : Colors.white,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      age,
                      style: GoogleFonts.mPlusRounded1c(
                        fontWeight: _selectedAgeGroup == age 
                            ? FontWeight.bold 
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (_selectedAgeGroup == age)
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.primaryColor,
                    ),
                ],
              ),
            ),
          ),
        )).toList(),
        
        const SizedBox(height: 24),
        
        // 注記
        Text(
          '※年齢情報は個人を特定するために使用されることはありません。',
          style: GoogleFonts.mPlusRounded1c(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '※あなたに合ったコンテンツの推奨やサービス改善のために活用されます。',
          style: GoogleFonts.mPlusRounded1c(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildTermsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '利用規約と個人情報保護方針',
          style: GoogleFonts.mPlusRounded1c(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '続行する前に、下記の規約をご確認ください。',
          style: GoogleFonts.mPlusRounded1c(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 24),
        
        // 利用規約
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Starlist利用規約',
                style: GoogleFonts.mPlusRounded1c(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '最終更新日: 2024年8月1日',
                style: GoogleFonts.mPlusRounded1c(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                '1. はじめに',
                style: GoogleFonts.mPlusRounded1c(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Starlist（以下「本サービス」）をご利用いただきありがとうございます。本利用規約（以下「本規約」）は、ユーザーと当社との間の法的合意を構成し、本サービスの利用に適用されます。',
                style: GoogleFonts.mPlusRounded1c(
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                '2. アカウント',
                style: GoogleFonts.mPlusRounded1c(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '本サービスを利用するには、アカウントの作成が必要です。アカウント情報の保護はユーザーの責任となります。',
                style: GoogleFonts.mPlusRounded1c(
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                '3. プライバシー',
                style: GoogleFonts.mPlusRounded1c(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '当社のプライバシーポリシーは、本サービスの利用に伴い当社が収集するデータとその使用方法について説明しています。',
                style: GoogleFonts.mPlusRounded1c(
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // 同意チェックボックス
        CheckboxListTile(
          title: Text(
            '利用規約に同意します',
            style: GoogleFonts.mPlusRounded1c(
              fontSize: 14,
            ),
          ),
          value: _termsAccepted,
          onChanged: (value) {
            setState(() {
              _termsAccepted = value ?? false;
            });
          },
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
        ),
        
        CheckboxListTile(
          title: Text(
            '個人情報保護方針に同意します',
            style: GoogleFonts.mPlusRounded1c(
              fontSize: 14,
            ),
          ),
          value: _privacyPolicyAccepted,
          onChanged: (value) {
            setState(() {
              _privacyPolicyAccepted = value ?? false;
            });
          },
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
        ),
      ],
    );
  }

  Widget _buildServicesSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '普段利用するサービス',
          style: GoogleFonts.mPlusRounded1c(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '普段利用するSNSや配信サイトを選択してください。連携機能の向上に役立ちます。',
          style: GoogleFonts.mPlusRounded1c(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 24),
        
        // SNSサービス
        Text(
          'SNS',
          style: GoogleFonts.mPlusRounded1c(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _selectedSnsServices.entries.map((entry) {
            return _buildServiceChip(
              label: entry.key,
              selected: entry.value,
              onSelected: (selected) {
                setState(() {
                  _selectedSnsServices[entry.key] = selected;
                });
              },
            );
          }).toList(),
        ),
        
        const SizedBox(height: 24),
        
        // 動画/配信サイト
        Text(
          '動画/配信サイト',
          style: GoogleFonts.mPlusRounded1c(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _selectedVideoServices.entries.map((entry) {
            return _buildServiceChip(
              label: entry.key,
              selected: entry.value,
              onSelected: (selected) {
                setState(() {
                  _selectedVideoServices[entry.key] = selected;
                });
              },
            );
          }).toList(),
        ),
        
        const SizedBox(height: 24),
        
        // 選択数
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$_selectedServicesCount個選択中',
              style: GoogleFonts.mPlusRounded1c(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 64,
        ),
        const SizedBox(height: 16),
        Text(
          'アカウント設定完了!',
          style: GoogleFonts.mPlusRounded1c(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Starlistへようこそ',
          style: GoogleFonts.mPlusRounded1c(
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'あなたの好みに基づいたコンテンツをホーム画面に表示しています。ぜひチェックしてみてください。',
          textAlign: TextAlign.center,
          style: GoogleFonts.mPlusRounded1c(
          ),
        ),
        const SizedBox(height: 24),
        
        // 次のステップ
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '次のステップ',
                style: GoogleFonts.mPlusRounded1c(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildNextStepItem('プロフィールを完成させる'),
              _buildNextStepItem('好きなスターをフォローする'),
              _buildNextStepItem('通知設定を確認する'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.mPlusRounded1c(
          color: selected ? Colors.white : Colors.black87,
        ),
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Colors.grey.shade100,
      selectedColor: AppTheme.primaryColor,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
  
  Widget _buildNextStepItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.mPlusRounded1c(),
          ),
        ],
      ),
    );
  }
} 