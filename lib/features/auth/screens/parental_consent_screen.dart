import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/parental_consent_service.dart';
import '../../../models/parental_consent.dart';
import '../../../widgets/loading_overlay.dart';

/// 親権者同意フロー画面
class ParentalConsentScreen extends ConsumerStatefulWidget {
  final String userId;
  final String minorName;

  const ParentalConsentScreen({
    super.key,
    required this.userId,
    required this.minorName,
  });

  @override
  ConsumerState<ParentalConsentScreen> createState() => _ParentalConsentScreenState();
}

class _ParentalConsentScreenState extends ConsumerState<ParentalConsentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _parentNameController = TextEditingController();
  final _parentEmailController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _parentAddressController = TextEditingController();
  
  String _selectedRelationship = '母';
  PlatformFile? _consentDocument;
  bool _isSubmitting = false;
  bool _documentUploaded = false;

  final List<String> _relationships = ['父', '母', '法定後見人', 'その他'];

  @override
  void dispose() {
    _parentNameController.dispose();
    _parentEmailController.dispose();
    _parentPhoneController.dispose();
    _parentAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('親権者同意手続き'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: LoadingOverlay(
        isLoading: _isSubmitting,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIntroSection(),
                const SizedBox(height: 30),
                _buildParentInfoSection(),
                const SizedBox(height: 30),
                _buildConsentDocumentSection(),
                const SizedBox(height: 30),
                _buildEKYCSection(),
                const SizedBox(height: 40),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 説明セクション
  Widget _buildIntroSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600]),
              const SizedBox(width: 8),
              Text(
                '未成年者の登録について',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.minorName}様は18歳未満のため、Starlistへの登録には親権者の同意が必要です。',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          const Text(
            '以下の手順で親権者同意の手続きを行ってください：',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildStepList(),
        ],
      ),
    );
  }

  /// 手順リスト
  Widget _buildStepList() {
    final steps = [
      '親権者の基本情報を入力',
      '親権者同意書をダウンロード・印刷',
      '親権者による署名・捺印',
      '同意書をアップロード',
      '親権者本人のeKYC認証（推奨）',
    ];

    return Column(
      children: steps.map((step) {
        final index = steps.indexOf(step) + 1;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 親権者情報セクション
  Widget _buildParentInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. 親権者情報',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // 続柄選択
        DropdownButtonFormField<String>(
          initialValue: _selectedRelationship,
          decoration: const InputDecoration(
            labelText: '続柄 *',
            border: OutlineInputBorder(),
          ),
          items: _relationships.map((relationship) {
            return DropdownMenuItem(
              value: relationship,
              child: Text(relationship),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedRelationship = value!;
            });
          },
        ),
        const SizedBox(height: 16),
        
        // 親権者氏名
        TextFormField(
          controller: _parentNameController,
          decoration: const InputDecoration(
            labelText: '親権者氏名 *',
            hintText: '例: 山田 太郎',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '親権者氏名を入力してください';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // メールアドレス
        TextFormField(
          controller: _parentEmailController,
          decoration: const InputDecoration(
            labelText: 'メールアドレス *',
            hintText: '例: parent@example.com',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'メールアドレスを入力してください';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return '正しいメールアドレスを入力してください';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // 電話番号
        TextFormField(
          controller: _parentPhoneController,
          decoration: const InputDecoration(
            labelText: '電話番号',
            hintText: '例: 090-1234-5678',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        
        // 住所
        TextFormField(
          controller: _parentAddressController,
          decoration: const InputDecoration(
            labelText: '住所 *',
            hintText: '例: 東京都渋谷区...',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '住所を入力してください';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 同意書セクション
  Widget _buildConsentDocumentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. 親権者同意書',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '親権者同意書のダウンロードと提出',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              const Text(
                '以下のボタンから親権者同意書をダウンロードし、親権者による署名・捺印を行った後、アップロードしてください。',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              
              // ダウンロードボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _downloadConsentForm,
                  icon: const Icon(Icons.download),
                  label: const Text('親権者同意書をダウンロード'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // アップロードエリア
              GestureDetector(
                onTap: _pickConsentDocument,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _documentUploaded ? Colors.green : Colors.grey[400]!,
                      style: BorderStyle.dashed,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: _documentUploaded ? Colors.green[50] : Colors.grey[50],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _documentUploaded ? Icons.check_circle : Icons.cloud_upload,
                        size: 40,
                        color: _documentUploaded ? Colors.green : Colors.grey[600],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _documentUploaded 
                          ? '同意書がアップロードされました'
                          : '署名済み同意書をアップロード',
                        style: TextStyle(
                          fontSize: 14,
                          color: _documentUploaded ? Colors.green[700] : Colors.grey[600],
                          fontWeight: _documentUploaded ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (_consentDocument != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _consentDocument!.name,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// eKYCセクション
  Widget _buildEKYCSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '3. 親権者本人確認（推奨）',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            border: Border.all(color: Colors.amber[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_user, color: Colors.amber[700]),
                  const SizedBox(width: 8),
                  Text(
                    'より確実な本人確認のために',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                '親権者による本人確認（eKYC）を行うことで、より迅速に審査を完了できます。同意書提出後に、親権者にeKYC認証のご案内をお送りします。',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 提出ボタン
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _canSubmit() ? _submitParentalConsent : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          '親権者同意情報を提出',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// 提出可能かチェック
  bool _canSubmit() {
    return !_isSubmitting && 
           _parentNameController.text.isNotEmpty &&
           _parentEmailController.text.isNotEmpty &&
           _parentAddressController.text.isNotEmpty &&
           _documentUploaded;
  }

  /// 同意書ダウンロード
  Future<void> _downloadConsentForm() async {
    const url = 'https://starlist.com/documents/parental_consent_form.pdf';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      _showErrorSnackBar('同意書のダウンロードに失敗しました');
    }
  }

  /// 同意書ファイル選択
  Future<void> _pickConsentDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _consentDocument = result.files.first;
          _documentUploaded = true;
        });
      }
    } catch (e) {
      _showErrorSnackBar('ファイルの選択に失敗しました');
    }
  }

  /// 親権者同意情報を提出
  Future<void> _submitParentalConsent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final parentalConsent = ParentalConsentRequest(
        userId: widget.userId,
        parentFullName: _parentNameController.text.trim(),
        parentEmail: _parentEmailController.text.trim(),
        parentPhone: _parentPhoneController.text.trim(),
        parentAddress: _parentAddressController.text.trim(),
        relationshipToMinor: _selectedRelationship,
        consentDocument: _consentDocument,
      );

      final result = await ParentalConsentService.submitParentalConsent(parentalConsent);

      if (result.success) {
        _showSuccessDialog();
      } else {
        _showErrorSnackBar(result.error ?? '提出に失敗しました');
      }
    } catch (e) {
      _showErrorSnackBar('エラーが発生しました: ${e.toString()}');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
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
            Text('提出完了'),
          ],
        ),
        content: const Text(
          '親権者同意情報を提出しました。\n\n'
          '運営による確認後、親権者へeKYC認証のご案内をお送りします。'
          'メールをご確認ください。',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // 前の画面に戻る
            },
            child: const Text('確認'),
          ),
        ],
      ),
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