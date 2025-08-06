import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../src/providers/theme_provider_enhanced.dart';
import '../../../src/providers/membership_provider.dart';

class FanSubscriptionScreen extends ConsumerStatefulWidget {
  const FanSubscriptionScreen({super.key});

  @override
  ConsumerState<FanSubscriptionScreen> createState() => _FanSubscriptionScreenState();
}

class _FanSubscriptionScreenState extends ConsumerState<FanSubscriptionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    final currentMembership = ref.watch(membershipProvider);
    final plans = ref.watch(membershipPlansProvider);
    
    return Container(
      color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ヘッダーセクション
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildHeaderSection(isDark, currentMembership),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // プラン一覧
                  ...plans.asMap().entries.map((entry) {
                    final index = entry.key;
                    final plan = entry.value;
                    
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0, 0.2 + (index * 0.1)),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            0.3 + (index * 0.1), 
                            1.0, 
                            curve: Curves.easeOutCubic,
                          ),
                        )),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: _buildPlanCard(plan, currentMembership, isDark),
                        ),
                      ),
                    );
                  }).toList(),
                  
                  const SizedBox(height: 32),
                  
                  // 特典比較表
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildFeatureComparison(isDark, plans),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(bool isDark, MembershipType currentMembership) {
    final currentPlan = ref.watch(membershipPlansProvider)
        .firstWhere((plan) => plan.type == currentMembership);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: _getPlanGradient(currentMembership),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getPlanColor(currentMembership).withOpacity( 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _getPlanIcon(currentMembership),
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            '現在のプラン',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentPlan.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          if (currentMembership != MembershipType.free) ...[
            const SizedBox(height: 8),
            Text(
              '月額 ¥${_formatPrice(currentMembership.monthlyPrice)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            currentPlan.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(MembershipPlan plan, MembershipType currentMembership, bool isDark) {
    final isCurrentPlan = plan.type == currentMembership;
    final isUpgrade = plan.type.index > currentMembership.index;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrentPlan 
              ? _getPlanColor(plan.type)
              : (isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0)),
          width: isCurrentPlan ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrentPlan 
                ? _getPlanColor(plan.type).withOpacity( 0.2)
                : (isDark ? Colors.black.withOpacity( 0.3) : Colors.black.withOpacity( 0.1)),
            blurRadius: isCurrentPlan ? 20 : 10,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // プランヘッダー
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: isCurrentPlan 
                  ? _getPlanGradient(plan.type)
                  : null,
              color: isCurrentPlan 
                  ? null 
                  : (isDark ? const Color(0xFF333333) : const Color(0xFFF8FAFC)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      _getPlanIcon(plan.type),
                      color: isCurrentPlan 
                          ? Colors.white 
                          : _getPlanColor(plan.type),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        plan.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isCurrentPlan 
                              ? Colors.white 
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ),
                    if (plan.isPopular && !isCurrentPlan) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '人気',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    if (isCurrentPlan) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity( 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '現在',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan.type == MembershipType.free ? '無料' : '¥${_formatPrice(plan.type.monthlyPrice)}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: isCurrentPlan 
                            ? Colors.white 
                            : _getPlanColor(plan.type),
                        letterSpacing: -1,
                      ),
                    ),
                    if (plan.type != MembershipType.free) ...[
                      Text(
                        '/月',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isCurrentPlan 
                              ? Colors.white70 
                              : (isDark ? Colors.white54 : Colors.black54),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  plan.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isCurrentPlan 
                        ? Colors.white70 
                        : (isDark ? Colors.white70 : Colors.black54),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          // 機能一覧
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 特典
                if (plan.features.isNotEmpty) ...[
                  Text(
                    '✨ 利用できる機能',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...plan.features.map((feature) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: _getPlanColor(plan.type),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.black54,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
                
                // 制限
                if (plan.restrictions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    '⚠️ 制限事項',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...plan.restrictions.map((restriction) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cancel,
                          color: Colors.grey[500],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            restriction,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
                
                const SizedBox(height: 24),
                
                // アクションボタン
                _buildActionButton(plan, isCurrentPlan, isUpgrade, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(MembershipPlan plan, bool isCurrentPlan, bool isUpgrade, bool isDark) {
    if (isCurrentPlan) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity( 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity( 0.3)),
        ),
        child: Text(
          '現在のプラン',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _subscribeToPlan(plan),
        style: ElevatedButton.styleFrom(
          backgroundColor: _getPlanColor(plan.type),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          isUpgrade ? 'アップグレード' : 'プランを選択',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureComparison(bool isDark, List<MembershipPlan> plans) {
    final features = [
      '毎日ピック from Star閲覧',
      'スター基本プロフィール閲覧',
      '選択3データカテゴリ閲覧',
      '全データカテゴリ閲覧',
      '詳細データ（商品コメント・レビュー）',
      '投票機能参加',
       'プレミアムファンバッジ',
    ];
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              '📊 機能比較表',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          ...features.asMap().entries.map((entry) {
            final index = entry.key;
            final feature = entry.value;
            final isLast = index == features.length - 1;
            
            return _buildComparisonRow(feature, _getFeatureAccess(feature), isDark, isLast);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String feature, List<bool> access, bool isDark, bool isLast) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          ...access.asMap().entries.map((entry) {
            final index = entry.key;
            final hasAccess = entry.value;
            
            return Expanded(
              child: Center(
                child: Icon(
                  hasAccess ? Icons.check_circle : Icons.cancel,
                  color: hasAccess ? Colors.green : Colors.grey[400],
                  size: 20,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  List<bool> _getFeatureAccess(String feature) {
    switch (feature) {
      case '毎日ピック from Star閲覧':
        return [true, true, true, true];
      case 'スター基本プロフィール閲覧':
        return [true, true, true, true];
      case '選択3データカテゴリ閲覧':
        return [false, true, true, true];
      case '全データカテゴリ閲覧':
        return [false, false, true, true];
      case '詳細データ（商品コメント・レビュー）':
        return [false, false, false, true];
      case '投票機能参加':
        return [false, true, true, true];
      case 'プレミアムファンバッジ':
        return [false, false, false, true];
      default:
        return [false, false, false, false];
    }
  }

  Color _getPlanColor(MembershipType type) {
    switch (type) {
      case MembershipType.free:
        return Colors.grey;
      case MembershipType.light:
        return const Color(0xFF4ECDC4);
      case MembershipType.standard:
        return const Color(0xFF667EEA);
      case MembershipType.premium:
        return const Color(0xFFFFD700);
    }
  }

  LinearGradient _getPlanGradient(MembershipType type) {
    switch (type) {
      case MembershipType.free:
        return const LinearGradient(
          colors: [Colors.grey, Color(0xFF757575)],
        );
      case MembershipType.light:
        return const LinearGradient(
          colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
        );
      case MembershipType.standard:
        return const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        );
      case MembershipType.premium:
        return const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
        );
    }
  }

  IconData _getPlanIcon(MembershipType type) {
    switch (type) {
      case MembershipType.free:
        return Icons.person;
      case MembershipType.light:
        return Icons.star_border;
      case MembershipType.standard:
        return Icons.star_half;
      case MembershipType.premium:
        return FontAwesomeIcons.crown;
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]},',
    );
  }

  void _subscribeToPlan(MembershipPlan plan) {
    HapticFeedback.lightImpact();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              _getPlanIcon(plan.type),
              color: _getPlanColor(plan.type),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'プラン変更確認',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${plan.title}に変更しますか？',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            if (plan.type != MembershipType.free) ...[
              Text(
                '月額料金: ¥${_formatPrice(plan.type.monthlyPrice)}',
                style: TextStyle(
                  color: _getPlanColor(plan.type),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              plan.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'キャンセル',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(membershipProvider.notifier).changeMembership(plan.type);
              Navigator.of(context).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${plan.title}に変更しました'),
                  backgroundColor: _getPlanColor(plan.type),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getPlanColor(plan.type),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '変更する',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}