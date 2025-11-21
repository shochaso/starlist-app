---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# WS14: Observer → Supabase POST検証証跡

**実行日時**: 2025-11-13
**作業者**: Cursor AI

## 検証方法

Observer → SupabaseへのPOSTをcurl+jqで検証し、応答JSONを保全。

### 検証コマンド

```bash
# POSTリクエスト
curl -X POST "${SUPABASE_URL}/rest/v1/slsa_audit_metrics" \
  -H "Authorization: Bearer ${SUPABASE_SERVICE_KEY}" \
  -H "apikey: ${SUPABASE_SERVICE_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "audit_run_id": 123456789,
    "provenance_run_id": 987654321,
    "validation_run_id": 111222333,
    "audit_timestamp": "2025-11-13T00:00:00Z",
    "provenance_status": "success",
    "validation_status": "success",
    "sha256_verified": true,
    "predicate_type_verified": true,
    "supabase_provenance_synced": true,
    "supabase_validation_synced": true
  }' | jq '.' > response.json

# 応答確認
cat response.json
```

## 検証結果

**Status**: ⏳ Pending (credentials確認待ち)

**期待される応答**:
- 201 Created: 新規作成成功
- 200 OK: 更新成功（on_conflict時）
- 400 Bad Request: リクエスト不正
- 401 Unauthorized: 認証失敗

**応答JSON**: [記録待ち]

**状態**: ⏳ 実行待ち

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
