# データモデル設計書の独立化

## 概要

functional-design.md からデータモデルの実装設計（論理・物理レベル）を分離し、専用ドキュメントとして独立させる。

## 背景

- functional-design.md の責務は「PRDの要求を機能に分解・構造化すること」
- データモデルの詳細（TypeScriptインターフェース、フィールド定義、制約、ER図）は実装設計の領域であり、機能設計書の責務を逸脱している
- functional-design.md にはドメインモデルの概念図（エンティティの存在と関係性）のみを残す

## やること

1. データモデル設計書の専用ドキュメントを定義（配置先・フォーマット）
2. 専用の agent を作成（data-model-designer.md）
3. 専用の skill を作成（data-model-design/SKILL.md, template.md）
4. 02-documents.md のドキュメント体系に追加
5. 関連ワークフローの修正（new-project 等でデータモデル設計書の生成ステップを追加）
6. 02-documents.md の機能設計書の記載内容から「データモデルの概要」の説明を「ドメインモデルの概念（エンティティの存在と関係性）」に修正

## 備考

- functional-design の agents/skills 修正とは別タスクとして実施する

## 関連する後続修正

- データモデル設計の agent/skill が確定したら、`functional-designer.md` の61行目「データモデルの詳細設計: フィールド定義・型・制約（データモデル設計書の責務）」の「データモデル設計書」を、実際の agent/skill に合わせた具体的な名称に更新する
  - 同様に `SKILL.md` の該当箇所も合わせて更新する
