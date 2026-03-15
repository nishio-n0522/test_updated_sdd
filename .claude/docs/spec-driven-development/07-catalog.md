# 7. Skills / Agents カタログ

全ワークフロー（WF1〜WF5）のシーケンス設計から抽出した、必要な Skills と Agents の一覧。

---

## 7.1. Skills 一覧

### 7.1.1. オーケストレーター型 Skills

ユーザーとの対話・承認ゲートを管理し、サブエージェントを順序制御する。

| # | Skill名 | ファイルパス | 使用WF | 目的 |
|---|---|---|---|---|
| S-O1 | アイデア壁打ち | `skills/brainstorm/` | WF1 | ユーザーと対話的にアイデアを壁打ち・整理 |
| S-O2 | 新規PJ立ち上げ | `skills/new-project/` | WF2 | 全ステップの順序制御・ユーザー承認ゲート管理 |
| S-O3 | 技術検証 | `skills/tech-verify/` | WF3 | 要件整理（対話）・4フェーズの承認ゲート管理 |
| S-O4 | issue作成 | `skills/create-issue/` | WF4 | 種別判定・要件整理（対話）・承認ゲート管理 |
| S-O5 | autopilot入口 | `skills/autopilot/` | WF5 | バッチ処理制御・ブランチ管理・完了レポート |

#### S-O1: アイデア壁打ち

| 項目 | 内容 |
|---|---|
| 入力 | ユーザーの構想・課題（対話） |
| 出力 | `docs/ideas/YYYYMMDD-memo.md` |
| 起動するAgent | なし（Skillが直接対話） |
| 特記事項 | 新規PJ（WF2の前段）でも既存PJ（WF4の前段）でも利用可能。コンテキスト分離のため独立WFとして設計 |

#### S-O2: 新規PJ立ち上げ

| 項目 | 内容 |
|---|---|
| 入力 | `docs/ideas/YYYYMMDD-memo.md`（WF1の出力） |
| 出力 | 各種仕様ドキュメント（`docs/`）+ GitHub issues + `.issue/` |
| 起動するAgent | PRD作成 → 機能設計 → 画面仕様 → データモデル設計 → 実装仕様 → 用語集作成 → issue分解・登録（+ 各ステップでドキュメントレビュー） |
| 特記事項 | Step 2 で技術検証が必要な場合、WF3 の実行を提案 |

#### S-O3: 技術検証

| 項目 | 内容 |
|---|---|
| 入力 | ユーザーの技術要件（対話）+ `docs/architecture.md` + `docs/design-patterns/` |
| 出力 | `poc/{技術名}/` + `docs/tech-decisions/YYYYMMDD-{topic}.md` + `docs/design-patterns/{concern}.md` + `docs/design-patterns/index.md` |
| 起動するAgent | 技術評価（Phase 1, 3）→ PoC実装（Phase 2）→ パターン設計（Phase 4）（+ Phase 1, 3, 4でドキュメントレビュー） |
| 特記事項 | Phase 3 で不採用の場合、Phase 4 をスキップ |

#### S-O4: issue作成

| 項目 | 内容 |
|---|---|
| 入力 | ユーザーの要求（対話）+ `docs/` 配下の既存ドキュメント |
| 出力 | GitHub issue + `.issue/{N}/` |
| 起動するAgent | issue種別に応じて分岐: 機能追加→機能設計+画面仕様+PRDスコープ検証 / その他→issue仕様作成（+ ドキュメントレビュー）→ issue登録 |
| 特記事項 | 機能設計・画面仕様・issue登録はWF2のAgentを再利用 |

#### S-O5: autopilot入口

| 項目 | 内容 |
|---|---|
| 入力 | なし（オープンissue全件を自動取得） |
| 出力 | 完了レポート（全issue処理結果サマリ） |
| 起動するAgent | autopilot管理（issue単位で起動） |
| 特記事項 | autopilotブランチを作成し、issue/{N}ブランチで逐次処理。成功時はautopilotブランチにマージ |

