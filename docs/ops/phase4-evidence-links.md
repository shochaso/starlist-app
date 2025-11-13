# Phase 4 Evidence Linking Policy

## このドキュメントの使い方 / How to Use During 2025-11-14 Event
- Phase 4 の監査証跡を PR コメントや Slack 連携へ記載する際のルール集です。
- 実施前に `_evidence_index.md` (2025-11-14) と整合性を取り、重複リンクを避けます。

## 記載原則
1. 直接リンクを共有しない。GitHub Run ID や Artifact 名、Supabase オブジェクトキーなどの識別子のみ記載。
2. Slack では `status / timestamp / summary` のみを共有し、リンクは "参照: docs/reports/2025-11-14/_manifest.json" と明記。
3. PR コメントでは以下フォーマットを使用:
   ```
   - Evidence: RUN_ID=123456789 (artifact: phase4/audit/provenance-123456.json)
   - SHA Parity: true (computed via scripts/phase4-sha-compare.sh)
   - Stored At: docs/reports/2025-11-14/artifacts/123456/
   ```

## `_manifest.json` の位置づけ
- 各証跡を `_manifest.json` に一元管理し、`phase4-manifest-atomic.sh` で追加。
- フィールド例: `run_id`, `artifact_path`, `evidence_type`, `recorded_at_utc`, `notes`.
- PR コメントでは Manifest の相対パスを指し示し、閲覧者がローカルで参照できるようにする。

## 監査ログとの整合
- `RUNS_SUMMARY.json` の `observer_notes` と `_evidence_index.md` の `Notes` を必ず同期。
- 証跡削除が必要な場合は、先に Manifest から行を削除し、`AUTO_OBSERVER_SUMMARY.md` に理由を記載。
