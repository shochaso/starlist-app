---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# トラブルシューティングガイド（即応コマンド集）

## 実行直後に送ってほしいログ

以下のログを実行後に送ってください：

1. **flutter pub get の全文ログ**
   ```bash
   flutter pub get 2>&1 | tee flutter_pub_get.log
   ```

2. **dart analyze の全文出力**
   ```bash
   dart analyze lib/core/prefs/secure_prefs.dart lib/core/prefs/local_store.dart 2>&1 | tee dart_analyze.log
   ```

3. **dart test -p chrome の結果**
   ```bash
   dart test -p chrome 2>&1 | tee dart_test.log
   ```

4. **flutter run -d chrome 実行中の Console エラー**
   - DevTools → Console のエラーメッセージをテキストでコピー
   - CSP違反、importエラー、runtimeエラーを含む

5. **GitHub Actions の workflow 実行ログ URL**
   - PR作成後のActionsタブから取得

---

## 詰まりやすい箇所と即応コマンド

### 1. 相対importによるanalyzer警告

**問題**: 相対importが警告を出す

**対処**: package importに一括置換

```bash
# lib/core/prefs/*.dart の相対importをpackage形式へ置換
perl -0777 -pe "s|import 'forbidden_keys.dart';|import 'package:starlist_app/core/prefs/forbidden_keys.dart';|g" -i lib/core/prefs/*.dart
```

---

### 2. flutter_secure_storageがWebビルドでエラー

**問題**: Webビルドで`flutter_secure_storage`が参照できない

**対処**: Conditional importを使用（以下のファイルを作成）

#### `lib/core/prefs/secure_storage_interface.dart`

```dart
abstract class SecureStorageInterface {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<void> deleteAll();
}
```

#### `lib/core/prefs/secure_storage_io.dart`

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'secure_storage_interface.dart';

class SecureStorageIO implements SecureStorageInterface {
  final _impl = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  Future<void> write({required String key, required String value}) =>
      _impl.write(key: key, value: value);

  @override
  Future<String?> read({required String key}) => _impl.read(key: key);

  @override
  Future<void> delete({required String key}) => _impl.delete(key: key);

  @override
  Future<void> deleteAll() => _impl.deleteAll();
}
```

#### `lib/core/prefs/secure_storage_web.dart`

```dart
import 'secure_storage_interface.dart';

class SecureStorageWeb implements SecureStorageInterface {
  // Webでは永続化しない（no-op）
  @override
  Future<void> write({required String key, required String value}) async =>
      Future<void>.value();

  @override
  Future<String?> read({required String key}) async => null;

  @override
  Future<void> delete({required String key}) async => Future<void>.value();

  @override
  Future<void> deleteAll() async => Future<void>.value();
}
```

#### `lib/core/prefs/secure_prefs.dart`（修正版）

```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'secure_storage_interface.dart'
    if (dart.library.html) 'secure_storage_web.dart'
    if (dart.library.io) 'secure_storage_io.dart';

class SecurePrefs {
  static const _forbiddenKeys = {
    'token',
    'access_token',
    'refresh_token',
    'jwt',
    'supabase.auth.token',
    'auth_token',
    'session_token',
  };

  static final _storage = kIsWeb
      ? SecureStorageWeb()
      : SecureStorageIO();

  static Future<void> setString(String key, String value) async {
    _assertKey(key);
    if (kIsWeb) {
      throw StateError(
        'Web では機密値の永続化を禁止: key=$key. '
        'Webではインメモリ運用（persistSession: false）を推奨し、再開時はEdge Function経由の再発行を利用してください。',
      );
    } else {
      await _storage.write(key: key, value: value);
    }
  }

  static Future<String?> getString(String key) async {
    _assertKey(key);
    if (kIsWeb) return null;
    return _storage.read(key: key);
  }

  static Future<void> remove(String key) async {
    if (kIsWeb) return;
    await _storage.delete(key: key);
  }

  static Future<void> clear() async {
    if (kIsWeb) return;
    await _storage.deleteAll();
  }

