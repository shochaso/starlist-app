import "package:starlist_app/src/features/payment/models/payment_model.dart";
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

const String _kStripeSecretKey = String.fromEnvironment('STRIPE_SECRET_KEY');
const String _kStripeWebhookSecret = String.fromEnvironment('STRIPE_WEBHOOK_SECRET');

abstract class PaymentService {
  Future<PaymentModel> createPayment({
    required String userId,
    required double amount,
    required String currency,
    required String paymentMethodId,
    Map<String, dynamic>? metadata,
  });

  Future<PaymentModel> getPayment(String paymentId);
  Future<List<PaymentModel>> getUserPayments(String userId);
  Future<PaymentModel> cancelPayment(String paymentId);
  Future<PaymentModel> refundPayment(String paymentId, {double? amount});
  Future<void> handleWebhook(String payload, String signature);
  Future<String> createPaymentIntent({
    required double amount,
    required String currency,
    required String customerId,
    Map<String, dynamic>? metadata,
  });
}

class PaymentServiceImpl implements PaymentService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _stripeSecretKey = _kStripeSecretKey;
  final String _stripeWebhookSecret = _kStripeWebhookSecret;

  static const String _stripeApiUrl = 'https://api.stripe.com/v1';

  @override
  Future<PaymentModel> createPayment({
    required String userId,
    required double amount,
    required String currency,
    required String paymentMethodId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final paymentIntentId = await createPaymentIntent(
        amount: amount,
        currency: currency,
        customerId: userId,
        metadata: metadata,
      );

      final paymentData = {
        'id': paymentIntentId,
        'user_id': userId,
        'amount': amount,
        'currency': currency.toUpperCase(),
        'payment_method_id': paymentMethodId,
        'status': 'pending',
        'metadata': metadata ?? {},
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('payments')
          .insert(paymentData)
          .select()
          .single();

      return PaymentModel.fromJson(response);
    } catch (e) {
      throw PaymentException('決済の作成に失敗しました: $e');
    }
  }

  @override
  Future<String> createPaymentIntent({
    required double amount,
    required String currency,
    required String customerId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_stripeApiUrl/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': (amount * 100).toInt().toString(),
          'currency': currency.toLowerCase(),
          'customer': customerId,
          'automatic_payment_methods[enabled]': 'true',
          if (metadata != null)
            ...metadata.map(
                (key, value) => MapEntry('metadata[$key]', value.toString())),
        },
      );

      if (response.statusCode != 200) {
        throw PaymentException('Stripe API エラー: ${response.body}');
      }

      final data = json.decode(response.body);
      return data['id'];
    } catch (e) {
      throw PaymentException('Payment Intent作成エラー: $e');
    }
  }

  @override
  Future<PaymentModel> getPayment(String paymentId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select()
          .eq('id', paymentId)
          .single();

      return PaymentModel.fromJson(response);
    } catch (e) {
      throw PaymentException('決済情報の取得に失敗しました: $e');
    }
  }

  @override
  Future<List<PaymentModel>> getUserPayments(String userId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response
          .map<PaymentModel>((json) => PaymentModel.fromJson(json))
          .toList();
    } catch (e) {
      throw PaymentException('ユーザーの決済履歴取得に失敗しました: $e');
    }
  }

  @override
  Future<PaymentModel> cancelPayment(String paymentId) async {
    try {
      final stripeResponse = await http.post(
        Uri.parse('$_stripeApiUrl/payment_intents/$paymentId/cancel'),
        headers: {
          'Authorization': 'Bearer $_stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (stripeResponse.statusCode != 200) {
        throw PaymentException('Stripe キャンセルエラー: ${stripeResponse.body}');
      }

      final response = await _supabase
          .from('payments')
          .update({
            'status': 'cancelled',
            'auto_renew': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paymentId)
          .select()
          .single();

      return PaymentModel.fromJson(response);
    } catch (e) {
      throw PaymentException('決済のキャンセルに失敗しました: $e');
    }
  }

  @override
  Future<PaymentModel> refundPayment(String paymentId, {double? amount}) async {
    try {
      final payment = await getPayment(paymentId);

      if (payment.status != PaymentStatus.completed) {
        throw PaymentException('成功した決済のみ返金可能です');
      }

      final refundData = {
        'payment_intent': paymentId,
        if (amount != null) 'amount': (amount * 100).toInt().toString(),
      };

      final stripeResponse = await http.post(
        Uri.parse('$_stripeApiUrl/refunds'),
        headers: {
          'Authorization': 'Bearer $_stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: refundData,
      );

      if (stripeResponse.statusCode != 200) {
        throw PaymentException('Stripe 返金エラー: ${stripeResponse.body}');
      }

      final response = await _supabase
          .from('payments')
          .update({
            'status': amount == null ? 'refunded' : 'partially_refunded',
            'refunded_amount': amount ?? payment.amount,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paymentId)
          .select()
          .single();

      return PaymentModel.fromJson(response);
    } catch (e) {
      throw PaymentException('返金処理に失敗しました: $e');
    }
  }

  @override
  Future<void> handleWebhook(String payload, String signature) async {
    try {
      if (!_verifyWebhookSignature(payload, signature)) {
        throw PaymentException('Webhook署名が無効です');
      }

      final event = json.decode(payload);
      final eventType = event['type'];
      final paymentIntent = event['data']['object'];

      switch (eventType) {
        case 'payment_intent.succeeded':
          await _handlePaymentSucceeded(paymentIntent);
          break;
        case 'payment_intent.payment_failed':
          await _handlePaymentFailed(paymentIntent);
          break;
        case 'payment_intent.canceled':
          await _handlePaymentCanceled(paymentIntent);
          break;
        default:
          // ignore: avoid_print
          print('未処理のWebhookイベント: $eventType');
      }
    } catch (e) {
      throw PaymentException('Webhook処理エラー: $e');
    }
  }

  bool _verifyWebhookSignature(String payload, String signature) {
    return signature.isNotEmpty && _stripeWebhookSecret.isNotEmpty;
  }

  Future<void> _handlePaymentSucceeded(
      Map<String, dynamic> paymentIntent) async {
    final paymentId = paymentIntent['id'];

    await _supabase.from('payments').update({
      'status': 'succeeded',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', paymentId);
  }

  Future<void> _handlePaymentFailed(Map<String, dynamic> paymentIntent) async {
    final paymentId = paymentIntent['id'];

    await _supabase.from('payments').update({
      'status': 'failed',
      'failure_reason': paymentIntent['last_payment_error']?['message'],
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', paymentId);
  }

  Future<void> _handlePaymentCanceled(
      Map<String, dynamic> paymentIntent) async {
    final paymentId = paymentIntent['id'];

    await _supabase.from('payments').update({
      'status': 'cancelled',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', paymentId);
  }
}

class PaymentException implements Exception {
  final String message;
  PaymentException(this.message);

  @override
  String toString() => 'PaymentException: $message';
}

class MockPaymentService implements PaymentService {
  final Map<String, PaymentModel> _payments = {};

  @override
  Future<PaymentModel> createPayment({
    required String userId,
    required double amount,
    required String currency,
    required String paymentMethodId,
    Map<String, dynamic>? metadata,
  }) async {
    final now = DateTime.now();
    final id = 'mock_pay_${now.microsecondsSinceEpoch}';
    final payment = PaymentModel(
      id: id,
      userId: userId,
      amount: amount,
      currency: currency.toUpperCase(),
      status: PaymentStatus.completed,
      method: PaymentMethod.creditCard,
      createdAt: now,
      completedAt: now,
      transactionId: 'mock_txn_$id',
      metadata: metadata ?? <String, dynamic>{},
    );
    _payments[id] = payment;
    return payment;
  }

  @override
  Future<String> createPaymentIntent({
    required double amount,
    required String currency,
    required String customerId,
    Map<String, dynamic>? metadata,
  }) async {
    return 'mock_intent_${DateTime.now().microsecondsSinceEpoch}';
  }

  @override
  Future<PaymentModel> getPayment(String paymentId) async {
    final payment = _payments[paymentId];
    if (payment == null) {
      throw PaymentException('支払いが見つかりません: $paymentId');
    }
    return payment;
  }

  @override
  Future<List<PaymentModel>> getUserPayments(String userId) async {
    return _payments.values
        .where((payment) => payment.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<PaymentModel> cancelPayment(String paymentId) async {
    final payment = await getPayment(paymentId);
    final updated = PaymentModel(
      id: payment.id,
      userId: payment.userId,
      amount: payment.amount,
      currency: payment.currency,
      status: PaymentStatus.canceled,
      method: payment.method,
      createdAt: payment.createdAt,
      completedAt: payment.completedAt,
      transactionId: payment.transactionId,
      metadata: payment.metadata,
    );
    _payments[paymentId] = updated;
    return updated;
  }

  @override
  Future<PaymentModel> refundPayment(String paymentId, {double? amount}) async {
    final payment = await getPayment(paymentId);
    final updated = PaymentModel(
      id: payment.id,
      userId: payment.userId,
      amount: payment.amount,
      currency: payment.currency,
      status: PaymentStatus.refunded,
      method: payment.method,
      createdAt: payment.createdAt,
      completedAt: DateTime.now(),
      transactionId: payment.transactionId,
      metadata: {
        ...payment.metadata,
        if (amount != null) 'refund_amount': amount,
      },
    );
    _payments[paymentId] = updated;
    return updated;
  }

  @override
  Future<void> handleWebhook(String payload, String signature) async {
    // モック環境では特に処理しない
  }
}

final paymentServiceProvider = Provider<PaymentService>((ref) {
  if (_kStripeSecretKey.isEmpty) {
    debugPrint('[PaymentService] Stripeキーが設定されていないため、モックサービスを利用します。');
    return MockPaymentService();
  }
  return PaymentServiceImpl();
});
