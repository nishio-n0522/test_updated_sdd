#!/bin/bash
# scripts/setup.sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
GIT_CONFIG_FILE="$WORKSPACE_DIR/.devcontainer/git-config.local"
FLAG_FILE="$HOME/.devcontainer-initialized"

# 初回のみ実行
if [ -f "$FLAG_FILE" ]; then
  exit 0
fi

echo "=== コンテナ初期セットアップ ==="

# Git設定
echo ""
echo "--- Git設定 ---"

if [ -f "$GIT_CONFIG_FILE" ]; then
  # 保存済みの設定を読み込んで自動適用
  source "$GIT_CONFIG_FILE"
  git config --global user.name "$GIT_USER_NAME"
  git config --global user.email "$GIT_USER_EMAIL"
  echo "✓ Git設定を保存済みファイルから復元しました (name: $GIT_USER_NAME, email: $GIT_USER_EMAIL)"
else
  # 初回: ユーザーに入力を求め、ローカルに保存
  read -p "Git name: " git_name
  read -p "Git email: " git_email
  git config --global user.name "$git_name"
  git config --global user.email "$git_email"

  # 設定をローカルファイルに保存
  cat > "$GIT_CONFIG_FILE" <<EOF
GIT_USER_NAME="$git_name"
GIT_USER_EMAIL="$git_email"
EOF
  echo "✓ Git設定完了（設定を .devcontainer/git-config.local に保存しました）"
fi

# GitHub CLI認証
echo ""
echo "--- GitHub CLI認証 ---"
gh auth login
gh auth setup-git
echo "✓ GitHub CLI認証完了"

echo ""
echo "✓ セットアップ完了！"

# フラグファイルを作成
touch "$FLAG_FILE"
