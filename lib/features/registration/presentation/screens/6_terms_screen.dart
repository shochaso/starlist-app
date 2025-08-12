import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:starlist/features/registration/application/terms_provider.dart';
import 'package:starlist/features/registration/presentation/widgets/registration_progress_indicator.dart';
import 'package:starlist/features/registration/application/registration_provider.dart';

class TermsScreen extends ConsumerWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(termsProvider);
    final notifier = ref.read(termsProvider.notifier);
    final registrationState = ref.watch(registrationProvider);

    ref.listen<AsyncValue<void>>(registrationProvider, (_, next) {
      next.when(
        data: (_) {
          // On success, navigate to the complete screen
          context.go('/registration-complete');
        },
        error: (err, stack) {
          // On error, show a snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('登録に失敗しました: ${err.toString()}')),
          );
        },
        loading: () {
          // Do nothing while loading, UI is handled by the button state
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('利用規約'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/sns-link');
            }
          },
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: RegistrationProgressIndicator(currentStep: 6),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '利用規約とプライバシーポリシー',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'スターとして活動を開始する前に、特に重要な点をご確認ください。',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildTermsSummary(context),
            const SizedBox(height: 16),
            _buildCheckbox(
              title: 'スター利用規約に同意します',
              value: state.termsAccepted,
              onChanged: (val) => notifier.setTermsAccepted(val ?? false),
            ),
            _buildCheckbox(
              title: 'プライバシーポリシーに同意します',
              value: state.privacyAccepted,
              onChanged: (val) => notifier.setPrivacyAccepted(val ?? false),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: state.isFormValid && !registrationState.isLoading
                  ? () => ref.read(registrationProvider.notifier).submitRegistration()
                  : null,
              child: registrationState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('同意してスターアカウントを作成'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('スター活動における主な規約', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _buildSummaryItem(FontAwesomeIcons.copyright, 'コンテンツの権利と責任:', 'あなたが共有する全てのデータに関する著作権や肖像権は、あなた自身の責任で管理・許諾を得てください。'),
          _buildSummaryItem(FontAwesomeIcons.userSlash, '禁止事項:', '誹謗中傷、差別的発言、虚偽の情報、第三者のプライバシーを侵害するコンテンツの共有は固く禁止します。'),
          _buildSummaryItem(FontAwesomeIcons.building, '事務所との関係:', '芸能事務所等に所属している場合、本サービスの利用が所属先の契約に違反しないことを確認し、必要な許可を得た上でご登録ください。'),
          _buildSummaryItem(FontAwesomeIcons.yenSign, '収益と支払い:', 'ファンからのサブスクリプション等の収益は、所定の手数料を差し引いた後、指定された方法で支払われます。'),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: RichText(
              text: TextSpan(
                text: '利用規約の全文を読む ',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blue),
                recognizer: TapGestureRecognizer()..onTap = () { /* TODO: Launch URL */ },
                children: const [
                   WidgetSpan(child: FaIcon(FontAwesomeIcons.externalLinkAlt, size: 14, color: Colors.blue)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(icon, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4),
                children: [
                  TextSpan(text: '$title ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: content),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox({required String title, required bool value, required ValueChanged<bool?> onChanged}) {
    return CheckboxListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
} 