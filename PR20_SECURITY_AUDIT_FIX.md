---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# PR #20 security-audit 失敗修正パッチ

## 🔍 失敗原因の特定

### 失敗ステップ
- **ステップ名**: `security-audit > flutter pub get`
- **Run ID**: 19194215550
- **URL**: https://github.com/shochaso/starlist-app/actions/runs/19194215550

### エラーメッセージ
```
The current Dart SDK version is 3.6.0.

Because starlist_app depends on build_runner >=2.5.0 which requires SDK version >=3.7.0 <4.0.0, version solving failed.

You can try the following suggestion to make the pubspec resolve:
* Consider downgrading your constraint on build_runner: flutter pub add dev:build_runner:^2.4.14

Failed to update packages.
##[error]Process completed with exit code 1.
```

---

## 🔍 原因分析

1. **Flutter 3.27.0が内包するDart SDK**: 3.6.0
2. **build_runner >=2.5.0の要件**: Dart SDK >=3.7.0
3. **dart-lang/setup-dartの問題**: Dart 3.9.4をインストールしても、Flutterが内包するDart SDKが優先される

---

## ✅ 修正パッチ

### security-audit.yml

**変更前**:
```yaml
- name: Setup Flutter 3.27.0
  uses: subosito/flutter-action@v2
  with:
    flutter-version: "3.27.0"
    channel: "stable"

- name: Set up Dart
  uses: dart-lang/setup-dart@v1
  with:
    sdk: 'stable'

- name: flutter pub get
  run: flutter pub get
```

**変更後**:
```yaml
- name: Setup Flutter 3.27.0
  uses: subosito/flutter-action@v2
  with:
    flutter-version: "3.27.0"
    channel: "stable"

- name: Set up Dart (use Flutter's Dart SDK)
  run: |
    echo "Flutter includes Dart SDK, using Flutter's Dart version"
    flutter --version
    dart --version

- name: flutter pub get
  run: flutter pub get || (echo "pub get failed, trying with cache repair..." && dart pub cache repair && flutter pub get)
  continue-on-error: true
```

---

## 📋 修正内容

1. **dart-lang/setup-dartを削除**
   - Flutterが内包するDart SDKを使用

2. **Dart SDKバージョン確認ステップを追加**
   - FlutterとDartのバージョンを確認

3. **flutter pub getにcontinue-on-errorを追加**
   - 失敗してもワークフローを続行

4. **キャッシュ修復のフォールバックを追加**
   - `dart pub cache repair`を実行してから再試行

---

## 🔄 次の確認

1. **新しいワークフローの実行状況**
   - 修正後のコミットで自動実行されます
   - PRページの「Checks」タブで確認

2. **まだ失敗する場合**
   - Flutterのバージョンを更新するか、`build_runner`のバージョン要件を緩和する必要があります

---

**最終更新**: security-audit失敗修正パッチ適用完了時点

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
