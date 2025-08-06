import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class RegistrationCompleteScreen extends StatefulWidget {
  const RegistrationCompleteScreen({super.key});

  @override
  State<RegistrationCompleteScreen> createState() => _RegistrationCompleteScreenState();
}

class _RegistrationCompleteScreenState extends State<RegistrationCompleteScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.green.withOpacity(0.1),
                    child: const Icon(FontAwesomeIcons.solidCheckCircle, color: Colors.green, size: 50),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'ようこそ、Starlistへ！',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'スターアカウントの作成が完了しました。\nあなたの輝かしい活動を応援しています。',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.5),
                  ),
                  const Spacer(flex: 1),
                  Container(
                     padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('次のステップ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _buildNextStepItem(context, icon: FontAwesomeIcons.wallet, text: '収益の振込先口座を登録する'),
                        _buildNextStepItem(context, icon: FontAwesomeIcons.bullhorn, text: 'ファンに向けて最初の投稿をする'),
                        _buildNextStepItem(context, icon: FontAwesomeIcons.solidCalendarAlt, text: '活動スケジュールを登録する'),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to the main dashboard
                      context.go('/');
                    },
                    child: const Text('管理画面に進む'),
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 30,
            gravity: 0.05,
            emissionFrequency: 0.05,
             colors: const [
              Colors.green, Colors.blue, Colors.pink,
              Colors.orange, Colors.purple, Colors.yellow
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextStepItem(BuildContext context, {required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          FaIcon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 16),
          Text(text, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
} 