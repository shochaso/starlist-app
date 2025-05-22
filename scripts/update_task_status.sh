#!/bin/bash
# Script to update task status in Task.md

# Get task ID and status from arguments
TASK_ID=$1
STATUS=$2

# Check if both arguments are provided
if [ -z "$TASK_ID" ] || [ -z "$STATUS" ]; then
  echo "Usage: $0 <task_id> <status>"
  echo "Status can be: complete, progress, next, pending"
  exit 1
fi

# Check if Task.md exists
if [ ! -f "Task.md" ]; then
  echo "Error: Task.md file not found!"
  exit 1
fi

# Update task status based on the provided status
case "$STATUS" in
  "complete")
    # Mark task as completed
    sed -i '' -E "s/\[ \] (P[0-9] [🔄🔜📅⏸️]* ).*$TASK_ID.*$/[x] \1 ✅ 完了 $TASK_ID/" Task.md
    echo "Task $TASK_ID marked as completed"
    ;;
  "progress")
    # Mark task as in progress
    sed -i '' -E "s/\[ \] (P[0-9] [🔜📅⏸️]* ).*$TASK_ID.*$/[ ] \1 🔄 進行中 $TASK_ID/" Task.md
    echo "Task $TASK_ID marked as in progress"
    ;;
  "next")
    # Mark task for next sprint
    sed -i '' -E "s/\[ \] (P[0-9] [🔄📅⏸️]* ).*$TASK_ID.*$/[ ] \1 🔜 次のスプリント $TASK_ID/" Task.md
    echo "Task $TASK_ID marked for next sprint"
    ;;
  "pending")
    # Mark task as pending
    sed -i '' -E "s/\[ \] (P[0-9] [🔄🔜📅]* ).*$TASK_ID.*$/[ ] \1 ⏸️ 保留中 $TASK_ID/" Task.md
    echo "Task $TASK_ID marked as pending"
    ;;
  *)
    echo "Error: Unknown status '$STATUS'"
    echo "Status can be: complete, progress, next, pending"
    exit 1
    ;;
esac

# Automatically add changes to git staging
git add Task.md
echo "Changes to Task.md have been staged"

exit 0 