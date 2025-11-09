# 実行ログ（送信用テンプレート）

## 1. flutter pub get のログ

```
[ここにflutter pub getの全文ログを貼り付け]
```

**実行コマンド**:
```bash
flutter pub get 2>&1 | tee flutter_pub_get.log
```

---

## 2. dart analyze の出力

```
[ここにdart analyzeの全文出力を貼り付け]
```

**実行コマンド**:
```bash
dart analyze lib/core/prefs/secure_prefs.dart lib/core/prefs/local_store.dart 2>&1 | tee dart_analyze.log
```

---

## 3. dart test -p chrome の結果

```
[ここにdart testの結果を貼り付け]
```

**実行コマンド**:
```bash
dart test -p chrome 2>&1 | tee dart_test.log
```

---

## 4. flutter run -d chrome の Console エラー

```
[ここにDevTools Consoleのエラーメッセージをテキストで貼り付け]
```

**確認方法**:
1. `flutter run -d chrome`を実行
2. Chrome DevToolsを開く（F12）
3. Consoleタブのエラーメッセージをコピー

**含めるべき情報**:
- CSP違反メッセージ
- importエラー
- runtimeエラー
- スタックトレース（あれば）

---

## 5. GitHub Actions の workflow 実行ログ URL

```
[ここにGitHub Actionsの実行ログURLを貼り付け]
```

**取得方法**:
1. PR作成後、GitHubリポジトリにアクセス
2. Actionsタブを選択
3. 実行されたワークフローを選択
4. URLをコピー

**例**: `https://github.com/shochaso/starlist-app/actions/runs/1234567890`

---

## 送信時の注意事項

- ログは全文を送ってください（成功時も短いログでOK）
- エラーが発生した場合は、エラーメッセージ全文を含めてください
- スタックトレースがある場合は、すべて含めてください
- スクリーンショットではなく、テキストで送ってください

---

## 即応コマンド（詰まった時）

### 相対import警告の一括置換

```bash
perl -0777 -pe "s|import 'forbidden_keys.dart';|import 'package:starlist_app/core/prefs/forbidden_keys.dart';|g" -i lib/core/prefs/*.dart
```

### git applyで.rejが出た場合

```bash
# 該当ファイルを丸ごと上書き
cat > lib/core/prefs/secure_prefs.dart <<'EOF'
（パッチ内の内容）
EOF

git add lib/core/prefs/secure_prefs.dart
```

### CSP受け口が必要な場合

`supabase/functions/csp-report/index.ts`が既に作成済みです。

デプロイ:
```bash
supabase functions deploy csp-report
```

---

**重要**: ログを送っていただければ、最短で修正パッチを作成します。


## 1. flutter pub get のログ

```
[ここにflutter pub getの全文ログを貼り付け]
```

**実行コマンド**:
```bash
flutter pub get 2>&1 | tee flutter_pub_get.log
```

---

## 2. dart analyze の出力

```
[ここにdart analyzeの全文出力を貼り付け]
```

**実行コマンド**:
```bash
dart analyze lib/core/prefs/secure_prefs.dart lib/core/prefs/local_store.dart 2>&1 | tee dart_analyze.log
```

---

## 3. dart test -p chrome の結果

```
[ここにdart testの結果を貼り付け]
```

**実行コマンド**:
```bash
dart test -p chrome 2>&1 | tee dart_test.log
```

---

## 4. flutter run -d chrome の Console エラー

```
[ここにDevTools Consoleのエラーメッセージをテキストで貼り付け]
```

**確認方法**:
1. `flutter run -d chrome`を実行
2. Chrome DevToolsを開く（F12）
3. Consoleタブのエラーメッセージをコピー

**含めるべき情報**:
- CSP違反メッセージ
- importエラー
- runtimeエラー
- スタックトレース（あれば）

---

## 5. GitHub Actions の workflow 実行ログ URL

```
[ここにGitHub Actionsの実行ログURLを貼り付け]
```

**取得方法**:
1. PR作成後、GitHubリポジトリにアクセス
2. Actionsタブを選択
3. 実行されたワークフローを選択
4. URLをコピー

**例**: `https://github.com/shochaso/starlist-app/actions/runs/1234567890`

---

## 送信時の注意事項

- ログは全文を送ってください（成功時も短いログでOK）
- エラーが発生した場合は、エラーメッセージ全文を含めてください
- スタックトレースがある場合は、すべて含めてください
- スクリーンショットではなく、テキストで送ってください

---

## 即応コマンド（詰まった時）

### 相対import警告の一括置換

```bash
perl -0777 -pe "s|import 'forbidden_keys.dart';|import 'package:starlist_app/core/prefs/forbidden_keys.dart';|g" -i lib/core/prefs/*.dart
```

### git applyで.rejが出た場合

```bash
# 該当ファイルを丸ごと上書き
cat > lib/core/prefs/secure_prefs.dart <<'EOF'
（パッチ内の内容）
EOF

git add lib/core/prefs/secure_prefs.dart
```

### CSP受け口が必要な場合

`supabase/functions/csp-report/index.ts`が既に作成済みです。

デプロイ:
```bash
supabase functions deploy csp-report
```

---

**重要**: ログを送っていただければ、最短で修正パッチを作成します。

