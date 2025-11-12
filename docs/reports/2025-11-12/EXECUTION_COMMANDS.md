# Execution Commands (Copy-Paste Ready)

**Date**: 2025-11-13 (UTC)
**Purpose**: One-pass execution commands for WS02-WS14 evidence collection

---

## Prerequisites Check

```bash
# A. workflow_dispatch確認
grep -n "workflow_dispatch" .github/workflows/slsa-provenance.yml
grep -n "workflow_dispatch" .github/workflows/provenance-validate.yml

# B. Secrets確認
gh secret list --repo shochaso/starlist-app | grep -E "SUPABASE_URL|SUPABASE_SERVICE_KEY|SLACK_WEBHOOK_URL" || echo "Secrets not found"

# C. 日付ディレクトリ準備
REPORT_DIR="docs/reports/$(date -u +%F)"
mkdir -p "$REPORT_DIR/slack_excerpts" "$REPORT_DIR/artifacts" "$REPORT_DIR/observer"
echo "REPORT_DIR=$REPORT_DIR"
```

---

## 1) Success Case Execution

```bash
# 1-1 実行（手動dispatch）
TAG_SUCCESS="vtest-success-$(date +%Y%m%d%H%M%S)"
gh workflow run .github/workflows/slsa-provenance.yml -f tag="$TAG_SUCCESS"

# 1-2 最新の slsa-provenance 実行を特定
sleep 5
RUN_ID_SUCCESS=$(gh run list --workflow slsa-provenance.yml --json databaseId,displayTitle,createdAt \
  -q '.[0].databaseId')
echo "RUN_ID_SUCCESS=$RUN_ID_SUCCESS"

# 1-3 ログ＆アーティファクト取得
gh run view "$RUN_ID_SUCCESS" --log > "$REPORT_DIR/run_${RUN_ID_SUCCESS}.log"
gh run download "$RUN_ID_SUCCESS" --dir "$REPORT_DIR/artifacts/${RUN_ID_SUCCESS}"

# 1-4 provenance JSON の predicate / SHA 突合
PROV=$(find "$REPORT_DIR/artifacts/${RUN_ID_SUCCESS}" -name "provenance-*.json" | head -n1)
if [ -n "$PROV" ]; then
  METASHA=$(jq -r '.metadata.content_sha256' "$PROV")
  CALCSHA=$(shasum -a 256 "$PROV" | awk '{print $1}')
  PREDICATE=$(jq -r '.predicateType' "$PROV")
  echo -e "| run_id | tag | predicateType | meta_sha | calc_sha | equal |\n|---|---|---|---|---|---|\n| $RUN_ID_SUCCESS | $TAG_SUCCESS | $PREDICATE | $METASHA | $CALCSHA | $([ "$METASHA" = "$CALCSHA" ] && echo OK || echo MISMATCH) |" \
    > "$REPORT_DIR/WS06_SHA256_VALIDATION.md"
fi

# 1-5 manifest 追記（原子）
MANI="$REPORT_DIR/_manifest.json"
TMP="$MANI.tmp"
jq -n --arg rid "$RUN_ID_SUCCESS" --arg tag "$TAG_SUCCESS" --arg sha "${CALCSHA:-}" --arg url "https://github.com/shochaso/starlist-app/actions/runs/$RUN_ID_SUCCESS" --arg ts "$(date -u +%FT%TZ)" \
  '{run_id:($rid|tonumber), tag:$tag, sha256:$sha, run_url:$url, created_at:$ts, uploader:"actions/slsa-provenance"}' > "$TMP"
if [ -s "$MANI" ]; then 
  jq -s '.[0] as $n | .[1] + [$n]' "$TMP" "$MANI" > "$MANI.new"
  mv "$MANI.new" "$MANI"
else 
  jq -s '.' "$TMP" > "$MANI"
fi
rm -f "$TMP"

# 1-6 報告書の追記（Success レコード）
cat >> "$REPORT_DIR/PHASE2_2_VALIDATION_REPORT.md" <<SUCCESS_EOF

## Success Case

- Run URL: https://github.com/shochaso/starlist-app/actions/runs/${RUN_ID_SUCCESS}
- Tag: ${TAG_SUCCESS}
- Conclusion: success（想定）
- Artifacts: ${PROV##*/}
- Executed at (UTC/JST): $(date -u +%FT%TZ) / $(TZ=Asia/Tokyo date +%F\ %T%z)
- Validator run: [to be filled after validate]

SUCCESS_EOF
```

---

## 2) Failure Case Execution

