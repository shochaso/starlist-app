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
  
  // アニメーション
  late Animation<double> _leverAnimation;
  late Animation<double> _machineShakeAnimation;
  late Animation<Offset> _capsulePositionAnimation;
  late Animation<double> _capsuleRotationAnimation;
  late Animation<double> _capsuleOpenAnimation;
  late Animation<double> _resultScaleAnimation;
  late Animation<double> _confettiAnimation;
  
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
      vsync: this,
    );
    _leverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _leverController,
      curve: Curves.easeOutQuart, // MD3推奨カーブ
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
    
    // カプセル落下アニメーション - Material Motion: 重力感のある落下
    _capsuleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _capsulePositionAnimation = Tween<Offset>(
      begin: const Offset(0, -2.5),
      end: const Offset(0, 0.2),
    ).animate(CurvedAnimation(
      parent: _capsuleController,
      curve: const Cubic(0.25, 0.46, 0.45, 0.94), // 自然な重力カーブ
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
    
    // 結果表示アニメーション - 削除（あたり表示不要）
    _resultController = AnimationController(
      duration: const Duration(milliseconds: 1),
      vsync: this,
    );
    _resultScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(_resultController);
    
    // 紙吹雪アニメーション - Material Motion: 祝祭感のある動き
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOutCirc,
    ));
    
    // リスナー設定
    _setupAnimationListeners();
  }
  
  void _setupAnimationListeners() {
    _leverController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _currentPhase == 0) {
        _triggerHapticFeedback(HapticFeedback.lightImpact);
        _nextPhase();
      }
    });
    
    _machineShakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _currentPhase == 1) {
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
        _nextPhase();
      }
    });
    
    _capsuleOpenController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _currentPhase == 3) {
        _triggerHapticFeedback(HapticFeedback.heavyImpact);
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
    
    setState(() {
      _currentPhase = 0;
      _showCapsule = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 320,
        height: 420,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 紙吹雪エフェクト
            if (_confettiController.status == AnimationStatus.forward)
              _buildConfetti(),
            
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
      animation: Listenable.merge([_machineShakeAnimation, _leverAnimation]),
      builder: (context, child) {
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
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFF4ECDC4).withOpacity(0.3),
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
                  child: Container(
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
                // カプセル下半分 - Material Design: 精緻なグラデーション
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
                      ],
                    ),
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: const Color(0xFFE91E63).withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                
                // カプセル上半分 - Material Motion: スムーズな開封動作
                Transform.translate(
                  offset: Offset(0, -_capsuleOpenAnimation.value * 50),
                  child: Transform.scale(
                    scale: 1.0 + (_capsuleOpenAnimation.value * 0.1),
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
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(35),
                          topRight: Radius.circular(35),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: const Color(0xFF4ECDC4).withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 0),
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
  
  // あたり表示は削除（空のWidget）
  Widget _buildResult() {
    return const SizedBox.shrink();
  }
  
  Widget _buildConfetti() {
    return AnimatedBuilder(
      animation: _confettiAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(30, (index) {
            final random = math.Random(index);
            final x = random.nextDouble() * 320;
            final y = _confettiAnimation.value * 420 + random.nextDouble() * 80;
            final rotation = _confettiAnimation.value * 6 * math.pi + random.nextDouble() * 2 * math.pi;
            final scale = 0.6 + random.nextDouble() * 0.8;
            
            // Material Design 3のカラーパレット
            final colors = [
              const Color(0xFF4ECDC4),
              const Color(0xFF44A08D),
              const Color(0xFFFFC107),
              const Color(0xFFFF8F00),
              const Color(0xFFE91E63),
              const Color(0xFFC2185B),
            ];
            
            return Positioned(
              left: x,
              top: y,
              child: Transform.rotate(
                angle: rotation,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colors[index % colors.length],
                          colors[index % colors.length].withOpacity(0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors[index % colors.length].withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
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
    super.dispose();
  }
}