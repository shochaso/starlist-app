# STARLIST Day5 実装進行サマリー

Status: in-progress  
Last-Updated: 2025-11-07  
Owner: PM (Tim) / Impl DRI: Mine

---

## 1. 概要

- Day4 ドキュメント整備・Node20 強制・LinkCheck 自動化が完了し、Day5 Telemetry/OPS 実装フェーズへ移行。  
- docs 情報アーキテクチャを `overview / features / architecture / ops / guides` に統合。  
- Lint/CI は `scripts/ensure-node20.js` + `docs-link-check.yml` で自動実行 (Node 20 固定)。

## 2. ハイライト (Day4 → Day5)

| 項目 | 状況 | メモ |
| --- | --- | --- |
| Node 20 enforcement | ✅ Done | `.nvmrc`, `.npmrc (engine-strict)`, `package.json` `engines` を更新。 |
| Link Check | ✅ Done | `lint:md` + `.mlc.json` + GH Actions badge が緑。 |
| Docs IA | ✅ Done | `COMMON_DOCS_INDEX.md`, `STARLIST_OVERVIEW.md`, Mermaid を新構成に同期。 |
| Day5 kick-off | 🚀 Start | DB→Edge→Flutter→UI→CI の順で Telemetry/OPS を実装。 |

## 3. Day5 実装タスク (DoD)

1. **DB**: `ops_metrics` + `v_ops_5min` マイグレーション (`supabase db push`)  
2. **Edge**: `telemetry` → `ops-alert` の順で serve/deploy。`dryRun` で通知を検証。  
3. **Flutter**: `OpsTelemetry` サービスを介してイベント送信ボタンを用意（ダミー）。  
4. **UI**: OPS ダッシュボードに 5分平均のカード + 折れ線を表示。  
5. **CI**: `qa-e2e.yml` で Telemetry POST / ops-alert dryRun の 2 ケースを自動化。

## 4. ロードマップ

- Day5 (現フェーズ): Telemetry/OPS 実装・QA 自動化。  
- Day6 (予告): 運用監視フェーズ（OPS-002）を拡張、通知チューニング & BizOpsレポート連携。

## 5. 参考リンク

- docs/overview/COMMON_DOCS_INDEX.md  
- docs/overview/STARLIST_OVERVIEW.md  
- docs/Mermaid.md  
- docs/ops/OPS-MONITORING-001.md (正準)  
- scripts/ensure-node20.js, scripts/lint-md-local.sh

