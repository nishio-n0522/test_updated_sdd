#!/bin/bash
# .devcontainer/setup.sh
set -e

FLAG_FILE="$HOME/.devcontainer-initialized"

# 初回のみ実行
if [ -f "$FLAG_FILE" ]; then
  exit 0
fi

echo "=== コンテナ初期セットアップ ==="

# Git設定
echo ""
echo "--- Git設定 ---"
read -p "Git name: " git_name
read -p "Git email: " git_email
git config --global user.name "$git_name"
git config --global user.email "$git_email"
echo "✓ Git設定完了"

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