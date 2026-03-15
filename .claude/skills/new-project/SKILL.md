---
name: new-project
description: 新規プロジェクト立ち上げのオーケストレーター。アイデアメモから仕様ドキュメント群とissueを一貫生成する
allowed-tools: Read, Write, Edit, Bash, Agent, Glob
---

# 新規プロジェクト立ち上げ（WF2 オーケストレーター）

アイデアメモ（WF1の出力）を起点に、プロダクト仕様作成 → 実装仕様作成 → 用語集作成 → issue分解・登録を順次実行し、新規プロジェクトの立ち上げを完了する。

## 起動方法

```
/new-project [アイデアメモのパス]
```

引数が省略された場合、`docs/ideas/` 配下の最新の `*-memo.md` を自動選択する。該当ファイルが存在しない場合はエラーメッセージを表示して終了する。

## 重要: 実行ルール

**以下のルールを厳守すること:**

1. **全ステップを順番通りに実行する** — ステップの省略・順序変更は禁止
2. **1ステップずつ実行する** — 各ステップは前のステップの承認完了後に開始する
3. **各ステップで必ずファイル生成を確認する** — Agent完了後、出力ファイルが実際に存在することをGlobで確認する
4. **承認されるまで次に進まない** — ユーザーの明示的な承認（またはスキップ指示）を待つ

## 全体フロー

```
Step 1: プロダクト仕様作成（4ドキュメントを順次作成）
  1-1: PRD作成 → レビュー → ユーザー承認
  1-2: 機能設計 → レビュー → ユーザー承認    ← 必須（実装仕様の入力）
  1-3: 画面仕様 → レビュー → ユーザー承認    ← 必須（実装仕様の入力）
  1-4: データモデル設計 → レビュー → ユーザー承認

Step 2: 実装仕様作成（Step 1の全4ドキュメント完了後に開始、依存順に1つずつ作成）
  前提確認
  2-1: アーキテクチャ設計 → レビュー → ユーザー承認
  2-2: リポジトリ構造定義 → レビュー → ユーザー承認
  2-3: 開発ガイドライン → レビュー → ユーザー承認
  2-4: デザインパターン → レビュー → ユーザー承認
  [技術検証が必要な場合: WF3の実行を提案]

Step 3: 用語集作成
  用語集 → レビュー → ユーザー承認

Step 4: issue分解・登録
  issue分解・登録 → ユーザー確認
```

## 共通パターン: ドキュメント生成→レビュー→承認

各ドキュメント生成ステップでは以下のパターンを適用する。

1. **生成Agent起動**: サブエージェントを起動してドキュメントを生成する
2. **出力確認**: 生成されたファイルが存在することをGlobで確認する。ファイルが存在しない場合はエラーを報告する
3. **レビューAgent起動**: `doc-reviewer` サブエージェントを起動してレビューする。レビューAgentには生成Agentと同じスキルを状況依存スキルとして指定する
4. **ユーザーに提示**: 生成ドキュメントとレビュー結果をユーザーに提示する
5. **承認ゲート**: ユーザーの承認を待つ。フィードバックがあれば生成Agentを再起動して修正する

## Step 1: プロダクト仕様作成

Step 1では4つのドキュメントを **1-1 → 1-2 → 1-3 → 1-4 の順に1つずつ** 作成する。**いずれのステップも省略してはならない。**

### 1-1: PRD作成

1. `prd-writer` エージェントを起動する
   - 入力: アイデアメモ
   - 出力: `docs/product-requirements.md`
2. `docs/product-requirements.md` の存在を確認する
3. `doc-reviewer` エージェントを起動する
   - 状況依存スキル: `prd-writing`
   - 入力: 生成されたPRD
4. PRD + レビュー結果をユーザーに提示し、承認を待つ

**→ 承認後、1-2に進む**

### 1-2: 機能設計

**前提**: `docs/product-requirements.md` が存在し承認済みであること。

1. `functional-designer` エージェントを起動する
   - 入力: PRD + アイデアメモ
   - 出力: `docs/functional-design.md`
2. `docs/functional-design.md` の存在を確認する
3. `doc-reviewer` エージェントを起動する
   - 状況依存スキル: `functional-design`
   - 入力: 生成された機能設計書
4. 機能設計書 + レビュー結果をユーザーに提示し、承認を待つ

**→ 承認後、1-3に進む**

### 1-3: 画面仕様

**前提**: `docs/product-requirements.md` と `docs/functional-design.md` が存在し承認済みであること。

1. `screen-spec-writer` エージェントを起動する
   - 入力: PRD + 機能設計書
   - 出力: `docs/screen-specification/`
2. `docs/screen-specification/index.md` の存在を確認する
3. `doc-reviewer` エージェントを起動する
   - 状況依存スキル: `screen-specification`
   - 入力: 生成された画面仕様書
4. 画面仕様書 + レビュー結果をユーザーに提示し、承認を待つ

