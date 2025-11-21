---
source_of_truth: true
version: v1
updated_date: 2025-11-17
owner: tim (COO/PM)
updated: 2025-11-17
status: draft
category: ops/security
---





# データ悪用インシデントRunbook

## 1. 兆候と検知

- 監査ログ（`ops_metrics`）で「再識別試行」「大量ダウンロード」「404が増加」などの異常を検知。  
- Threat team からの報告、顧客問い合わせ（「データが怪しい」との指摘）もトリガー。  
- Slack `#ops-alert` に自動通知し、PM/法務/開発チームで即時共有。

## 2. 初期対応（5分以内）

1. 該当APIキーを Supabase で即ロック。  
2. 当該契約者のアクセスを一時停止（dashboard UI で status = suspended）。  
3. ログをエクスポートし、`logs/data-abuse/<timestamp>.json` に保管。  
4. 弁護士に一次連絡（簡易説明 + 影響範囲）。

## 3. 二次調査

- どのデータ（スター統計・スパチャ等）が漏れたかを `DATA_ANONYMIZATION_GUIDE.md` と照合。  
- 再識別が起きていないか、サンプルサイズ・ニッチ属性が意図せず出力されているか確認。  
- 影響スター・ファンにも通知（必要に応じて法務と定型文を調整）。

## 4. 復旧・再発防止

- APIキー/シークレットを再発行し、旧キーは完全に無効化。  
- 関連ドキュメント（API Terms, Anonymization Guide）への追記を実施。  
- インシデント報告書を `docs/ops/INCIDENT_REPORTS/<id>.md` に保存し、次回運用会議で共有。

## 5. 役割

- **PM (tim)**：ステークホルダー連絡、契約リスク判断。  
- **法務**：通知文案確認、継続契約の可否判断。  
- **開発/OPS**：キー停止、ログ出力、再発防止策の実行。  
- **SRE**：監視/アラートルールの調整とドキュメント更新。
---
source_of_truth: true
version: v1
updated_date: 2025-11-17
owner: tim (COO/PM)
updated: 2025-11-17
status: draft
category: ops/security
---



# データ悪用インシデント・ランブック

## 1. 適用範囲

再識別、再販売、データ漏洩など `DATA_LICENSE…` に違反する疑いのある API 利用や外部提供の兆候を検知した際に迅速に動くためのチェックリストです。

## 2. インシデント対応フロー

1. **検知**:  
   - `ops_metrics` で `data_reidentification_attempt` イベント  
   - `api_rate_limiter` で異常なリクエストパターン  
   - レポート（法務/PM）など。  
2. **一次確認**:  
   - PM → `api_key_registry` から対象キー特定  
   - 開発チームがリクエストボディ/レスポンスを確認し、PIIが含まれていないかチェック  
3. **緊急停止**:  
   - 該当 API キーを即時無効化（`is_active=false`）  
   - Cloudflare/WAF で IPブロック  
4. **ステータス連絡**:  
   - PM→法務→顧客へ状況と再開要件を通知  
5. **保全**:  
   - ログ（Supabase / Edge Function）を zip して `docs/legal/DATA_LICENSE…` チームに渡す  
6. **振り返り**:  
   - チームでインシデントレビュー（週次）

## 3. 役割

- PM: tim（連絡、ドキュメント、裁量決定）  
- 技術: APIチーム（ログ確認、キー停止、再発防止策）  
- 法務: 規約違反か判定・弁護士相談  
- Ops: infra 側（WAF/キーの即時ローテーション）

## 4. 主要シグナル

- `super_chat_messages` で `tier_n_threshold` を超える量を短時間にDLしようとしたログ  
- `external_api_keys` から同一IPに複数キーのリクエスト  
- 複数のAPIで同じ契約IDを用いて再販の痕跡（`referer`/`user_agent`）が怪しい

## 5. フォローアップ

1. インシデント後三日以内に `DATA_LICENSE…`/`API_TERMS…` に反映  
2. 年次棚卸しで本ランブックを見直し、評価/改善ポイントを記録  
3. 重大インシデントは顧客通知テンプレート（`docs/legal/API_TERMS…`）にも記載

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
