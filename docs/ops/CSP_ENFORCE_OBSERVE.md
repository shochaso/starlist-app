# CSP Enforcement Observation Guide

## 1. DevTools確認
1. Chromeを開き `chrome://inspect` で Flutter web (http://localhost:8080) を選択
2. Console → `Content-Security-Policy` 警告がないか確認
3. Application → Storage で Local/Session Storage にトークンが保存されていないことを確認

## 2. CSPレポート送出の再現
1. `curl -X POST https://<edge-function>/functions/v1/csp-report` を実行
2. `curl` のレスポンスに 204 が返る
3. `logs` または `docs/reports/OPS-SUMMARY-LOGS.md` に `CSP REPORT` ログを確認

## 3. 予期せぬ違反の調査
- inline style が `unsafe-inline` なしでデフォルトブロックされる場合は、`web/index.html` の `style-src` を緩めず、必要なモジュールだけ hash を追加
- Web フォントや外部スクリプトが必要な場合は `connect-src`/`font-src` 上に明示的に追加する

## 4. 運用観測
- `docs/reports/OPS-SUMMARY-LOGS.md` に `CSP REPORT` 経由で届いたタイムスタンプと IP を追記
- 1週間以上 0 件なら `CSP_ENFORCE_OBSERVE.md` の「Weekly review」セクションへ記録
