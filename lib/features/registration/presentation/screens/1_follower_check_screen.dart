import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:starlist_app/features/registration/application/follower_check_provider.dart';
import 'package:starlist_app/features/registration/presentation/widgets/registration_progress_indicator.dart';

class FollowerCheckScreen extends ConsumerStatefulWidget {
  const FollowerCheckScreen({super.key});

  @override
  ConsumerState<FollowerCheckScreen> createState() => _FollowerCheckScreenState();
}

class _FollowerCheckScreenState extends ConsumerState<FollowerCheckScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step), halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep), halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(followerCheckProvider);
    final notifier = ref.read(followerCheckProvider.notifier);

    ref.listen<FollowerCheckState>(followerCheckProvider, (previous, next) {
      if (next.isTierJustReached) {
        _confettiController.play();
        // Reset the flag after animation
        Future.delayed(const Duration(seconds: 2), () {
          notifier.confettiAnimationCompleted();
        });
      }
    });

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('スター登録'),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: RegistrationProgressIndicator(currentStep: 1),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'あなたの総フォロワー数を教えてください',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Starlistでは、ファンの総数に応じて特別なランクをご用意しています。複数のSNSで活動している場合は、その合計値を入力してください。',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _FollowerCounter(
                  totalFollowers: state.totalFollowers,
                  tierColor: state.tierColor,
                  reachedTier: state.reachedTier,
                ),
                const SizedBox(height: 8),
                Text(
                  state.feedbackMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: state.tierColor,
                  ),
                ),
                const SizedBox(height: 24),
                _SnsInputGrid(),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: state.totalFollowers >= 1000
                      ? () => context.go('/basic-info')
                      : null,
                  child: const Text('次へ進む'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          numberOfParticles: 50, // Increase particle count
          gravity: 0.1, // Slower fall
          emissionFrequency: 0.05,
          colors: const [
            Colors.green, Colors.blue, Colors.pink,
            Colors.orange, Colors.purple, Colors.yellow
          ],
          createParticlePath: drawStar,
        ),
      ],
    );
  }
}

class _FollowerCounter extends StatelessWidget {
  final int totalFollowers;
  final int reachedTier;
  final Color tierColor;

  const _FollowerCounter({
    required this.totalFollowers,
    required this.reachedTier,
    required this.tierColor,
  });

  @override
  Widget build(BuildContext context) {
    final progress = min(totalFollowers / 1000, 1.0);
    
    return Column(
      children: [
        const Text('合計フォロワー数', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Text(
            totalFollowers.toString(),
            key: ValueKey<int>(totalFollowers),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: tierColor,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 10,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: double.infinity,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: reachedTier < 1000000 ? tierColor : null,
                   gradient: reachedTier >= 1000000
                      ? const LinearGradient(colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple])
                      : null,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SnsInputGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 3.5,
      children: [
        _SnsInputField(snsType: SnsType.x, icon: FontAwesomeIcons.xTwitter),
        _SnsInputField(snsType: SnsType.instagram, icon: FontAwesomeIcons.instagram, iconColor: Colors.pink),
        _SnsInputField(snsType: SnsType.youtube, icon: FontAwesomeIcons.youtube, iconColor: Colors.red),
        _SnsInputField(snsType: SnsType.tiktok, icon: FontAwesomeIcons.tiktok),
        _SnsInputField(snsType: SnsType.twitch, icon: FontAwesomeIcons.twitch, iconColor: Colors.purple),
        _SnsInputField(snsType: SnsType.other, icon: FontAwesomeIcons.users, iconColor: Colors.grey),
      ],
    );
  }
}

class _SnsInputField extends ConsumerWidget {
  final SnsType snsType;
  final IconData icon;
  final Color? iconColor;

  const _SnsInputField({
    required this.snsType,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        FaIcon(icon, color: iconColor ?? Theme.of(context).iconTheme.color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              ref.read(followerCheckProvider.notifier).updateFollowerCount(snsType, int.tryParse(value) ?? 0);
            },
            decoration: InputDecoration(
              hintText: '0',
              filled: false,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              border: const UnderlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
} 