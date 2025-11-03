import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:starlist_app/widgets/media_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/subscription_plan.dart';
import '../../providers/subscription_provider.dart';

class PaymentMethodScreen extends ConsumerStatefulWidget {
  final SubscriptionPlan plan;
  final bool isYearly;

  const PaymentMethodScreen({
    super.key,
    required this.plan,
    this.isYearly = false,
  });

  @override
  ConsumerState<PaymentMethodScreen> createState() =>
      _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedPaymentMethod = 'credit_card';

  // カード情報
  String _cardNumber = '';
  String _expiryDate = '';
  String _cvv = '';
  String _cardHolderName = '';

  bool _isProcessing = false;

  void _submitPayment() async {
    if (_selectedPaymentMethod == 'credit_card' &&
        !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // 仮の処理遅延（実際はサーバー通信）
    await Future.delayed(const Duration(seconds: 2));

    // サブスクリプション登録
    final userId = Supabase.instance.client.auth.currentUser?.id ?? 'mock-user';

    String? cardLast4;
    if (_selectedPaymentMethod == 'credit_card') {
      final sanitized = _cardNumber.replaceAll(RegExp(r'\s+'), '');
      if (sanitized.length >= 4) {
        cardLast4 = sanitized.substring(sanitized.length - 4);
      }
      final holder = _cardHolderName.trim();
      final hasCvv = _cvv.trim().isNotEmpty;
      debugPrint(
          '[Payment] Card holder: ${holder.isEmpty ? '未入力' : holder}, expiry: $_expiryDate, cvvProvided: $hasCvv');
    }

    final paymentMethodId =
        'pm_${DateTime.now().millisecondsSinceEpoch}_${cardLast4 ?? _selectedPaymentMethod}';

    try {
      await ref.read(subscriptionProvider).subscribe(
            userId,
            widget.plan.id,
            paymentMethodId,
          );

      // 成功時の処理
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _selectedPaymentMethod == 'credit_card' && cardLast4 != null
                  ? 'カード末尾$cardLast4でサブスクリプションが開始されました！'
                  : 'サブスクリプションが開始されました！',
            ),
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      // エラー処理
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isYearlyPlan =
        widget.isYearly || widget.plan.billingPeriod.inDays >= 360;
    final discountMonths = widget.plan.metadata['discount_months_free'] as int?;
    final monthlyEquivalentValue =
        widget.plan.metadata['yearly_monthly_equivalent'] as num?;
    final monthlyEquivalent = isYearlyPlan
        ? (monthlyEquivalentValue?.toDouble() ?? (widget.plan.price / 12))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('支払い方法'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 選択したプラン情報
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.plan.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.plan.isPopular)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              '人気',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.plan.price == 0
                          ? '無料'
                          : '¥${widget.plan.price.toInt()} / ${isYearlyPlan ? '年' : '月'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isYearlyPlan && widget.plan.price > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          discountMonths != null
                              ? '月あたり ¥${monthlyEquivalent!.toStringAsFixed(0)}（$discountMonthsヶ月分お得）'
                              : '月あたり ¥${monthlyEquivalent!.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      widget.plan.description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              '支払い方法を選択',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // 支払い方法選択
            _buildPaymentMethodSelector(theme),

            const SizedBox(height: 24),

            // 選択した支払い方法のフォーム
            _selectedPaymentMethod == 'credit_card'
                ? _buildCreditCardForm()
                : _buildQRPaymentUI(_selectedPaymentMethod),

            const SizedBox(height: 32),

            // 支払いボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _submitPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        '支払いを完了する',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // 注意事項
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '注意事項:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• サブスクリプションは自動更新されます\n'
                    '• いつでもアカウント設定から解約できます\n'
                    '• 選択した支払い方法で${isYearlyPlan ? '年' : '月'}額が自動的に請求されます',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
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

  Widget _buildPaymentMethodSelector(ThemeData theme) {
    return Column(
      children: [
        // クレジットカード
        ListTile(
          title: const Text('クレジット/デビットカード'),
          leading: Radio<String>(
            value: 'credit_card',
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
            activeColor: theme.colorScheme.primary,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MediaGate(
                minWidth: 40,
                minHeight: 25,
                child: Image.asset(
                  'assets/images/visa.png',
                  width: 40,
                  height: 25,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.credit_card,
                      size: 30,
                      color: Colors.blue),
                ),
              ),
              const SizedBox(width: 8),
              MediaGate(
                minWidth: 40,
                minHeight: 25,
                child: Image.asset(
                  'assets/images/jcb.png',
                  width: 40,
                  height: 25,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.credit_card,
                      size: 30,
                      color: Colors.green),
                ),
              ),
            ],
          ),
        ),

        const Divider(),

        // PayPay
        ListTile(
          title: const Text('PayPay'),
          leading: Radio<String>(
            value: 'paypay',
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
            activeColor: theme.colorScheme.primary,
          ),
          trailing: MediaGate(
            minWidth: 40,
            minHeight: 40,
            child: Image.asset(
              'assets/images/paypay.png',
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.account_balance_wallet,
                  size: 30,
                  color: Colors.red),
            ),
          ),
        ),

        const Divider(),

        // メルペイ
        ListTile(
          title: const Text('メルペイ'),
          leading: Radio<String>(
            value: 'merpay',
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
            activeColor: theme.colorScheme.primary,
          ),
          trailing: MediaGate(
            minWidth: 40,
            minHeight: 40,
            child: Image.asset(
              'assets/images/merpay.png',
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.shopping_cart,
                  size: 30,
                  color: Colors.orange),
            ),
          ),
        ),