---

### 7.1.2. 専門知識型 Skills

Agentが参照するドメイン知識（テンプレート・品質基準・チェックリスト等）を提供する。

| # | Skill名 | 概要 | 参照元Agent（コア） | 参照元Agent（状況依存） | 使用WF |
|---|---|---|---|---|---|
| S-K1 | `idea-brainstorming` | アイデア壁打ちの方法論・質問フレームワーク・アイデアメモテンプレート | —（S-O1が直接利用） | — | WF1 |
| S-K2 | `prd-writing` | PRDのテンプレート・品質基準 | PRD作成 | ドキュメントレビュー | WF2 |
| S-K3 | `functional-design` | 機能設計書のテンプレート・品質基準 | 機能設計 | ドキュメントレビュー | WF2, WF4 |
| S-K4 | `screen-specification` | 画面仕様書のテンプレート・品質基準 | 画面仕様 | ドキュメントレビュー | WF2, WF4 |
| S-K5 | `data-model-design` | データモデル設計書のテンプレート・品質基準 | データモデル設計 | ドキュメントレビュー | WF2, WF4 |
| S-K6 | `architecture-design` | アーキテクチャ設計のテンプレート・品質基準 | 実装仕様 | ドキュメントレビュー | WF2 |
| S-K7 | `design-patterns` | デザインパターンのテンプレート・品質基準・カタログ管理 | パターン設計 | 実装仕様, ドキュメントレビュー | WF2, WF3 |
| S-K8 | `development-guidelines` | 開発ガイドラインのテンプレート・品質基準 | 実装 | 実装仕様 | WF2, WF5 |
| S-K9 | `repository-structure` | リポジトリ構造のテンプレート・品質基準 | — | 実装仕様 | WF2 |
| S-K10 | `glossary-creation` | 用語集のテンプレート・品質基準 | 用語集作成 | ドキュメントレビュー | WF2 |
| S-K11 | `issue-workflow` | issue分解・登録の方法論・フォーマット | issue分解・登録 | — | WF2, WF4 |
| S-K12 | `doc-review` | ドキュメントレビューの方法論・出力フォーマット・重要度分類 | ドキュメントレビュー | — | WF2, WF3, WF4 |
| S-K13 | `tech-evaluation` | 技術評価の方法論・比較フレームワーク・選定基準 | 技術評価 | ドキュメントレビュー | WF3 |
| S-K14 | `poc-workflow` | PoC実装のガイドライン・ディレクトリ構造規約・テンプレート | PoC実装 | — | WF3 |
| S-K15 | `issue-specification` | issue仕様ドキュメントのテンプレート・品質基準（種別別） | issue仕様作成 | ドキュメントレビュー | WF4 |
| S-K16 | `implementation-planning` | 実装計画ドキュメント（requirements/design/test-spec/tasklist）のテンプレート・品質基準 | autopilot管理 | — | WF5 |
| S-K17 | `review-coding` | コーディング規約レビューの方法論・チェックリスト | コーディングレビュー | — | WF5 |
| S-K18 | `review-architecture` | アーキテクチャレビューの方法論・チェックリスト | アーキテクチャレビュー | — | WF5 |
| S-K19 | `review-i18n` | i18nレビューの方法論・チェックリスト | i18nレビュー | — | WF5 |

### 7.1.3. Skill 統計

- **オーケストレーター型**: 5件
- **専門知識型**: 19件
- **合計**: 24件

---

## 7.2. Agents 一覧

### 7.2.1. ドキュメント生成系 Agent

仕様ドキュメントを生成するAgent。主にWF2〜WF4で使用される。

