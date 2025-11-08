# 受入テスト（AT）シナリオ 50本

## 抜粋10本

* **AT-01**: Permalink正常 → 監査票にURL記録
* **AT-02**: Permalink欠損 → Exit 21発火
* **AT-03**: Stripe 0件（権限不足） → Exit 22
* **AT-04**: send空（HTTP 4xx） → Exit 23
* **AT-05**: p95 予算超過 → Go/No-GoでNo-Go
* **AT-06**: DB整数違反レコード → Pricing監査でNG件検知
* **AT-07**: 通貨不一致（USD混入） → 突合NG
* **AT-08**: レダクション検証（疑似PAN/電話/メール）
* **AT-09**: 緊急停止フラグ=1 → 送信スキップ・監査のみ
* **AT-10**: 120日Artifact保持確認（古いRun参照）

## 実行方法

```bash
# 全シナリオ実行
make at-all

# 個別シナリオ実行
make at-01  # Permalink正常テスト
make at-02  # Permalink欠損テスト
# ...
```

