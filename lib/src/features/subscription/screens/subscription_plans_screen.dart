import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/subscription_models.dart' as plan_models;
import '../models/subscription_plan.dart' as payment_plan;
import '../widgets/subscription_plan_card.dart';
import '../presentation/screens/payment_method_screen.dart';

/// 4プラン表示画面（更新版）
class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  const SubscriptionPlansScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState
    extends ConsumerState<SubscriptionPlansScreen> {
  plan_models.SubscriptionPlanType? selectedPlan;
  bool isYearly = true; // デフォルトで年間プランを表示

  @override
  void initState() {
    super.initState();
    // デフォルトで人気プランを選択
    selectedPlan = plan_models.SubscriptionPlans.popularPlan.planType;
  }

  @override
  Widget build(BuildContext context) {
    final plans = plan_models.SubscriptionPlans.allPlans;
    return Scaffold(
      appBar: AppBar(
        title: const Text('プラン選択'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ヘッダーセクション（余白をやや圧縮）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildHeaderSection(context),
          ),
          const SizedBox(height: 8),
          // 年額/月額切り替え
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildBillingToggle(context),
          ),
          const SizedBox(height: 12),
          // プラン一覧（縦にそのまま並べる）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                for (final plan in plans)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SubscriptionPlanCard(
                      plan: plan,
                      isSelected: selectedPlan == plan.planType,
                      isYearly: isYearly,
                      onTap: () => setState(() => selectedPlan = plan.planType),
                      showRemovedFeatures: false,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // フッター（スクロールに含める）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildFooterSection(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Column(
        children: [
          Text(
            'あなたにぴったりのプランを\n見つけてください',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'すべてのプランで毎日ピック機能をお楽しみいただけます',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          _buildRemovedFeaturesNotice(context),
        ],
      ),
    );
  }

  Widget _buildRemovedFeaturesNotice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingToggle(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isYearly = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isYearly ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: !isYearly
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  '月額プラン',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: !isYearly ? Colors.black : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isYearly = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isYearly ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: isYearly
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '年額プラン',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isYearly ? Colors.black : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '2ヶ月無料',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // _buildPlansList は未使用になったが、必要なら別画面で再利用可能

  Widget _buildFooterSection(BuildContext context) {
    final selectedPlanData = selectedPlan != null
        ? plan_models.SubscriptionPlans.getPlan(selectedPlan!)
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedPlanData != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${selectedPlanData.nameJa}プラン',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      isYearly
                          ? '年額 ¥${selectedPlanData.priceYearlyJpy}（月あたり ¥${selectedPlanData.yearlyMonthlyEquivalent}）'
                          : '月額 ¥${selectedPlanData.priceMonthlyJpy}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
                Text(
                  '${selectedPlanData.starPointsMonthly}P/月',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed:
                  selectedPlan != null ? () => _proceedToPayment() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '支払い方法を選択',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• いつでもキャンセル可能です\n• 初回7日間無料トライアル\n• 自動更新（設定で変更可能）',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

  void _proceedToPayment() {
    // 支払い画面へ遷移
    final planData = plan_models.SubscriptionPlans.getPlan(selectedPlan!);
    if (planData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('プラン情報の取得に失敗しました')),
      );
      return;
    }

    final paymentPlan = _mapToPaymentPlan(planData, isYearly: isYearly);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentMethodScreen(
          plan: paymentPlan,
          isYearly: isYearly,
        ),
      ),
    );
  }

  payment_plan.SubscriptionPlan _mapToPaymentPlan(
      plan_models.SubscriptionPlan plan,
      {required bool isYearly}) {
    final isFree = plan.planType == plan_models.SubscriptionPlanType.free;
    final double price = isFree
        ? 0
        : isYearly
            ? plan.priceYearlyJpy.toDouble()
            : plan.priceMonthlyJpy.toDouble();
    final duration =
        isYearly ? const Duration(days: 365) : const Duration(days: 30);

    final idSuffix = isYearly ? 'yearly' : 'monthly';

    return payment_plan.SubscriptionPlan(
      id: '${plan.planType.name}_$idSuffix',
      name: isYearly ? '${plan.nameJa}（年額）' : plan.nameJa,
      description: plan.description ?? (isYearly ? '年額プラン' : '月額プラン'),
      price: price,
      currency: 'JPY',
      billingPeriod: duration,
      features: plan.benefits,
      isPopular: plan.isPopular,
      metadata: {
        'interval': isYearly ? 'yearly' : 'monthly',
        'plan_type': plan.planType.name,
        'star_points_monthly': plan.starPointsMonthly,
        'removed_features': plan.removedFeatures,
        if (isYearly) 'discount_months_free': 2,
        if (isYearly) 'yearly_monthly_equivalent': plan.yearlyMonthlyEquivalent,
      },
    );
  }
}
