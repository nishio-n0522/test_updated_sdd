# リポジトリ構造定義書 (Repository Structure Document)

## プロジェクト構造

```
project-root/
├── src/                   # ソースコード（単体テストは各ファイルの隣に配置）
│   ├── router/            # ルーティングとページ
│   ├── features/           # フィーチャー（機能）モジュール
│   │   ├── [feature1]/
│   │   └── [feature2]/
│   └── shared/            # 共有コード
│       ├── ui/
│       ├── lib/
│       ├── api/
│       ├── types/
│       └── constants/
├── e2e/                   # E2Eテスト（アプリ全体のシナリオテスト）
├── docs/                  # プロジェクトドキュメント
├── config/                # 設定ファイル
└── scripts/               # ビルド・デプロイスクリプト
```

## 依存ルール

### レイヤー間のインポート制約

```
router/  →  features/  →  shared/
  │            │
  │            ├── shared/ からインポート可能
  │            └── 他の features/ から公開API経由でインポート可能（※循環禁止）
  │
  └── features/, shared/ の両方からインポート可能

shared/ → router/, features/ のいずれからもインポート不可
```

| レイヤー | インポート可能な対象 | インポート禁止の対象 |
|----------|----------------------|----------------------|
| `router/` | `features/`, `shared/` | なし |
| `features/` | `shared/`, 他の `features/`（公開API経由・循環禁止） | `router/` |
| `shared/` | なし（自己完結） | `router/`, `features/` |

#### features/ 間のインポートルール

- **公開API（`index.ts`）経由のみ**: 他フィーチャーの内部ファイルへの直接インポートは禁止
- **循環参照の禁止**: A→B かつ B→A のような双方向依存は禁止
- **最小限の依存**: 複数フィーチャーで使う汎用コードはできる限り `shared/` に抽出する

## ディレクトリ詳細

### src/router/ (ルーティングディレクトリ)

**役割**: アプリケーションのルーティング定義とページコンポーネント

**配置ファイル**:

- `index.ts`: ルーター設定のエントリポイント
- `routes.ts`: ルート定義
- `pages/*.tsx`: ページコンポーネント

**命名規則**:

- ページコンポーネント: PascalCase + `Page` 接尾辞（例: `TaskListPage.tsx`）
- ルート定義: camelCase

**依存関係**:

- 依存可能: `features/`, `shared/`
- 依存禁止: なし

**例**:

```
src/router/
├── index.ts
├── routes.ts
└── pages/
    ├── HomePage.tsx
    ├── TaskListPage.tsx
    └── UserProfilePage.tsx
```

### src/features/ (フィーチャーディレクトリ)

**役割**: フィーチャー（機能）ごとの独立したモジュール

**構造**:

各フィーチャーは以下のサブディレクトリを必要に応じて持ちます:

```
src/features/[feature-name]/
├── index.ts              # 公開APIのエクスポート
├── components/           # フィーチャー固有のUIコンポーネント
│   ├── TaskCard.tsx
│   └── TaskCard.test.tsx # ← 単体テストは同じディレクトリに配置
├── hooks/                # フィーチャー固有のカスタムフック
├── services/             # ビジネスロジック
│   ├── TaskService.ts
│   └── TaskService.test.ts
├── repositories/         # データアクセス
├── types/                # フィーチャー固有の型定義
├── validators/           # バリデーション
└── constants/            # フィーチャー固有の定数
```

**命名規則**:

- フィーチャーディレクトリ: 単数形、kebab-case（例: `task/`, `user-profile/`）
- エントリポイント: `index.ts`（公開APIを集約）
- コンポーネント: PascalCase（例: `TaskCard.tsx`）
- サービス: PascalCase + 役割接尾辞（例: `TaskService.ts`）

**依存関係**:

- 依存可能: `shared/`, 他の `features/`（公開API経由・循環禁止）
- 依存禁止: `router/`

**例**:

```
src/features/
├── task/
│   ├── index.ts
│   ├── components/
│   │   ├── TaskCard.tsx
│   │   ├── TaskCard.test.tsx     # 単体テスト
│   │   ├── TaskForm.tsx
│   │   └── TaskForm.test.tsx
│   ├── services/
│   │   ├── TaskService.ts
│   │   └── TaskService.test.ts
│   ├── repositories/
│   │   ├── TaskRepository.ts
│   │   └── TaskRepository.test.ts
│   └── types/
│       └── Task.ts
└── user/
    ├── index.ts
    ├── components/
    │   ├── UserAvatar.tsx
    │   └── UserAvatar.test.tsx
    ├── services/
    │   ├── UserService.ts
    │   └── UserService.test.ts
    └── types/
        └── User.ts
```

### src/shared/ (共有ディレクトリ)

**役割**: 複数のフィーチャーやルーターから共通利用される自己完結したコード

**配置ファイル**:

