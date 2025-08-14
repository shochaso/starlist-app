import "package:starlist_app/src/features/payment/models/payment_model.dart";
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final String _stripeSecretKey = const String.fromEnvironment('STRIPE_SECRET_KEY');
  final String _stripeWebhookSecret = const String.fromEnvironment('STRIPE_WEBHOOK_SECRET');
  
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
            ...metadata.map((key, value) => MapEntry('metadata[$key]', value.toString())),
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

      return response.map<PaymentModel>((json) => PaymentModel.fromJson(json)).toList();
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
      
      if (payment.status != 'succeeded') {
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

  Future<void> _handlePaymentSucceeded(Map<String, dynamic> paymentIntent) async {
    final paymentId = paymentIntent['id'];
    
    await _supabase
        .from('payments')
        .update({
          'status': 'succeeded',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', paymentId);
  }

  Future<void> _handlePaymentFailed(Map<String, dynamic> paymentIntent) async {
    final paymentId = paymentIntent['id'];
    
    await _supabase
        .from('payments')
        .update({
          'status': 'failed',
          'failure_reason': paymentIntent['last_payment_error']?['message'],
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', paymentId);
  }

  Future<void> _handlePaymentCanceled(Map<String, dynamic> paymentIntent) async {
    final paymentId = paymentIntent['id'];
    
    await _supabase
        .from('payments')
        .update({
          'status': 'cancelled',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', paymentId);
  }
}

class PaymentException implements Exception {
  final String message;
  PaymentException(this.message);
  
  @override
  String toString() => 'PaymentException: $message';
}

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentServiceImpl();
});