        const Divider(),

        // Apple Pay（iOSの場合）
        if (Theme.of(context).platform == TargetPlatform.iOS)
          ListTile(
            title: const Text('Apple Pay'),
            leading: Radio<String>(
              value: 'apple_pay',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
              activeColor: theme.colorScheme.primary,
            ),
            trailing: MediaGate(
              minWidth: 40,
              minHeight: 40,
              child: Image.asset(
                'assets/images/apple_pay.png',
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.apple, size: 30),
              ),
            ),
          ),

        // Google Pay（Androidの場合）
        if (Theme.of(context).platform == TargetPlatform.android)
          ListTile(
            title: const Text('Google Pay'),
            leading: Radio<String>(
              value: 'google_pay',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
              activeColor: theme.colorScheme.primary,
            ),
            trailing: MediaGate(
              minWidth: 40,
              minHeight: 40,
              child: Image.asset(
                'assets/images/google_pay.png',
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.g_mobiledata,
                    size: 30,
                    color: Colors.blue),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCreditCardForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'カード情報を入力',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // カード番号
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'カード番号',
              hintText: '1234 5678 9012 3456',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _cardNumber = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'カード番号を入力してください';
              }
              // 数字のみで16桁チェック
              if (value.replaceAll(' ', '').length != 16) {
                return '有効なカード番号を入力してください';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // 有効期限とCVV
          Row(
            children: [
              // 有効期限
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: '有効期限',
                    hintText: 'MM/YY',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.datetime,
                  onChanged: (value) {
                    _expiryDate = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '有効期限を入力してください';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(width: 16),

              // CVV
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'セキュリティコード',
                    hintText: '123',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  onChanged: (value) {
                    _cvv = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'セキュリティコードを入力してください';
                    }
                    if (value.length < 3) {
                      return '有効なコードを入力してください';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // カード名義
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'カード名義',
              hintText: 'TARO YAMADA',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
            onChanged: (value) {
              _cardHolderName = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'カード名義を入力してください';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQRPaymentUI(String paymentMethod) {
    String methodName = '';
    Color methodColor = Colors.blue;
    IconData methodIcon = Icons.qr_code;

    switch (paymentMethod) {
      case 'paypay':
        methodName = 'PayPay';
        methodColor = Colors.red;
        methodIcon = Icons.account_balance_wallet;
        break;
      case 'merpay':
        methodName = 'メルペイ';
        methodColor = Colors.orange;
        methodIcon = Icons.shopping_cart;
        break;
      case 'apple_pay':
        methodName = 'Apple Pay';
        methodColor = Colors.black;
        methodIcon = Icons.apple;
        break;
      case 'google_pay':
        methodName = 'Google Pay';
        methodColor = Colors.blue;
        methodIcon = Icons.g_mobiledata;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            methodIcon,
            size: 64,
            color: methodColor,
          ),
          const SizedBox(height: 16),
          Text(
            '$methodNameで支払う',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: methodColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '「支払いを完了する」ボタンを押すと$methodNameアプリが開きます',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
