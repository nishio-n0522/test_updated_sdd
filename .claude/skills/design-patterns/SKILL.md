---
name: design-patterns
description: 実装時に必要な技術スタックのデザインパターンを参照するスキル。コード実装・レビュー時に使用し、該当する技術スタックのパターンのみを読み込む。
allowed-tools: Read, Glob, Grep
---

# デザインパターン参照スキル

実装作業中に、使用する技術スタックに対応したデザインパターンドキュメントを必要分だけ読み取り、一貫した実装を支援します。

## デザインパターンドキュメントの所在

```
docs/design-patterns/
└── tanstack-query/
    ├── index.md            # 概要・共通ルール・現状の問題点
    ├── data-strategy.md    # データ権威・キャッシュ戦略パターン (A/B/C/D)
    └── coding-patterns.md  # コーディングパターン（クエリ消費・SSR・エラー処理）
```

## 使い方

### 1. 対象の技術スタックとドキュメントを特定する

実装対象のコードがどの技術スタックに関わるかを判断し、必要なドキュメントのみ読む。

#### TanStack Query

| 作業内容 | 読むドキュメント |
|---------|----------------|
| 新規 feature の API 層設計（staleTime/gcTime 決定） | `tanstack-query/index.md` → `tanstack-query/data-strategy.md` |
| コンポーネントでクエリを消費する実装 | `tanstack-query/coding-patterns.md` |
| mutation の追加・修正 | `tanstack-query/data-strategy.md`（該当パターンの Mutation 後の戦略） |
| SSR プリフェッチの実装 | `tanstack-query/coding-patterns.md`（SSR セクション） |
| コードレビュー | `tanstack-query/index.md`（現状の問題点 + 共通ルール） |

### 2. 作業別の参照ガイド

#### 新規 feature の API 層を実装する場合

1. `tanstack-query/index.md` の「共通ルール」でキーファクトリ・3層構造を確認
2. `tanstack-query/data-strategy.md` の「パターン選定フローチャート」で該当パターンを特定
3. 該当パターンの「推奨設定」と「実装テンプレート」を参照

#### コンポーネントでクエリを使う場合

1. `tanstack-query/coding-patterns.md` の「パターン選定フローチャート」で使うフックを決定
2. 該当パターンの実装例を参照
3. Suspense / ErrorBoundary の配置ルールを確認

#### 既存 feature の mutation を追加・修正する場合

1. `tanstack-query/data-strategy.md` で該当 feature のパターン（A/B/C/D）を確認
2. そのパターンの「Mutation 後の戦略」を参照

#### コードレビュー時

1. `tanstack-query/index.md` の「現状の問題点」で既知のアンチパターンを確認
2. `tanstack-query/data-strategy.md` で対象コードのパターンが適切か照合
3. `tanstack-query/coding-patterns.md` でクエリ消費パターンが適切か照合

### 3. 判断基準クイックリファレンス

| 疑問 | 参照先 |
|------|--------|
| staleTime/gcTime の値は？ | `data-strategy.md` → 該当パターンの推奨設定 |
| mutation 後のキャッシュ操作は？ | `data-strategy.md` → 該当パターンの Mutation 後の戦略 |
| useSuspenseQuery と useQuery どちらを使う？ | `coding-patterns.md` → パターン選定フローチャート |
| query-options はどう渡す？ | `coding-patterns.md` → query-options の消費パターン |
| クエリキーの命名は？ | `index.md` → 共通ルール: キーファクトリパターン |
| エラー時にどうする？ | `index.md` → 共通ルール: エラーハンドリング |
| リトライは必要？ | `index.md` → 共通ルール: リトライ戦略 |
| SSR プリフェッチは必要？ | `coding-patterns.md` → SSR プリフェッチ & ハイドレーション |
| カスタムフックでラップすべき？ | `coding-patterns.md` → カスタムフックによるクエリラップ |

## 注意事項

- このスキルは**読み取り専用**です。デザインパターンドキュメント自体の編集は行いません。
- ドキュメントに記載のないパターンが必要な場合は、既存パターンに最も近いものを参考にしつつ、ドキュメントへの追加を検討してください。
- `docs/design-patterns/` に新しい技術スタックのドキュメントが追加された場合、このスキルの対応表も更新してください。
