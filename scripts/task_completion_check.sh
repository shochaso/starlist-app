#!/bin/bash
# Script to automatically check if tasks are completed based on code state

# Navigate to project root
cd "$(git rev-parse --show-toplevel)" || exit 1

echo "Checking task completion status..."

# Define task keywords as individual variables instead of associative array
# Format: task_keyword_<identifier>="search pattern"
task_keyword_user_registration="lib/src/features/auth"
task_keyword_login="lib/src/features/auth/screens/login_screen.dart"
task_keyword_social_login="GoogleAuthProvider|AppleAuthProvider"
task_keyword_youtube="YouTubeApiService"
task_keyword_spotify="SpotifyApiService"
task_keyword_theme="lib/src/theme"

# Define task names
task_name_user_registration="ユーザー登録機能"
task_name_login="ログイン機能"
task_name_social_login="ソーシャルログイン連携"
task_name_youtube="YouTube視聴履歴"
task_name_spotify="Spotify再生履歴"
task_name_theme="アプリのテーマ設定"

# Check user registration task
if [ -d "$task_keyword_user_registration" ]; then
  echo "✅ Task related to '$task_name_user_registration' appears to be implemented (directory exists)"
  sed -i '' -E "s/\[ \] (P[0-9] [🔄🔜📅⏸️]* ).*$task_name_user_registration.*$/[x] \1 ✅ 完了 $task_name_user_registration/" Task.md 2>/dev/null || true
fi

# Check login task
if [ -f "$task_keyword_login" ]; then
  echo "✅ Task related to '$task_name_login' appears to be implemented (file exists)"
  sed -i '' -E "s/\[ \] (P[0-9] [🔄🔜📅⏸️]* ).*$task_name_login.*$/[x] \1 ✅ 完了 $task_name_login/" Task.md 2>/dev/null || true
fi

# Check social login task
if grep -rE "$task_keyword_social_login" --include="*.dart" lib/ > /dev/null; then
  echo "✅ Task related to '$task_name_social_login' appears to be implemented"
  sed -i '' -E "s/\[ \] (P[0-9] [🔄🔜📅⏸️]* ).*$task_name_social_login.*$/[x] \1 ✅ 完了 $task_name_social_login/" Task.md 2>/dev/null || true
fi

# Check YouTube task
if grep -r "YouTubeApiService" --include="*.dart" lib/ > /dev/null; then
  echo "✅ Task related to '$task_name_youtube' appears to be implemented"
  sed -i '' -E "s/\[ \] (P[0-9] [🔄🔜📅⏸️]* ).*$task_name_youtube.*$/[x] \1 ✅ 完了 $task_name_youtube/" Task.md 2>/dev/null || true
fi

# Check Spotify task
if grep -r "SpotifyApiService" --include="*.dart" lib/ > /dev/null; then
  echo "✅ Task related to '$task_name_spotify' appears to be implemented"
  sed -i '' -E "s/\[ \] (P[0-9] [🔄🔜📅⏸️]* ).*$task_name_spotify.*$/[x] \1 ✅ 完了 $task_name_spotify/" Task.md 2>/dev/null || true
fi

# Check theme task
if [ -d "$task_keyword_theme" ]; then
  echo "✅ Task related to '$task_name_theme' appears to be implemented (directory exists)"
  sed -i '' -E "s/\[ \] (P[0-9] [🔄🔜📅⏸️]* ).*$task_name_theme.*$/[x] \1 ✅ 完了 $task_name_theme/" Task.md 2>/dev/null || true
fi

# Check if any Task.md changes were made
if git diff --name-only | grep -q "Task.md"; then
  echo "Task.md was updated based on code implementation status"
  git config --global user.name "GitHub Actions Bot"
  git config --global user.email "actions@github.com"
  git add Task.md
  git commit -m "Update task completion status [skip ci]"
  git push
else
  echo "No task status updates were needed"
fi

exit 0 