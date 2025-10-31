#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/.report"
mkdir -p "$OUT"

if command -v rg >/dev/null 2>&1; then
  HAS_RG=1
else
  HAS_RG=0
  echo "[warn] ripgrep not found. Falling back to grep (slower)."
fi

REPORT="$OUT/report.md"
: >"$REPORT"

{
  echo "# 開発進捗レポート（自動生成）"
  echo
  echo "## 📦 ブランチ / コミット"
  echo "- ブランチ: \`$(git -C "$ROOT" rev-parse --abbrev-ref HEAD)\`"
  echo "- 最新コミット: \`$(git -C "$ROOT" log -1 --pretty=%h)\` $(git -C "$ROOT" log -1 --pretty=%s)"
  echo "- 直近変更ファイル数(過去24h): $(git -C "$ROOT" log --since='24 hours ago' --name-only --pretty='' | sort -u | wc -l)"
  echo
  echo "## 🧩 主な変更領域"
  echo "- Supabase / Edge Functions: $(git -C "$ROOT" diff --name-only HEAD~1..HEAD | grep -E '^supabase/functions' | wc -l) files"
  echo "- Flutter / Web: $(git -C "$ROOT" diff --name-only HEAD~1..HEAD | grep -E '(^lib/|^web/|^src/)' | wc -l) files"
  echo "- CI/CD: $(git -C "$ROOT" diff --name-only HEAD~1..HEAD | grep -E '^.github/workflows' | wc -l) files"
  echo
  echo "## ⚙️ ステータス（自動ヒント）"
  echo "| 項目 | 状況 | 根拠 |"
  echo "|---|---|---|"
  if [[ -f "$ROOT/supabase/functions/exchange/index.ts" ]]; then
    echo "| exchange関数(Line Auth交換) | ✅ | ファイル存在 |"
    if [[ $HAS_RG -eq 1 ]]; then
      if rg "Deno\.serve\(|Response\(" "$ROOT/supabase/functions/exchange/index.ts" >/dev/null 2>&1; then
        echo "| CORS/途中切断対策 | ✅ | CORS/Response検出 |"
      else
        echo "| CORS/途中切断対策 | ⏳ | 未検出 |"
      fi
    else
      if grep -E "Deno\.serve\(|Response\(" "$ROOT/supabase/functions/exchange/index.ts" >/dev/null 2>&1; then
        echo "| CORS/途中切断対策 | ✅ | CORS/Response検出 |"
      else
        echo "| CORS/途中切断対策 | ⏳ | 未検出 |"
      fi
    fi
  else
    echo "| exchange関数(Line Auth交換) | ⏳ | 未検出 |"
    echo "| CORS/途中切断対策 | ⏳ | 未検出 |"
  fi
  if command -v supabase >/dev/null 2>&1; then
    echo "| Supabase CLI | ✅ | CLI検出 |"
  else
    echo "| Supabase CLI | ⏳ | 未検出 |"
  fi
  if [[ -f "$ROOT/.github/workflows/supabase.yml" ]]; then
    echo "| SupabaseデプロイCI | ✅ | supabase.yml検出 |"
  else
    echo "| SupabaseデプロイCI | ⏳ | なし |"
  fi
  echo
  echo "## 🚨 TODO / FIXME（抜粋）"
  if [[ $HAS_RG -eq 1 ]]; then
    rg -n 'TODO|FIXME|NOTE:' -S --max-filesize 200K --glob '!**/dist/**' --glob '!**/build/**' "$ROOT" | head -n 30 || echo "（該当なし）"
  else
    grep -RsnE 'TODO|FIXME|NOTE:' --exclude-dir=.git "$ROOT" | head -n 30 || echo "（該当なし）"
  fi
  echo
  echo "## 💬 次のアクション提案"
  echo "1. exchange の JWT 期限短縮 & 401時の自動再交換"
  echo "2. RLS E2Eテスト（他人データ不可の検証）を追加"
  echo "3. release/* → STG、本番(main)ラインのデプロイ動作を1度通す"
} >>"$REPORT"

echo "Report written to $REPORT"
