import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/agency_terms_agreement.dart';
import '../../application/providers/terms_agreement_provider.dart';
import '../../../core/presentation/widgets/loading_overlay.dart';
import '../../../core/presentation/widgets/custom_button.dart';

/// 事務所利用規約同意画面
class TermsAgreementScreen extends ConsumerStatefulWidget {
  final String userId;
  final String userName;

  const TermsAgreementScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  ConsumerState<TermsAgreementScreen> createState() => _TermsAgreementScreenState();
}

class _TermsAgreementScreenState extends ConsumerState<TermsAgreementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _agencyNameController = TextEditingController();
  final _agencyEmailController = TextEditingController();
  final _agencyPhoneController = TextEditingController();
  
  bool _individualResponsibilityAcknowledged = false;
  bool _platformTermsAgreed = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _agencyNameController.dispose();
    _agencyEmailController.dispose();
    _agencyPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final termsState = ref.watch(termsAgreementProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('事務所利用規約への同意'),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // 戻るボタンを無効化
      ),
      body: LoadingOverlay(
        isLoading: _isSubmitting || termsState.isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(),
                const SizedBox(height: 30),
                _buildAgencyInfoSection(),
                const SizedBox(height: 30),
                _buildTermsContentSection(),
                const SizedBox(height: 30),
                _buildAgreementCheckboxes(),
                const SizedBox(height: 40),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ウェルカムセクション
  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[50]!, Colors.blue[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars, color: Colors.indigo[600], size: 28),
              const SizedBox(width: 12),
              Text(
                'Starlistへようこそ！',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${widget.userName}様、スター登録を開始します。',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          const Text(
            'まず、事務所に所属されている方の利用規約への同意が必要です。個人での活動の場合は「個人」とご記入ください。',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// 事務所情報セクション
  Widget _buildAgencyInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '事務所情報',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // 事務所名
        TextFormField(
          controller: _agencyNameController,
          decoration: const InputDecoration(
            labelText: '事務所名 *',
            hintText: '例: ○○エンタテインメント / 個人',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.business),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '事務所名を入力してください（個人の場合は「個人」と入力）';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // 事務所連絡先メール
        TextFormField(
          controller: _agencyEmailController,
          decoration: const InputDecoration(
            labelText: '事務所連絡先メールアドレス',
            hintText: '例: contact@agency.com',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return '正しいメールアドレスを入力してください';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // 事務所電話番号
        TextFormField(
          controller: _agencyPhoneController,
          decoration: const InputDecoration(
            labelText: '事務所電話番号',
            hintText: '例: 03-1234-5678',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  /// 利用規約内容セクション
  Widget _buildTermsContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '事務所所属スターの利用規約',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const SingleChildScrollView(
            child: Text(
              '''
【事務所所属スターの利用規約】

第1条（適用範囲）
本規約は、事務所に所属するスターがStarlistプラットフォームを利用する際の条件を定めます。

第2条（事務所の責任と個人の責任）
1. スターは、所属事務所の許諾を得てStarlistを利用することとします。
2. Starlistの利用に関する責任は、スター個人が負うものとします。
3. 事務所は、スターのStarlist利用について直接的な責任を負いません。

第3条（コンテンツと収益）
1. スターが投稿するコンテンツの著作権は、事務所との契約に従います。
2. Starlist上での収益配分は、スターと事務所間の契約に基づきます。
3. Starlistは、スターと事務所間の契約内容に関与しません。

第4条（禁止事項）
1. 事務所の許可なく、事務所の機密情報を投稿すること
2. 事務所の名誉を毀損する行為
3. その他、事務所との契約に違反する行為

第5条（個人情報の取扱い）
Starlistは、スターの個人情報を適切に管理し、事務所への無断提供は行いません。

第6条（免責事項）
Starlistは、スターと事務所間のトラブルについて責任を負いません。

第7条（規約の変更）
本規約は、法令の変更等により変更される場合があります。

以上の内容に同意いただける場合のみ、Starlistをご利用いただけます。
              ''',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  /// 同意チェックボックス
  Widget _buildAgreementCheckboxes() {
    return Column(
      children: [
        // 個人責任の確認
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange[600]),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '重要：個人責任に関する確認',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _individualResponsibilityAcknowledged,
                onChanged: (value) {
                  setState(() {
                    _individualResponsibilityAcknowledged = value ?? false;
                  });
                },
                title: const Text(
                  'Starlistの利用は個人の責任において行い、事務所は直接的な責任を負わないことを理解しました',
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: const Text(
                  '※事務所との間で別途契約がある場合は、その契約内容が優先されます',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // プラットフォーム規約同意
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: CheckboxListTile(
            value: _platformTermsAgreed,
            onChanged: (value) {
              setState(() {
                _platformTermsAgreed = value ?? false;
              });
            },
            title: const Text(
              '上記の事務所利用規約およびStarlistの利用規約に同意します',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  /// 送信ボタン
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: '同意して次のステップへ',
        onPressed: _canSubmit() ? _submitAgreement : null,
        isLoading: _isSubmitting,
        icon: Icons.arrow_forward,
      ),
    );
  }

  /// 送信可能かチェック
  bool _canSubmit() {
    return !_isSubmitting &&
           _agencyNameController.text.isNotEmpty &&
           _individualResponsibilityAcknowledged &&
           _platformTermsAgreed;
  }

  /// 規約同意を送信
  Future<void> _submitAgreement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final agreement = AgencyTermsAgreement(
        userId: widget.userId,
        agencyName: _agencyNameController.text.trim(),
        agencyContactEmail: _agencyEmailController.text.trim().isEmpty 
            ? null 
            : _agencyEmailController.text.trim(),
        agencyContactPhone: _agencyPhoneController.text.trim().isEmpty 
            ? null 
            : _agencyPhoneController.text.trim(),
        individualResponsibilityAcknowledged: _individualResponsibilityAcknowledged,
        platformTermsVersion: '1.0.0',
        agreementIpAddress: null, // 実装時はクライアントIPを取得
        agreementUserAgent: null, // 実装時はUser-Agentを取得
      );

      final result = await ref.read(termsAgreementProvider.notifier)
          .submitAgreement(agreement);

      if (result.isSuccess) {
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        if (mounted) {
          _showErrorSnackBar(result.error ?? '送信に失敗しました');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('エラーが発生しました: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// 成功ダイアログ
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('同意完了'),
          ],
        ),
        content: const Text(
          '事務所利用規約への同意が完了しました。\n\n'
          '次に、本人確認（eKYC）を実施します。'
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToNextStep();
            },
            child: const Text('本人確認へ進む'),
          ),
        ],
      ),
    );
  }

  /// 次のステップに遷移
  void _navigateToNextStep() {
    // eKYC画面に遷移（実装予定）
    Navigator.of(context).pushReplacementNamed(
      '/ekyc-start',
      arguments: {
        'userId': widget.userId,
        'userName': widget.userName,
      },
    );
  }

  /// エラースナックバー
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
} 