| # | Agent名 | ファイル名 | コアskill | 使用WF | 再利用 |
|---|---|---|---|---|---|
| A-G1 | PRD作成 | `agents/prd-writer.md` | `prd-writing` | WF2 | — |
| A-G2 | 機能設計 | `agents/functional-designer.md` | `functional-design` | WF2, WF4 | WF4で変更仕様モード |
| A-G3 | 画面仕様 | `agents/screen-spec-writer.md` | `screen-specification` | WF2, WF4 | WF4で変更仕様モード |
| A-G4 | データモデル設計 | `agents/data-model-designer.md` | `data-model-design` | WF2, WF4 | WF4で変更仕様モード |
| A-G5 | 実装仕様 | `agents/implementation-spec-writer.md` | `architecture-design` | WF2 | — |
| A-G6 | 用語集作成 | `agents/glossary-creator.md` | `glossary-creation` | WF2 | — |
| A-G7 | issue仕様作成 | `agents/issue-spec-writer.md` | `issue-specification` | WF4 | — |

#### A-G1: PRD作成

| 項目 | 内容 |
|---|---|
| 目的 | アイデアメモからプロダクト要件定義書を生成する |
| コアskill | `prd-writing` |
| 入力 | `docs/ideas/YYYYMMDD-memo.md` |
| 出力 | `docs/product-requirements.md` |

#### A-G2: 機能設計

| 項目 | 内容 |
|---|---|
| 目的 | 機能設計書を生成・更新する |
| コアskill | `functional-design` |
| 入力（WF2・新規） | PRD + アイデアメモ |
| 出力（WF2・新規） | `docs/functional-design.md` |
| 入力（WF4・変更） | 要件 + `docs/functional-design.md`（既存） |
| 出力（WF4・変更） | 機能変更仕様 |

#### A-G3: 画面仕様

| 項目 | 内容 |
|---|---|
| 目的 | 画面仕様書を生成・更新する |
| コアskill | `screen-specification` |
| 入力（WF2・新規） | PRD + 機能設計書 |
| 出力（WF2・新規） | `docs/screen-specification/` |
| 入力（WF4・変更） | 要件 + `docs/screen-specification/`（既存） |
| 出力（WF4・変更） | 画面変更仕様 |

#### A-G4: データモデル設計

| 項目 | 内容 |
|---|---|
| 目的 | データモデル設計書を生成・更新する |
| コアskill | `data-model-design` |
| 入力（WF2・新規） | PRD + 機能設計書 + 画面仕様書 |
| 出力（WF2・新規） | `docs/data-model/` |
| 入力（WF4・変更） | 要件 + `docs/data-model/`（既存） |
| 出力（WF4・変更） | データモデル変更仕様 |

#### A-G5: 実装仕様

| 項目 | 内容 |
|---|---|
| 目的 | アーキテクチャ・開発ガイドライン・デザインパターン・リポジトリ構造を生成する |
| コアskill | `architecture-design` |
| 状況依存skill | `design-patterns`, `development-guidelines`, `repository-structure` |
| 入力 | PRD + 機能設計書 + 画面仕様書 + データモデル設計書 |
| 出力 | `docs/architecture/`, `docs/design-patterns/`, `docs/development-guidelines/`, `docs/repository-structure/` |

#### A-G6: 用語集作成

| 項目 | 内容 |
|---|---|
| 目的 | プロダクトで使用する用語を定義する |
| コアskill | `glossary-creation` |
| 入力 | Step 1〜2 の全出力ドキュメント |
| 出力 | `docs/glossary.md` |

#### A-G7: issue仕様作成

| 項目 | 内容 |
|---|---|
| 目的 | issue種別に応じた固有ドキュメント（不具合再現手順、リファクタリング方針等）を作成する |
| コアskill | `issue-specification` |
| 入力 | 種別 + 要件 + 関連 `docs/` |
| 出力 | 種別固有ドキュメント |

---

### 7.2.2. 技術検証系 Agent

技術の評価・PoC実装・デザインパターン設計を行うAgent。WF3で使用される。

