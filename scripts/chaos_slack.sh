#!/usr/bin/env bash
# Chaos（安全版）：一時的にSlack送信を失敗させる検証
# 検証環境のみで使用すること

export STARLIST_SEND_DISABLED=1
./FINAL_INTEGRATION_SUITE.sh --day11-only || true
echo "[chaos] Slack send disabled simulated"

