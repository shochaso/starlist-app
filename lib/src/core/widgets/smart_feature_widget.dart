import 'package:flutter/material.dart';
import '../utils/lazy_loading_manager.dart';

/// スマート機能Widget
/// ユーザーの使用状況に応じて段階的に機能を開放
class SmartFeatureWidget extends StatefulWidget {
  final String featureId;
  final FeatureLevel requiredLevel;
  final Widget Function() lightBuilder;
  final Widget Function()? standardBuilder;
  final Widget Function()? premiumBuilder;
  final VoidCallback? onUpgradeRequest;

  const SmartFeatureWidget({
    super.key,
    required this.featureId,
    required this.requiredLevel,
    required this.lightBuilder,
    this.standardBuilder,
    this.premiumBuilder,
    this.onUpgradeRequest,
  });

  @override
  State<SmartFeatureWidget> createState() => _SmartFeatureWidgetState();
}

class _SmartFeatureWidgetState extends State<SmartFeatureWidget> {
  FeatureLevel _currentLevel = FeatureLevel.light;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _determineFeatureLevel();
  }

  Future<void> _determineFeatureLevel() async {
    // ユーザーの利用状況と端末性能を分析
    final userLevel = await _analyzeUserLevel();
    final deviceCapability = await _analyzeDeviceCapability();
    
    setState(() {
      _currentLevel = _calculateOptimalLevel(userLevel, deviceCapability);
    });
  }

  Future<FeatureLevel> _analyzeUserLevel() async {
    // ユーザーの使用頻度、課金状況等を分析
    // 仮実装
    return FeatureLevel.standard;
  }

  Future<DeviceCapability> _analyzeDeviceCapability() async {
    // 端末のRAM、CPU、ストレージを分析
    // 仮実装
    return DeviceCapability.medium;
  }

  FeatureLevel _calculateOptimalLevel(
    FeatureLevel userLevel, 
    DeviceCapability deviceCap,
  ) {
    // 端末性能が低い場合は機能を制限
    if (deviceCap == DeviceCapability.low) {
      return FeatureLevel.light;
    }
    
    // ユーザーレベルと端末性能の組み合わせで決定
    return userLevel;
  }

  @override
  Widget build(BuildContext context) {
    return _buildFeatureByLevel();
  }

  Widget _buildFeatureByLevel() {
    switch (_currentLevel) {
      case FeatureLevel.light:
        return _buildLightFeature();
      case FeatureLevel.standard:
        return _buildStandardFeature();
      case FeatureLevel.premium:
        return _buildPremiumFeature();
    }
  }

  Widget _buildLightFeature() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            widget.lightBuilder(),
            if (widget.standardBuilder != null)
              _buildUpgradePrompt(FeatureLevel.standard),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardFeature() {
    if (widget.standardBuilder == null) {
      return _buildLightFeature();
    }

    return LazyWidget(
      moduleId: '${widget.featureId}_standard',
      builder: () async => widget.standardBuilder!(),
      placeholder: _buildLoadingPlaceholder(),
    );
  }

  Widget _buildPremiumFeature() {
    if (widget.premiumBuilder == null) {
      return _buildStandardFeature();
    }

    return LazyWidget(
      moduleId: '${widget.featureId}_premium',
      builder: () async => widget.premiumBuilder!(),
      placeholder: _buildLoadingPlaceholder(),
    );
  }

  Widget _buildUpgradePrompt(FeatureLevel targetLevel) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.upgrade, color: Colors.blue[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${_getFeatureName(targetLevel)}機能を利用できます',
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _requestUpgrade(targetLevel),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
            ),
            child: Text(
              '有効化',
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  String _getFeatureName(FeatureLevel level) {
    switch (level) {
      case FeatureLevel.light:
        return '基本';
      case FeatureLevel.standard:
        return '標準';
      case FeatureLevel.premium:
        return 'プレミアム';
    }
  }

  Future<void> _requestUpgrade(FeatureLevel targetLevel) async {
    setState(() => _isLoading = true);

    try {
      // 機能アップグレード処理
      await _upgradeFeature(targetLevel);
      setState(() => _currentLevel = targetLevel);
      
      if (widget.onUpgradeRequest != null) {
        widget.onUpgradeRequest!();
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _upgradeFeature(FeatureLevel targetLevel) async {
    // 必要なモジュールの遅延ロード
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

enum FeatureLevel {
  light,    // 軽量版（基本機能のみ）
  standard, // 標準版（通常機能）
  premium,  // プレミアム版（全機能）
}

enum DeviceCapability {
  low,    // 低性能端末
  medium, // 中性能端末
  high,   // 高性能端末
} 