import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// 洗練されたガチャポンマシンアニメーションWidget (Material Motion Principles)
class GachaMachineWidget extends StatefulWidget {
  final VoidCallback? onAnimationComplete;
  final bool isActive;
  
  const GachaMachineWidget({
    super.key,
    this.onAnimationComplete,
    this.isActive = false,
  });

  @override
  State<GachaMachineWidget> createState() => _GachaMachineWidgetState();
}

class _GachaMachineWidgetState extends State<GachaMachineWidget>
    with TickerProviderStateMixin {
  
  // アニメーションコントローラー
  late AnimationController _leverController;
  late AnimationController _machineShakeController;
  late AnimationController _capsuleController;
  late AnimationController _capsuleOpenController;
  late AnimationController _resultController;
  late AnimationController _confettiController;
  late AnimationController _shineController;
  
  // アニメーション
  late Animation<double> _leverAnimation;
  late Animation<double> _machineShakeAnimation;
  late Animation<Offset> _capsulePositionAnimation;
  late Animation<double> _capsuleRotationAnimation;
  late Animation<double> _capsuleOpenAnimation;
  late Animation<double> _resultScaleAnimation;
  late Animation<double> _confettiAnimation;
  late Animation<double> _shineAnimation;
  
  // アニメーション段階
  int _currentPhase = 0;
  bool _showCapsule = false;
  bool _showResult = false;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }
  
  void _setupAnimations() {
    // レバーアニメーション - Material Motion: 感応的な操作フィードバック
    _leverController = AnimationController(
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _leverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _leverController,
      curve: Curves.easeOutQuart, // MD3推奨カーブ
      reverseCurve: Curves.elasticOut,
    ));
    
    // マシン振動アニメーション - Material Motion: 自然な物理応答
    _machineShakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _machineShakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _machineShakeController,
      curve: Curves.easeInOutCubic, // スムーズな加減速
    ));
    
    // カプセル落下アニメーション - Material Motion: 重力感のある落下（着地バウンス）
    _capsuleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _capsulePositionAnimation = Tween<Offset>(
      begin: const Offset(0, -2.5),
      end: const Offset(0.06, 0.2), // ほんの少し右へ転がる
    ).animate(CurvedAnimation(
      parent: _capsuleController,
      curve: Curves.bounceOut, // 自然な着地バウンス
    ));
    _capsuleRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.5 * math.pi,
    ).animate(CurvedAnimation(
      parent: _capsuleController,
      curve: Curves.easeOutQuint,
    ));
    
    // カプセル開封アニメーション - Material Motion: 段階的開示
    _capsuleOpenController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _capsuleOpenAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _capsuleOpenController,
      curve: Curves.easeOutExpo, // 期待感のあるカーブ
    ));
    
    // 結果表示アニメーション（光のリビールに利用）
    _resultController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _resultScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _resultController,
      curve: Curves.easeOutCubic,
    ));
    
    // 紙吹雪アニメーション - Material Motion: 祝祭感のある動き
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );
    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOutCirc,
    ));

    // マシンのガラス面に走るシャイン
    _shineController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _shineAnimation = Tween<double>(
      begin: -0.4,
      end: 1.4,
    ).animate(CurvedAnimation(
      parent: _shineController,
      curve: Curves.easeInOutSine,
    ));
    
    // リスナー設定
    _setupAnimationListeners();
  }
  
  void _setupAnimationListeners() {
    _leverController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _currentPhase == 0) {
        _triggerHapticFeedback(HapticFeedback.lightImpact);
        // レバーをバウンスさせながら戻す
        _leverController.reverse();
        _nextPhase();
      }
    });
    
    _machineShakeController.addStatusListener((status) {
      if (status == AnimationStatus.forward) return;
      if (status == AnimationStatus.completed && _currentPhase == 1) {
        // シャインを停止
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
        // リビール光＆紙吹雪
        _resultController.forward();
        _confettiController.forward();
        Future.delayed(const Duration(milliseconds: 300), () {
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
        // 振動と同時にシャイン開始
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
    return Center(
      child: SizedBox(
        width: 300, // 320から300に縮小
        height: 380, // 420から380に縮小
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 紙吹雪エフェクト
            if (_confettiController.status == AnimationStatus.forward)
              _buildConfetti(),
            
            // リビールの光
            if (_resultController.status == AnimationStatus.forward)
              _buildRevealGlow(),
            
            // ガチャマシン本体
            _buildMachine(),
            
            // カプセル
            if (_showCapsule)
              _buildCapsule(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMachine() {
    return AnimatedBuilder(
      animation: Listenable.merge([_machineShakeAnimation, _leverAnimation, _shineAnimation]),
      builder: (context, child) {
        final shakeIntensity = 1 + (_machineShakeAnimation.value * 0.6);
        return Transform.translate(
          offset: Offset(
            math.sin(_machineShakeAnimation.value * 8) * 2,
            math.cos(_machineShakeAnimation.value * 12) * 1,
          ),
          child: Container(
            width: 280,
            height: 370,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF4ECDC4).withOpacity(0.9),
                  const Color(0xFF44A08D),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15 * shakeIntensity),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFF4ECDC4).withOpacity(0.3 * shakeIntensity),
                  blurRadius: 40,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Stack(
              children: [
                // ガラス窓 - Material Design 3のGlass morphism
                Positioned(
                  top: 50,
                  left: 24,
                  right: 24,
                  height: 160,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
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
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // シャイン（斜めの光が走る）
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Transform(
                            transform: Matrix4.identity()
                              ..translate(_shineAnimation.value * 260)
                              ..rotateZ(-0.6),
                            alignment: Alignment.center,
                            child: Container(
                              width: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.white.withOpacity(0.0),
                                    Colors.white.withOpacity(0.35),
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
                
                // レバー - Material Motion: 感応的フィードバック
                Positioned(
                  right: 16,
                  top: 220,
                  child: Transform.rotate(
                    angle: _leverAnimation.value * 0.6,
                    child: Container(
                      width: 36,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFFFC107),
                            const Color(0xFFFF8F00),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: const Color(0xFFFFC107).withOpacity(0.4),
                            blurRadius: 12,
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
                
                // 取り出し口 - Material Design: 機能的な形状
                Positioned(
                  bottom: 40,
                  left: 70,
                  right: 70,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF37474F),
                          const Color(0xFF263238),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF546E7A).withOpacity(0.6),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // ロゴ - Material Design: タイポグラフィ
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'STARLIST',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
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
      animation: Listenable.merge([_capsulePositionAnimation, _capsuleRotationAnimation, _capsuleOpenAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _capsulePositionAnimation.value.dx * 100,
            _capsulePositionAnimation.value.dy * 200,
          ),
          child: Transform.rotate(
            angle: _capsuleRotationAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // カプセル下半分 - 超高品質なグラデーションと光沢効果
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFE91E63),
                        const Color(0xFFC2185B),
                        const Color(0xFF9C27B0),
                        const Color(0xFF673AB7),
                        const Color(0xFF3F51B5),
                      ],
                      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: const Color(0xFFE91E63).withOpacity(0.8),
                        blurRadius: 30,
                        offset: const Offset(0, 0),
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(-3, -3),
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: const Color(0xFF9C27B0).withOpacity(0.6),
                        blurRadius: 25,
                        offset: const Offset(3, 3),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      gradient: RadialGradient(
                        center: Alignment.topLeft,
                        radius: 0.8,
                        colors: [
                          Colors.white.withOpacity(0.6),
                          Colors.white.withOpacity(0.3),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),
                
                // カプセル上半分 - 超高品質な開封アニメーション
                Transform.translate(
                  offset: Offset(0, -_capsuleOpenAnimation.value * 50),
                  child: Transform.scale(
                    scale: 1.0 + (_capsuleOpenAnimation.value * 0.2),
                    child: Container(
                      width: 70,
                      height: 35,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF4ECDC4),
                            const Color(0xFF44A08D),
                            const Color(0xFF26A69A),
                            const Color(0xFF00BCD4),
                            const Color(0xFF0097A7),
                          ],
                          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(35),
                          topRight: Radius.circular(35),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: const Color(0xFF4ECDC4).withOpacity(0.8),
                            blurRadius: 30,
                            offset: const Offset(0, 0),
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(-4, -4),
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: const Color(0xFF00BCD4).withOpacity(0.7),
                            blurRadius: 25,
                            offset: const Offset(4, 4),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35),
                          ),
                          gradient: RadialGradient(
                            center: Alignment.topLeft,
                            radius: 0.7,
                            colors: [
                              Color(0xFFFFFFFF),
                              Color(0xCCFFFFFF),
                              Color(0x00FFFFFF),
                            ],
                            stops: [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // 追加の光沢効果レイヤー
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    gradient: RadialGradient(
                      center: Alignment.topLeft,
                      radius: 0.6,
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                
                // 反射光のアニメーション
                AnimatedBuilder(
                  animation: _capsuleRotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _capsuleRotationAnimation.value * 2,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.4),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.white.withOpacity(0.2),
                            ],
                            stops: const [0.0, 0.3, 0.7, 1.0],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // リビールの光（結果UIではなく、演出用の発光）
  Widget _buildRevealGlow() {
    return AnimatedBuilder(
      animation: _resultScaleAnimation,
      builder: (context, child) {
        final scale = _resultScaleAnimation.value;
        return IgnorePointer(
          child: Opacity(
            opacity: 0.8 * (1.0 - (scale * 0.6)),
            child: Transform.scale(
              scale: 0.8 + scale * 0.6,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.9),
                      const Color(0xFF4ECDC4).withOpacity(0.35),
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
  
  // あたり表示は削除（演出のみ）
  Widget _buildResult() {
    return const SizedBox.shrink();
  }
  
  Widget _buildConfetti() {
    return AnimatedBuilder(
      animation: _confettiAnimation,
      builder: (context, child) {
        final t = _confettiAnimation.value;
        return IgnorePointer(
          child: Stack(
            children: List.generate(60, (index) {
              final random = math.Random(index * 997);
              final baseX = random.nextDouble() * 320;
              final drift = math.sin((t * 6 + index) * 0.8) * (6 + random.nextDouble() * 10);
              final x = baseX + drift;
              final y = t * 420 + random.nextDouble() * 80;
              final rotation = t * 8 * math.pi + random.nextDouble() * 2 * math.pi;
              final scale = 0.5 + random.nextDouble() * 0.9;
              final opacity = (1.0 - t).clamp(0.0, 1.0);
              
              // Material Design 3のカラーパレット
              final colors = [
                const Color(0xFF4ECDC4),
                const Color(0xFF44A08D),
                const Color(0xFFFFC107),
                const Color(0xFFFF8F00),
                const Color(0xFFE91E63),
                const Color(0xFFC2185B),
              ];
              final color = colors[index % colors.length];

              // 形状のバリエーション: 円/角/バー
              final shapeType = index % 3;
              Widget shard;
              if (shapeType == 0) {
                shard = Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color, color.withOpacity(0.8)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                );
              } else if (shapeType == 1) {
                shard = Container(
                  width: 10,
                  height: 14,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color, color.withOpacity(0.75)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.25),
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                );
              } else {
                shard = Container(
                  width: 6,
                  height: 18,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                );
              }
              
              return Positioned(
                left: x,
                top: y,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.rotate(
                    angle: rotation,
                    child: Transform.scale(
                      scale: scale,
                      child: shard,
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
  
  @override
  void dispose() {
    _leverController.dispose();
    _machineShakeController.dispose();
    _capsuleController.dispose();
    _capsuleOpenController.dispose();
    _resultController.dispose();
    _confettiController.dispose();
    _shineController.dispose();
    super.dispose();
  }
}