```bash
# 2-1 テスト用ブランチ（必要なら）
git switch -c chore/slsa-fail-inject || git checkout chore/slsa-fail-inject

# 2-2 一時ステップを挿入（slsa-provenance.yml の任意ステップ直後）
# 注意: 実際のファイル編集が必要

# 2-3 実行（failタグ）
TAG_FAIL="vtest-fail-$(date +%Y%m%d%H%M%S)"
gh workflow run .github/workflows/slsa-provenance.yml -f tag="$TAG_FAIL"
sleep 5
RUN_ID_FAIL=$(gh run list --workflow slsa-provenance.yml --json databaseId -q '.[0].databaseId')
gh run view "$RUN_ID_FAIL" --log > "$REPORT_DIR/run_${RUN_ID_FAIL}.log"
gh run download "$RUN_ID_FAIL" --dir "$REPORT_DIR/artifacts/${RUN_ID_FAIL}" || true

# 2-4 Slack非機微ログ抜粋
grep -nEi "slack|webhook|POST" "$REPORT_DIR/run_${RUN_ID_FAIL}.log" | head -n 10 \
  > "$REPORT_DIR/slack_excerpts/${RUN_ID_FAIL}.log" || echo "No Slack logs found"

# 2-5 報告書追記（Failure）
cat >> "$REPORT_DIR/PHASE2_2_VALIDATION_REPORT.md" <<FAIL_EOF

## Failure Case

- Run URL: https://github.com/shochaso/starlist-app/actions/runs/${RUN_ID_FAIL}
- Tag: ${TAG_FAIL}
- Conclusion: failure（意図的）
- Executed at (UTC/JST): $(date -u +%FT%TZ) / $(TZ=Asia/Tokyo date +%F\ %T%z)
- Slack excerpt: ${REPORT_DIR}/slack_excerpts/${RUN_ID_FAIL}.log

FAIL_EOF

# 2-6 一時ステップを即リバート
git revert -n HEAD && git commit -m "revert: remove intentional fail step" && git push
```

---

## 3) Concurrency Case Execution

```bash
# 3本同時実行
for i in 1 2 3; do
  gh workflow run .github/workflows/slsa-provenance.yml -f tag="vtest-conc-$i-$(date +%s)" &
  sleep 1
done
wait

# 最新3件の run_id を記録
gh run list --workflow slsa-provenance.yml --json databaseId,url,createdAt -q '.[0:3][] | "- " + .url' \
  >> "$REPORT_DIR/PHASE2_2_VALIDATION_REPORT.md"
```

---

## 4) Validator Execution

```bash
# 成功RUNと失敗RUNについて provenance-validate を手動起動
gh workflow run .github/workflows/provenance-validate.yml -f run_id="$RUN_ID_SUCCESS" -f tag="$TAG_SUCCESS" || true
gh workflow run .github/workflows/provenance-validate.yml -f run_id="$RUN_ID_FAIL" -f tag="$TAG_FAIL" || true

# 直近の validator の結論を報告書へ
VAL_LAST=$(gh run list --workflow provenance-validate.yml --json databaseId,conclusion,url -q '.[0]')
echo "- Latest validator: $(echo "$VAL_LAST" | jq -r .url) / verdict: $(echo "$VAL_LAST" | jq -r .conclusion)" \
  >> "$REPORT_DIR/PHASE2_2_VALIDATION_REPORT.md"
```

---

## 5) Supabase Integration (if configured)

```bash
if [ -n "${SUPABASE_URL:-}" ] && [ -n "${SUPABASE_SERVICE_KEY:-}" ]; then
  curl -s -H "apikey: ${SUPABASE_SERVICE_KEY}" -H "Authorization: Bearer ${SUPABASE_SERVICE_KEY}" \
    "${SUPABASE_URL}/rest/v1/slsa_audit_metrics?select=run_id,tag,status,created_at&order=created_at.desc&limit=10" \
    > "$REPORT_DIR/SUPABASE_RESPONSE.json"
  echo "- Supabase response saved: $REPORT_DIR/SUPABASE_RESPONSE.json" >> "$REPORT_DIR/PHASE3_AUDIT_SUMMARY.md"
else
  echo "- Supabase: [保留] Secrets 未設定のためREST確認はスキップ" >> "$REPORT_DIR/PHASE3_AUDIT_SUMMARY.md"
fi
```

---

## 6) Observer Execution

```bash
# 手動実行
gh workflow run .github/workflows/phase3-audit-observer.yml

sleep 5
OB_RUN=$(gh run list --workflow phase3-audit-observer.yml --json databaseId -q '.[0].databaseId')
gh run download "$OB_RUN" --name phase3-audit-summary-$OB_RUN --dir "$REPORT_DIR/observer" || true
```

---

## 7) PR Comment (when conditions met)

```bash
gh pr comment 61 --repo shochaso/starlist-app \
  --body "## ✅ Phase 3 Audit Operationalization Verified

All validation checks passed successfully.

**✅ Phase 3 Audit Operationalization Verified — Proceed to Phase 4 (Telemetry & KPI Dashboard)**"
```

---

**Note**: Execute these commands in order. Results will be saved to `$REPORT_DIR`.