**→ 承認後、1-4に進む**

### 1-4: データモデル設計

**前提**: `docs/product-requirements.md`、`docs/functional-design.md`、`docs/screen-specification/index.md` が存在し承認済みであること。

1. `data-model-designer` エージェントを起動する
   - 入力: PRD + 機能設計書 + 画面仕様書
   - 出力: `docs/data-model/`
2. `docs/data-model/index.md` の存在を確認する
3. `doc-reviewer` エージェントを起動する
   - 状況依存スキル: `data-model-design`
   - 入力: 生成されたデータモデル設計書
4. データモデル設計書 + レビュー結果をユーザーに提示し、承認を待つ

**→ 承認後、Step 2に進む**

## Step 2: 実装仕様作成

**前提確認（必須）**: Step 2の開始前に、以下のファイルがすべて存在することを確認する。1つでも欠けている場合はStep 2を開始せず、欠けているドキュメントの作成に戻る。

- `docs/product-requirements.md`
- `docs/functional-design.md`
- `docs/data-model/index.md`
- `docs/screen-specification/index.md`

Step 2では4つのドキュメントを **2-1 → 2-2 → 2-3 → 2-4 の順に1つずつ** 作成する。この順序は依存関係に基づく（後のドキュメントが前のドキュメントを参照する）。**いずれのステップも省略してはならない。**

### 2-1: アーキテクチャ設計

**前提**: Step 1の全4ドキュメントが承認済みであること。

1. `architecture-writer` エージェントを起動する
   - 入力: PRD + 機能設計書 + 画面仕様書
   - 出力: `docs/architecture/`
2. `docs/architecture/index.md` の存在を確認する
3. `doc-reviewer` エージェントを起動する
   - 状況依存スキル: `architecture-design`
   - 入力: 生成されたアーキテクチャ設計書
4. アーキテクチャ設計書 + レビュー結果をユーザーに提示し、承認を待つ

**→ 承認後、2-2に進む**

### 2-2: リポジトリ構造定義

**前提**: `docs/architecture/` が存在し承認済みであること。

1. `repository-structure-writer` エージェントを起動する
   - 入力: PRD + 機能設計書 + アーキテクチャ設計書
   - 出力: `docs/repository-structure/`
2. `docs/repository-structure/index.md` の存在を確認する
3. `doc-reviewer` エージェントを起動する
   - 状況依存スキル: `repository-structure`
   - 入力: 生成されたリポジトリ構造定義書
4. リポジトリ構造定義書 + レビュー結果をユーザーに提示し、承認を待つ

**→ 承認後、2-3に進む**

### 2-3: 開発ガイドライン

**前提**: `docs/architecture/` と `docs/repository-structure/` が存在し承認済みであること。

1. `development-guidelines-writer` エージェントを起動する
   - 入力: アーキテクチャ設計書 + リポジトリ構造定義書
   - 出力: `docs/development-guidelines/`
2. `docs/development-guidelines/index.md` の存在を確認する
3. `doc-reviewer` エージェントを起動する
   - 状況依存スキル: `development-guidelines`
   - 入力: 生成された開発ガイドライン
4. 開発ガイドライン + レビュー結果をユーザーに提示し、承認を待つ

**→ 承認後、2-4に進む**

### 2-4: デザインパターン

**前提**: `docs/architecture/` が存在し承認済みであること。

1. `design-patterns-writer` エージェントを起動する
   - 入力: PRD + 機能設計書 + アーキテクチャ設計書
   - 出力: `docs/design-patterns/`
2. `docs/design-patterns/index.md` の存在を確認する
3. `doc-reviewer` エージェントを起動する
   - 状況依存スキル: `design-patterns`
   - 入力: 生成されたデザインパターン
4. デザインパターン + レビュー結果をユーザーに提示し、承認を待つ

### 技術検証の提案（条件付き）

実装仕様の中で技術選定に不確実性がある場合（複数の候補技術がある、実績の少ない技術を採用する等）、ユーザーに技術検証（WF3: `/tech-verify`）の実施を提案する。WF3は独立ワークフローとして単独実行される。

## Step 3: 用語集作成

1. `glossary-creator` エージェントを起動する
   - 入力: Step 1〜2 の全出力ドキュメント
   - 出力: `docs/glossary.md`
2. `docs/glossary.md` の存在を確認する
3. `doc-reviewer` エージェントを起動する
   - 状況依存スキル: `glossary-creation`
   - 入力: 生成された用語集
4. 用語集 + レビュー結果をユーザーに提示し、承認を待つ

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
- [ ] `docs/data-model/` が承認済み
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
| 出力ファイルが生成されていない | エラーを報告し、サブエージェントを再実行する |
| ユーザーがステップをスキップしたい | 該当ステップをスキップし、次のステップに進む。ただしスキップされた出力に依存するステップは警告を表示する |
