import 'package:flutter/material.dart';
import '../models/subscription_models.dart';

/// サブスクリプションプランカードウィジェット
class SubscriptionPlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final bool isYearly;
  final VoidCallback? onTap;
  final bool showRemovedFeatures;

  const SubscriptionPlanCard({
    Key? key,
    required this.plan,
    this.isSelected = false,
    this.isYearly = false,
    this.onTap,
    this.showRemovedFeatures = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final price = isYearly ? plan.yearlyMonthlyEquivalent : plan.priceMonthlyJpy;
    final originalPrice = isYearly ? plan.priceMonthlyJpy : null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected 
              ? Theme.of(context).primaryColor.withOpacity(0.05)
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 人気プランバッジ
            if (plan.isPopular)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    '👑 人気No.1',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            
            // メインコンテンツ
            Padding(
              padding: EdgeInsets.all(20).copyWith(
                top: plan.isPopular ? 44 : 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // プラン名とアイコン
                  Row(
                    children: [
                      _buildPlanIcon(context),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.nameJa,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected 
                                    ? Theme.of(context).primaryColor
                                    : null,
                              ),
                            ),
                            if (plan.description != null)
                              Text(
                                plan.description!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 価格表示
                  _buildPriceSection(context, price, originalPrice),
                  
                  const SizedBox(height: 20),
                  
                  // スターP付与
                  _buildStarPointsSection(context),
                  
                  const SizedBox(height: 16),
                  
                  // 特典リスト
                  _buildBenefitsList(context),
                  
                  // 削除された機能（デバッグ用）
                  if (showRemovedFeatures && plan.removedFeatures.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildRemovedFeaturesList(context),
                  ],
                  
                  const SizedBox(height: 20),
                  
                  // 選択ボタン
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected 
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade200,
                        foregroundColor: isSelected 
                            ? Colors.white 
                            : Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isSelected ? '選択済み' : 'プランを選択',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanIcon(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (plan.planType) {
      case SubscriptionPlanType.basic:
        iconData = Icons.star_outline;
        iconColor = Colors.blue;
        break;
      case SubscriptionPlanType.standard:
        iconData = Icons.star_half;
        iconColor = Colors.purple;
        break;
      case SubscriptionPlanType.premium:
        iconData = Icons.star;
        iconColor = Colors.orange;
        break;
      case SubscriptionPlanType.ultimate:
        iconData = Icons.auto_awesome;
        iconColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  Widget _buildPriceSection(BuildContext context, int price, int? originalPrice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: [
            Text(
              '¥${price.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              '/月',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            if (originalPrice != null && originalPrice > price) ...[
              const SizedBox(width: 8),
              Text(
                '¥${originalPrice.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ],
        ),
        if (isYearly) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '年払いで${((plan.yearlyDiscountRate * 100).round())}%オフ',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStarPointsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
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
            '月間 ${plan.starPointsMonthly.toStringAsFixed(0)} スターP付与',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '含まれる特典',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...plan.benefits.map((benefit) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 16,
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
    );
  }

  Widget _buildRemovedFeaturesList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '削除された機能',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.red.shade700,
          ),
        ),
        const SizedBox(height: 8),
        ...plan.removedFeatures.map((feature) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.remove_circle,
                color: Colors.red.shade400,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  feature,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red.shade600,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}