| # | Agent名 | ファイル名 | コアskill | 使用WF |
|---|---|---|---|---|
| A-T1 | 技術評価 | `agents/tech-evaluator.md` | `tech-evaluation` | WF3 |
| A-T2 | PoC実装 | `agents/poc-implementer.md` | `poc-workflow` | WF3 |
| A-T3 | パターン設計 | `agents/pattern-designer.md` | `design-patterns` | WF3 |

#### A-T1: 技術評価

| 項目 | 内容 |
|---|---|
| 目的 | 技術候補の調査・比較（Phase 1）、PoC結果を踏まえたメリット・デメリット評価・推薦（Phase 3） |
| コアskill | `tech-evaluation` |
| 入力（Phase 1） | 要件 + `docs/architecture.md` |
| 出力（Phase 1） | 技術候補一覧（比較表 + 各候補の概要） |
| 入力（Phase 3） | 全PoC結果 + 候補一覧 + 要件 |
| 出力（Phase 3） | `docs/tech-decisions/YYYYMMDD-{topic}.md`（メリット・デメリット比較 + 推薦） |
| 特記事項 | 同一Agentを Phase 1 と Phase 3 で二度起動する。入力が異なるため各フェーズに適したコンテキストで動作 |

#### A-T2: PoC実装

| 項目 | 内容 |
|---|---|
| 目的 | PoCディレクトリで検証コードを実装する |
| コアskill | `poc-workflow` |
| 入力 | 候補技術 + 要件 |
| 出力 | `poc/{技術名}/`（`src/` + `README.md`） |

#### A-T3: パターン設計

| 項目 | 内容 |
|---|---|
| 目的 | PoCディレクトリでベストプラクティスとトライ&エラーを通じてデザインパターンを設計する |
| コアskill | `design-patterns` |
| 入力 | 技術選定結果 + `poc/{技術名}/` + `docs/architecture.md` + `docs/design-patterns/` |
| 出力 | `docs/design-patterns/{concern}.md`（新規）+ `docs/design-patterns/index.md`（更新）+ `poc/{技術名}/src/`（パターン検証コード） |

---

### 7.2.3. issue管理系 Agent

issueの登録・スコープ検証を行うAgent。WF2・WF4で使用される。

| # | Agent名 | ファイル名 | コアskill | 使用WF | 再利用 |
|---|---|---|---|---|---|
| A-I1 | issue分解・登録 | `agents/issue-decomposer.md` | `issue-workflow` | WF2, WF4 | WF4で登録モード |
| A-I2 | PRDスコープ検証 | `agents/prd-scope-checker.md` | — | WF4 | — |

#### A-I1: issue分解・登録

| 項目 | 内容 |
|---|---|
| 目的 | 仕様をissueに分解しGitHubに登録する |
| コアskill | `issue-workflow` |
| 入力 | 全仕様ドキュメント |
| 出力 | GitHub issues + `.issue/{N}/` |
| 特記事項 | WF2では全仕様から分解、WF4では単一issueの登録として動作 |

#### A-I2: PRDスコープ検証

| 項目 | 内容 |
|---|---|
| 目的 | 変更がPRDの範囲を逸脱するか検証する |
| コアskill | — |
| 入力 | 変更仕様 + `docs/product-requirements.md` |
| 出力 | スコープ判定結果（範囲内 / 逸脱） |

---

### 7.2.4. 品質検証系 Agent

ドキュメントやコードの品質を検証するAgent。

| # | Agent名 | ファイル名 | コアskill | 使用WF | 検証対象 |
|---|---|---|---|---|---|
| A-Q1 | ドキュメントレビュー | `agents/doc-reviewer.md` | `doc-review` | WF2, WF3, WF4 | 仕様ドキュメント |
| A-Q2 | コーディングレビュー | `agents/coding-reviewer.md` | `review-coding` | WF5 | 実装コード |
| A-Q3 | アーキテクチャレビュー | `agents/architecture-reviewer.md` | `review-architecture` | WF5 | 実装コード |
| A-Q4 | i18nレビュー | `agents/i18n-reviewer.md` | `review-i18n` | WF5 | 実装コード |
| A-Q5 | テスト実行 | `agents/test-runner.md` | — | WF5 | テスト・リント・型チェック・ビルド |

