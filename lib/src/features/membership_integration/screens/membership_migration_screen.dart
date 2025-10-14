import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/membership_integration_service.dart';
import '../../subscription/models/subscription_models.dart';

/// 既存会員サービス移行画面
class MembershipMigrationScreen extends ConsumerStatefulWidget {
  const MembershipMigrationScreen({super.key});

  @override
  ConsumerState<MembershipMigrationScreen> createState() => _MembershipMigrationScreenState();
}

class _MembershipMigrationScreenState extends ConsumerState<MembershipMigrationScreen> {
  bool _isLoading = false;
  MembershipIntegrationResult? _integrationResult;
  MigrationResult? _migrationResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('既存会員データ移行'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(context),
            const SizedBox(height: 30),
            _buildMigrationSection(context),
            if (_integrationResult != null) ...[
              const SizedBox(height: 30),
              _buildResultSection(context),
            ],
            if (_migrationResult != null) ...[
              const SizedBox(height: 20),
              _buildMigrationDetailsSection(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.swap_horiz,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '既存会員データの移行',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'これまでのポイント・特典をStarlistに引き継ぎます',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildMigrationBenefits(context),
      ],
    );
  }

  Widget _buildMigrationBenefits(BuildContext context) {
    final benefits = [
      {
        'icon': Icons.stars,
        'title': 'ポイント移行',
        'description': '既存ポイントを1:1でスターPに変換',
      },
      {
        'icon': Icons.card_membership,
        'title': '会員ランク継承',
        'description': '現在のランクに応じたプラン推奨',
      },
      {
        'icon': Icons.auto_awesome,
        'title': '特典引き継ぎ',
        'description': 'VIP期間・バッジ・限定アクセス権',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '移行される特典',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...benefits.map((benefit) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  benefit['icon'] as IconData,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        benefit['title'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        benefit['description'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMigrationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '移行を開始',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Icon(
                Icons.cloud_sync,
                size: 48,
                color: _isLoading 
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                _isLoading 
                    ? '会員データを確認中...'
                    : '既存の会員情報を確認して移行を行います',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _startMigration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '移行を開始',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultSection(BuildContext context) {
    final result = _integrationResult!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: result.success 
            ? Colors.green.shade50
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result.success 
              ? Colors.green.shade200
              : Colors.red.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.success ? Icons.check_circle : Icons.error,
                color: result.success ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                result.success ? '移行成功' : '移行失敗',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: result.success ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            result.message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          
          if (result.success && result.externalInfo != null) ...[
            const SizedBox(height: 16),
            _buildMembershipInfo(context, result.externalInfo!),
            
            if (result.convertedStarPoints != null && result.convertedStarPoints! > 0) ...[
              const SizedBox(height: 12),
              _buildPointConversion(context, result.convertedStarPoints!),
            ],
            
            if (result.recommendedPlan != null) ...[
              const SizedBox(height: 12),
              _buildRecommendedPlan(context, result.recommendedPlan!),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildMembershipInfo(BuildContext context, ExternalMembershipInfo info) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '移行された会員情報',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('会員ID', info.externalMemberId),
          _buildInfoRow('会員ランク', info.membershipTier.toUpperCase()),
          _buildInfoRow('会員歴', '${DateTime.now().difference(info.memberSince).inDays}日'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointConversion(BuildContext context, int convertedPoints) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.stars,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '${convertedPoints.toStringAsFixed(0)} スターP に変換されました',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedPlan(BuildContext context, SubscriptionPlanType planType) {
    final plan = SubscriptionPlans.getPlan(planType);
    if (plan == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.recommend,
            color: Colors.orange.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${plan.nameJa}プランをおすすめします',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _navigateToSubscription(planType),
            child: Text(
              'プラン詳細',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMigrationDetailsSection(BuildContext context) {
    final result = _migrationResult!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '移行詳細',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        if (result.migratedBenefits.isNotEmpty) ...[
          _buildBenefitsList(
            context,
            '移行完了',
            result.migratedBenefits,
            Colors.green,
            Icons.check_circle,
          ),
        ],
        
        if (result.failedBenefits.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildBenefitsList(
            context,
            '移行失敗',
            result.failedBenefits,
            Colors.red,
            Icons.error,
          ),
        ],
      ],
    );
  }

  Widget _buildBenefitsList(
    BuildContext context,
    String title,
    List<String> benefits,
    Color color,
    IconData iconData,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconData, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...benefits.map((benefit) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    benefit,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Future<void> _startMigration() async {
    setState(() => _isLoading = true);

    try {
      // デモ用のサービスを使用
      final service = MembershipIntegrationService(
        externalService: DemoExternalMembershipService(),
      );

      // 仮のユーザーIDを使用
      const userId = 'demo_user_123';

      // 会員連携を実行
      final integrationResult = await service.linkExternalMembership(userId);
      
      setState(() {
        _integrationResult = integrationResult;
      });

      // 成功した場合は特典移行も実行
      if (integrationResult.success && integrationResult.externalInfo != null) {
        final migrationResult = await service.migrateMemberBenefits(
          userId,
          integrationResult.externalInfo!,
        );
        
        setState(() {
          _migrationResult = migrationResult;
        });
      }

    } catch (e) {
      setState(() {
        _integrationResult = MembershipIntegrationResult.error(
          '移行中にエラーが発生しました: $e',
        );
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToSubscription(SubscriptionPlanType planType) {
    // TODO: サブスクリプション画面への遷移
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${SubscriptionPlans.getPlan(planType)?.nameJa}プラン詳細画面に遷移'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}