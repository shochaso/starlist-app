import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 洗練されたガチャマシンのビジュアルおよびアニメーション
class GachaMachineWidget extends StatefulWidget {
  const GachaMachineWidget(
      {super.key, this.onAnimationComplete, this.isActive = false});

  final VoidCallback? onAnimationComplete;
  final bool isActive;

  @override
  State<GachaMachineWidget> createState() => _GachaMachineWidgetState();
}

class _GachaMachineWidgetState extends State<GachaMachineWidget>
    with TickerProviderStateMixin {
  static const double _machineWidth = 280;
  static const double _machineHeight = 360;
  static const double _capsuleSize = 72;

  late AnimationController _leverController;
  late AnimationController _machineShakeController;
  late AnimationController _capsuleController;
  late AnimationController _capsuleOpenController;
  late AnimationController _resultController;
  late AnimationController _confettiController;
  late AnimationController _shineController;

  late Animation<double> _leverAnimation;
  late Animation<double> _machineShakeAnimation;
  late Animation<Offset> _capsulePositionAnimation;
  late Animation<double> _capsuleRotationAnimation;
  late Animation<double> _capsuleOpenAnimation;
  late Animation<double> _resultScaleAnimation;
  late Animation<double> _confettiAnimation;
  late Animation<double> _shineAnimation;

  int _currentPhase = 0;
  bool _showCapsule = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _leverController = AnimationController(
      duration: const Duration(milliseconds: 420),
      reverseDuration: const Duration(milliseconds: 520),
      vsync: this,
    );
    _leverAnimation = CurvedAnimation(
      parent: _leverController,
      curve: Curves.easeOutQuart,
      reverseCurve: Curves.elasticOut,
    );

    _machineShakeController = AnimationController(
      duration: const Duration(milliseconds: 620),
      vsync: this,
    );
    _machineShakeAnimation = CurvedAnimation(
      parent: _machineShakeController,
      curve: Curves.easeInOutCubic,
    );

    _capsuleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _capsulePositionAnimation = Tween<Offset>(
      begin: const Offset(0, -2.6),
      end: const Offset(0.08, 0.24),
    ).animate(
        CurvedAnimation(parent: _capsuleController, curve: Curves.bounceOut));
    _capsuleRotationAnimation = CurvedAnimation(
      parent: _capsuleController,
      curve: Curves.easeOutQuint,
    );

    _capsuleOpenController = AnimationController(
      duration: const Duration(milliseconds: 480),
      vsync: this,
    );
    _capsuleOpenAnimation = CurvedAnimation(
      parent: _capsuleOpenController,
      curve: Curves.easeOutExpo,
    );

    _resultController = AnimationController(
      duration: const Duration(milliseconds: 780),
      vsync: this,
    );
    _resultScaleAnimation = CurvedAnimation(
      parent: _resultController,
      curve: Curves.easeOutCubic,
    );

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );
    _confettiAnimation = CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOutCirc,
    );

    _shineController = AnimationController(
      duration: const Duration(milliseconds: 1300),
      vsync: this,
    );
    _shineAnimation = CurvedAnimation(
      parent: _shineController,
      curve: Curves.easeInOutSine,
    );

    _setupAnimationListeners();
  }

  void _setupAnimationListeners() {
    _leverController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _currentPhase == 0) {
        _triggerHapticFeedback(HapticFeedback.lightImpact);
        _leverController.reverse();
        _nextPhase();
      }
    });

    _machineShakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _currentPhase == 1) {
        _shineController.stop();
        _triggerHapticFeedback(HapticFeedback.mediumImpact);
        _nextPhase();
      }
    });

    _capsuleController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _currentPhase == 2) {
        _triggerHapticFeedback(HapticFeedback.lightImpact);
        _nextPhase();
      }
    });

    _capsuleOpenController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _currentPhase == 3) {
        _triggerHapticFeedback(HapticFeedback.heavyImpact);
        _resultController.forward();
        _confettiController.forward();
        Future.delayed(const Duration(milliseconds: 320), () {
          widget.onAnimationComplete?.call();
        });
      }
    });
  }

  void _triggerHapticFeedback(Future<void> Function() feedback) {
    feedback();
  }

  void _nextPhase() {
    setState(() {
      _currentPhase++;
    });

    switch (_currentPhase) {
      case 1:
        _shineController.repeat();
        _machineShakeController.forward();
        break;
      case 2:
        setState(() {
          _showCapsule = true;
        });
        _capsuleController.forward();
        break;
      case 3:
        _capsuleOpenController.forward();
        break;
    }
  }

  @override
  void didUpdateWidget(GachaMachineWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _resetAnimations();
    _leverController.forward();
  }

  void _resetAnimations() {
    _leverController.reset();
    _machineShakeController.reset();
    _capsuleController.reset();
    _capsuleOpenController.reset();
    _resultController.reset();
    _confettiController.reset();
    _shineController.reset();

    setState(() {
      _currentPhase = 0;
      _showCapsule = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.isActive ? 1.05 : 1.0;

    return Center(
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutBack,
        child: SizedBox(
          width: _machineWidth + 72,
          height: _machineHeight + 96,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: 10,
                child: _buildMachineBase(),
              ),
              if (_confettiController.status == AnimationStatus.forward)
                _buildConfetti(),
              if (_resultController.status == AnimationStatus.forward)
                _buildRevealGlow(),
              _buildMachine(),
              if (_showCapsule) _buildCapsule(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMachine() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _machineShakeAnimation,
        _leverAnimation,
        _shineAnimation,
      ]),
      builder: (context, child) {
        final shakeIntensity = 1 + (_machineShakeAnimation.value * 0.6);
        return Transform.translate(
          offset: Offset(
            math.sin(_machineShakeAnimation.value * 8) * 2,
            math.cos(_machineShakeAnimation.value * 12) * 1,
          ),
          child: Container(
            width: _machineWidth,
            height: _machineHeight,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4ECDC4),
                  Color(0xFF44A08D),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.16 * shakeIntensity),
                  blurRadius: 26,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: const Color(0xFF4ECDC4)
                      .withOpacity(0.28 * shakeIntensity),
                  blurRadius: 42,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 46,
                  left: 26,
                  right: 26,
                  height: 156,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.26),
                            width: 1.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.18),
                                  Colors.white.withOpacity(0.06),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Transform(
                            transform: Matrix4.identity()
                              ..translate(_shineAnimation.value * 280)
                              ..rotateZ(-0.58),
                            alignment: Alignment.center,
                            child: Container(
                              width: 62,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.white.withOpacity(0.0),
                                    Colors.white.withOpacity(0.38),
                                    Colors.white.withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 18,
                  top: _machineHeight * 0.68,
                  child: Transform.rotate(
                    angle: _leverAnimation.value * 0.58,
                    child: Container(
                      width: 38,
                      height: 94,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFFC107), Color(0xFFFF8F00)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.22),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: const Color(0xFFFFC107).withOpacity(0.42),
                            blurRadius: 16,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.sports_esports_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 32,
                  left: _machineWidth * 0.24,
                  right: _machineWidth * 0.24,
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF455A64), Color(0xFF263238)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF607D8B).withOpacity(0.55),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.32),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 18,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'STARLIST',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.28),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCapsule() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _capsulePositionAnimation,
        _capsuleRotationAnimation,
        _capsuleOpenAnimation,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _capsulePositionAnimation.value.dx * (_machineWidth * 0.34),
            _capsulePositionAnimation.value.dy * (_machineHeight * 0.55),
          ),
          child: Transform.rotate(
            angle: _capsuleRotationAnimation.value * math.pi,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: _capsuleSize,
                  height: _capsuleSize,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE91E63),
                        Color(0xFFC2185B),
                        Color(0xFF9C27B0),
                        Color(0xFF673AB7),
                        Color(0xFF3F51B5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(_capsuleSize / 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.38),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: const Color(0xFFE91E63).withOpacity(0.65),
                        blurRadius: 30,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_capsuleSize / 2),
                      gradient: RadialGradient(
                        center: Alignment.topLeft,
                        radius: 0.8,
                        colors: [
                          Colors.white.withOpacity(0.55),
                          Colors.white.withOpacity(0.28),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, -_capsuleOpenAnimation.value * 50),
                  child: Transform.scale(
                    scale: 1.0 + (_capsuleOpenAnimation.value * 0.18),
                    child: Container(
                      width: _capsuleSize,
                      height: _capsuleSize / 2,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF4ECDC4),
                            Color(0xFF44A08D),
                            Color(0xFF26A69A),
                            Color(0xFF00BCD4),
                            Color(0xFF0097A7),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(36),
                          topRight: Radius.circular(36),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.36),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: _capsuleSize,
                  height: _capsuleSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_capsuleSize / 2),
                    gradient: RadialGradient(
                      center: Alignment.topLeft,
                      radius: 0.55,
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _capsuleRotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _capsuleRotationAnimation.value * 2,
                      child: Container(
                        width: _capsuleSize,
                        height: _capsuleSize,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(_capsuleSize / 2),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.4),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.white.withOpacity(0.2),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  width: 26 + (_capsuleOpenAnimation.value * 16),
                  height: 26 + (_capsuleOpenAnimation.value * 16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.0),
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRevealGlow() {
    return AnimatedBuilder(
      animation: _resultScaleAnimation,
      builder: (context, child) {
        final scale = _resultScaleAnimation.value;
        return IgnorePointer(
          child: Opacity(
            opacity: 0.85 * (1.0 - (scale * 0.6)),
            child: Transform.scale(
              scale: 0.8 + scale * 0.6,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.85),
                      const Color(0xFF4ECDC4).withOpacity(0.38),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMachineBase() {
    return SizedBox(
      width: _machineWidth * 1.18,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1F3A5F),
                  Color(0xFF102337),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.28),
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
                BoxShadow(
                  color: const Color(0xFF4ECDC4).withOpacity(0.24),
                  blurRadius: 32,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.32),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -10,
            left: 28,
            right: 28,
            child: Container(
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.28),
                    Colors.black.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfetti() {
    return AnimatedBuilder(
      animation: _confettiAnimation,
      builder: (context, child) {
        final t = _confettiAnimation.value;
        return IgnorePointer(
          child: Stack(
            children: List.generate(60, (index) {
              final random = math.Random(index * 977);
              final baseX = random.nextDouble() * 320;
              final drift = math.sin((t * 6 + index) * 0.8) *
                  (6 + random.nextDouble() * 10);
              final x = baseX + drift;
              final y = t * 420 + random.nextDouble() * 80;
              final rotation =
                  t * 8 * math.pi + random.nextDouble() * 2 * math.pi;
              final scale = 0.5 + random.nextDouble() * 0.9;
              final opacity = (1.0 - t).clamp(0.0, 1.0);

              final colors = [
                const Color(0xFF4ECDC4),
                const Color(0xFF44A08D),
                const Color(0xFF9575CD),
                const Color(0xFFFFC107),
                const Color(0xFFFF8A65),
              ];
              return Positioned(
                left: x,
                top: y,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Transform.rotate(
                      angle: rotation,
                      child: Container(
                        width: 8,
                        height: 16,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
