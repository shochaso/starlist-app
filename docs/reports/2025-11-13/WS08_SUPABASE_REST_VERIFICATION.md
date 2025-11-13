# WS08: Supabase REST API検証証跡

**実行日時**: 2025-11-13
**作業者**: Cursor AI

## 検証方法

Supabase SERVICE/ANONキーの有無で分岐し、REST APIを検証。

### 分岐ロジック

```bash
if [ -z "${SUPABASE_URL:-}" ] || [ -z "${SUPABASE_SERVICE_KEY:-}" ]; then
  echo "⚠️ Supabase credentials not set - skipping"
  echo "SKIP=true" >> $GITHUB_OUTPUT
else
  # REST API呼び出し
  curl -X GET "${SUPABASE_URL}/rest/v1/slsa_runs?select=*&limit=1" \
    -H "Authorization: Bearer ${SUPABASE_SERVICE_KEY}" \
    -H "apikey: ${SUPABASE_SERVICE_KEY}"
fi
```

## 検証結果

### SERVICE KEY検証

**Status**: ⏳ Pending (credentials確認待ち)

**期待される応答**:
- 200 OK: 成功
- 401 Unauthorized: 認証失敗
- 404 Not Found: テーブル不存在

**応答JSON**: [記録待ち]

### ANON KEY検証

**Status**: ⏳ Pending (credentials確認待ち)

**期待される応答**:
- 200 OK: 成功（RLSポリシーにより読み取りのみ）
- 401 Unauthorized: 認証失敗

**応答JSON**: [記録待ち]

## 証跡

- 実行時刻: [記録待ち]
- HTTP Status: [記録待ち]
- 応答JSON: [記録待ち]
- エラーメッセージ: [記録待ち]

**状態**: ⏳ 実行待ち
