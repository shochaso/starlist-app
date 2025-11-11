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

