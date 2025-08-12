import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TwoFactorSetupScreen extends ConsumerStatefulWidget {
  const TwoFactorSetupScreen({super.key});

  @override
  ConsumerState<TwoFactorSetupScreen> createState() => _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends ConsumerState<TwoFactorSetupScreen> {
  String _secret = '';
  String _otpauthUrl = '';
  final TextEditingController _codeCtrl = TextEditingController();
  bool _isEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() => _isLoading = true);
    try {
      // サーバーから状態とシークレット取得（なければ発行）
      // Edge FunctionやRPCを用意するのが安全。ここではUIのみ用意。
      // TODO: integrate with Supabase Edge Function
      _secret = 'JBSWY3DPEHPK3PXP';
      _otpauthUrl = 'otpauth://totp/Starlist:${Uri.encodeComponent('user@example.com')}?secret=$_secret&issuer=${Uri.encodeComponent('Starlist')}&algorithm=SHA1&digits=6&period=30';
      _isEnabled = false;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('二段階認証')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('セキュリティ強化', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    '認証アプリ（Google Authenticator等）でQRコードをスキャンし、表示された6桁コードを入力して有効化してください。',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: QrImageView(
                        data: _otpauthUrl,
                        size: 200,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SelectableText('手動入力用シークレット: $_secret', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _codeCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: '6桁コード',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyAndEnable,
                      child: Text(_isEnabled ? '無効化' : '有効化'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _verifyAndEnable() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Edge FunctionでTOTP検証(サーバ検証)し、有効化/無効化フラグを保存
      // ここではUIの反映のみ
      _isEnabled = !_isEnabled;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEnabled ? '二段階認証が有効になりました' : '二段階認証を無効にしました'),
          backgroundColor: _isEnabled ? Colors.green : Colors.orange,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
} 