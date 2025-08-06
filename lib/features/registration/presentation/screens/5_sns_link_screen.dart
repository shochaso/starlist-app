import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:starlist/features/registration/application/sns_link_provider.dart';
import 'package:starlist/features/registration/presentation/widgets/registration_progress_indicator.dart';

class SnsLinkScreen extends ConsumerWidget {
  const SnsLinkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(snsLinkProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SNS連携'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: RegistrationProgressIndicator(currentStep: 5),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'SNS連携',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '活動しているSNSアカウントのURLやユーザー名を入力してください。ファンがあなたを見つけやすくなります。（任意）',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildSnsInput(
              icon: FontAwesomeIcons.xTwitter,
              hint: 'X (旧Twitter) のユーザー名 (@なし)',
              onChanged: notifier.updateX,
            ),
            const SizedBox(height: 16),
             _buildSnsInput(
              icon: FontAwesomeIcons.instagram,
              iconColor: Colors.pink,
              hint: 'Instagram のユーザー名',
              onChanged: notifier.updateInstagram,
            ),
            const SizedBox(height: 16),
             _buildSnsInput(
              icon: FontAwesomeIcons.youtube,
              iconColor: Colors.red,
              hint: 'YouTubeチャンネルのURL',
              onChanged: notifier.updateYoutube,
            ),
            const SizedBox(height: 16),
             _buildSnsInput(
              icon: FontAwesomeIcons.tiktok,
              hint: 'TikTok のユーザー名',
              onChanged: notifier.updateTiktok,
            ),
            const SizedBox(height: 16),
             _buildSnsInput(
              icon: FontAwesomeIcons.link,
              iconColor: Colors.grey,
              hint: 'その他のウェブサイトURL',
              onChanged: notifier.updateWebsite,
            ),
             const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '入力された情報はプロフィールに表示され、ファンがあなたの他の活動をフォローするのに役立ちます。',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => context.go('/terms'),
              child: const Text('次へ進む'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSnsInput({
    required IconData icon,
    required String hint,
    required void Function(String) onChanged,
    Color? iconColor,
  }) {
    return Row(
      children: [
        FaIcon(icon, color: iconColor, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
            ),
          ),
        ),
      ],
    );
  }
} 