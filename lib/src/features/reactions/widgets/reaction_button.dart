import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/reaction_model.dart';

/// リアクションボタンウィジェット
/// 👍いいね と ❤️ハート のボタンを表示
class ReactionButton extends StatefulWidget {
  const ReactionButton({
    Key? key,
    required this.reactionType,
    required this.count,
    required this.isActive,
    required this.onTap,
    this.size = 20,
    this.showCount = true,
    this.isLoading = false,
  }) : super(key: key);

  final ReactionType reactionType;
  final int count;
  final bool isActive;
  final VoidCallback onTap;
  final double size;
  final bool showCount;
  final bool isLoading;

  @override
  State<ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<ReactionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isLoading) return;
    
    // ハプティックフィードバック
    HapticFeedback.lightImpact();
    
    // アニメーション実行
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    
    // コールバック実行
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isActive
                        ? _getActiveBackgroundColor(isDark)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.isActive
                          ? _getActiveColor()
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // リアクションアイコン
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: widget.isLoading
                            ? SizedBox(
                                width: widget.size,
                                height: widget.size,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getActiveColor(),
                                  ),
                                ),
                              )
                            : Text(
                                widget.reactionType.emoji,
                                style: TextStyle(
                                  fontSize: widget.size,
                                  color: widget.isActive
                                      ? _getActiveColor()
                                      : _getInactiveColor(isDark),
                                ),
                              ),
                      ),
                      
                      // カウント表示
                      if (widget.showCount) ...[
                        const SizedBox(width: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: widget.size * 0.8,
                            fontWeight: widget.isActive
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: widget.isActive
                                ? _getActiveColor()
                                : _getInactiveColor(isDark),
                          ),
                          child: Text(
                            _formatCount(widget.count),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getActiveColor() {
    switch (widget.reactionType) {
      case ReactionType.like:
        return const Color(0xFF4285F4); // Google Blue
      case ReactionType.heart:
        return const Color(0xFFFF4458); // Red Heart
    }
  }

  Color _getActiveBackgroundColor(bool isDark) {
    final baseColor = _getActiveColor();
    return isDark
        ? baseColor.withOpacity( 0.15)
        : baseColor.withOpacity( 0.1);
  }

  Color _getInactiveColor(bool isDark) {
    return isDark
        ? Colors.grey.shade400
        : Colors.grey.shade600;
  }

  String _formatCount(int count) {
    if (count == 0) return '';
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }
}

/// リアクションボタンの行
/// 👍いいね と ❤️ハート を横並びで表示
class ReactionButtonRow extends StatelessWidget {
  const ReactionButtonRow({
    Key? key,
    required this.reactionCounts,
    required this.userReactionState,
    required this.onReactionToggle,
    this.isLoading = false,
    this.size = 20,
  }) : super(key: key);

  final ReactionCountModel reactionCounts;
  final UserReactionState userReactionState;
  final Function(ReactionType) onReactionToggle;
  final bool isLoading;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 👍いいねボタン
        ReactionButton(
          reactionType: ReactionType.like,
          count: reactionCounts.like,
          isActive: userReactionState.hasLiked,
          onTap: () => onReactionToggle(ReactionType.like),
          isLoading: isLoading,
          size: size,
        ),
        
        const SizedBox(width: 16),
        
        // ❤️ハートボタン
        ReactionButton(
          reactionType: ReactionType.heart,
          count: reactionCounts.heart,
          isActive: userReactionState.hasHearted,
          onTap: () => onReactionToggle(ReactionType.heart),
          isLoading: isLoading,
          size: size,
        ),
      ],
    );
  }
}

/// コンパクトなリアクションボタン（小さなスペース用）
class CompactReactionButton extends StatelessWidget {
  const CompactReactionButton({
    Key? key,
    required this.reactionType,
    required this.count,
    required this.isActive,
    required this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  final ReactionType reactionType;
  final int count;
  final bool isActive;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ReactionButton(
      reactionType: reactionType,
      count: count,
      isActive: isActive,
      onTap: onTap,
      isLoading: isLoading,
      size: 16,
      showCount: count > 0,
    );
  }
}

/// リアクション統計表示ウィジェット
class ReactionStats extends StatelessWidget {
  const ReactionStats({
    Key? key,
    required this.reactionCounts,
    this.showPercentage = false,
  }) : super(key: key);

  final ReactionCountModel reactionCounts;
  final bool showPercentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = reactionCounts.total;
    
    if (total == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 👍統計
          if (reactionCounts.like > 0) ...[
            Text(
              '👍 ${reactionCounts.like}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (showPercentage) ...[
              const SizedBox(width: 4),
              Text(
                '(${(reactionCounts.like / total * 100).toStringAsFixed(0)}%)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
          
          // セパレーター
          if (reactionCounts.like > 0 && reactionCounts.heart > 0) ...[
            const SizedBox(width: 12),
            Container(
              width: 1,
              height: 12,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(width: 12),
          ],
          
          // ❤️統計
          if (reactionCounts.heart > 0) ...[
            Text(
              '❤️ ${reactionCounts.heart}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (showPercentage) ...[
              const SizedBox(width: 4),
              Text(
                '(${(reactionCounts.heart / total * 100).toStringAsFixed(0)}%)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}