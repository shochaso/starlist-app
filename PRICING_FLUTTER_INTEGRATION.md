# Flutter 統合の最終確認

## 2-1. Provider 取得 → 画面結線（抜粋）

```dart
// 画面 init 相当で config 読み込み（Riverpod）
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starlist/src/features/pricing/data/pricing_repository.dart';
import 'package:starlist/src/features/pricing/domain/pricing_validator.dart';
import 'package:starlist/src/features/pricing/widgets/pricing_cards.dart';

// 画面内で使用
final cfgAsync = ref.watch(pricingConfigProvider);

cfgAsync.when(
  data: (cfg) {
    final isAdult = /* ログインユーザー属性から判定 */;
    final limits = limitsFromConfig(cfg, isAdult: isAdult);
    final recLight = recommendedFor(cfg, tier: 'light', isAdult: isAdult);
    final recStandard = recommendedFor(cfg, tier: 'standard', isAdult: isAdult);
    final recPremium = recommendedFor(cfg, tier: 'premium', isAdult: isAdult);
    
    return Column(
      children: [
        TierCard(
          title: 'Light',
          tier: 'light',
          isAdult: isAdult,
          onChanged: (v) {
            // 金額を状態に反映
            // 例: ref.read(selectedPriceProvider.notifier).state = v;
          },
        ),
        TierCard(
          title: 'Standard',
          tier: 'standard',
          isAdult: isAdult,
          onChanged: (v) { /* ... */ },
        ),
        TierCard(
          title: 'Premium',
          tier: 'premium',
          isAdult: isAdult,
          onChanged: (v) { /* ... */ },
        ),
      ],
    );
  },
  loading: () => const CircularProgressIndicator(),
  error: (err, stack) {
    // ロガー連携も推奨
    // logger.error('Failed to fetch pricing config', err, stack);
    return Text('設定の取得に失敗しました');
  },
);
```

## 2-2. 送出前バリデーション（刻み/上下限）

```dart
// Checkout送信前のバリデーション
final inputYen = /* TextFieldから取得した値 */;
final limits = limitsFromConfig(config, isAdult: isAdult);
final msg = validatePrice(value: inputYen, limits: limits);

if (msg != null) {
  // CTAを無効化し、メッセージ表示
  // 例: ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  return;
}

// ここで Stripe Checkout へ（最終価格 = inputYen）
// 例: await stripeClient.createCheckoutSession(amount: inputYen);
```

**期待動作:**
- ✅ **推奨バッジ表示**（TierCardにChipで表示）
- ✅ **リアルタイム検証**（TextFieldのonChangedで即座にバリデーション）
- ✅ **不正値はCTA無効**（validatePriceの結果でボタンを無効化）
- ✅ 成功後は「次回請求日」「Billing Portal」導線を表示

## 2-3. 統合例（完全版）

```dart
class PricingPage extends ConsumerStatefulWidget {
  const PricingPage({super.key});

  @override
  ConsumerState<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends ConsumerState<PricingPage> {
  int? selectedPrice;
  String? validationError;

  @override
  Widget build(BuildContext context) {
    final cfgAsync = ref.watch(pricingConfigProvider);
    final isAdult = /* ユーザー属性から判定 */;

    return cfgAsync.when(
      data: (cfg) {
        final limits = limitsFromConfig(cfg, isAdult: isAdult);
        
        return Scaffold(
          appBar: AppBar(title: const Text('プラン選択')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TierCard(
                title: 'Light',
                tier: 'light',
                isAdult: isAdult,
                onChanged: (price) {
                  setState(() {
                    selectedPrice = price;
                    validationError = validatePrice(value: price, limits: limits);
                  });
                },
              ),
              const SizedBox(height: 16),
              if (validationError != null)
                Text(
                  validationError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: selectedPrice != null && validationError == null
                    ? () async {
                        // Stripe Checkoutへ
                        // await createCheckoutSession(selectedPrice!);
                      }
                    : null,
                child: const Text('購入する'),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('設定の取得に失敗しました: $err'),
              ElevatedButton(
                onPressed: () => ref.invalidate(pricingConfigProvider),
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```