  static void _assertKey(String key) {
    final lowerKey = key.toLowerCase();
    if (_forbiddenKeys.contains(lowerKey)) {
      throw StateError(
        'このキーは保存禁止です: $key. '
        '機密情報はWebでは永続化せず、モバイルではSecureStorageを使用してください。',
      );
    }
  }
}
```

---

### 3. git applyで.rejファイルが出る

**問題**: パッチ適用時にコンフリクト

**対処**: 該当ファイルを丸ごと上書き

```bash
# 例: secure_prefs.dartを丸ごと上書き
cat > lib/core/prefs/secure_prefs.dart <<'EOF'
（パッチ内のsecure_prefs.dartの内容）
EOF

git add lib/core/prefs/secure_prefs.dart
```

---

### 4. CSP受け口（/_/csp-report）が未設置

**問題**: CSP Report-Onlyのレポート先が404

**対処**: Supabase Edge Functionを作成（以下を実装）

---

## CSP受け口の実装

### Supabase Edge Function

#### `supabase/functions/csp-report/index.ts`

```typescript
Deno.serve(async (req: Request) => {
  try {
    if (req.method !== 'POST') {
      return new Response('Method Not Allowed', { status: 405 });
    }

    const body = await req.text();
    console.log('[CSP REPORT]', new Date().toISOString(), body);

    // 必要に応じてSupabaseに保存
    // const { createClient } = await import('https://esm.sh/@supabase/supabase-js@2');
    // const supabase = createClient(
    //   Deno.env.get('SUPABASE_URL') ?? '',
    //   Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    // );
    // await supabase.from('csp_reports').insert({ report: body, created_at: new Date().toISOString() });

    return new Response(null, { status: 204 });
  } catch (e) {
    console.error('[CSP REPORT ERROR]', e);
    return new Response(null, { status: 500 });
  }
});
```

**デプロイ**:
```bash
supabase functions deploy csp-report
```

**設定**: `web/index.html`の`report-uri`を以下に変更
```html
report-uri /functions/v1/csp-report
```

---

## 優先順位（何を送れば即着手できるか）

1. **flutter pub get の失敗ログ** → 依存の最小修正パッチを作成
2. **dart analyze のエラー出力** → import/型の最小修正を作成
3. **flutter run -d chrome の Console エラー** → 対処パッチ or CSP許可先追加案
4. **PR作成後の GitHub Actions 実行ログ URL** → Semgrep / gitleaks / trivy の誤検出対応 or 依存 pin案

---

## 即応コマンド集

### ログ取得コマンド

```bash
# flutter pub get
flutter pub get 2>&1 | tee flutter_pub_get.log

# dart analyze
dart analyze lib/core/prefs/secure_prefs.dart lib/core/prefs/local_store.dart 2>&1 | tee dart_analyze.log

# dart test
dart test -p chrome 2>&1 | tee dart_test.log

# flutter run (バックグラウンド実行)
flutter run -d chrome > flutter_run.log 2>&1 &
FLUTTER_PID=$!
sleep 10
kill $FLUTTER_PID 2>/dev/null || true
cat flutter_run.log
```

### 検証コマンド

```bash
# Supabase環境変数検証
export SUPABASE_URL="https://<project-ref>.supabase.co"
export OPS_SERVICE_SECRET="<your-secret>"
./scripts/verify_supabase_env.sh

# RLS監査
supabase db query < scripts/rls_audit.sql

# Gitleaks実行
gitleaks detect --config .gitleaks.toml --verbose
```

---

## よくあるエラーと対処法

### エラー: "Target of URI doesn't exist"

**原因**: パッケージがインストールされていない

**対処**:
```bash
flutter pub get
```

### エラー: "The name 'FlutterSecureStorage' isn't a class"

**原因**: Webビルドで`flutter_secure_storage`が使用できない

**対処**: Conditional importを使用（上記「2. flutter_secure_storageがWebビルドでエラー」参照）

### エラー: CSP違反が発生している

**原因**: CSP設定が厳しすぎる、または外部リソースが必要

**対処**: `web/index.html`のCSP設定を調整
```html
<!-- 例: 外部CDNを許可 -->
connect-src 'self' https://*.supabase.co https://cdn.example.com;
```

### エラー: Gitleaksで誤検出

**原因**: テストデータやドキュメント内のサンプル値

**対処**: `.gitleaks.toml`の`allowlist`に追加
```toml
[allowlist]
paths = [
  '''\.md$''',
  '''\.example$''',
  '''tests/''',
]
```

---

**重要**: エラーが発生したら、上記のログを取得して送ってください。最短で修正パッチを作成します。

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
