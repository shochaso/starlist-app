# STARLIST Gemini Knowledge Base
Generated on: 2025-11-21 18:05:00

---

## 0. 要約（Gem に渡せる即席サマリ）
- **サービス概要**  
  STARLIST は Flutter/Web アプリと Supabase を中心に、スター・ファン・運営が共創できる「推し活プラットフォーム」を構築しています。データインポート・決済/サブスク・AIアシスト・Ops監視を一気通貫で扱い、継続収益基盤を狙います。
- **ビジネス目標**  
  1. スターの収益化率を高める（保存・公開の行動を促進）。  
  2. Ops/監査の自動化を進め、スケーリング可能なガバナンスを維持。  
  3. Docs/Specs を Source-of-Truth 化してチーム合意を起こす。
- **主要KPI**  
  - 週次Ops配信成功率 ≥ 99%（`ops_summary_email_logs`）  
  - p95 APIレイテンシ ≤ 800ms（`v_ops_5min`）  
  - 失敗率（日次） ≤ 0.5%（`ops_metrics`）  
  - β登録スター数：週15〜20名（`star_profiles`）  
- **今必要な情報**  
  1. YouTube Import Revamp（GPT-4.1 OCR + YouTube Data API + Riverpod workflow + GAISTUDIO UIs）  
  2. Feature Matrix / Pricing Spec / Docs健全化課題（Linear STA-24〜STA-31）  
  3. Markdown CI と Node20 lint の共通セットアップ  
  4. Gem に渡すべき画像/スクショのレビュー手順（スクリーンショット→OCR→URL→保存/publish）  

---

## 1. サービス編成
- **Flutter App**: `lib/src/features/` + `providers/` でデータ取得・スクロール/カードを構成。最新は YouTube Import screen。  
- **Backend**: NestJS（`server/src`）＋Supabase（Edge Functions, RLS）。  
- **データ & Ops**: Supabase と Stripe を活用し、Edge/Download/Telemetryを統合。  
- **AI**: Gemini/OpenAI でOCRとリンク補完。Gem版は GPT-4.1 mini Responses API。YouTube Data API で確認済みURL取得。  
- **Docs/KPI**: `docs/overview/STARLIST_OVERVIEW.md`, `docs/specs`, `docs/aistudio` などで要約。MD_CI_REPORT で Markdown 健全性管理。

## 2. 今日のアクション
1. YouTube Import Revamp → PR準備 / CI + screenshot prompt / expansion blueprint などの文書化。  
2. Feature Matrix の PR + overview リンク + docsリンク整備（Linear STA-24/25）。  
3. Markdown/Docs cleanup（MD_CI_REPORT, table/codefence, Node20 lint, setup doc）  
4. Pricing spec + Supabase/RLS/migrationドキュメント更新（doc revenue pages）。  

## 3. TBD（TODO）
- GAISTUDIO-style UIのスクショレビュー：画像/動画を提供したら比較・epic patchを提示する引用限定の prompt を準備済み。  
- Shopping/Music/Receipt インポートを YouTube パターンで水平展開する計画あり。  
- Documentation health: MD_CI_REPORT の集計強化、UPDATE_LOG に進捗記録。  
- Node環境: scripts/ensure-node20.js の Node18互換 or Node20手順の docs を準備。  

## 4. References（Gem に見せたい資料）
- `docs/specs/STARLIST_FEATURE_MATRIX.md` – プロダクト機能一覧＆スコープ。  
- `lib/features/data_integration/screens/youtube_import_screen.dart` – 新UIワークフロー。  
- `lib/src/services/youtube_local_importer.dart` – Legacy/OpenAIとResponses APIの切替。  
- `docs/ops/` – ops runbooks + markdown guiding.  
- `docs/api/YOUTUBE_API_SETUP.md` – APIキー/環境変数の管理。  
- `Linear STA-24〜STA-31` – 進行中のタスク (Feature Matrix, Markdown CI, Node compatibility, Docs health)。

## 5. Contact & Next Steps
- PM: 仕様整備と Feature Matrixのキーハンドル）。  
- Ops lead: Monitoring/KPI。  
- Docs lead: Markdown cleanup、CI workflowの整備。  
- Next for GEM: Provide screenshot, confirm OCR flow, run new workflow (upload → OCR → link → save/publish).
