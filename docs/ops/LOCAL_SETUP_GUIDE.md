---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# Local Setup Guide

## Quick Start (Prod flow)

```bash
# 1) 作業開始（LinearのIssueキーが STA-6 の場合）
bin/new.sh STA-6 "Verify PR linkage"

# 2) レビュー依頼（任意）
gh pr edit --add-reviewer @me

# 3) マージ（レビュー承認 & CI通過後）
bin/finish.sh <PR番号>
```

* PRタイトルは **必ず** `[STA-<番号>]` から。

* これで Linear 側は自動で「In Progress → In Review → Done」へ遷移します。

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
