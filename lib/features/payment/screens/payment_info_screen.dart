import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/theme_provider.dart';

class PaymentInfoScreen extends ConsumerStatefulWidget {
  const PaymentInfoScreen({super.key});

  @override
  ConsumerState<PaymentInfoScreen> createState() => _PaymentInfoScreenState();
}

class _PaymentInfoScreenState extends ConsumerState<PaymentInfoScreen> {
  // 保存されている支払い方法
  final List<Map<String, dynamic>> _savedPaymentMethods = [
    {
      'id': '1',
      'type': 'credit_card',
      'name': 'Visa ****1234',
      'expiry': '12/25',
      'isDefault': true,
      'lastUsed': '2024-01-20',
    },
    {
      'id': '2',
      'type': 'paypal',
      'name': 'PayPal (john@example.com)',
      'isDefault': false,
      'lastUsed': '2024-01-15',
    },
  ];

  // 支払い履歴
  final List<Map<String, dynamic>> _paymentHistory = [
    {
      'id': '1',
      'date': '2024-01-20',
      'amount': 1980,
      'plan': 'スタンダードプラン',
      'status': 'completed',
      'method': 'Visa ****1234',
    },
    {
      'id': '2',
      'date': '2023-12-20',
      'amount': 1980,
      'plan': 'スタンダードプラン',
      'status': 'completed',
      'method': 'Visa ****1234',
    },
    {
      'id': '3',
      'date': '2023-11-20',
      'amount': 980,
      'plan': 'ライトプラン',
      'status': 'completed',
      'method': 'PayPal',
    },
  ];

  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'お支払い情報',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (_selectedTabIndex == 0)
            IconButton(
              icon: Icon(
                Icons.add,
                color: isDark ? Colors.white : Colors.black87,
              ),
              onPressed: () => _addPaymentMethod(),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // タブバー
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _buildTabItem('支払い方法', 0),
                  _buildTabItem('利用履歴', 1),
                  _buildTabItem('請求書', 2),
                ],
              ),
            ),
            
            // タブコンテンツ
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildTabItem(String label, int index) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    final isSelected = _selectedTabIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4ECDC4) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildPaymentMethodsTab();
      case 1:
        return _buildPaymentHistoryTab();
      case 2:
        return _buildInvoicesTab();
      default:
        return Container();
    }
  }

  Widget _buildPaymentMethodsTab() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 現在のプラン情報
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '現在のプラン',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'スタンダードプラン',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '¥1,980/月',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      '次回請求日: 2024-02-20',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 支払い方法リスト
          Text(
            '登録済み支払い方法',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          ..._savedPaymentMethods.map((method) => _buildPaymentMethodCard(method)).toList(),
          
          const SizedBox(height: 20),
          
          // 新しい支払い方法を追加ボタン
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _addPaymentMethod(),
              icon: const Icon(Icons.add, color: Color(0xFF4ECDC4)),
              label: const Text(
                '新しい支払い方法を追加',
                style: TextStyle(
                  color: Color(0xFF4ECDC4),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF4ECDC4)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    IconData methodIcon;
    Color methodColor;
    
    switch (method['type']) {
      case 'credit_card':
        methodIcon = Icons.credit_card;
        methodColor = const Color(0xFF4ECDC4);
        break;
      case 'paypal':
        methodIcon = Icons.paypal;
        methodColor = const Color(0xFF0070BA);
        break;
      case 'apple_pay':
        methodIcon = Icons.apple;
        methodColor = const Color(0xFF000000);
        break;
      default:
        methodIcon = Icons.payment;
        methodColor = const Color(0xFF888888);
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: method['isDefault'] ? const Color(0xFF4ECDC4) : (isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
          width: method['isDefault'] ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: methodColor.withOpacity( 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(methodIcon, color: methodColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            method['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        if (method['isDefault'])
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4ECDC4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'デフォルト',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (method['expiry'] != null)
                      Text(
                        '有効期限: ${method['expiry']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF888888) : Colors.black54,
                        ),
                      ),
                    Text(
                      '最終使用: ${method['lastUsed']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF888888) : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: isDark ? const Color(0xFF888888) : Colors.black54,
                ),
                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                onSelected: (value) => _handlePaymentMethodAction(value, method),
                itemBuilder: (context) => [
                  if (!method['isDefault'])
                    PopupMenuItem(
                      value: 'set_default',
                      child: Row(
                        children: [
                          Icon(Icons.star, color: isDark ? Colors.white : Colors.black87, size: 20),
                          const SizedBox(width: 8),
                          Text('デフォルトに設定', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: isDark ? Colors.white : Colors.black87, size: 20),
                        const SizedBox(width: 8),
                        Text('編集', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('削除', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryTab() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '支払い履歴',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ..._paymentHistory.map((payment) => _buildPaymentHistoryCard(payment)).toList(),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryCard(Map<String, dynamic> payment) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (payment['status']) {
      case 'completed':
        statusColor = const Color(0xFF4CAF50);
        statusText = '完了';
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = const Color(0xFFFF9800);
        statusText = '処理中';
        statusIcon = Icons.access_time;
        break;
      case 'failed':
        statusColor = const Color(0xFFFF6B6B);
        statusText = '失敗';
        statusIcon = Icons.error;
        break;
      default:
        statusColor = const Color(0xFF888888);
        statusText = '不明';
        statusIcon = Icons.help;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                payment['plan'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity( 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '¥${payment['amount'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: isDark ? const Color(0xFF888888) : Colors.black54,
              ),
              const SizedBox(width: 4),
              Text(
                payment['date'],
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF888888) : Colors.black54,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.payment,
                size: 16,
                color: isDark ? const Color(0xFF888888) : Colors.black54,
              ),
              const SizedBox(width: 4),
              Text(
                payment['method'],
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF888888) : Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _downloadReceipt(payment),
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('領収書'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4ECDC4),
                    side: const BorderSide(color: Color(0xFF4ECDC4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewPaymentDetails(payment),
                  icon: const Icon(Icons.info, size: 16),
                  label: const Text('詳細'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white70 : Colors.black54,
                    side: BorderSide(color: isDark ? Colors.white70 : Colors.black54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesTab() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '請求書',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: isDark ? const Color(0xFF888888) : Colors.black26,
                ),
                const SizedBox(height: 16),
                Text(
                  '請求書が利用可能になりました',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '月次および年次の請求書をダウンロード\nして会計処理にご利用ください',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFF888888) : Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _generateInvoice(),
                  icon: const Icon(Icons.download),
                  label: const Text('請求書をダウンロード'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addPaymentMethod() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('新しい支払い方法の追加画面を開きます'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  void _handlePaymentMethodAction(String action, Map<String, dynamic> method) {
    switch (action) {
      case 'set_default':
        setState(() {
          for (var m in _savedPaymentMethods) {
            m['isDefault'] = false;
          }
          method['isDefault'] = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('デフォルトの支払い方法を設定しました'),
            backgroundColor: Color(0xFF4ECDC4),
          ),
        );
        break;
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('支払い方法の編集画面を開きます'),
            backgroundColor: Color(0xFF4ECDC4),
          ),
        );
        break;
      case 'delete':
        _showDeletePaymentMethodDialog(method);
        break;
    }
  }

  void _showDeletePaymentMethodDialog(Map<String, dynamic> method) {
    final themeMode = ref.read(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        title: const Text(
          '支払い方法を削除',
          style: TextStyle(color: Color(0xFFFF6B6B)),
        ),
        content: Text(
          '${method['name']}を削除しますか？\nこの操作は元に戻せません。',
          style: TextStyle(color: isDark ? const Color(0xFF888888) : Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'キャンセル',
              style: TextStyle(color: isDark ? const Color(0xFF888888) : Colors.black54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _savedPaymentMethods.remove(method);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('支払い方法を削除しました'),
                  backgroundColor: Color(0xFFFF6B6B),
                ),
              );
            },
            child: const Text(
              '削除',
              style: TextStyle(color: Color(0xFFFF6B6B)),
            ),
          ),
        ],
      ),
    );
  }

  void _downloadReceipt(Map<String, dynamic> payment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${payment['plan']}の領収書をダウンロード中...'),
        backgroundColor: const Color(0xFF4ECDC4),
      ),
    );
  }

  void _viewPaymentDetails(Map<String, dynamic> payment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${payment['plan']}の詳細情報を表示'),
        backgroundColor: const Color(0xFF4ECDC4),
      ),
    );
  }

  void _generateInvoice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('請求書を生成しています...'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black).withOpacity( 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBottomNavItem(Icons.home, 'ホーム', () {
                context.go('/home');
              }),
              _buildBottomNavItem(Icons.search, '検索', () {
                context.go('/home');
              }),
              _buildBottomNavItem(Icons.notifications, '通知', () {
                context.go('/home');
              }),
              _buildBottomNavItem(Icons.star, 'マイリスト', () {
                context.go('/home');
              }),
              _buildBottomNavItem(Icons.person, 'マイページ', null, isSelected: true),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBottomNavItem(IconData icon, String label, VoidCallback? onTap, {bool isSelected = false}) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected 
                    ? const Color(0xFF4ECDC4) 
                    : (isDark ? Colors.white54 : const Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isSelected 
                      ? const Color(0xFF4ECDC4) 
                      : (isDark ? Colors.white54 : const Color(0xFF9CA3AF)),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}