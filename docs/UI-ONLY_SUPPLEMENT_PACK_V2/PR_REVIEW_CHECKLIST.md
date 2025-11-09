# PR Review Checklist — Docs / Security / CI (UI-only)

目的：UIでのレビューだけで最低限の安全性を担保するチェックリスト

- [ ] PR タイトル/本文に目的と影響範囲が明記されている
- [ ] CI ワークフロー（extended-security 等）が main に存在するか確認
- [ ] Docs 変更は `docs/reports/DAY12_SOT_DIFFS.md` に追記指示がある
- [ ] Security: Semgrep/Trivy の観察 run-id を PR コメントに添付
- [ ] SBOM/SARIF がアーティファクトとして生成されている（run artifacts を確認）
- [ ] Branch Protection に必要な contexts が PR description に提示されている
- [ ] ロールバック手順が記載されている（短く）
- [ ] レビュー承認者が 1 名以上設定されている
- [ ] ラベル（security / draft / docs）付与済み

