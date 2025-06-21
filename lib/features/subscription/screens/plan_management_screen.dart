import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PlanManagementScreen extends StatefulWidget {
  const PlanManagementScreen({super.key});

  @override
  State<PlanManagementScreen> createState() => _PlanManagementScreenState();
}

class _PlanManagementScreenState extends State<PlanManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // プランデータ
  final List<Map<String, dynamic>> _plans = [
    {
      'id': 'light',
      'name': 'ライトプラン',
      'price': 500,
      'subscribers': 1250,
      'revenue': 625000,
      'features': ['基本コンテンツ閲覧', '月1回の限定投稿', 'コメント機能'],
      'color': const Color(0xFF95E1D3),
      'isActive': true,
    },
    {
      'id': 'standard',
      'name': 'スタンダードプラン',
      'price': 2000,
      'subscribers': 850,
      'revenue': 1700000,
      'features': ['全コンテンツ閲覧', '週2回の限定投稿', 'DM機能', '優先サポート'],
      'color': const Color(0xFF4ECDC4),
      'isActive': true,
    },
    {
      'id': 'premium',
      'name': 'プレミアムプラン',
      'price': 5000,
      'subscribers': 320,
      'revenue': 1600000,
      'features': ['全コンテンツ閲覧', '毎日の限定投稿', 'ビデオ通話', '限定グッズ', '特別イベント招待'],
      'color': const Color(0xFFFFE66D),
      'isActive': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          'プラン管理',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showCreatePlanDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.analytics, color: Colors.white),
            onPressed: () => _showAnalytics(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF4ECDC4),
          labelColor: const Color(0xFF4ECDC4),
          unselectedLabelColor: const Color(0xFF888888),
          tabs: const [
            Tab(text: 'プラン一覧'),
            Tab(text: '統計'),
            Tab(text: '設定'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlansTab(),
          _buildStatisticsTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildPlansTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlanOverview(),
          const SizedBox(height: 20),
          const Text(
            'プラン一覧',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ..._plans.map((plan) => _buildPlanCard(plan)).toList(),
        ],
      ),
    );
  }

  Widget _buildPlanOverview() {
    final totalSubscribers = _plans.fold<int>(0, (sum, plan) => sum + (plan['subscribers'] as int));
    final totalRevenue = _plans.fold<int>(0, (sum, plan) => sum + (plan['revenue'] as int));
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'プラン概要',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '総会員数',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatNumber(totalSubscribers)}人',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '月間収益',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '¥${_formatNumber(totalRevenue)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: plan['color'],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  plan['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Switch(
                value: plan['isActive'],
                onChanged: (value) => _togglePlanStatus(plan['id'], value),
                activeColor: const Color(0xFF4ECDC4),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPlanStat(
                  '価格',
                  '¥${_formatNumber(plan['price'])}/月',
                  Icons.monetization_on,
                ),
              ),
              Expanded(
                child: _buildPlanStat(
                  '会員数',
                  '${_formatNumber(plan['subscribers'])}人',
                  Icons.people,
                ),
              ),
              Expanded(
                child: _buildPlanStat(
                  '月間収益',
                  '¥${_formatNumber(plan['revenue'])}',
                  Icons.trending_up,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '特典内容',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          ...plan['features'].map<Widget>((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: plan['color'],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  feature,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          )).toList(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _editPlan(plan),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: plan['color']),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '編集',
                    style: TextStyle(color: plan['color']),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _viewPlanDetails(plan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: plan['color'],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '詳細',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanStat(String title, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF4ECDC4), size: 16),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF888888),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRevenueChart(),
          const SizedBox(height: 20),
          _buildSubscriberGrowth(),
          const SizedBox(height: 20),
          _buildPlanComparison(),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '収益推移',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Expanded(
            child: Center(
              child: Text(
                '収益チャート\n（実装予定）',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF888888),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriberGrowth() {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '会員数推移',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Expanded(
            child: Center(
              child: Text(
                '会員数チャート\n（実装予定）',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF888888),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'プラン比較',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: Column(
            children: _plans.map((plan) => _buildComparisonItem(plan)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonItem(Map<String, dynamic> plan) {
    final conversionRate = (plan['revenue'] / (plan['subscribers'] * plan['price']) * 100).toStringAsFixed(1);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: plan['color'],
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              plan['name'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${plan['subscribers']}人',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '$conversionRate%',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF888888),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGeneralSettings(),
          const SizedBox(height: 20),
          _buildPaymentSettings(),
          const SizedBox(height: 20),
          _buildNotificationSettings(),
        ],
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '一般設定',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            '自動更新',
            'プラン価格の自動更新を有効にする',
            true,
            (value) => {},
          ),
          _buildSettingItem(
            '新規会員通知',
            '新しい会員登録時に通知を受け取る',
            true,
            (value) => {},
          ),
          _buildSettingItem(
            'プラン変更通知',
            '会員のプラン変更時に通知を受け取る',
            false,
            (value) => {},
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSettings() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '支払い設定',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildPaymentMethodItem('Stripe', 'クレジットカード決済', true),
          _buildPaymentMethodItem('PayPal', 'PayPal決済', false),
          _buildPaymentMethodItem('Apple Pay', 'Apple Pay決済', true),
          _buildPaymentMethodItem('Google Pay', 'Google Pay決済', true),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem(String name, String description, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) => {},
            activeColor: const Color(0xFF4ECDC4),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '通知設定',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            'メール通知',
            '重要な更新をメールで受け取る',
            true,
            (value) => {},
          ),
          _buildSettingItem(
            'プッシュ通知',
            'アプリ内通知を受け取る',
            true,
            (value) => {},
          ),
          _buildSettingItem(
            '週次レポート',
            '週次の収益レポートを受け取る',
            false,
            (value) => {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, String description, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4ECDC4),
          ),
        ],
      ),
    );
  }

  // ヘルパーメソッド
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  // アクションメソッド
  void _showCreatePlanDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          '新しいプランを作成',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'プラン作成機能は実装予定です。',
          style: TextStyle(color: Color(0xFF888888)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF4ECDC4)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAnalytics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('詳細分析画面に移動します'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  void _togglePlanStatus(String planId, bool isActive) {
    setState(() {
      final planIndex = _plans.indexWhere((plan) => plan['id'] == planId);
      if (planIndex != -1) {
        _plans[planIndex]['isActive'] = isActive;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isActive ? 'プランを有効にしました' : 'プランを無効にしました'),
        backgroundColor: const Color(0xFF4ECDC4),
      ),
    );
  }

  void _editPlan(Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(
          '${plan['name']}を編集',
          style: const TextStyle(color: Colors.white),
        ),
        content: const Text(
          'プラン編集機能は実装予定です。',
          style: TextStyle(color: Color(0xFF888888)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'キャンセル',
              style: TextStyle(color: Color(0xFF888888)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '保存',
              style: TextStyle(color: Color(0xFF4ECDC4)),
            ),
          ),
        ],
      ),
    );
  }

  void _viewPlanDetails(Map<String, dynamic> plan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan['name'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '価格: ¥${_formatNumber(plan['price'])}/月',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            Text(
              '会員数: ${_formatNumber(plan['subscribers'])}人',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            Text(
              '月間収益: ¥${_formatNumber(plan['revenue'])}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
} 