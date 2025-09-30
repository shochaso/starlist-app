import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../src/providers/membership_provider.dart';
import '../../../src/providers/theme_provider_enhanced.dart';

/// 無料会員向けのコンテンツ表示画面
class FreeMemberScreen extends ConsumerStatefulWidget {
  const FreeMemberScreen({super.key});

  @override
  ConsumerState<FreeMemberScreen> createState() => _FreeMemberScreenState();
}

class _FreeMemberScreenState extends ConsumerState<FreeMemberScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider).isDarkMode;
    final membershipPlan = ref.watch(currentMembershipPlanProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('スターデータ'),
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange, width: 1),
            ),
            child: Text(
              membershipPlan.type.displayName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 制限通知カード
            _buildLimitationNotice(isDark),
            const SizedBox(height: 24),
            
            // 利用可能なコンテンツ
            _buildAvailableContent(isDark),
            const SizedBox(height: 24),
            
            // 制限されたコンテンツ
            _buildRestrictedContent(isDark),
            const SizedBox(height: 24),
            
            // アップグレード促進
            _buildUpgradePrompt(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitationNotice(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '無料プラン制限',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '今月の詳細データ閲覧: 3/5回\n広告付きコンテンツが表示されます',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '👀 閲覧可能なコンテンツ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // 基本データカード
        _buildContentCard(
          title: 'スター基本情報',
          description: 'プロフィール、フォロワー数、基本統計',
          icon: Icons.person,
          isAvailable: true,
          isDark: isDark,
        ),
        
        _buildContentCard(
          title: '直近の活動（3日分）',
          description: '最新の投稿やライブ配信情報',
          icon: Icons.timeline,
          isAvailable: true,
          isDark: isDark,
        ),
        
        _buildContentCard(
          title: 'フォロー機能',
          description: 'お気に入りスターをフォロー（最大10名）',
          icon: Icons.favorite_border,
          isAvailable: true,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildRestrictedContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lock,
              color: Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              '制限されたコンテンツ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 制限コンテンツカード
        _buildContentCard(
          title: '詳細データ分析',
          description: '詳細な視聴履歴、購買パターン分析',
          icon: Icons.analytics,
          isAvailable: false,
          isDark: isDark,
          requiredPlan: 'ベーシック会員以上',
        ),
        
        _buildContentCard(
          title: 'リアルタイム更新',
          description: '1時間以内の最新データ更新',
          icon: Icons.refresh,
          isAvailable: false,
          isDark: isDark,
          requiredPlan: 'ベーシック会員以上',
        ),
        
        _buildContentCard(
          title: 'プレミアムコンテンツ',
          description: '限定動画、写真、メッセージ',
          icon: Icons.star,
          isAvailable: false,
          isDark: isDark,
          requiredPlan: 'プレミアム会員以上',
        ),
        
        _buildContentCard(
          title: 'VIP限定コンテンツ',
          description: 'VIP専用イベント、限定交流',
          icon: Icons.diamond,
          isAvailable: false,
          isDark: isDark,
          requiredPlan: 'VIP会員のみ',
        ),
      ],
    );
  }

  Widget _buildContentCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isAvailable,
    required bool isDark,
    String? requiredPlan,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAvailable 
            ? (isDark ? const Color(0xFF2A2A2A) : Colors.white)
            : (isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF5F5F5)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailable 
              ? const Color(0xFF4ECDC4).withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
        boxShadow: isAvailable ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isAvailable 
                  ? const Color(0xFF4ECDC4).withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isAvailable ? const Color(0xFF4ECDC4) : Colors.grey[600],
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
                    color: isAvailable 
                        ? (isDark ? Colors.white : Colors.black87)
                        : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isAvailable 
                        ? (isDark ? Colors.white70 : Colors.black54)
                        : Colors.grey[500],
                  ),
                ),
                if (!isAvailable && requiredPlan != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      requiredPlan,
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
          if (!isAvailable)
            Icon(
              Icons.lock,
              color: Colors.grey[400],
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildUpgradePrompt(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.upgrade,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 12),
          const Text(
            '🚀 もっと楽しもう！',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'ベーシックプランで広告なし＋詳細データを楽しもう',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // プラン選択画面に遷移
                Navigator.of(context).pushNamed('/subscription');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4ECDC4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'プランを見る ›',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}