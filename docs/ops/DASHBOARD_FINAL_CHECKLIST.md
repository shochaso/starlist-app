# ✅ 最終合格（Go/No-Go）チェック — Dashboard編（8項）

## チェックリスト

1. **v2スキーマ検証**：`make verify-v2` が成功（`tz=Asia/Tokyo`/必須キー充足）。
2. **KPIスナップショット**：`dashboard/data/latest.json` が**存在**し、`updated_at` が当日。
3. **CI連携**：`integration-audit.yml` 実行後に `latest.json` が**自動更新**される（コミットログに反映）。
4. **UI表示**：`/dashboard/audit` にて**4指標**（成功率/件数/p95/不一致）が表示。
5. **10分ウォッチ**：`make watch-10min` を2回連続で実行し、**p95が上昇していない**。
6. **データ分離**：PIIなし（`latest.json` は集計値のみ）、原本はArtifactsで120日保全。
7. **エッジAPI（任意）**：`/api/audit/latest` が 200 を返し、`latest.json` と一致。
8. **Safe Mode**：`STARLIST_SEND_DISABLED=1` で**送信停止＋監査のみ**に切替可。

→ 8項すべてOKで **Go** 判定です。

---

## 🧪 スモーク & 回帰テスト（貼って即実行）

```bash
# スキーマ拡張・検証
make schema && make verify-v2

# フェイクデータで煙テスト（UIとCIの流れを疑似）
make smoke-fake

# 10分ウォッチ（2回目まで待機）
make watch-10min

# ダッシュボード起動（Next.js）
npm i recharts
npm run dev   # http://localhost:3000/dashboard/audit
```

**合格基準（最小）**

* `/dashboard/audit` で値が表示（NaN/undefinedなし）
* `make smoke-fake` → 監査票生成・検証成功
* 10分後の再計測で p95 が**増加傾向にない**

---

## 🧯 よくある詰まりと即応（ダッシュボード増設後）

### latest.jsonが更新されない

* **原因**: CIの`Publish latest KPI`ステップが `if: success()` に乗っているか確認／`git push` 権限。
* **対応**: GitHub Actionsの権限設定を確認、`GITHUB_TOKEN`の権限を確認。

### 成功率が0%のまま

* **原因**: `send.json` が空 → Exit 23の影響か、パス誤り。
* **対応**: `tmp/audit_day11/send.json` の有無と長さ確認。

### チャートがダミーのまま

* **原因**: `TrendChart`はモック。
* **対応**: 実データに置き換える場合は、週次集計JSON（`dashboard/data/weekly.json`等）をCIで生成→差し替え。

### PII混入懸念

* **原因**: `latest.json` にIDやメールが含まれている可能性。
* **対応**: `scripts/utils/redact.sh` をCI前段で適用。

### CORS/パスズレ

* **原因**: `/dashboard/data/latest.json` の公開パスと `route.ts` のBASE_URL が不一致。
* **対応**: 環境に合わせる（`NEXT_PUBLIC_BASE_URL`）。

---

## 🔐 セキュリティ・ガバナンス最終ひと押し

* **Secrets指紋**：`make fingerprint` を**Go宣言直後**に実行し、`launch_decision.log` にハッシュ追記。
* **署名タグ**：`git tag -s "launch-<YYYYMMDD-HHMM>"` を**ダッシュボード公開コミット**に付与（監査票リンク記載）。
* **データ保持**：`DATA_RETENTION_POLICY.md` にダッシュボードKPI（集計値のみ）を**対象外**として明記（PIIを一切保持しない宣言）。

---

## 🗺️ ロールアウト計画（現実運用の順番）

1. **Stage**（社内のみ）：`make smoke-fake` → `/dashboard/audit`表示確認 → KPIのしきい値（目標）をREADME/チェックリストに併記。
2. **Pilot**（限定共有）：実データCIで`latest.json`更新 → 2週間の安定観察（p95/成功率/不一致ゼロ継続）。
3. **Prod**（全社）：READMEバッジに**ダッシュボードリンク**を追加。
4. **運用定着**：週次定例でダッシュボードの4指標をレビュー → No-Goのしきい値を運用合意（例：p95>2000ms 2週連続で改善アクション必須）。

---

## 📈 将来の拡張ポイント（無理なく足せるやつ）

* **週次トレンドデータ**：CIで `weekly.json` を生成し `TrendChart` に差し替え。
* **ゼロ不一致ストリーク**：`streak` をCIで計算（不一致0の日が続くごとに +1）。
* **SLO違反通知**：p95や成功率が目標割れでSlack自動通知（チャネル #ops-audit）。
* **権限・監査ログ**：`/api/audit/latest` へのアクセスをIP制限／Basic認証（運用体制に応じて）。

---

## 🧭 本番入りの最短3ステップ（ダッシュボード込み）

```bash
AUDIT_LOOKBACK_HOURS=48 ./FINAL_INTEGRATION_SUITE.sh
make verify-v2 && make summarize && make gonogo
# Goなら
npm run build && npm run start   # or デプロイCI
```

---

**最終更新**: 2025-11-08  
**責任者**: Ops Team  
**承認**: COO兼PM ティム