#### A-Q1: ドキュメントレビュー

| 項目 | 内容 |
|---|---|
| 目的 | 生成ドキュメントの品質検証（共通パターン 6.0） |
| コアskill | `doc-review` |
| 状況依存skill | レビュー対象に応じたskill（例: PRDレビュー時は `prd-writing`） |
| 入力 | レビュー対象ドキュメント |
| 出力 | レビュー結果（指摘事項 + MUST/SHOULD/MAY 重要度分類） |
| 特記事項 | 全WF（WF1・WF5除く）で共通利用。最も再利用頻度が高いAgent |

#### A-Q2: コーディングレビュー

| 項目 | 内容 |
|---|---|
| 目的 | コーディング規約準拠の検証 |
| コアskill | `review-coding` |
| 入力 | 差分コード + `docs/development-guidelines.md` |
| 出力 | コーディングレビュー結果（MUST/SHOULD/MAY） |

#### A-Q3: アーキテクチャレビュー

| 項目 | 内容 |
|---|---|
| 目的 | アーキテクチャ準拠の検証 |
| コアskill | `review-architecture` |
| 入力 | 差分コード + `docs/architecture.md` + `docs/design-patterns/` |
| 出力 | アーキテクチャレビュー結果（MUST/SHOULD/MAY） |

#### A-Q4: i18nレビュー

| 項目 | 内容 |
|---|---|
| 目的 | 多言語対応の検証 |
| コアskill | `review-i18n` |
| 入力 | 差分コード |
| 出力 | i18nレビュー結果（MUST/SHOULD/MAY） |

#### A-Q5: テスト実行

| 項目 | 内容 |
|---|---|
| 目的 | テスト・リント・型チェック・ビルドの実行 |
| コアskill | — |
| 入力 | なし（コードベース全体を対象） |
| 出力 | テスト実行結果（PASS / FAIL + 詳細） |

---

### 7.2.5. autopilot系 Agent

issueの自律実行を行うAgent。WF5で使用される。

| # | Agent名 | ファイル名 | コアskill | 使用WF |
|---|---|---|---|---|
| A-A1 | autopilot管理 | `agents/autopilot-manager.md` | `implementation-planning` | WF5 |
| A-A2 | 実装 | `agents/implementer.md` | `development-guidelines` | WF5 |
| A-A3 | テスト作成 | `agents/test-writer.md` | — | WF5 |

#### A-A1: autopilot管理

| 項目 | 内容 |
|---|---|
| 目的 | issue単位の計画→実装→レビュー→PR作成を自律管理する |
| コアskill | `implementation-planning` |
| 入力 | issue情報 + `.issue/{N}/`（WF4が作成したissue仕様ドキュメント） |
| 出力 | PR（autopilotブランチベース）+ `docs/` 更新 |
| 起動するAgent | 実装 + テスト作成（Phase B・並列）、コーディングレビュー + アーキテクチャレビュー + i18nレビュー + テスト実行（Phase C・並列） |
| 特記事項 | 唯一のAgent型オーケストレーター（設計原則 4.4: 自律実行のためAgentとして定義） |

#### A-A2: 実装

| 項目 | 内容 |
|---|---|
| 目的 | 本番コード（`src/`）の実装・修正 |
| コアskill | `development-guidelines` |
| 入力（初回） | `.issue/{N}/design.md` + `.issue/{N}/tasklist.md` |
| 入力（修正時） | `.issue/{N}/` 内の修正指示書 |
| 出力 | `src/` の実装コード |
| 特記事項 | `src/` のみ編集可。`tests/` は編集不可（テスト作成Agentの責務） |

#### A-A3: テスト作成

