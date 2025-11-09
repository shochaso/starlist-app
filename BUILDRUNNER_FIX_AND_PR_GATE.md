# build_runner バージョン固定とPRゲート設定

## 🔍 問題

- **build_runner >=2.5.0** は Dart SDK >=3.7.0 を要求
- **Flutter 3.27.0** が内包する Dart SDK は 3.6.0
- CI で `flutter pub get` が失敗する

## ✅ 解決策

### 1. build_runner バージョンの固定

**pubspec.yaml**:
```yaml
dev_dependencies:
  build_runner: ^2.4.14  # Dart >=3.7 を要求しない最終安定帯（Flutter 3.27.x / Dart 3.6.x 対応）
```

### 2. PRゲートを邪魔しない設定

#### ops-alert-dryrun.yml

**変更前**:
```yaml
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
```

**変更後**:
```yaml
on:
  push:
    branches: [ main ]
  # pull_request を除外（PRゲートを邪魔しないため）
```

#### notify.yml

**変更前**:
```yaml
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
  pull_request:
    types: [opened, synchronize, reopened]
```

**変更後**:
```yaml
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
  # pull_request の自動実行を外し、PRゲートから切り離す
```

---

## 📋 適用した変更

1. **build_runner バージョン固定**: `^2.6.0` → `^2.4.14`
   - Dart 3.6.x / Flutter 3.27.x と互換性あり

2. **ops-alert-dryrun.yml**: `pull_request` トリガーを削除
   - main への push 時のみ実行

3. **notify.yml**: `pull_request` トリガーを削除
   - PRゲートから切り離し

---

## 🔄 次の確認

1. **新しいワークフローの実行状況**
   - 修正後のコミットで自動実行されます
   - PRページの「Checks」タブで確認

2. **security-audit の成功確認**
   - `flutter pub get` が成功することを確認

---

**最終更新**: build_runner バージョン固定とPRゲート設定適用完了時点

