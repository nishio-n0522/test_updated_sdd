---
description: GitHub issueを自律的に解決し、PR作成まで行う完全自動ワークフロー
---

# autopilot — 自律Issue解決ワークフロー

**重要:** このワークフローは、ユーザーの介入なしに、開始から完了まで完全に自動で実行されるように設計されています。各ステップは完了後、ただちに次のステップへ移行してください。ユーザーに判断を仰がない。

**引数:** なし（オープンissue全件を自動処理）

---

## ステップ1: 初期化

1. `gh issue list --limit 20 --state open --json number,title,labels,body` でissue一覧を取得する
2. issueが0件の場合は「対象issueなし」と報告して終了する
3. `git checkout main && git pull origin main` で最新のmainを取得する
4. 現在の日時をYYYYMMDDHHmmss形式で取得し、`git checkout -b autopilot/{YYYYMMDDHHmmss}` でautopilotブランチを作成する

## ステップ2: Issue処理ループ

取得したissue全件を番号が若い順に処理する。各issueに対して以下を実行する:

### 2-1. 作業ブランチの作成

```bash
git checkout autopilot/{timestamp}
git checkout -b issue/{N}
```

### 2-2. issue詳細の取得

```bash
gh issue view {N} --json title,body,labels
```

### 2-3. ステアリングディレクトリの作成

```bash
mkdir -p .steering/{YYYYMMDDHHmmss}-issue-{N}-{slug}/reviews
mkdir -p .steering/{YYYYMMDDHHmmss}-issue-{N}-{slug}/fixes
```

slugはissueタイトルを英数字・ハイフンのみ、最大30文字に変換したもの。

### 2-4. CC2（中間管理エージェント）の起動

Taskツールで `autopilot-manager` エージェントを起動する:

```
Task(
  subagent_type: "autopilot-manager",
  prompt: "issue番号: {N}\n作業ブランチ: issue/{N}\nissueタイトル: {title}\nissue本文: {body}\nissueラベル: {labels}\nステアリングディレクトリ: {steering_dir}\n\nissueのラベル・内容からissueタイプ（enhancement/ui/refactor/bug等）を判定し、計画→実装→レビュー→PR作成の全フローを自律的に実行してください。",
  model: "opus"
)
```

### 2-5. 結果に応じた分岐

**CC2が「完了」を報告した場合（PR URL付き）:**

```bash
git checkout autopilot/{timestamp}
git merge issue/{N}
# マージが成功し、変更が取り込まれたことを確認する
git log --oneline -3
```

**CC2が「スキップ」を報告した場合:**

```bash
git checkout autopilot/{timestamp}
git branch -D issue/{N}
```

### 2-6. 次のissueへ

ループの先頭に戻り、次のissueを処理する。

---

## ステップ3: 完了レポート

全issueの処理が完了したら、以下の形式で結果をユーザーに報告する:

```markdown
# autopilot 実行結果

## サマリ
- 処理issue数: {total}
- 成功: {success}
- 失敗: {failed}
- スキップ: {skipped}

## 詳細

| issue | タイトル | 結果 | PR |
|---|---|---|---|
| #{N} | {title} | 成功 / 失敗 / スキップ | {PR URL or -} |
```

---

## 完了条件

このワークフローは以下の全条件を満たした時点で完了となる:

- ステップ1: issue一覧の取得が完了している
- ステップ2: 全issueの処理（成功/失敗/スキップのいずれか）が完了している
- ステップ3: 完了レポートがユーザーに報告されている

## autopilotブランチのクリーンアップ

全issue処理完了後、autopilotブランチが不要であれば削除する:

```bash
git checkout main
git branch -D autopilot/{timestamp}
```

ただし、未マージのissueブランチが残っている場合はautopilotブランチを保持する。

## 設計原則

- ユーザーの介入なしで自律的に最後まで実行する
- 各issueは逐次処理する（並列にissueを処理しない）
- 次のissueに移る前に、前のissueがマージ済みであること
- 各issueブランチは必ずautopilotブランチから切る（mainからではない）
- 前のissueの変更がautopilotブランチにマージされた状態から次のissueブランチを作成する
- CC2への指示にはissue情報 + ステアリングディレクトリパス + 作業ブランチ名を含める
- ユーザーに判断を仰がない。判断はCC2が自律的に行う
