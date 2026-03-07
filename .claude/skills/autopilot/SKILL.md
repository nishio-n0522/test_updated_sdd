---
name: autopilot
description: バッチ処理制御・ブランチ管理・完了レポートを行うautopilot入口オーケストレーター
allowed-tools: Read, Write, Edit, Bash, Agent
---

# autopilot入口オーケストレーター

オープンissue全件を自動取得し、issue/{N}ブランチで逐次処理する。各issueに対してautopilot管理エージェントを起動し、完了レポートを生成する。

## 起動方法

```
/autopilot
```

## 全体フロー

```
初期化（main最新化 + autopilotブランチ作成）
  ↓
loop 各issue（番号昇順・逐次処理）
  issue/{N} ブランチ作成
    ↓
  autopilot管理エージェント起動（Phase A〜D 自律実行）
    ↓
  結果に応じた分岐（成功: マージ + push / スキップ: ブランチ削除）
end loop
  ↓
完了レポート出力
```

## ステップ1: 初期化

1. `git checkout main && git pull origin main` で最新のmainを取得する
2. 現在の日時をYYYYMMDDHHmmss形式で取得し、`git checkout -b autopilot/{YYYYMMDDHHmmss}` でautopilotブランチを作成する
3. autopilotブランチをリモートへプッシュする: `git push -u origin autopilot/{YYYYMMDDHHmmss}`
4. 全バッチの累計結果を記録するリストを初期化する（処理済みissue番号のセット、成功/失敗/スキップのカウンター、詳細リスト）

## ステップ2: バッチ取得・処理ループ

未処理のissueがなくなるまで繰り返す。

### 2-0. issueバッチの取得

```bash
gh issue list --limit 20 --state open --json number,title,labels,body
```

- 処理済みissue番号を除外し、残りが0件ならステップ3へ
- 番号が若い順にソートする

### 2-1. 各issueの処理

各issueに対して以下を実行する:

#### 2-1-1. 作業ブランチの作成

```bash
git checkout autopilot/{timestamp}
git checkout -b issue/{N}
```

#### 2-1-2. autopilot管理エージェントの起動

`autopilot-manager` エージェントをAgentツールで起動する:

```
Agent(
  subagent_type: "autopilot-manager",
  prompt: "issue番号: {N}
作業ブランチ: issue/{N}
autopilotブランチ: autopilot/{timestamp}
issueタイトル: {title}
issue本文: {body}
issueラベル: {labels}

計画→実装→レビュー→PR作成の全フローを自律的に実行してください。"
)
```

#### 2-1-3. 結果に応じた分岐

| 結果 | 動作 |
|---|---|
| 完了（PR URL付き） | `git checkout autopilot/{timestamp}` → `git merge issue/{N}` → `git push origin autopilot/{timestamp}` |
| スキップ | `git checkout autopilot/{timestamp}` → `git branch -D issue/{N}` |

処理結果（issue番号、タイトル、成功/スキップ、PR URL）を累計結果リストに記録する。

### 2-2. バッチ完了後のコンテキストクリーンアップ

1. 累計結果の中間サマリを生成する（次のバッチに引き継ぐため）
2. `/compact` を実行してコンテキストを圧縮する
3. ステップ2-0に戻り、新しいissueバッチの取得を試みる

## ステップ3: 完了レポート

未処理のissueがなくなりループが終了したら、以下の形式で結果を報告する:

```markdown
# autopilot 実行結果

## サマリ
- 処理バッチ数: {batch_count}
- 処理issue数: {total}
- 成功: {success}
- 失敗: {failed}
- スキップ: {skipped}

## 詳細

| issue | タイトル | 結果 | PR |
|---|---|---|---|
| #{N} | {title} | 成功 / 失敗 / スキップ | {PR URL or -} |
```

## 完了条件

- [ ] 初期化が完了している（main最新化 + autopilotブランチ作成）
- [ ] バッチ取得でissueが0件になるまでループを繰り返している
- [ ] 全バッチの累計完了レポートがユーザーに報告されている

## 設計原則

| 原則 | 説明 |
|---|---|
| 完全自律実行 | ユーザーの介入なしで最後まで実行する |
| 逐次issue処理 | issueは番号昇順で逐次処理。並列にissueを処理しない |
| 前issueマージ済み保証 | 次のissueに移る前に、前のissueがautopilotブランチにマージ済み |
| autopilotブランチベース | 各issueブランチはautopilotブランチから切る（mainではない） |
| ドキュメント駆動 | エージェント間の情報伝達は `.issue/{N}/` 配下のドキュメントを介して行う |
| バッチ間コンテキスト管理 | バッチ完了ごとにコンテキストを圧縮し、次のバッチの処理品質を維持する |

## autopilotブランチのクリーンアップ

全issue処理完了後、autopilotブランチはリモートに残る（各issueのPRのベースブランチとなるため）。全PRがマージまたはクローズされた後に、手動でautopilotブランチを削除する。

## エラー時の動作

| ケース | 動作 |
|---|---|
| `gh issue list` が失敗 | 最大3回リトライ後、ステップ3（完了レポート）へ進む |
| autopilot管理エージェントがエラーで終了 | スキップとして記録し、次のissueへ進む |
| `git merge` がコンフリクト | issueにコメント + `autopilot-failed` ラベル付与 → スキップとして記録 |
