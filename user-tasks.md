# テスト対象 Agents & Skills 一覧

ワークフロー内で同時に使用される agent/skill はまとめて1つのテスト単位とする。
各テスト単位は、前提となる入力を用意した上で手動実行し、出力の品質を確認・修正する。

---

## WF1: アイデア壁打ち (`/brainstorm`)

### T-01: brainstorm スキル（直接対話）

| 項目 | 内容 |
|------|------|
| **スキル** | `brainstorm`（SKILL.md 直接実行、agent なし） |
| **入力** | ユーザーとの対話 |
| **出力** | `docs/ideas/YYYYMMDD-{topic}-memo.md` |
| **確認観点** | 質問の質、アイデアメモの構造・網羅性 |

---

## WF2: 新規プロジェクト立ち上げ (`/new-project`)

### Step 1: プロダクト仕様作成

#### T-02: prd-writer + doc-reviewer

| 項目 | 内容 |
|------|------|
| **Agent** | `prd-writer` → `doc-reviewer` |
| **スキル** | `prd-writing`, `doc-review` |
| **入力** | アイデアメモ (`docs/ideas/*.md`) |
| **出力** | `docs/product-requirements.md` + レビュー結果 |
| **確認観点** | PRD の完全性・明確性、レビュー指摘の妥当性 |

#### T-03: functional-designer + doc-reviewer

| 項目 | 内容 |
|------|------|
| **Agent** | `functional-designer` → `doc-reviewer` |
| **スキル** | `functional-design`, `doc-review` |
| **入力** | PRD + アイデアメモ |
| **出力** | `docs/functional-design.md` + レビュー結果 |
| **確認観点** | 機能分解の妥当性、概要UI設計の有無、PRD との整合性 |

#### T-04: screen-spec-writer + doc-reviewer

| 項目 | 内容 |
|------|------|
| **Agent** | `screen-spec-writer` → `doc-reviewer` |
| **スキル** | `screen-specification`, `doc-review` |
| **入力** | PRD + 機能設計書 |
| **出力** | `docs/screen-specification/` (index.md + 画面別ファイル) + レビュー結果 |
| **確認観点** | 画面一覧の網羅性、画面遷移図、レイアウト記述の品質 |

### Step 2: 実装仕様作成

#### T-05: implementation-spec-writer + doc-reviewer

| 項目 | 内容 |
|------|------|
| **Agent** | `implementation-spec-writer` → `doc-reviewer` |
| **スキル** | `architecture-design`, `design-patterns`, `development-guidelines`, `repository-structure`, `doc-review` |
| **入力** | PRD + 機能設計書 + 画面仕様書 |
| **出力** | `docs/architecture/`, `docs/design-patterns/`, `docs/development-guidelines/`, `docs/repository-structure/` + レビュー結果 |
| **確認観点** | 4ドキュメント群すべてが生成されること、スタック別分割の妥当性、相互整合性 |

### Step 3: 用語集作成

#### T-06: glossary-creator + doc-reviewer

| 項目 | 内容 |
|------|------|
| **Agent** | `glossary-creator` → `doc-reviewer` |
| **スキル** | `glossary-creation`, `doc-review` |
| **入力** | Step 1〜2 の全ドキュメント |
| **出力** | `docs/glossary.md` + レビュー結果 |
| **確認観点** | 用語の網羅性、定義の明確性、ドキュメント横断の一貫性 |

### Step 4: issue 分解・登録

#### T-07: issue-decomposer

| 項目 | 内容 |
|------|------|
| **Agent** | `issue-decomposer` |
| **スキル** | `issue-workflow` |
| **入力** | 全仕様ドキュメント |
| **出力** | GitHub issues + `.issue/{N}/spec.md` |
| **確認観点** | issue 粒度の適切さ、依存関係の整理、spec.md の品質 |

---

## WF3: 技術検証 (`/tech-verify`)

### Phase 1: 技術候補調査

#### T-08: tech-evaluator（調査モード）

