# Spec-Driven Development Template

AIエージェント（Claude Code）によるスペック駆動開発を実現するためのテンプレートプロジェクトです。

## 概要

このテンプレートは、ドキュメント駆動でソフトウェア開発を進めるための環境とワークフローを提供します。Claude Codeがプロジェクトのドキュメントを理解し、一貫性のある実装を支援します。

### 特徴

- **マルチ言語対応**: Python、Node.js、Go、Ruby など複数の言語に対応
- **柔軟な環境構築**: mise により必要な言語を後から追加可能
- **スペック駆動開発**: ドキュメントファーストのアプローチ
- **Claude Code 統合**: AI による効率的な開発支援
- **軽量 DevContainer**: 必要最小限のベースイメージ (Debian 12)

## 使い方

### 1. テンプレートからリポジトリを作成

GitHubのテンプレートリポジトリ機能を使用してください。

1. このリポジトリページの **[Use this template]** ボタンをクリック
2. 新しいリポジトリ名を入力して作成
3. ローカルにクローン

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_NEW_REPO.git
cd YOUR_NEW_REPO
```

### 2. DevContainer で開く

VS Code で開き、DevContainer で再起動します。

```bash
code .
```

- コマンドパレット（Cmd/Ctrl + Shift + P）
- "Dev Containers: Reopen in Container" を選択

### 3. 言語環境のセットアップ（必要に応じて）

プロジェクトで使用する言語をインストールします。

```bash
# 例: Python プロジェクト
mise install python@3.12
mise global python@3.12

# 例: TypeScript/React プロジェクト
mise install node@22
mise global node@22

# 例: Go プロジェクト
mise install go@1.23
mise global go@1.23
```

詳細は `.devcontainer/LANGUAGE_SETUP.md` を参照してください。

### 4. GitHub との接続

```bash
# GitHub CLI で認証
gh auth login
# → GitHub.com 選択
# → HTTPS 選択
# → Y (Authenticate Git)
# → Login with a web browser 選択

# Git 設定を適用
gh auth setup-git

# 確認
git remote -v
```

### 5. プロジェクトのセットアップ

Claude Code でプロジェクトドキュメントを作成します。

```
/setup-project
```

対話的に以下のドキュメントが作成されます：

- プロダクト要求定義書（PRD）
- 機能設計書
- アーキテクチャ設計書
- リポジトリ構造定義書
- 開発ガイドライン
- 用語集

## ドキュメント構造

- **`CLAUDE.md`**: Claude Code 向けのプロジェクトメモリ
- **`docs/`**: 永続的なプロジェクトドキュメント
- **`.issue/`**: issue単位の詳細ドキュメント（自動生成）
- **`.devcontainer/`**: 開発環境設定

## 推奨される開発フロー

1. **計画**: ドキュメントで「何を作るか」を定義
2. **実装**: Claude Code に依頼して実装
3. **検証**: テストと動作確認
4. **更新**: 必要に応じてドキュメント更新

詳細は `CLAUDE.md` を参照してください。

## 必要な環境

- Docker
- VS Code
- Claude Code 拡張機能

## ライセンス

このテンプレートは自由に使用・改変できます。

## 参考資料

- [実践Claude Code入門](https://github.com/GenerativeAgents/claude-code-book-chapter8)
- [mise ドキュメント](https://mise.jdx.dev/)
- [DevContainers](https://containers.dev/)
