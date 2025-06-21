# 決済処理コンポーネントの設計

## 1. アーキテクチャ概要

決済処理システムは以下のレイヤーで構成します：

1. **プレゼンテーション層**：ユーザーインターフェース（支払い画面、サブスクリプション管理画面など）
2. **ユースケース層**：決済処理のビジネスロジック
3. **ドメイン層**：決済関連のエンティティとビジネスルール
4. **データ層**：決済情報の永続化と外部決済サービスとの連携

## 2. コンポーネント構成

### 2.1 支払い方法管理

#### 2.1.1 モデル
```dart
// lib/src/models/payment_method_model.dart
enum PaymentMethodType {
  creditCard,
  electronicMoney,
  carrierBilling,
  convenienceStore,
  bankTransfer,
}

class PaymentMethod {
  final String id;
  final String userId;
  final PaymentMethodType type;
  final String name;
  final Map<String, dynamic> details;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // コンストラクタ、JSONシリアライズ/デシリアライズ、copyWithメソッドなど
}
```

#### 2.1.2 リポジトリ
```dart
// lib/src/repositories/payment_method_repository.dart
abstract class PaymentMethodRepository {
  Future<List<PaymentMethod>> getPaymentMethodsForUser(String userId);
  Future<PaymentMethod> addPaymentMethod(PaymentMethod method);
  Future<PaymentMethod> updatePaymentMethod(PaymentMethod method);
  Future<void> deletePaymentMethod(String id);
  Future<PaymentMethod> setDefaultPaymentMethod(String id);
}
```

#### 2.1.3 サービス
```dart
// lib/src/services/payment_method_service.dart
class PaymentMethodService {
  final PaymentMethodRepository repository;
  
  // 支払い方法の追加、更新、削除、デフォルト設定などのメソッド
  // 各決済プロバイダーとの連携ロジック
}
```

### 2.2 決済処理

#### 2.2.1 モデル
```dart
// lib/src/models/payment_processor_model.dart
enum PaymentProcessorType {
  stripe,
  paypal,
  applePay,
  googlePay,
  paypay,
  linePay,
  carrierBilling,
}

class PaymentProcessor {
  final PaymentProcessorType type;
  final Map<String, dynamic> config;
  
  // 各決済プロセッサーの設定と初期化
}
```

#### 2.2.2 サービス
```dart
// lib/src/services/payment_service.dart
class PaymentService {
  final Map<PaymentProcessorType, PaymentProcessor> processors;
  final TransactionRepository transactionRepository;
  
  // 決済処理の実行
  Future<Transaction> processPayment({
    required String userId,
    required double amount,
    required String currency,
    required PaymentMethodType methodType,
    required String paymentMethodId,
    required TransactionType transactionType,
    Map<String, dynamic>? metadata,
  });
  
  // 決済状態の確認
  Future<TransactionStatus> checkPaymentStatus(String transactionId);
  
  // 決済のキャンセル
  Future<bool> cancelPayment(String transactionId);
}
```

### 2.3 サブスクリプション管理

#### 2.3.1 モデル
```dart
// lib/src/models/subscription_lifecycle_model.dart
enum SubscriptionEvent {
  created,
  activated,
  renewed,
  paymentFailed,
  cancelled,
  expired,
}

class SubscriptionLifecycle {
  final String id;
  final String subscriptionId;
  final SubscriptionEvent event;
  final DateTime eventDate;
  final Map<String, dynamic>? metadata;
  
  // コンストラクタ、JSONシリアライズ/デシリアライズなど
}
```

#### 2.3.2 サービス
```dart
// lib/src/services/subscription_lifecycle_service.dart
class SubscriptionLifecycleService {
  final SubscriptionRepository subscriptionRepository;
  final TransactionRepository transactionRepository;
  final NotificationService notificationService;
  
  // サブスクリプションの作成
  Future<Subscription> createSubscription({
    required String userId,
    required SubscriptionPlanType planType,
    required PaymentMethodType paymentMethodType,
    required String paymentMethodId,
  });
  
  // サブスクリプションの更新
  Future<Subscription> renewSubscription(String subscriptionId);
  
  // サブスクリプションのキャンセル
  Future<Subscription> cancelSubscription(String subscriptionId);
  
  // 支払い失敗時の処理
  Future<Subscription> handlePaymentFailure(String subscriptionId);
  
  // リマインダー通知の送信
  Future<void> sendRenewalReminders();
}
```