| 項目 | 内容 |
|------|------|
| **Agent** | `tech-evaluator` |
| **スキル** | `tech-evaluation` |
| **入力** | 要件（対話で収集）+ `docs/architecture/` |
| **出力** | 比較表 + 候補概要 |
| **確認観点** | 候補の網羅性、比較軸の妥当性、調査の深さ |

### Phase 2: PoC 実装

#### T-09: poc-implementer

| 項目 | 内容 |
|------|------|
| **Agent** | `poc-implementer` |
| **スキル** | `poc-workflow` |
| **入力** | 選択した技術候補 + 要件 |
| **出力** | `poc/{tech-name}/` (overview.md + src/ + findings.md) |
| **確認観点** | PoC コードの動作、findings の具体性 |

### Phase 3: 技術選定

#### T-10: tech-evaluator（評価モード）

| 項目 | 内容 |
|------|------|
| **Agent** | `tech-evaluator` |
| **スキル** | `tech-evaluation` |
| **入力** | 全 PoC 結果 + 候補情報 + 要件 |
| **出力** | `docs/tech-decisions/YYYYMMDD-{topic}.md` |
| **確認観点** | 評価の客観性、PoC 結果の反映度、推奨理由の明確性 |

### Phase 4: デザインパターン策定

#### T-11: pattern-designer

| 項目 | 内容 |
|------|------|
| **Agent** | `pattern-designer` |
| **スキル** | `design-patterns` |
| **入力** | 技術選定結果 + PoC コード + アーキテクチャ文書 |
| **出力** | `docs/design-patterns/{concern}.md` |
| **確認観点** | パターンの実用性、PoC 知見の反映、既存パターンとの整合 |

---

## WF4: issue 作成 (`/create-issue`)

### Phase 2a: 変更仕様（機能変更の場合）

#### T-12: functional-designer（変更モード）+ doc-reviewer

| 項目 | 内容 |
|------|------|
| **Agent** | `functional-designer`（変更仕様モード）→ `doc-reviewer` |
| **スキル** | `functional-design`, `doc-review` |
| **入力** | 変更要件 + 既存 `docs/functional-design.md` |
| **出力** | 変更仕様 + レビュー結果 |
| **確認観点** | 変更範囲の特定精度、既存設計との整合性 |

#### T-13: screen-spec-writer（変更モード）+ doc-reviewer

| 項目 | 内容 |
|------|------|
| **Agent** | `screen-spec-writer`（変更仕様モード）→ `doc-reviewer` |
| **スキル** | `screen-specification`, `doc-review` |
| **入力** | 変更要件 + 既存 `docs/screen-specification/` |
| **出力** | 変更仕様 + レビュー結果 |
| **確認観点** | UI 変更箇所の網羅性、既存画面仕様との整合性 |

#### T-14: prd-scope-checker

| 項目 | 内容 |
|------|------|
| **Agent** | `prd-scope-checker` |
| **スキル** | （agent 定義に内包） |
| **入力** | 変更仕様 + `docs/product-requirements.md` |
| **出力** | スコープ判定（範囲内 / PRD 更新要） |
| **確認観点** | 判定の正確性、逸脱時の指摘の具体性 |

### Phase 2b: issue 仕様（非機能変更の場合）

#### T-15: issue-spec-writer + doc-reviewer

| 項目 | 内容 |
|------|------|
| **Agent** | `issue-spec-writer` → `doc-reviewer` |
| **スキル** | `issue-specification`, `doc-review` |
| **入力** | issue 種別 + 要件 + 関連ドキュメント |
| **出力** | 種別固有の仕様ドキュメント + レビュー結果 |
| **確認観点** | 種別テンプレートの適用、必要情報の網羅性 |

### Phase 3: issue 登録

#### T-16: issue-decomposer（登録モード）

| 項目 | 内容 |
|------|------|
| **Agent** | `issue-decomposer`（登録のみモード） |
| **スキル** | `issue-workflow` |
| **入力** | 仕様ドキュメント |
| **出力** | GitHub issue + `.issue/{N}/spec.md` |
| **確認観点** | issue 内容と仕様の一致、spec.md の品質 |

---

## WF5: autopilot (`/autopilot`)

### Phase A: 計画

#### T-17: autopilot-manager（計画フェーズ）

