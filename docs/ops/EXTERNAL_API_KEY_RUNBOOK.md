---
source_of_truth: true
version: v1
updated_date: 2025-11-17
owner: tim (COO/PM)
updated: 2025-11-17
status: draft
category: ops/api_keys
---





# External API Key Runbook

## 1. 発行フロー

1. 開発チームが `DATA_LICENSE_AND_EXTERNAL_API_POLICY.md` を確認し、対象APIのレベルを定義。  
2. PMが対象APIに応じた **プラン（Partner / Premium / Internal）** を決定し、法務と合意。  
3. `api-key-requests@starlist.jp` に依頼メール（用途、期間、担当者）を送信。  
4. セキュリティチームが申請者の身元を確認し、承認後に Supabase でキーを生成。  
5. APIキーは `STAR_API_KEYS` vault に記録し、発行理由・有効期限を保持。

## 2. 承認ルール

- 月額 50万円超のデータライセンス契約時は COO（tim）による最終承認を必須。  
- スター本人向けキーはスター本人または所属事務所承認を要する。  
- 売上目的のキーは「用途」と「SLA」（500ms/99%）を明記。

## 3. ローテーション・削除

- APIキーは 180日ごとにローテーション。  
- 変更時は `docs/version_log/api_keys.md` に「旧キー・新キー・日付」を記録。  
- 停止理由（例: 規約違反、退職）が確定したら即座に `ops_metrics` で `api_key_revoked` イベントを送出。

## 4. インシデント対応

- 異常検知（レート超過、未知IP）は OPS チームに Slack 通知。  
- 5分以内にキーを無効化し、API利用者へメール/チャットで通知。  
- ログを保全し、 `DATA_ABUSE_INCIDENT_RUNBOOK.md` に従って弁護士にも報告。

## 5. 記録とトレーニング

- 月次で APIキーの有効数・用途・漏洩リスクをレビューし、必要なら制限を追加。  
- 新規キー発行時は `ops/KEY_ONBOARDING.md` に記録し、チーム内トレーニングを実施。
---
source_of_truth: true
version: v1
updated_date: 2025-11-17
owner: tim (COO/PM)
updated: 2025-11-17
status: draft
category: ops/api_keys
---



# External API Key Runbook

## 1. 趣旨

外部APIを管理するために発行されるAPIキーの生成・発行・承認・ローテーション・失効のフローを明文化した手順書。データライセンスとの整合性を保ちつつ、運用で迷わないためのチェックリストを提供します。

## 2. 発行と承認

- 発行者: PM（tim）または指定された技術担当者（APIチームリード）。
- 承認条件: 対象APIが `DATA_LICENSE_AND_EXTERNAL_API_POLICY.md` に準拠し、利用者が「企業/代理店」であることを確認。
- 承認フロー:  
  1. 利用申請を `docs/legal/API_TERMS_OF_USE_DRAFT.md` に沿って記載。  
  2. PMレビュー（tim）→ 法務/弁護士レビュー（必要時）→ 技術チームでキー発行。  
  3. 承認完了後、`api_key_registry`（Supabase の `external_api_keys` テーブル等）に記録。

## 3. ローテーションとモニタリング

- ローテーション周期: 通常90日、重要案件は60日。トークンの有効期限を `api_key_metadata` に記録。
- モニタリング: `ops_metrics` で `api.external.usage` イベントを拾い、5分単位でレート超過or異常アクセスを確認。
- 異常検知: 1分間に2000req/キーを超える or 1日3回以上 `403` 返却。即時 `status=revoked`。

## 4. 事故・違反時対応

- トークン停止: `external_api_keys` テーブルで `is_active=false` -> Supabase Function でキャッシュクリア。
- 連絡: PM→法務→API利用者へステータス連絡（テンプレ `docs/legal/API_TERMS_OF_USE_DRAFT.md` を引用）。
- ログ保持: `ops_metrics` + `super_chat_messages` + `api_rate_limiter` のログを ZIP で弁護士に提出要件を備える。

## 5. 資産管理

- すべてのAPIキー操作（発行/ローテーション/失効）は PR にて記録。  
- スプレッドシート等に「契約先・キーID・対応API・期限」を管理し、月次レビューで新規/更新/失効を確認。

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
