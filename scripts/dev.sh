#!/usr/bin/env bash
set -euo pipefail

SESSION=flutter_dev

if tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "[dev] already running → hot reload"
  tmux send-keys -t "$SESSION" r
  # Chrome タブをリロード（macOS）
  osascript -e 'tell application "Google Chrome" to tell window 1 to reload active tab'
else
  # ★ 起動は一度だけ。以降ずっと常駐させる
  tmux new-session -d -s "$SESSION" \
    'flutter run -d chrome --web-port 8080'
  echo "[dev] started at http://localhost:8080"
  open -a "Google Chrome" "http://localhost:8080"
fi