| 項目 | 内容 |
|------|------|
| **Agent** | `autopilot-manager`（Phase A のみ） |
| **スキル** | `implementation-planning` |
| **入力** | `.issue/{N}/spec.md` + 関連 `docs/` |
| **出力** | `requirements.md`, `design.md`, `test-spec.md`, `tasklist.md` |
| **確認観点** | 4文書の整合性、タスク粒度の適切さ、既存コードの考慮 |

### Phase B: 並列実装

#### T-18: implementer + test-writer（同時実行）

| 項目 | 内容 |
|------|------|
| **Agent** | `implementer` + `test-writer`（並列起動） |
| **スキル** | `development-guidelines`（implementer）, `implementation-planning`（test-writer） |
| **入力** | `design.md` + `test-spec.md` + `tasklist.md` |
| **出力** | `src/` の実装コード + `tests/` のテストコード + `tasklist.md` 更新 |
| **確認観点** | コードの品質、テストカバレッジ、tasklist 進捗更新の正確性 |

### Phase C: 並列レビュー

#### T-19: coding-reviewer + architecture-reviewer + i18n-reviewer + test-runner（同時実行）

| 項目 | 内容 |
|------|------|
| **Agent** | `coding-reviewer` + `architecture-reviewer` + `i18n-reviewer` + `test-runner`（並列起動） |
| **スキル** | `review-coding`, `review-architecture`, `review-i18n`（各レビュー agent） |
| **入力** | 実装コード + テストコード + 関連仕様 |
| **出力** | `reviews/review-coding-r{N}.md`, `reviews/review-architecture-r{N}.md`, `reviews/review-i18n-r{N}.md`, `reviews/test-results-r{N}.md` |
| **確認観点** | 指摘の妥当性、重要度分類の適切さ、テスト実行結果の正確性 |

---

## テスト実行順序（推奨）

依存関係に基づく推奨順序:

```
T-01 (brainstorm)
  ↓ アイデアメモ生成
T-02 (prd-writer)
  ↓ PRD 生成
T-03 (functional-designer)
  ↓ 機能設計書生成
T-04 (screen-spec-writer)        ← /new-project で欠落していた出力
  ↓ 画面仕様書生成
T-05 (implementation-spec-writer)
  ↓ 実装仕様群生成
T-06 (glossary-creator)
  ↓ 用語集生成
T-07 (issue-decomposer)
  ↓ issue 登録完了
T-17 (autopilot Phase A)
  ↓ 計画文書生成
T-18 (implementer + test-writer)
  ↓ 実装完了
T-19 (reviewers + test-runner)
```

WF3（T-08〜T-11）と WF4（T-12〜T-16）は独立して任意のタイミングでテスト可能。

---

## テスト方法

テスト用のスキルやツールを別途作成する必要はない。
各テスト単位は、会話の中から直接エージェントを起動してテストする。

### 手順

1. **入力ファイルを用意する** — 前のテスト単位の出力、またはサンプルデータ
2. **会話で直接エージェント起動を指示する** — 例:
   ```
   prd-writer エージェントを起動して、docs/ideas/xxx-memo.md を入力にPRDを作成してください
   ```
3. **出力を確認・修正する**
4. **後続エージェントも同じ会話内で指示する** — 例:
   ```
   続けて doc-reviewer で今の出力をレビューしてください
   ```
5. **次のテスト単位へ進む**

### 補足

- ワークフロー（オーケストレータースキル）を経由せず、Agent ツールで直接起動できる
- 繰り返しテストで毎回同じプロンプトを打つのが面倒な場合のみ、テスト用スキル作成を検討
- 今回は1つずつ出力を確認・修正する手動テストなので、会話ベースで十分

---

## 備考

- 各テスト単位で出力を確認・修正した後、次のテストに進む
- `/new-project` の問題点: T-04（screen-spec-writer）が実行されず画面仕様書が欠落 → Step 1 の順序制御を重点確認
- `doc-reviewer` は単独テスト不要（各生成 agent とセットでテスト）
- `data-model-designer` agent は現在どのワークフローからも呼ばれていない → 必要に応じて WF2 への組み込みを検討
