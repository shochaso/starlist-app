import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'gacha_machine_widget.dart';

/// レスポンシブ対応のガチャマシンWidget
class ResponsiveGachaMachineWidget extends StatelessWidget {
  final VoidCallback? onGachaComplete;
  final bool isAnimating;
  
  const ResponsiveGachaMachineWidget({
    super.key,
    this.onGachaComplete,
    this.isAnimating = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 画面サイズに応じてスケールを調整
        double scale = _calculateScale(constraints);
        
        return Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth * 0.8,
              maxHeight: constraints.maxHeight * 0.7,
            ),
            child: Transform.scale(
              scale: scale,
              child: GachaMachineWidget(
                onGachaComplete: onGachaComplete,
                isAnimating: isAnimating,
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// 画面サイズに基づいてスケールを計算
  double _calculateScale(BoxConstraints constraints) {
    // 基準サイズ（ガチャマシンの実際のサイズ）
    const double baseWidth = 300.0;
    const double baseHeight = 400.0;
    
    // 利用可能なスペースに対する比率を計算
    double widthScale = (constraints.maxWidth * 0.8) / baseWidth;
    double heightScale = (constraints.maxHeight * 0.7) / baseHeight;
    
    // より小さい方の値を使用（アスペクト比を維持）
    double scale = widthScale < heightScale ? widthScale : heightScale;
    
    // 最小・最大スケールを制限
    if (kIsWeb) {
      // Webでは大きな画面でも適度なサイズを維持
      return scale.clamp(0.5, 1.5);
    } else {
      // モバイルでは画面に合わせてより柔軟にスケール
      return scale.clamp(0.3, 2.0);
    }
  }
}