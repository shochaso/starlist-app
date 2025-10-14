import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider_enhanced.dart';
import '../core/constants/theme_constants.dart';

/// テーマモード切り替えウィジェット
class ThemeModeSwitcher extends ConsumerWidget {
  final bool showLabels;
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const ThemeModeSwitcher({
    super.key,
    this.showLabels = true,
    this.direction = Axis.horizontal,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProviderEnhanced);
    final themeActions = ref.read(themeActionProvider);
    
    if (themeState.isLoading) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final children = AppThemeMode.values.map((mode) {
      final isSelected = themeState.themeMode == mode;
      
      return _buildThemeOption(
        context: context,
        mode: mode,
        isSelected: isSelected,
        onTap: () => themeActions.setThemeMode(mode),
        showLabel: showLabels,
      );
    }).toList();

    return direction == Axis.horizontal
        ? Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: _addSpacing(children, direction),
          )
        : Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: _addSpacing(children, direction),
          );
  }

  /// テーマオプションを構築
  Widget _buildThemeOption({
    required BuildContext context,
    required AppThemeMode mode,
    required bool isSelected,
    required VoidCallback onTap,
    required bool showLabel,
  }) {
    final icon = _getThemeIcon(mode);
    final color = isSelected 
        ? ThemeConstants.primaryPurple
        : Theme.of(context).hintColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: ThemeConstants.animationNormal,
        curve: ThemeConstants.animationCurveDefault,
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spaceSm,
          vertical: ThemeConstants.spaceXs,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? ThemeConstants.primaryPurple.withOpacity( 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(ThemeConstants.radiusSm),
          border: isSelected
              ? Border.all(
                  color: ThemeConstants.primaryPurple.withOpacity( 0.3),
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: ThemeConstants.animationNormal,
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            if (showLabel) ...[ 
              const SizedBox(height: ThemeConstants.spaceXs),
              AnimatedDefaultTextStyle(
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: isSelected 
                      ? ThemeConstants.fontWeightMedium
                      : ThemeConstants.fontWeightRegular,
                ),
                duration: ThemeConstants.animationNormal,
                child: Text(mode.displayName),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// テーマアイコンを取得
  IconData _getThemeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.settings_suggest;
    }
  }

  /// 子要素間にスペースを追加
  List<Widget> _addSpacing(List<Widget> children, Axis direction) {
    if (children.isEmpty) return children;
    
    final spacing = direction == Axis.horizontal
        ? const SizedBox(width: ThemeConstants.spaceMd)
        : const SizedBox(height: ThemeConstants.spaceSm);
    
    final result = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(spacing);
      }
    }
    
    return result;
  }
}

/// シンプルなテーマ切り替えボタン
class ThemeToggleButton extends ConsumerWidget {
  final double size;
  final Color? iconColor;
  final Color? backgroundColor;

  const ThemeToggleButton({
    super.key,
    this.size = 24.0,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProviderEnhanced);
    final themeActions = ref.read(themeActionProvider);
    
    if (themeState.isLoading) {
      return SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final isDark = themeState.isDarkMode;
    final icon = isDark ? Icons.light_mode : Icons.dark_mode;
    final tooltip = isDark ? 'ライトモードに切り替え' : 'ダークモードに切り替え';

    return IconButton(
      onPressed: () => themeActions.toggle(),
      icon: AnimatedSwitcher(
        duration: ThemeConstants.animationNormal,
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: animation,
            child: child,
          );
        },
        child: Icon(
          icon,
          key: ValueKey(isDark),
          size: size,
          color: iconColor ?? Theme.of(context).iconTheme.color,
        ),
      ),
      tooltip: tooltip,
      style: backgroundColor != null
          ? IconButton.styleFrom(
              backgroundColor: backgroundColor,
            )
          : null,
    );
  }
}

/// テーマ設定カード
class ThemeSettingsCard extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final EdgeInsetsGeometry? padding;

  const ThemeSettingsCard({
    super.key,
    this.title = 'テーマ設定',
    this.subtitle,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProviderEnhanced);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(ThemeConstants.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              children: [
                const Icon(
                  Icons.palette,
                  color: ThemeConstants.primaryPurple,
                  size: 20,
                ),
                const SizedBox(width: ThemeConstants.spaceSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: ThemeConstants.fontWeightSemiBold,
                        ),
                      ),
                      if (subtitle != null) ...[ 
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                // 現在のテーマ表示
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConstants.spaceSm,
                    vertical: ThemeConstants.spaceXs,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeConstants.primaryPurple.withOpacity( 0.1),
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusSm),
                    border: Border.all(
                      color: ThemeConstants.primaryPurple.withOpacity( 0.3),
                    ),
                  ),
                  child: Text(
                    themeState.themeMode.displayName,
                    style: const TextStyle(
                      color: ThemeConstants.primaryPurple,
                      fontSize: 12,
                      fontWeight: ThemeConstants.fontWeightMedium,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: ThemeConstants.spaceMd),
            
            // テーマ切り替えオプション
            const ThemeModeSwitcher(
              showLabels: true,
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            
            if (themeState.themeMode == AppThemeMode.system) ...[ 
              const SizedBox(height: ThemeConstants.spaceSm),
              Container(
                padding: const EdgeInsets.all(ThemeConstants.spaceSm),
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withOpacity( 0.1),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusSm),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: ThemeConstants.spaceSm),
                    Expanded(
                      child: Text(
                        'システム設定に従います（現在: ${themeState.isDarkMode ? 'ダーク' : 'ライト'}）',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// アニメーション付きテーマ切り替えボタン
class AnimatedThemeButton extends ConsumerStatefulWidget {
  final double size;
  final Duration animationDuration;

  const AnimatedThemeButton({
    super.key,
    this.size = 48.0,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  @override
  ConsumerState<AnimatedThemeButton> createState() => _AnimatedThemeButtonState();
}

class _AnimatedThemeButtonState extends ConsumerState<AnimatedThemeButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleThemeToggle() async {
    await _controller.forward();
    ref.read(themeActionProvider).toggle();
    await _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProviderEnhanced);
    
    return GestureDetector(
      onTap: _handleThemeToggle,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: themeState.isDarkMode
                        ? [Colors.indigo, Colors.purple]
                        : [Colors.orange, Colors.amber],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (themeState.isDarkMode 
                          ? Colors.purple 
                          : Colors.orange).withOpacity( 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  themeState.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                  color: Colors.white,
                  size: widget.size * 0.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}