- `ui/`: 共通UIコンポーネント
- `lib/`: 汎用ユーティリティ関数
- `api/`: API通信基盤
- `types/`: 共通型定義
- `constants/`: 共通定数

**配置基準**: 2つ以上のフィーチャーで使われるコードのみ配置する

**命名規則**:

- サブディレクトリ: 役割ベース、kebab-case
- コンポーネント: PascalCase（例: `Button.tsx`）
- 関数: camelCase（例: `formatDate.ts`）
- 定数: kebab-case（例: `api-endpoints.ts`）

**依存関係**:

- 依存可能: `shared/` 内の他モジュール（例: `shared/lib/` → `shared/types/`）
- 依存禁止: `router/`, `features/`

**例**:

```
src/shared/
├── ui/
│   ├── Button.tsx
│   ├── Modal.tsx
│   └── Input.tsx
├── lib/
│   ├── formatDate.ts
│   ├── validateEmail.ts
│   └── http-client.ts
├── api/
│   └── client.ts
├── types/
│   └── common.ts
└── constants/
    └── config.ts
```

### 単体テスト・統合テスト（ソースコードと同居）

**役割**: 各ファイルの単体テスト・統合テスト

**配置**: テスト対象ファイルと同じディレクトリに配置し、サフィックスで種別を区別

```
src/features/task/services/
├── TaskService.ts                         # 本番コード
├── TaskService.test.ts                    # 単体テスト（モック使用）
└── TaskService.integration.test.ts        # 統合テスト（実モジュールと結合）

src/shared/lib/
├── formatDate.ts
└── formatDate.test.ts
```

**命名規則**:

- 単体テスト: `[テスト対象ファイル名].test.ts`
- 統合テスト: `[テスト対象ファイル名].integration.test.ts`

### e2e/ (E2Eテストディレクトリ)

**役割**: アプリケーション全体を通したE2E（End-to-End）テスト専用

**構造**:

```
e2e/
├── task-workflow.test.ts
├── user-registration.test.ts
└── checkout-flow.test.ts
```

**命名規則**:

- パターン: `[ユーザーシナリオ].test.ts`（kebab-case）
- 例: `task-workflow.test.ts`, `user-registration.test.ts`

### docs/ (ドキュメントディレクトリ)

**配置ドキュメント**:

- `product-requirements.md`: プロダクト要求定義書
- `functional-design.md`: 機能設計書
- `architecture.md`: アーキテクチャ設計書
- `repository-structure.md`: リポジトリ構造定義書（本ドキュメント）
- `development-guidelines.md`: 開発ガイドライン
- `glossary.md`: 用語集

### config/ (設定ファイルディレクトリ - 該当する場合)

**配置ファイル**:

- 設定ファイル
- 定数定義ファイル

**例**:

```
config/
├── default.ts
└── constants.ts
```

### scripts/ (スクリプトディレクトリ - 該当する場合)

**配置ファイル**:

- ビルドスクリプト
- 開発補助スクリプト

## ファイル配置規則

### ソースファイル

| ファイル種別 | 配置先 | 命名規則 | 例 |
|-------------|--------|---------|-----|
| ページコンポーネント | `router/pages/` | PascalCase + `Page` | `TaskListPage.tsx` |
| フィーチャーコンポーネント | `features/[name]/components/` | PascalCase | `TaskCard.tsx` |
| 共通UIコンポーネント | `shared/ui/` | PascalCase | `Button.tsx` |
| サービス | `features/[name]/services/` | PascalCase + `Service` | `TaskService.ts` |
| リポジトリ | `features/[name]/repositories/` | PascalCase + `Repository` | `TaskRepository.ts` |
| フィーチャー型定義 | `features/[name]/types/` | PascalCase | `Task.ts` |
| 共通型定義 | `shared/types/` | PascalCase（複数の型をまとめるファイルはkebab-case可） | `User.ts`, `common.ts` |
| ユーティリティ | `shared/lib/` | camelCase | `formatDate.ts` |

### テストファイル

| テスト種別 | 配置先 | 命名規則 | 例 |
|-----------|--------|---------|-----|
| 単体テスト | テスト対象ファイルと同じディレクトリ | `[対象].test.ts` | `TaskService.test.ts` |
| 統合テスト | テスト対象ファイルと同じディレクトリ | `[対象].integration.test.ts` | `TaskService.integration.test.ts` |
| E2Eテスト | `e2e/` | `[シナリオ].test.ts` | `task-workflow.test.ts` |

### 設定ファイル

| ファイル種別 | 配置先 | 命名規則 |
|-------------|--------|---------|
| 環境設定 | `config/` | `[環境名].ts` |
| ツール設定 | プロジェクトルート | `[ツール名].config.js` |

## 命名規則

### ディレクトリ名

- **レイヤーディレクトリ**: kebab-case
  - 例: `router/`, `features/`, `shared/`
