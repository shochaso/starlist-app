import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../src/providers/membership_provider.dart';
import '../../../src/providers/theme_provider_enhanced.dart';
import 'free_member_screen.dart';
import 'premium_member_screen.dart';

/// 会員種別デモ画面 - アクセス制御の違いを体験
class MembershipDemoScreen extends ConsumerStatefulWidget {
  const MembershipDemoScreen({super.key});

  @override
  ConsumerState<MembershipDemoScreen> createState() => _MembershipDemoScreenState();
}

class _MembershipDemoScreenState extends ConsumerState<MembershipDemoScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider).isDarkMode;
    final currentMembership = ref.watch(membershipProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('会員制アクセスデモ'),
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 現在の会員状態表示
            _buildCurrentStatusCard(isDark, currentMembership),
            const SizedBox(height: 24),
            
            // 会員切り替えセクション
            _buildMembershipSwitcher(isDark, currentMembership),
            const SizedBox(height: 24),
            
            // アクセステストセクション
            _buildAccessTestSection(isDark, currentMembership),
            const SizedBox(height: 24),
            
            // 機能比較表
            _buildFeatureComparisonTable(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatusCard(bool isDark, MembershipType currentMembership) {
    final plan = ref.watch(membershipPlansProvider)
        .firstWhere((p) => p.type == currentMembership);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _getMembershipGradient(currentMembership),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            _getMembershipIcon(currentMembership),
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            '現在の会員種別',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            plan.type.displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          if (plan.type != MembershipType.free) ...[
            const SizedBox(height: 8),
            Text(
              '月額 ¥${plan.type.monthlyPrice}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMembershipSwitcher(bool isDark, MembershipType currentMembership) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🔄 会員種別を体験',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '異なる会員種別でのアクセス権限を体験してみましょう',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 16),
        
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: MembershipType.values.map((type) {
            final isSelected = type == currentMembership;
            
            return GestureDetector(
              onTap: () {
                ref.read(membershipProvider.notifier).changeMembership(type);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFF4ECDC4)
                      : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFF4ECDC4)
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getMembershipIcon(type),
                      color: isSelected ? Colors.white : const Color(0xFF4ECDC4),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected 
                            ? Colors.white 
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAccessTestSection(bool isDark, MembershipType currentMembership) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🚪 アクセステスト',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '現在の会員レベルでアクセス可能なページを確認',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 16),
        
        _buildAccessButton(
          title: '無料会員向けページ',
          description: '基本コンテンツと制限情報',
          icon: Icons.lock_open,
          canAccess: true,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const FreeMemberScreen(),
              ),
            );
          },
          isDark: isDark,
        ),
        
        _buildAccessButton(
          title: 'プレミアムコンテンツページ',
          description: '詳細データ、限定コンテンツ、ダウンロード機能',
          icon: Icons.star,
          canAccess: currentMembership.index >= MembershipType.light.index,
          requiredLevel: 'ライトプラン以上',
          onTap: () {
            if (currentMembership.index >= MembershipType.light.index) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PremiumMemberScreen(),
                ),
              );
            } else {
              _showAccessDeniedDialog(context, 'ライトプラン以上');
            }
          },
          isDark: isDark,
        ),
        
        _buildAccessButton(
          title: 'プレミアム限定ページ',
          description: 'プレミアム専用イベント、限定交流機会',
          icon: Icons.diamond,
          canAccess: currentMembership == MembershipType.premium,
          requiredLevel: 'プレミアムプランのみ',
          onTap: () {
            if (currentMembership == MembershipType.premium) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PremiumMemberScreen(),
                ),
              );
            } else {
              _showAccessDeniedDialog(context, 'プレミアムプランのみ');
            }
          },
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildAccessButton({
    required String title,
    required String description,
    required IconData icon,
    required bool canAccess,
    required VoidCallback onTap,
    required bool isDark,
    String? requiredLevel,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: canAccess 
                  ? (isDark ? const Color(0xFF2A2A2A) : Colors.white)
                  : (isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF5F5F5)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: canAccess 
                    ? const Color(0xFF4ECDC4).withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: canAccess 
                        ? const Color(0xFF4ECDC4).withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    canAccess ? icon : Icons.lock,
                    color: canAccess ? const Color(0xFF4ECDC4) : Colors.grey[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: canAccess 
                              ? (isDark ? Colors.white : Colors.black87)
                              : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: canAccess 
                              ? (isDark ? Colors.white70 : Colors.black54)
                              : Colors.grey[500],
                        ),
                      ),
                      if (!canAccess && requiredLevel != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '要求レベル: $requiredLevel',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  canAccess ? Icons.arrow_forward_ios : Icons.lock,
                  color: canAccess ? const Color(0xFF4ECDC4) : Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureComparisonTable(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📊 機能比較表',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              _buildComparisonRow('基本データ閲覧', [true, true, true, true], isDark),
              _buildComparisonRow('詳細分析', [false, true, true, true], isDark),
              _buildComparisonRow('広告なし', [false, true, true, true], isDark),
              _buildComparisonRow('プレミアムコンテンツ', [false, false, true, true], isDark),
              _buildComparisonRow('高画質動画', [false, false, true, true], isDark),
              _buildComparisonRow('ダウンロード機能', [false, false, false, true], isDark),
              _buildComparisonRow('限定イベント', [false, false, false, true], isDark, isLast: true),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 凡例
        Row(
          children: [
            _buildLegendItem('無料', Colors.grey, isDark),
            const SizedBox(width: 12),
            _buildLegendItem('ライト', const Color(0xFF4ECDC4), isDark),
            const SizedBox(width: 12),
            _buildLegendItem('スタンダード', const Color(0xFF667EEA), isDark),
            const SizedBox(width: 12),
            _buildLegendItem('プレミアム', const Color(0xFFFFD700), isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildComparisonRow(String feature, List<bool> access, bool isDark, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
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
          ...List.generate(4, (index) {
            return Expanded(
              child: Center(
                child: Icon(
                  access[index] ? Icons.check_circle : Icons.cancel,
                  color: access[index] ? Colors.green : Colors.red,
                  size: 20,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  LinearGradient _getMembershipGradient(MembershipType type) {
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

  IconData _getMembershipIcon(MembershipType type) {
    switch (type) {
      case MembershipType.free:
        return Icons.person;
      case MembershipType.light:
        return Icons.star_border;
      case MembershipType.standard:
        return Icons.star_half;
      case MembershipType.premium:
        return Icons.diamond;
    }
  }

  void _showAccessDeniedDialog(BuildContext context, String requiredLevel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.red),
            SizedBox(width: 8),
            Text('アクセス制限'),
          ],
        ),
        content: Text('このコンテンツは$requiredLevel限定です。\n会員種別を変更してお試しください。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // プラン変更画面に遷移する場合
              Navigator.of(context).pushNamed('/subscription');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ECDC4),
              foregroundColor: Colors.white,
            ),
            child: const Text('プラン変更'),
          ),
        ],
      ),
    );
  }
}