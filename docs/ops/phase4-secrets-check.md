# Phase 4 Secrets Presence Checklist

## このドキュメントの使い方 / How to Use During 2025-11-14 Event
- 自動監査ワークフロー実行前に Secrets の存在確認を行い、欠落している場合は運用チームへ連絡します。
- 秘密値を表示しないようにし、GitHub Actions `env` への参照は `${{ secrets.NAME }}` の形式を守ること。

## 必須シークレット一覧 (Presence Only)
| Secret Name | 用途 | チェック方法 | 備考 |
| --- | --- | --- | --- |
| SUPABASE_SERVICE_KEY | Supabase REST upsert | GitHub Actions 設定画面で存在確認 | 値は絶対にログ出力しない |
| SUPABASE_URL | Supabase エンドポイント | 同上 | `https://` で始まるかを設定時に確認 |
| SLACK_WEBHOOK_URL | 成功/失敗通知 | CI ガードで空チェック | URL 本体は記録禁止 |
| GH_PAT_READ | `gh run download` 用 PAT | `phase4-auto-collect.sh` 実行前に `gh auth status` で検証 | PAT 掲載禁止 |

## チェック手順 (CLI ベース)
1. `gh secret list` (必要権限がある場合) で存在を確認し、欠落時はスクリーンショットではなく `missing: SECRET_NAME` と記録。
2. `./scripts/phase4-secrets-sanity.sh` (Step7 でオプション実装可能) を実行して boolean 結果を取得。
3. CI 側では `.github/workflows/phase4-auto-audit.yml` と `phase4-retry-guard.yml` の最初のジョブで `-z "${{ secrets.NAME }}"` を使ってガード。

## 欠落時の対応
- Secrets が欠落した場合は `PHASE4_ENTRYPOINT.md` の Escalation Matrix に従って連絡。
- 補完後は再度ガードを実行し、成功ログ(シークレット値なし)を `_evidence_index.md` に追記。
