import 'package:flutter/material.dart';

/// アプリナビゲーションウィジェット
class AppNavigation extends StatelessWidget {
  /// 現在のインデックス
  final int currentIndex;
  
  /// インデックスが変更されたときのコールバック
  final Function(int) onIndexChanged;
  
  /// ナビゲーションアイテム
  final List<NavigationItem> items;
  
  /// 背景色
  final Color? backgroundColor;
  
  /// 選択色
  final Color? selectedItemColor;
  
  /// 非選択色
  final Color? unselectedItemColor;
  
  /// アイコンサイズ
  final double iconSize;
  
  /// ラベルのフォントサイズ
  final double? labelFontSize;
  
  /// ラベルを表示するかどうか
  final bool showLabels;

  /// コンストラクタ
  const AppNavigation({
    Key? key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.items,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.iconSize = 24.0,
    this.labelFontSize,
    this.showLabels = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navBackgroundColor = backgroundColor ?? theme.bottomNavigationBarTheme.backgroundColor;
    final navSelectedItemColor = selectedItemColor ?? theme.colorScheme.primary;
    final navUnselectedItemColor = unselectedItemColor ?? Colors.grey;
    
    return Container(
      decoration: BoxDecoration(
        color: navBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;
              
              return InkWell(
                onTap: () => onIndexChanged(index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: isSelected ? navSelectedItemColor : navUnselectedItemColor,
                      size: iconSize,
                    ),
                    if (showLabels) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: isSelected ? navSelectedItemColor : navUnselectedItemColor,
                          fontSize: labelFontSize ?? 12.0,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// ナビゲーションアイテム
class NavigationItem {
  /// ラベル
  final String label;
  
  /// アイコン
  final IconData icon;
  
  /// アクティブ時のアイコン
  final IconData activeIcon;

  /// コンストラクタ
  const NavigationItem({
    required this.label,
    required this.icon,
    IconData? activeIcon,
  }) : activeIcon = activeIcon ?? icon;
}