### 2.4 返金システム

#### 2.4.1 モデル
```dart
// lib/src/models/refund_model.dart
enum RefundReason {
  customerRequest,
  technicalIssue,
  fraudulentTransaction,
  productIssue,
  other,
}

enum RefundStatus {
  requested,
  underReview,
  approved,
  rejected,
  processed,
  failed,
}

class Refund {
  final String id;
  final String transactionId;
  final String userId;
  final double amount;
  final RefundReason reason;
  final String? description;
  final RefundStatus status;
  final String? approvedBy;
  final DateTime requestedAt;
  final DateTime? processedAt;
  
  // コンストラクタ、JSONシリアライズ/デシリアライズ、copyWithメソッドなど
}
```

#### 2.4.2 リポジトリ
```dart
// lib/src/repositories/refund_repository.dart
abstract class RefundRepository {
  Future<List<Refund>> getRefundsForUser(String userId);
  Future<List<Refund>> getPendingRefunds();
  Future<Refund> createRefundRequest(Refund refund);
  Future<Refund> updateRefundStatus(String refundId, RefundStatus status);
  Future<Refund> getRefundById(String refundId);
}
```

#### 2.4.3 サービス
```dart
// lib/src/services/refund_service.dart
class RefundService {
  final RefundRepository refundRepository;
  final TransactionRepository transactionRepository;
  final PaymentService paymentService;
  final NotificationService notificationService;
  
  // 返金リクエストの作成
  Future<Refund> requestRefund({
    required String transactionId,
    required String userId,
    required double amount,
    required RefundReason reason,
    String? description,
  });
  
  // 返金リクエストの承認
  Future<Refund> approveRefund(String refundId, String adminId);
  
  // 返金リクエストの拒否
  Future<Refund> rejectRefund(String refundId, String adminId, String reason);
  
  // 返金処理の実行
  Future<Refund> processRefund(String refundId);
  
  // 返金状態の確認
  Future<RefundStatus> checkRefundStatus(String refundId);
}
```

## 3. 外部サービス連携

### 3.1 Stripe連携
```dart
// lib/src/services/payment_processors/stripe_processor.dart
class StripeProcessor implements PaymentProcessor {
  // Stripe APIとの連携
  // カード情報のトークン化
  // 決済処理
  // サブスクリプション管理
  // 返金処理
}
```

### 3.2 PayPal連携
```dart
// lib/src/services/payment_processors/paypal_processor.dart
class PayPalProcessor implements PaymentProcessor {
  // PayPal APIとの連携
  // 決済処理
  // サブスクリプション管理
  // 返金処理
}
```

### 3.3 その他の決済プロセッサー
各決済方法（Apple Pay、Google Pay、PayPay、LINE Pay、キャリア決済など）に対応するプロセッサークラスを実装

## 4. セキュリティ対策

1. **PCI DSS準拠**
   - カード情報の非保持化（トークン化）
   - 通信の暗号化（TLS 1.2以上）
   - アクセス制御と監査ログ

2. **不正検知**
   - 異常な取引パターンの検出
   - デバイスフィンガープリンティング
   - 位置情報の検証

3. **データ保護**
   - 個人情報の暗号化
   - データアクセスの最小権限原則
   - 定期的なセキュリティ監査

## 5. エラーハンドリング

1. **ネットワークエラー**
   - 再試行メカニズム
   - オフライン処理キュー

2. **決済エラー**
   - エラーコードの標準化
   - ユーザーフレンドリーなエラーメッセージ
   - 代替決済方法の提案

3. **システムエラー**
   - 例外のロギング
   - 自動復旧メカニズム
   - 管理者通知
