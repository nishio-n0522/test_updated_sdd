# プロジェクトメモリ

## 技術スタック

### 開発環境

- **DevContainer**: mcr.microsoft.com/devcontainers/base:debian-12
- **バージョン管理**: mise（統合バージョンマネージャー）

### 言語・ランタイム（必要に応じてインストール）

- **Python**: mise経由で必要なバージョンをインストール
- **Node.js**: mise経由で必要なバージョンをインストール
- **Go**: mise経由で必要なバージョンをインストール
- **その他**: Ruby、Deno、Bun、Flutter等も対応可能

### ツール

- Git、curl、wget、jq（プリインストール）
- AWS CLI（必要に応じてインストール）
- GitHub CLI（devcontainer feature）
- Docker-in-Docker（devcontainer feature）

**言語セットアップの詳細**: `.devcontainer/LANGUAGE_SETUP.md` を参照

## スペック駆動開発の基本原則

### 基本フロー

1. **ドキュメント作成**: 永続ドキュメント(`docs/`)で「何を作るか」を定義
2. **issue作成**: GitHub issueと`.issue/{issue番号}/`で「今回何をするか」を計画
3. **実装**: autopilotがissueを自動実行し、進捗を随時更新
4. **検証**: テストと動作確認
5. **更新**: 必要に応じてドキュメント更新

### 重要なルール

#### ドキュメント作成時

**1ファイルずつ作成し、必ずユーザーの承認を得てから次に進む**

承認待ちの際は、明確に伝える:

```
「[ドキュメント名]の作成が完了しました。内容を確認してください。
承認いただけたら次のドキュメントに進みます。」
```

#### 実装前の確認

新しい実装を始める前に、必ず以下を確認:

1. CLAUDE.mdを読む
2. 関連する永続ドキュメント(`docs/`)を読む
3. Grepで既存の類似実装を検索
4. 既存パターンを理解してから実装開始

#### issue管理

issueごとに `.issue/{issue番号}/` を作成し、ライフサイクル全体のドキュメントを格納:

```
.issue/{issue番号}/
├── spec.md                # issue仕様書（issue登録時に作成）
├── requirements.md        # 要求の構造化（autopilot実行時に作成）
├── design.md              # 実装設計（autopilot実行時に作成）
├── test-spec.md           # テスト仕様（autopilot実行時に作成）
├── tasklist.md            # タスクリスト・進捗管理（autopilot実行時に作成）
├── reviews/               # レビュー結果（autopilot実行時に作成）
│   ├── review-coding-r{N}.md
│   ├── review-architecture-r{N}.md
│   └── test-results-r{N}.md
└── fixes/                 # 修正指示書（レビュー指摘時に作成）
    └── fix-order-r{N}.md
```

issueの作成は `/create-issue` で対話的に行い、実行は `/autopilot` で自動化します。

## ディレクトリ構造

### 永続的ドキュメント(`docs/`)

アプリケーション全体の「何を作るか」「どう作るか」を定義:

#### 下書き・アイデア（`docs/ideas/`）

- 壁打ち・ブレインストーミングの成果物
- 技術調査メモ
- 自由形式（構造化は最小限）
- `/setup-project`実行時に自動的に読み込まれる

#### 正式版ドキュメント

- **product-requirements.md** - プロダクト要求定義書
- **functional-design.md** - 機能設計書（機能分解 + ドメインモデル概念 + 概要レベルUI設計）
- **data-model.md** - データモデル設計書（エンティティのフィールド定義・型・制約・ER図）
- **screen-specification/** - 画面仕様書（詳細な画面レイアウト・操作挙動、画面ごとに分割）
- **architecture/** - 技術仕様書（index.md + スタック別ファイル）
- **repository-structure/** - リポジトリ構造定義書（index.md + スタック別ファイル）
- **development-guidelines/** - 開発ガイドライン（index.md + スタック別ファイル）
- **design-patterns/** - デザインパターン（index.md + 個別パターンファイル）
- **glossary.md** - ユビキタス言語定義

### issue固有ドキュメント(`.issue/{issue番号}/`)

各issueのライフサイクル全体に関わるドキュメントを保持:

- `spec.md`: issue仕様書（issue登録時に作成）
- `requirements.md`: 要求の構造化（autopilot実行時に作成）
- `design.md`: 実装設計（autopilot実行時に作成）
- `test-spec.md`: テスト仕様（autopilot実行時に作成）
- `tasklist.md`: タスクリスト・進捗管理（autopilot実行時に作成）
- `reviews/`: レビュー結果（autopilot実行時に作成）
- `fixes/`: 修正指示書（レビュー指摘時に作成）

## 開発プロセス

### 初回セットアップ

1. このテンプレートを使用
2. `/new-project` で永続的ドキュメント作成・issue分解・登録
3. `/autopilot` でissueを自動実行

### 段階的UI設計

UI設計は2段階で詳細化します:

1. **初期段階（setup-project時）**: `functional-design.md` に概要レベルのUI設計を記載
   - 画面一覧、大まかなレイアウト、画面遷移の全体像
   - 「だいたいこんなアプリ」のイメージを定義
2. **実装が進んだ後**: `screen-specification/` に詳細な画面仕様を記載
   - `index.md`（画面一覧・画面遷移図）+ 画面ごとの個別ファイル
   - 全UI要素の定義、状態別ワイヤーフレーム、操作ごとの挙動
   - 実装経験で得た知見を反映した詳細仕様

### 日常的な使い方

**基本は普通に会話で依頼してください:**

```bash
# ドキュメントの編集
> PRDに新機能を追加してください
> architecture.mdのパフォーマンス要件を見直して
> glossary.mdに新しいドメイン用語を追加

# issue作成(定型フローはコマンド)
> /create-issue ユーザープロフィール編集

# 詳細レビュー(詳細なレポートが必要なとき)
> /review-docs docs/product-requirements.md
```

**ポイント**: スペック駆動開発の詳細を意識する必要はありません。Claude Codeが適切なスキルを判断してロードします。

## ドキュメント管理の原則

### 永続的ドキュメント(`docs/`)

- 基本設計を記述
- 頻繁に更新されない
- プロジェクト全体の「北極星」

### issue固有ドキュメント(`.issue/`)

- 特定のissueに特化
- issueごとに作成
- 実装のライフサイクル全体を記録
