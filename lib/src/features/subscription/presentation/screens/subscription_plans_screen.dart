import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/subscription_plans_data.dart';
import '../../models/subscription_plan.dart';
import '../../providers/subscription_provider.dart';
import '../widgets/plan_card.dart';
import '../screens/payment_method_screen.dart';

class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  const SubscriptionPlansScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends ConsumerState<SubscriptionPlansScreen> {
  SubscriptionPlan? _selectedPlan;

  @override
  void initState() {
    super.initState();
    
    // プラン情報を読み込む
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionProvider).loadAvailablePlans();
    });
  }

  void _selectPlan(SubscriptionPlan plan) {
    setState(() {
      _selectedPlan = plan;
    });
  }

  void _proceedToPayment() {
    if (_selectedPlan == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentMethodScreen(plan: _selectedPlan!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionProvider);
    final availablePlans = subscriptionState.availablePlans.isNotEmpty
        ? subscriptionState.availablePlans
        : SubscriptionPlansData.allPlans;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('サブスクリプションプラン'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: subscriptionState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildPlansContent(availablePlans),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildPlansContent(List<SubscriptionPlan> plans) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Starlistの料金プラン',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'あなたに最適なプランをお選びください。いつでも変更可能です。',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          
          // プランリスト
          ...plans.map((plan) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PlanCard(
              plan: plan,
              isSelected: _selectedPlan?.id == plan.id,
              onTap: () => _selectPlan(plan),
            ),
          )),
          
          const SizedBox(height: 16),
          
          // プランの利用条件説明
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'プラン利用条件',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• サブスクリプションは期間終了まで自動更新されます\n'
                    '• 解約はいつでも可能で、次の請求期間に適用されます\n'
                    '• お支払いは各種クレジットカードおよび決済サービスが利用可能です',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _selectedPlan == null ? null : _proceedToPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            '次へ進む',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
} 