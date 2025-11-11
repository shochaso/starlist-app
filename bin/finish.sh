#!/usr/bin/env bash

set -euo pipefail

PR="${1:-}"

if [[ -z "$PR" ]]; then
  # カレントブランチのPRを推定
  PR="$(gh pr view --json number -q .number 2>/dev/null || true)"
fi

if [[ -z "$PR" ]]; then
  echo "Usage: bin/finish.sh <PR number or URL>"
  exit 1
fi

# 既定：Squash & ブランチ削除（必要なら --admin で上書き可）
gh pr merge "$PR" --squash --delete-branch

# ローカル整理
git fetch origin --prune
git switch main
git pull --ff-only
echo "✅ Merged PR #$PR and refreshed main."

