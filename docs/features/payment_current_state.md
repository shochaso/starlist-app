---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



Status:: 
Source-of-Truth:: (TBD)
Spec-State:: 
Last-Updated:: 


# Starlist 決済機能 現行実装概要

2025年10月時点のリポジトリに含まれる実装をコードベースから確認した結果をまとめる。計画ドキュメントに記載されたコンビニ／キャリア決済フローは未実装であり、現在はサブスクリプション購入時の簡易的な支払いフォームがあるのみ。

---

## 1. 画面フロー

- 決済画面は `PaymentMethodScreen` ただ一つで、サブスクリプションプラン選択後に遷移する (`lib/src/features/subscription/presentation/screens/payment_method_screen.dart:18`)。
- 画面冒頭は選択したプラン情報を表示し、その下に「支払い方法を選択」セクションが続く (`lib/src/features/subscription/presentation/screens/payment_method_screen.dart:206`)。
- 支払い方法の選択肢は以下のラジオボタンに固定されている。
  - クレジット／デビットカード (`lib/src/features/subscription/presentation/screens/payment_method_screen.dart:303`)
  - PayPay (`lib/src/features/subscription/presentation/screens/payment_method_screen.dart:352`)
  - メルペイ (`lib/src/features/subscription/presentation/screens/payment_method_screen.dart:382`)
  - Apple Pay（iOSプラットフォームのみ表示） (`lib/src/features/subscription/presentation/screens/payment_method_screen.dart:413`)
  - Google Pay（Androidプラットフォームのみ表示） (`lib/src/features/subscription/presentation/screens/payment_method_screen.dart:440`)
- クレジットカードを選ぶとカード番号・有効期限・セキュリティコード・名義を入力するフォームが表示される (`lib/src/features/subscription/presentation/screens/payment_method_screen.dart:474`〜`lib/src/features/subscription/presentation/screens/payment_method_screen.dart:512`)。
- それ以外の決済手段を選ぶと、実際の外部連携ではなく「〇〇で支払う」というガイド文とアイコンのみを表示する簡易UIに切り替わる (`lib/src/features/subscription/presentation/screens/payment_method_screen.dart:516`)。
- 画面下部には注意事項として「自動更新」「解約はアカウント設定から」等の固定テキストが並び、コンビニ期限・キャリア認証等の記述は存在しない (`lib/src/features/subscription/presentation/screens/payment_method_screen.dart:268`)。

## 2. ユーザー操作時の挙動

- 「支払いを完了する」ボタン押下で `_submitPayment` が実行される (`lib/src/features/subscription/presentation/screens/payment_method_screen.dart:229`)。
- バリデーションはクレジットカードフォームのみ対象で、その他の決済方式では入力項目がないため追加チェックは行われない (`lib/src/features/subscription/presentation/screens/payment_method_screen.dart:37`)。
- `_submitPayment` 内では疑似的な `Future.delayed`(2秒) を挟んだ後、Supabase のログインユーザー ID が無ければ `'mock-user'` を使用する形になっている (`lib/src/features/subscription/presentation/screens/payment_method_screen.dart:47`〜`lib/src/features/subscription/presentation/screens/payment_method_screen.dart:53`)。
- 決済固有のパラメータは生成された `paymentMethodId` 文字列のみで、コンビニ店舗やキャリア種別などは扱っていない (`lib/src/features/subscription/presentation/screens/payment_method_screen.dart:65`)。
- 生成した ID を渡して `subscriptionProvider.subscribe` を呼び出し、成功するとトースト通知を表示したうえでトップまで画面をポップする簡易フローになっている (`lib/src/features/subscription/presentation/screens/payment_method_screen.dart:70`)。

## 3. サブスクリプション処理

- プロバイダーは `SubscriptionService` を通して Supabase/Postgres と Stripe API を利用する設計 (`lib/src/features/subscription/services/subscription_service.dart:26`)。
- `subscribe` 内でプラン情報取得→既存契約の重複チェック→決済実行→`subscriptions` テーブルへのレコード登録という順に処理される (`lib/src/features/subscription/services/subscription_service.dart:69`)。
- 決済部分は `PaymentService.createPayment` を呼び出すだけで、支払い手段の種類を判別するロジックは無い (`lib/src/features/subscription/services/subscription_service.dart:88`)。
- Supabase 側に格納されるメタデータは `subscription_plan_id` と `subscription_type` の2項目のみ。コンビニ番号やキャリア契約 ID といったフィールドは存在しない (`lib/src/features/subscription/services/subscription_service.dart:93`)。

## 4. 決済サービス層

- 実装クラス `PaymentServiceImpl` は Stripe の PaymentIntent API だけを対象としており、環境変数から読み込むシークレットキーを使って HTTP リクエストを直接送信する (`lib/src/features/payment/services/payment_service.dart:8`)。
- `createPaymentIntent` で自動的にカードなどの決済手段を有効化する設定を渡しているが、Stripe のコンビニ決済・キャリア決済向けパラメータは指定していない (`lib/src/features/payment/services/payment_service.dart:98`)。
- Supabase の `payments` テーブルには PaymentIntent ID をそのまま主キーとして保存し、ステータスは `'pending'` 固定で書き込まれる (`lib/src/features/payment/services/payment_service.dart:57`)。
- 返金やキャンセル処理も Stripe API に限定されており、他ゲートウェイ用の処理分岐は存在しない (`lib/src/features/payment/services/payment_service.dart:149` / `lib/src/features/payment/services/payment_service.dart:181`)。

## 5. データモデル

- `PaymentModel` の決済手段列挙は `creditCard`・`bankTransfer`・`paypal`・`applePay`・`googlePay` の5種類のみで、コンビニ／キャリア向けの定数は定義されていない (`lib/src/features/payment/models/payment_model.dart:12`)。
- モデルの `metadata` フィールドは汎用の `Map<String, dynamic>` だが、現状の呼び出しではサブスクリプション関連の簡易情報しか格納されていない (`lib/src/features/subscription/services/subscription_service.dart:93`)。

## 6. 補助的な未使用コード

- `payment_service_backup.dart` にはコンビニやキャリア等を想定した抽象インターフェースが定義されているが、現在のアプリケーションからは参照されていない (`lib/src/features/payment/payment_service_backup.dart:24`)。
- `PaymentProcessorType.convenienceStore` や `PaymentProcessorType.carrierBilling` などの列挙値は存在するものの、実装クラスが無く UI も連携していない (`lib/src/features/payment/payment_service_backup.dart:30`)。

## 7. 未実装・制約事項

- コンビニ決済／キャリア決済／銀行振込の入力フォーム、コード発行画面、認証リダイレクトといった要件は現行コードに含まれていない。
- 支払い手数料・支払期限・注意事項なども固定テキストであり、ゲートウェイからの戻り値を表示する仕組みは未実装。
- 決済イベントの計測（`pm_detail_view` など）はコードベースに確認できず、分析ログは送信していない。
- 複数ゲートウェイを切り替える構造や、支払い失敗時のリトライ／既存請求案内といった高度なフローも実装されていない。

---

上記の通り、Starlist の現行実装は Stripe を利用した単一の PaymentIntent 作成フローにとどまっている。コンビニ・キャリア決済を導入するには UI、データモデル、サービス層、計測の全面的な拡張が必要となる。

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
