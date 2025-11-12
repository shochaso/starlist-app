#!/usr/bin/env bash
# scripts/generate_dora_metrics.sh
# DORA metrics (Deployment Frequency, Lead Time, MTTR, Change Failure Rate) 生成スクリプト
# Usage: ./scripts/generate_dora_metrics.sh [--output dora_metrics.json]

set -euo pipefail

OUTPUT_FILE="${1:-dora_metrics.json}"
REPO="${GITHUB_REPOSITORY:-shochaso/starlist-app}"

echo "📊 Generating DORA metrics..."

# 1. Deployment Frequency (直近30日)
DEPLOYMENT_COUNT=$(gh api repos/$REPO/releases --jq 'length' 2>/dev/null || echo "0")
DEPLOYMENT_FREQUENCY=$(echo "scale=2; $DEPLOYMENT_COUNT / 30" | bc || echo "0")

# 2. Lead Time (PR作成からマージまでの時間)
LEAD_TIMES=$(gh pr list --repo "$REPO" --state merged --limit 100 --json createdAt,mergedAt --jq '.[] | select(.mergedAt != null) | ((.mergedAt | fromdateiso8601) - (.createdAt | fromdateiso8601)) / 86400' 2>/dev/null || echo "")
LEAD_TIME_MEDIAN=$(echo "$LEAD_TIMES" | sort -n | awk '{
  a[NR]=$0
} END {
  if (NR % 2 == 1) print a[(NR+1)/2]
  else print (a[NR/2] + a[NR/2+1]) / 2
}' || echo "0")

# 3. MTTR (Mean Time To Recovery) - インシデント解決時間
# 簡易版: PR作成からマージまでの時間の中央値を使用
MTTR="$LEAD_TIME_MEDIAN"

# 4. Change Failure Rate (失敗したデプロイの割合)
FAILED_DEPLOYMENTS=$(gh run list --repo "$REPO" --workflow="release.yml" --limit 30 --json conclusion --jq '[.[] | select(.conclusion == "failure")] | length' 2>/dev/null || echo "0")
TOTAL_DEPLOYMENTS=$(gh run list --repo "$REPO" --workflow="release.yml" --limit 30 --json conclusion --jq 'length' 2>/dev/null || echo "1")
CHANGE_FAILURE_RATE=$(echo "scale=4; $FAILED_DEPLOYMENTS / $TOTAL_DEPLOYMENTS * 100" | bc || echo "0")

# JSON生成
jq -n \
  --arg df "$DEPLOYMENT_FREQUENCY" \
  --arg lt "$LEAD_TIME_MEDIAN" \
  --arg mttr "$MTTR" \
  --arg cfr "$CHANGE_FAILURE_RATE" \
  --arg generated "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
  '{
    generated: $generated,
    metrics: {
      deployment_frequency: ($df | tonumber),
      lead_time_days: ($lt | tonumber),
      mttr_days: ($mttr | tonumber),
      change_failure_rate_percent: ($cfr | tonumber)
    },
    metadata: {
      deployment_count: '$DEPLOYMENT_COUNT',
      failed_deployments: '$FAILED_DEPLOYMENTS',
      total_deployments: '$TOTAL_DEPLOYMENTS'
    }
  }' > "$OUTPUT_FILE"

echo "✅ DORA metrics generated: $OUTPUT_FILE"
cat "$OUTPUT_FILE"