- **フィーチャーディレクトリ**: 単数形、kebab-case
  - 例: `task/`, `user/`, `user-profile/`
- **shared/ サブディレクトリ**: 役割ベース、kebab-case
  - 例: `ui/`, `lib/`, `api/`, `types/`

### ファイル名

- **コンポーネント**: PascalCase
  - 例: `TaskCard.tsx`, `Button.tsx`
- **サービス/リポジトリ**: PascalCase + 役割接尾辞
  - 例: `TaskService.ts`, `UserRepository.ts`
- **関数ファイル**: camelCase（動詞で始める）
  - 例: `formatDate.ts`, `validateEmail.ts`, `parseCommandArguments.ts`
- **定数ファイル**: kebab-case
  - 例: `api-endpoints.ts`, `error-messages.ts`
- **エントリポイント**: `index.ts`

### テストファイル名

- **単体テスト**: `[テスト対象].test.ts` / `.test.tsx`（テスト対象と同じディレクトリに配置）
  - 例: `TaskService.test.ts`, `TaskCard.test.tsx`, `formatDate.test.ts`
- **統合テスト**: `[テスト対象].integration.test.ts` / `.integration.test.tsx`（テスト対象と同じディレクトリに配置）
  - 例: `TaskService.integration.test.ts`, `TaskRepository.integration.test.ts`
- **E2Eテスト**: `[シナリオ名].test.ts`（kebab-case、`e2e/` に配置）
  - 例: `task-workflow.test.ts`, `user-registration.test.ts`

## 依存関係のルール

### レイヤー間の依存（再掲）

```
router/ → features/, shared/                           (OK)
features/ → shared/                                    (OK)
features/ → 他のfeatures/（公開API経由・循環禁止）       (OK)
shared/ → （なし）                                     (自己完結)

features/ → router/                                    (❌ 禁止)
features/ → 他のfeatures/ の内部ファイルに直接アクセス    (❌ 禁止)
features/ 間の循環参照（A→B かつ B→A）                   (❌ 禁止)
shared/ → router/                                      (❌ 禁止)
shared/ → features/                                    (❌ 禁止)
```

### フィーチャー間の依存管理

**推奨: 公開API経由の一方向インポート**

```typescript
// ✅ 良い例: 公開API経由（一方向）
import { getUserById } from "../../features/user";  // user/index.ts 経由

// ❌ 悪い例: 内部ファイルへの直接インポート
import { UserService } from "../../features/user/services/UserService";  // 禁止
```

**循環参照が発生しそうな場合の解決策**:

```typescript
// ✅ 解決策1: 共通の型を shared/ に抽出
// shared/types/common.ts
export interface SharedType { /* ... */ }

// ✅ 解決策2: router/ 層で組み合わせる
// router/pages/SomePage.tsx
import { ComponentA } from "../../features/feature-a";
import { ComponentB } from "../../features/feature-b";

// ✅ 解決策3: 依存の方向を一方向に統一する
// feature-a → feature-b は許可、feature-b → feature-a は禁止と決める
```

## スケーリング戦略

### 機能の追加

新しい機能を追加する際の判断基準:

1. **既存フィーチャーに属する場合**: そのフィーチャー内にファイルを追加
2. **新規フィーチャーの場合**: `features/` に新しいフィーチャーディレクトリを作成
3. **共通コードの場合**: `shared/` に追加（2つ以上のフィーチャーで使用される場合のみ）

### フィーチャーの肥大化への対応

フィーチャー内のファイル数が多くなった場合、サブフィーチャーに分割:

```
src/features/task/
├── index.ts                # 公開APIの集約
├── core/                   # 基本CRUD
├── assignment/             # 割り当て
└── analytics/              # 分析
```

### ファイルサイズの管理

- 1ファイル: 500行以下を推奨
- 500-800行: リファクタリングを検討
- 800行以上: 分割を強く推奨

## 特殊ディレクトリ

### .issue/ (issue固有ドキュメント)

**役割**: 各issueのライフサイクル全体に関わるドキュメントを保持

**構造**:

```
.issue/
└── {issue番号}/
    ├── （実装前）変更仕様書、影響範囲分析
    ├── （実装中）作業リスト（タスク分解・進捗管理）
    └── （実装後）レビュー結果、品質検証ドキュメント
```

### .claude/ (Claude Code設定)

**役割**: Claude Code設定とカスタマイズ

**構造**:

```
.claude/
├── commands/                # スラッシュコマンド
├── skills/                  # タスクモード別スキル
└── agents/                  # サブエージェント定義
```

## 除外設定

### .gitignore

プロジェクトで除外すべきファイル:

- `node_modules/`
- `dist/`
- `.env`
- `.issue/` (issue固有ドキュメント)
- `*.log`
- `.DS_Store`

### .prettierignore, .eslintignore

ツールで除外すべきファイル:

- `dist/`
- `node_modules/`
- `.issue/`
- `coverage/`