## 2-1. Provider 取得 → 画面結線（抜粋）

```dart
// 画面 init 相当で config 読み込み（Riverpod）
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starlist/src/features/pricing/data/pricing_repository.dart';
import 'package:starlist/src/features/pricing/domain/pricing_validator.dart';
import 'package:starlist/src/features/pricing/widgets/pricing_cards.dart';

// 画面内で使用
final cfgAsync = ref.watch(pricingConfigProvider);

cfgAsync.when(
  data: (cfg) {
    final isAdult = /* ログインユーザー属性から判定 */;
    final limits = limitsFromConfig(cfg, isAdult: isAdult);
    final recLight = recommendedFor(cfg, tier: 'light', isAdult: isAdult);
    final recStandard = recommendedFor(cfg, tier: 'standard', isAdult: isAdult);
    final recPremium = recommendedFor(cfg, tier: 'premium', isAdult: isAdult);
    
    return Column(
      children: [
        TierCard(
          title: 'Light',
          tier: 'light',
          isAdult: isAdult,
          onChanged: (v) {
            // 金額を状態に反映
            // 例: ref.read(selectedPriceProvider.notifier).state = v;
          },
        ),
        TierCard(
          title: 'Standard',
          tier: 'standard',
          isAdult: isAdult,
          onChanged: (v) { /* ... */ },
        ),
        TierCard(
          title: 'Premium',
          tier: 'premium',
          isAdult: isAdult,
          onChanged: (v) { /* ... */ },
        ),
      ],
    );
  },
  loading: () => const CircularProgressIndicator(),
  error: (err, stack) {
    // ロガー連携も推奨
    // logger.error('Failed to fetch pricing config', err, stack);
    return Text('設定の取得に失敗しました');
  },
);
```

## 2-2. 送出前バリデーション（刻み/上下限）

```dart
// Checkout送信前のバリデーション
final inputYen = /* TextFieldから取得した値 */;
final limits = limitsFromConfig(config, isAdult: isAdult);
final msg = validatePrice(value: inputYen, limits: limits);

if (msg != null) {
  // CTAを無効化し、メッセージ表示
  // 例: ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  return;
}

// ここで Stripe Checkout へ（最終価格 = inputYen）
// 例: await stripeClient.createCheckoutSession(amount: inputYen);
```

**期待動作:**
- ✅ **推奨バッジ表示**（TierCardにChipで表示）
- ✅ **リアルタイム検証**（TextFieldのonChangedで即座にバリデーション）
- ✅ **不正値はCTA無効**（validatePriceの結果でボタンを無効化）
- ✅ 成功後は「次回請求日」「Billing Portal」導線を表示

## 2-3. 統合例（完全版）

```dart
class PricingPage extends ConsumerStatefulWidget {
  const PricingPage({super.key});

  @override
  ConsumerState<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends ConsumerState<PricingPage> {
  int? selectedPrice;
  String? validationError;

  @override
  Widget build(BuildContext context) {
    final cfgAsync = ref.watch(pricingConfigProvider);
    final isAdult = /* ユーザー属性から判定 */;

    return cfgAsync.when(
      data: (cfg) {
        final limits = limitsFromConfig(cfg, isAdult: isAdult);
        
        return Scaffold(
          appBar: AppBar(title: const Text('プラン選択')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TierCard(
                title: 'Light',
                tier: 'light',
                isAdult: isAdult,
                onChanged: (price) {
                  setState(() {
                    selectedPrice = price;
                    validationError = validatePrice(value: price, limits: limits);
                  });
                },
              ),
              const SizedBox(height: 16),
              if (validationError != null)
                Text(
                  validationError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: selectedPrice != null && validationError == null
                    ? () async {
                        // Stripe Checkoutへ
                        // await createCheckoutSession(selectedPrice!);
                      }
                    : null,
                child: const Text('購入する'),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('設定の取得に失敗しました: $err'),
              ElevatedButton(
                onPressed: () => ref.invalidate(pricingConfigProvider),
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```


