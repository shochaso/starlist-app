# CI Required / Optional 最終ポリシー

## 確定日時
2025-11-11

## ポリシー概要

| 種別 | ステータス | 対象チェック名 | 備考 |
|------|----------|--------------|------|
| **必須（Required）** | ✅ | `Conventions / check (pull_request)` | PRタイトル・Linearキーの整合性確認 |
| 〃 | ✅ | `Build / lint (pull_request)` | Node/TSなどの構文・型崩れ防止 |
| **任意（Optional）** | ⚙️ | `Flutter Startup Performance / Check Startup Performance` | 実機依存・環境差により一時除外 |
| 〃 | ⚙️ | `security-audit / security-audit (pull_request)` | 誤検知多発のため週次チェックへ |
| 〃 | ⚙️ | `extended-security / security-scan (pull_request)` | 手動/週次運用（夜間自動実行） |

---

## 運用ルール

### mainブランチ保護

* **Required チェック**: `Conventions` と `Build/lint` のみ
* **Optional チェック**: CI 内では実行されるが失敗してもマージ可

### Flutter CI

* 単一デバイス (`chrome` or `web-server`) 固定で安定化
* 実機依存のパフォーマンスチェックは Optional 化

### Security audit

* 週次 + 手動実行モード（`workflow_dispatch`）
* 誤検知が多いため、必須チェックから除外

### 管理者マージ

* 障害・デモ時のみ明示的コメントを残して許可
* コメント例: `Admin bypass merge due to <理由>. Permanent fix will follow.`

---

## 実装方針

### Required チェックの設定

GitHub Settings → Branches → Branch protection rules → `main`:
- **Require status checks to pass before merging**: ON
- **Required checks**:
  - `Conventions / check`
  - `Build / lint` (または該当するNode/TSビルドチェック)

### Optional チェックの扱い

- CI ワークフロー内では実行されるが、`continue-on-error: true` を設定
- 失敗してもマージをブロックしない
- ログは記録され、後で確認可能

### Flutter CI の単一デバイス固定

- `flutter run` コマンドに `-d chrome` または `-d web-server` を指定
- マトリックス戦略を削除し、単一デバイスで実行
- パフォーマンスチェックは Optional 化

---

## 関連ファイル

- `.github/workflows/conventions.yml` - PRタイトル規約チェック
- `.github/workflows/ci.yml` - Flutter CI（現在Disabled）
- `.github/workflows/claude.yaml` - Flutter Startup Performance Check
- `.github/workflows/security-audit.yml` - セキュリティ監査（週次）

---

## 監査メモ

- **Required**: `build (pull_request)`, `check (pull_request)`
- **Optional**: Flutter, security-audit, extended-security
- **理由**: 安定・可観測・高速。Flutter/セキュリティは失敗を可視化しつつ進行を阻害しない。

## 失敗時ロールバック

- `release.yml` を `git revert <commit>` で戻す
- `CODEOWNERS` 削除でも保護は維持（ブランチ保護が本丸）

## 更新履歴

- 2025-11-11: 最終ポリシー確定
- 2025-11-12: 監査メモとロールバック手順追加