| 項目 | 内容 |
|---|---|
| 目的 | テストコード（`tests/`）の実装・修正 |
| コアskill | — |
| 入力（初回） | `.issue/{N}/test-spec.md` + `.issue/{N}/tasklist.md` |
| 入力（修正時） | `.issue/{N}/` 内の修正指示書 |
| 出力 | `tests/` のテストコード |
| 特記事項 | `tests/` のみ編集可。`src/` は編集不可（実装Agentの責務） |

---

## 7.3. Agent 統計

| カテゴリ | 件数 | Agent名 |
|---|---|---|
| ドキュメント生成系 | 7 | PRD作成, 機能設計, 画面仕様, データモデル設計, 実装仕様, 用語集作成, issue仕様作成 |
| 技術検証系 | 3 | 技術評価, PoC実装, パターン設計 |
| issue管理系 | 2 | issue分解・登録, PRDスコープ検証 |
| 品質検証系 | 5 | ドキュメントレビュー, コーディングレビュー, アーキテクチャレビュー, i18nレビュー, テスト実行 |
| autopilot系 | 3 | autopilot管理, 実装, テスト作成 |
| **合計** | **20** | |

### Agent 再利用マトリクス

複数WFで使用されるAgentの一覧:

| Agent名 | WF1 | WF2 | WF3 | WF4 | WF5 | 備考 |
|---|---|---|---|---|---|---|
| 機能設計 | — | 新規作成 | — | 変更仕様 | — | オーケストレーターがモード制御 |
| 画面仕様 | — | 新規作成 | — | 変更仕様 | — | オーケストレーターがモード制御 |
| データモデル設計 | — | 新規作成 | — | 変更仕様 | — | オーケストレーターがモード制御 |
| issue分解・登録 | — | 分解+登録 | — | 登録のみ | — | WF4では単一issue登録 |
| ドキュメントレビュー | — | ○ | ○ | ○ | — | 最多再利用（状況依存skillで対応） |

---

## 7.4. WF別 使用一覧

### WF1: アイデア壁打ち

| 種別 | 名前 |
|---|---|
| Skill（オーケストレーター） | `skills/brainstorm/` |
| Skill（知識型） | `idea-brainstorming` |
| Agent | なし |

### WF2: 新規プロジェクト立ち上げ

| 種別 | 名前 |
|---|---|
| Skill（オーケストレーター） | `skills/new-project/` |
| Skill（知識型） | `prd-writing`, `functional-design`, `screen-specification`, `data-model-design`, `architecture-design`, `design-patterns`, `development-guidelines`, `repository-structure`, `glossary-creation`, `issue-workflow`, `doc-review` |
| Agent | PRD作成, 機能設計, 画面仕様, データモデル設計, 実装仕様, 用語集作成, issue分解・登録, ドキュメントレビュー |

### WF3: 技術検証

| 種別 | 名前 |
|---|---|
| Skill（オーケストレーター） | `skills/tech-verify/` |
| Skill（知識型） | `tech-evaluation`, `poc-workflow`, `design-patterns`, `doc-review` |
| Agent | 技術評価, PoC実装, パターン設計, ドキュメントレビュー |

### WF4: issue作成

| 種別 | 名前 |
|---|---|
| Skill（オーケストレーター） | `skills/create-issue/` |
| Skill（知識型） | `functional-design`, `screen-specification`, `issue-specification`, `issue-workflow`, `doc-review` |
| Agent | 機能設計, 画面仕様, issue仕様作成, PRDスコープ検証, issue分解・登録, ドキュメントレビュー |

### WF5: autopilot実行

| 種別 | 名前 |
|---|---|
| Skill（オーケストレーター） | `skills/autopilot/` |
| Skill（知識型） | `implementation-planning`, `development-guidelines`, `review-coding`, `review-architecture`, `review-i18n` |
| Agent | autopilot管理, 実装, テスト作成, コーディングレビュー, アーキテクチャレビュー, i18nレビュー, テスト実行 |
