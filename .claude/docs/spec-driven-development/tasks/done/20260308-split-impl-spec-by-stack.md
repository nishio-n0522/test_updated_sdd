# 実装仕様ドキュメントの技術スタック別分離

## 概要

architecture.md, repository-structure.md, development-guidelines.md を単一ファイルから「index.md + スタック別ファイル」のディレクトリ構造に変更する。design-patternsと同じ選択的読み込みパターンを適用する。

## 背景

- 現状: 異なる技術スタック（frontend/backend等）が1ファイルに混在
- 問題: AIが実装時に全スタックの情報を読み込み、コンテキストが肥大化
- ユーザーの運用: 小さい単位で作業するため、フロントエンド・バックエンドを同時に作業しない
- design-patternsスキルは既に正しいパターン（index + 個別ファイル + 選択的読み込み）を実装済み

## 目標構造

```
docs/architecture/
├── index.md              # 全体概要・システム構成図・スタック間連携
└── {stack}.md            # スタック固有の詳細

docs/repository-structure/
├── index.md              # トップレベル構造・共通ルール
└── {stack}.md            # スタック固有のディレクトリ詳細

docs/development-guidelines/
├── index.md              # 共通ガイドライン（Git運用、コードレビュー等）
└── {stack}.md            # スタック固有のコーディング規約
```

## やること

### Skills修正（6ファイル）

1. `.claude/skills/architecture-design/SKILL.md`
   - 出力を `docs/architecture/` ディレクトリに変更
   - 「読み込み戦略」セクション追加（design-patternsと同じパターン）

2. `.claude/skills/architecture-design/template.md`
   - index.md用テンプレートと個別スタック用テンプレートに分割

3. `.claude/skills/repository-structure/SKILL.md`
   - 出力を `docs/repository-structure/` ディレクトリに変更
   - 「読み込み戦略」セクション追加

4. `.claude/skills/repository-structure/template.md`
   - index.md用テンプレートと個別スタック用テンプレートに分割

5. `.claude/skills/development-guidelines/SKILL.md`
   - 出力を `docs/development-guidelines/` ディレクトリに変更
   - 「読み込み戦略」セクション追加

6. `.claude/skills/development-guidelines/template.md`
   - index.md（共通部分: Git運用、コードレビュー等）と個別スタック用テンプレートに分割

### Agents修正（2ファイル）

7. `.claude/agents/implementation-spec-writer.md`
   - 出力定義をディレクトリベースに変更
   - 作業プロセス: まずスタック一覧を決定し、スタック単位で分割生成

8. `.claude/agents/implementer.md`
   - development-guidelines丸読み → index.md参照 → 該当スタックのみ読み込みに変更

### その他（2ファイル）

9. `.claude/skills/new-project/SKILL.md`
   - Step 2の出力定義をディレクトリベースに変更

10. `CLAUDE.md`
    - 「永続的ドキュメント」セクションのファイルパス記述を更新

## 設計方針

- design-patternsの既存パターンと統一: index.md（カタログ/概要）+ 個別ファイル + 選択的読み込み
- index.mdには「どのスタックファイルを読むべきか」の判断基準を記載
- 共通事項（Git運用等）はindex.mdに、スタック固有事項は個別ファイルに
- テンプレートは汎用的に保ち、プロジェクト固有のスタック名を強制しない

## 参考: design-patternsの読み込み戦略（お手本）

```
実装タスク開始
  └─ design-patterns/index.md を参照
       └─ タスクに該当するパターンのみ読み込み
```
