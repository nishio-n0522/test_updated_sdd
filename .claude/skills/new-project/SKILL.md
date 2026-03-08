---
name: new-project
description: 新規プロジェクト立ち上げのオーケストレーター。アイデアメモから仕様ドキュメント群とissueを一貫生成する
allowed-tools: Read, Write, Edit, Bash, Agent
---

# 新規プロジェクト立ち上げ（WF2 オーケストレーター）

アイデアメモ（WF1の出力）を起点に、プロダクト仕様作成 → 実装仕様作成 → 用語集作成 → issue分解・登録を順次実行し、新規プロジェクトの立ち上げを完了する。

## 起動方法

```
/new-project [アイデアメモのパス]
```

引数が省略された場合、`docs/ideas/` 配下の最新の `*-memo.md` を自動選択する。該当ファイルが存在しない場合はエラーメッセージを表示して終了する。

## 全体フロー

```
Step 1: プロダクト仕様作成
  PRD作成 → レビュー → ユーザー承認
  機能設計 → レビュー → ユーザー承認
  データモデル設計 → レビュー → ユーザー承認
  画面仕様 → レビュー → ユーザー承認

Step 2: 実装仕様作成
  実装仕様(4ドキュメント) → レビュー → ユーザー承認
  [技術検証が必要な場合: WF3の実行を提案]

Step 3: 用語集作成
  用語集 → レビュー → ユーザー承認

Step 4: issue分解・登録
  issue分解・登録 → ユーザー確認
```

## 共通パターン: ドキュメント生成→レビュー→承認

各ドキュメント生成ステップでは以下のパターンを適用する。

1. **生成Agent起動**: サブエージェントを起動してドキュメントを生成する
2. **レビューAgent起動**: `doc-reviewer` サブエージェントを起動してレビューする。レビューAgentには生成Agentと同じスキルを状況依存スキルとして指定する
3. **ユーザーに提示**: 生成ドキュメントとレビュー結果をユーザーに提示する
4. **承認ゲート**: ユーザーの承認を待つ。フィードバックがあれば生成Agentを再起動して修正する

## Step 1: プロダクト仕様作成

### 1-1: PRD作成

1. `prd-writer` エージェントを起動する
   - 入力: アイデアメモ
   - 出力: `docs/product-requirements.md`
2. `doc-reviewer` エージェントを起動する
   - 状況依存スキル: `prd-writing`
   - 入力: 生成されたPRD
3. PRD + レビュー結果をユーザーに提示し、承認を待つ

### 1-2: 機能設計

1. `functional-designer` エージェントを起動する
   - 入力: PRD + アイデアメモ
   - 出力: `docs/functional-design.md`
2. `doc-reviewer` エージェントを起動する
   - 状況依存スキル: `functional-design`
   - 入力: 生成された機能設計書
3. 機能設計書 + レビュー結果をユーザーに提示し、承認を待つ

### 1-3: データモデル設計

1. `data-model-designer` エージェントを起動する
   - 入力: PRD + 機能設計書
   - 出力: `docs/data-model.md`
2. `doc-reviewer` エージェントを起動する
   - 状況依存スキル: `data-model-design`
   - 入力: 生成されたデータモデル設計書
3. データモデル設計書 + レビュー結果をユーザーに提示し、承認を待つ

### 1-4: 画面仕様

1. `screen-spec-writer` エージェントを起動する
   - 入力: PRD + 機能設計書
   - 出力: `docs/screen-specification/`
2. `doc-reviewer` エージェントを起動する
   - 状況依存スキル: `screen-specification`
   - 入力: 生成された画面仕様書
3. 画面仕様書 + レビュー結果をユーザーに提示し、承認を待つ

## Step 2: 実装仕様作成

1. `implementation-spec-writer` エージェントを起動する
   - 入力: PRD + 機能設計書 + 画面仕様書
   - 出力: `docs/architecture/`, `docs/design-patterns/`, `docs/development-guidelines/`, `docs/repository-structure/`
2. `doc-reviewer` エージェントを起動する
   - 状況依存スキル: `architecture-design`
   - 入力: 生成された実装仕様ドキュメント群
3. 実装仕様 + レビュー結果をユーザーに提示し、承認を待つ

### 技術検証の提案（条件付き）

実装仕様の中で技術選定に不確実性がある場合（複数の候補技術がある、実績の少ない技術を採用する等）、ユーザーに技術検証（WF3: `/tech-verify`）の実施を提案する。WF3は独立ワークフローとして単独実行される。

## Step 3: 用語集作成

1. `glossary-creator` エージェントを起動する
   - 入力: Step 1〜2 の全出力ドキュメント
   - 出力: `docs/glossary.md`
2. `doc-reviewer` エージェントを起動する
   - 状況依存スキル: `glossary-creation`
   - 入力: 生成された用語集
3. 用語集 + レビュー結果をユーザーに提示し、承認を待つ

## Step 4: issue分解・登録

1. `issue-decomposer` エージェントを起動する
   - 入力: 全仕様ドキュメント
   - 出力: GitHub issues + `.issue/`
2. issue一覧をユーザーに提示し、確認を待つ

issue登録はドキュメントレビューの対象外（構造的な処理のため）。

## 完了条件

以下がすべて完了した時点でプロジェクト立ち上げ完了とする:

- [ ] `docs/product-requirements.md` が承認済み
- [ ] `docs/functional-design.md` が承認済み
- [ ] `docs/data-model.md` が承認済み
- [ ] `docs/screen-specification/` が承認済み
- [ ] `docs/architecture/` が承認済み
- [ ] `docs/design-patterns/` が承認済み
- [ ] `docs/development-guidelines/` が承認済み
- [ ] `docs/repository-structure/` が承認済み
- [ ] `docs/glossary.md` が承認済み
- [ ] GitHub issues が登録済み
- [ ] `.issue/` ディレクトリに詳細ドキュメントが配置済み

## エラー時の動作

| ケース | 動作 |
|---|---|
| アイデアメモが存在しない | エラーメッセージを表示して終了 |
| サブエージェントがエラーで終了 | エラー内容をユーザーに報告し、再実行するか確認する |
| ユーザーがステップをスキップしたい | 該当ステップをスキップし、次のステップに進む。ただしスキップされた出力に依存するステップは警告を表示する |
