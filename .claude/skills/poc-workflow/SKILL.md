---
name: poc-workflow
description: 新技術の概念実証（PoC）を実施し、プロジェクトに適した設計パターンを発見・文書化するためのスキル。
allowed-tools: Read, Write, Edit, Bash
---

# PoC ワークフロースキル

新技術を採用する前に、技術検証とプロジェクトに適したデザインパターンの決定を行うためのスキルです。

## スキルの目的

- 新技術の概念実証（PoC）を体系的に実施する
- 使い捨ての検証コードを `poc/` に生成し、技術の適合性を評価する
- プロジェクトに適した設計パターンを発見・文書化する
- 検証結果を `docs/` に統合し、プロジェクトの設計指針として永続化する

## `/add-feature` との使い分け

| 観点 | `/poc` | `/add-feature` |
|------|--------|----------------|
| 対話モデル | フェーズごとに承認 | 完全自動 |
| 出力先 | `poc/[技術名]/` | `src/` |
| コードの性質 | 使い捨て検証コード | 本番コード |
| 主な成果物 | 設計パターン文書 + docs/更新 | 動作する機能 |
| 焦点 | パターン発見 | 機能実装 |

## ランタイム生成物

ワークフロー実行時に以下のファイルが作成されます:

```
poc/[技術名]/
├── overview.md          # PoC概要（テンプレートから生成）
├── src/                 # 最小限の検証コード
├── findings.md          # 検証結果（Phase 2完了後）
└── design-pattern.md    # 設計パターン（Phase 3完了後）

.steering/[YYYYMMDDHHmmss]-poc-[技術名]/
├── requirements.md      # 検証目的・評価基準
├── design.md           # PoC設計
└── tasklist.md          # 4フェーズのタスクリスト
```

## テンプレートの参照

PoCワークフローで使用するテンプレートは以下を参照してください:

- PoC概要: `./templates/poc-overview.md`
- 検証結果: `./templates/poc-findings.md`
- 設計パターン: `./templates/design-pattern.md`

## 詳細ガイド

各フェーズの詳細な手順は以下を参照してください:

- ガイド: `./guide.md`
