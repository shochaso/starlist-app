import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider_enhanced.dart';

class CommonAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBackToHome;
  final VoidCallback? onBackPressed;

  const CommonAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBackToHome = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;

    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      elevation: 0,
      leading: showBackToHome
          ? IconButton(
              icon: Icon(
                Icons.home,
                color: isDark ? Colors.white : Colors.black87,
              ),
              onPressed: onBackPressed ?? () => _navigateToHome(context),
            )
          : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ],
      ),
      actions: actions,
    );
  }

  void _navigateToHome(BuildContext context) {
    // すべてのルートをクリアしてホーム画面に戻る
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CommonBackButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final bool toHome;

  const CommonBackButton({
    super.key,
    this.onPressed,
    this.toHome = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;

    return GestureDetector(
      onTap: onPressed ?? () => _handleBack(context),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF333333) : Colors.grey.shade200,
          ),
        ),
        child: Icon(
          toHome ? Icons.home : Icons.arrow_back,
          color: isDark ? Colors.white : Colors.black87,
          size: 20,
        ),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    if (toHome) {
      // ホーム画面に戻る
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } else {
      // 前のページに戻る
      Navigator.of(context).pop();
    }
  }
} 