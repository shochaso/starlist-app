---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# 運用教育ミニ教材（5分×5本）

## 01：最短3コマンドの意味

```bash
AUDIT_LOOKBACK_HOURS=48 ./FINAL_INTEGRATION_SUITE.sh  # 監査実行
make verify && make summarize                          # 検証・要約
make gonogo                                            # Go/No-Go判定
```

## 02：Exit 21/22/23 の違いと初動

* **Exit 21**: Permalink未取得 → Slack Webhook/Secret再設定
* **Exit 22**: Stripe 0件 → HOURS延長/API Key権限確認
* **Exit 23**: send空 → JSON整合確認/Edgeログ再確認

## 03：緊急停止フラグの使いどころ

```bash
STARLIST_SEND_DISABLED=1 ./FINAL_INTEGRATION_SUITE.sh
```

事故時は即座に無害化して監査のみ継続。

## 04：Permalinkが命な理由（証跡連鎖）

Slack Permalinkは監査票とSlack投稿を結ぶ唯一の証跡。欠損するとExit 21。

## 05：p95の読み方（現場判断に効く）

p95 latencyが予算（2000ms）を超えるとSLO逸脱。Go/No-GoでNo-Go判定。



## 01：最短3コマンドの意味

```bash
AUDIT_LOOKBACK_HOURS=48 ./FINAL_INTEGRATION_SUITE.sh  # 監査実行
make verify && make summarize                          # 検証・要約
make gonogo                                            # Go/No-Go判定
```

## 02：Exit 21/22/23 の違いと初動

* **Exit 21**: Permalink未取得 → Slack Webhook/Secret再設定
* **Exit 22**: Stripe 0件 → HOURS延長/API Key権限確認
* **Exit 23**: send空 → JSON整合確認/Edgeログ再確認

## 03：緊急停止フラグの使いどころ

```bash
STARLIST_SEND_DISABLED=1 ./FINAL_INTEGRATION_SUITE.sh
```

事故時は即座に無害化して監査のみ継続。

## 04：Permalinkが命な理由（証跡連鎖）

Slack Permalinkは監査票とSlack投稿を結ぶ唯一の証跡。欠損するとExit 21。

## 05：p95の読み方（現場判断に効く）

p95 latencyが予算（2000ms）を超えるとSLO逸脱。Go/No-GoでNo-Go判定。

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
