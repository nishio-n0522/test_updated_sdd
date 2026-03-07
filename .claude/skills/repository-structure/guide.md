# リポジトリ構造定義書作成ガイド

## 基本原則

### 1. FSD（Feature-Sliced Design）ベースの構成

本ガイドでは、技術スタックベースではなく**フィーチャー（機能）ベース**のディレクトリ構成を採用します。
`src/` 配下は以下の3層で構成されます:

```
src/
├── router/          # アプリケーションのルーティング
├── features/         # フィーチャー（機能）ごとのモジュール
│   ├── user/
│   ├── task/
│   └── notification/
└── shared/          # 全体で共有するコード
```

### 2. レイヤー間の依存ルール（循環インポート防止）

**最も重要なルール**: レイヤー間のインポート方向と、フィーチャー間の循環参照を厳密に制限します。

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

フィーチャー間のインポートは許可しますが、以下のルールを厳守してください:

1. **公開API（`index.ts`）経由のみ**: 他フィーチャーの内部ファイルへの直接インポートは禁止
2. **循環参照の禁止**: A→B かつ B→A のような双方向依存は禁止
3. **できる限り `shared/` を優先**: 複数フィーチャーで使う汎用的なコードは `shared/` に抽出する

> フィーチャー間の依存は必要最小限に留めてください。依存が増えてきた場合は、共通ロジックを `shared/` に抽出するか、フィーチャーの分割を見直すサインです。

### 3. 役割の明確化

各ディレクトリは単一の明確な役割を持つべきです。

**悪い例**:

```
src/
├── stuff/           # 曖昧
├── misc/            # 雑多
└── utils/           # 汎用的すぎる
```

**良い例**:

```
src/
├── router/          # ルーティングとページ構成
├── features/
│   └── task/        # タスク管理フィーチャーの全責務
└── shared/
    ├── ui/          # 共通UIコンポーネント
    ├── lib/         # 汎用ユーティリティ
    └── api/         # API通信基盤
```

## ディレクトリ構造の設計

### router/ ディレクトリ

アプリケーションのルーティング定義とページコンポーネントを配置します。

```
src/router/
├── index.ts             # ルーター設定のエントリポイント
├── routes.ts            # ルート定義
└── pages/               # ページコンポーネント
    ├── HomePage.tsx
    ├── TaskListPage.tsx
    └── UserProfilePage.tsx
```

**役割**:
- ルーティングの定義と管理
- ページレベルのコンポーネント配置
- レイアウトの定義

**依存関係**:
- `features/` のコンポーネント・関数をインポートしてページを組み立てる
- `shared/` のユーティリティ・UIコンポーネントを使用する

### features/ ディレクトリ

フィーチャー（機能）ごとにモジュールを分割します。各フィーチャーは独立して動作可能な単位です。

```
src/features/
├── task/
│   ├── index.ts              # 公開APIのエクスポート
│   ├── components/           # フィーチャー固有のUIコンポーネント
│   │   ├── TaskCard.tsx
│   │   ├── TaskCard.test.tsx  # TaskCard の単体テスト
│   │   ├── TaskForm.tsx
│   │   └── TaskForm.test.tsx
│   ├── hooks/                # フィーチャー固有のフック
│   │   ├── useTask.ts
│   │   └── useTask.test.ts
│   ├── services/             # ビジネスロジック
│   │   ├── TaskService.ts
│   │   ├── TaskService.test.ts
│   │   └── TaskService.integration.test.ts  # 統合テスト
│   ├── repositories/         # データアクセス
│   │   ├── TaskRepository.ts
│   │   ├── TaskRepository.test.ts
│   │   └── TaskRepository.integration.test.ts
│   ├── types/                # フィーチャー固有の型定義
│   │   └── Task.ts
│   └── validators/           # バリデーション
│       ├── TaskValidator.ts
│       └── TaskValidator.test.ts
├── user/
│   ├── index.ts
│   ├── components/
│   ├── hooks/
│   ├── services/
│   ├── repositories/
│   └── types/
└── notification/
    ├── index.ts
    └── ...
```

**役割**:
- 特定のフィーチャーに関するすべてのコード（UI、ロジック、データアクセス）を包含
- 各フィーチャーは `index.ts` を通じて公開APIを提供

**依存関係**:
- `shared/` からインポート可能
- 他の `features/` モジュールから公開API（`index.ts`）経由でインポート可能（循環参照は禁止）
- `router/` からのインポートは禁止

**フィーチャー内部の構造**:

各フィーチャーモジュールの内部は、必要に応じて以下のサブディレクトリを持ちます:

| サブディレクトリ | 役割 | 必須/任意 |
|------------------|------|-----------|
| `components/` | フィーチャー固有のUIコンポーネント | 任意 |
| `hooks/` | フィーチャー固有のカスタムフック | 任意 |
| `services/` | ビジネスロジック | 任意 |
| `repositories/` | データアクセス・永続化 | 任意 |
| `types/` | フィーチャー固有の型定義 | 任意 |
| `validators/` | 入力検証 | 任意 |
| `constants/` | フィーチャー固有の定数 | 任意 |

### shared/ ディレクトリ

複数のフィーチャーやルーターから共通利用されるコードを配置します。

```
src/shared/
├── ui/                  # 共通UIコンポーネント
│   ├── Button.tsx
│   ├── Modal.tsx
│   └── Input.tsx
├── lib/                 # 汎用ユーティリティ関数
│   ├── formatDate.ts
│   ├── validateEmail.ts
│   └── http-client.ts
├── api/                 # API通信基盤
│   └── client.ts
├── types/               # 共通型定義
│   └── common.ts
└── constants/           # 共通定数
    └── config.ts
```

**役割**:
- 複数レイヤー・フィーチャーで再利用されるコードの配置
- 自己完結した、外部に依存しないモジュール

**依存関係**:
- `router/` からのインポートは禁止
- `features/` からのインポートは禁止
- `shared/` 内部での相互参照のみ許可

**配置基準**:
- 2つ以上のフィーチャーで使われるコードのみ `shared/` に配置する
- 1つのフィーチャーでしか使われないコードは、そのフィーチャー内に置く

## 依存関係の管理

### インポートルールの具体例

```typescript
// ✅ 良い例: router/ から features/ をインポート
// src/router/pages/TaskListPage.tsx
import { TaskList } from "../../features/task";
import { Button } from "../../shared/ui/Button";

// ✅ 良い例: features/ から shared/ をインポート
// src/features/task/services/TaskService.ts
import { httpClient } from "../../../shared/lib/http-client";

// ✅ 良い例: features/ 間の公開API経由インポート（一方向）
// src/features/task/services/TaskService.ts
import { getUserById } from "../../user";  // index.ts 経由

// ❌ 悪い例: shared/ から features/ をインポート
// src/shared/lib/formatDate.ts
import { Task } from "../../features/task/types/Task"; // 禁止！

// ❌ 悪い例: features/ から router/ をインポート
// src/features/task/components/TaskCard.tsx
import { routes } from "../../../router/routes"; // 禁止！

// ❌ 悪い例: features/ の内部ファイルへの直接インポート（index.tsを経由していない）
// src/features/task/services/TaskService.ts
import { UserService } from "../../user/services/UserService"; // 禁止！内部実装に直接依存

// ❌ 悪い例: features/ 間の循環参照
// features/task/ → features/user/ を参照
// features/user/ → features/task/ を参照  // 双方向は禁止！
```

### フィーチャー間の依存管理

#### 推奨: 公開API経由の一方向インポート

```typescript
// ✅ features/task が features/user の公開APIを使う（一方向）
// src/features/task/services/TaskService.ts
import { getUserById } from "../../user";  // user/index.ts が公開するAPIのみ使用

export class TaskService {
  async assignTask(taskId: string, userId: string) {
    const user = await getUserById(userId);
    // ...
  }
}
```

#### 循環参照が発生しそうな場合の解決策

**解決策1: 共通の型・ロジックを `shared/` に抽出**

```typescript
// shared/types/common.ts
export interface UserId {
  id: string;
}

// features/task/services/TaskService.ts
import type { UserId } from "../../../shared/types/common";

// features/user/services/UserService.ts
import type { UserId } from "../../../shared/types/common";
```

**解決策2: router/ 層で組み合わせる**

```typescript
// router/pages/TaskAssignmentPage.tsx
import { TaskList } from "../../features/task";
import { UserSelector } from "../../features/user";

// router 層でフィーチャー間の連携を行う
export function TaskAssignmentPage() {
  const selectedUser = useUserSelector();
  return <TaskList assignee={selectedUser} />;
}
```

**解決策3: 依存の方向を整理する**

双方向依存が生じた場合、どちらが「依存する側」かを明確にし、一方向に統一します:

```typescript
// ✅ task → user の一方向のみ許可と決める
// features/task/ は features/user/ の公開APIを使える
// features/user/ は features/task/ を参照しない

// user 側で task の情報が必要な場合は、router/ 層で結合する
```

## テスト配置方針

すべてのテストはソースコードと同じディレクトリに配置します（コロケーション）。テストの種類はサフィックスで区別します。

### サフィックス規則

| テスト種別 | サフィックス | 例 |
|-----------|-------------|-----|
| 単体テスト | `.test.ts` / `.test.tsx` | `TaskService.test.ts`, `TaskCard.test.tsx` |
| 統合テスト | `.integration.test.ts` / `.integration.test.tsx` | `TaskService.integration.test.ts` |

> `.tsx` はReactコンポーネント（JSXを含む）テストで使用

### 単体テスト（`.test.ts`）

単体テストは、テスト対象ファイルと同じディレクトリに `[ファイル名].test.ts` として配置します。依存はモック化し、対象モジュールを単独でテストします。

```
src/features/task/
├── services/
│   ├── TaskService.ts          # 本番コード
│   └── TaskService.test.ts     # 単体テスト（モック使用）
├── components/
│   ├── TaskCard.tsx
│   └── TaskCard.test.tsx
└── validators/
    ├── TaskValidator.ts
    └── TaskValidator.test.ts

src/shared/
├── lib/
│   ├── formatDate.ts
│   └── formatDate.test.ts      # shared/ 内も同様
└── ui/
    ├── Button.tsx
    └── Button.test.tsx
```

### 統合テスト（`.integration.test.ts`）

統合テストも同じディレクトリに配置し、`.integration.test.ts` サフィックスで区別します。複数モジュールの結合（実DB接続、API呼び出しなど）をテストします。

```
src/features/task/
├── services/
│   ├── TaskService.ts
│   ├── TaskService.test.ts                # 単体テスト
│   └── TaskService.integration.test.ts    # 統合テスト（実Repository等と結合）
└── repositories/
    ├── TaskRepository.ts
    ├── TaskRepository.test.ts
    └── TaskRepository.integration.test.ts # 統合テスト（実DB接続）
```

**理由**:
- テスト対象ファイルとテストの対応が一目で分かる
- ファイル移動・リネーム時にテストも一緒に扱える
- フィーチャー単位での凝集度が高まる
- サフィックスでテスト種別を識別できるため、テストランナーのglobパターンで実行を分けられる
  - 単体テストのみ: `**/*.test.ts` かつ `!**/*.integration.test.ts`
  - 統合テストのみ: `**/*.integration.test.ts`

### E2Eテスト: `e2e/` ディレクトリに配置

`e2e/` ディレクトリはアプリケーション全体を通したE2E（End-to-End）テスト専用です。ユーザー操作シナリオに基づくテストを配置します。

```
project/
├── src/
│   ├── router/
│   ├── features/          # 単体テスト・統合テストは各フィーチャー内に同居
│   └── shared/            # 単体テスト・統合テストは各モジュール内に同居
└── e2e/                   # E2Eテスト専用
    ├── task-workflow.test.ts
    ├── user-registration.test.ts
    └── checkout-flow.test.ts
```

**理由**:
- E2Eテストは特定のフィーチャーに属さず、複数フィーチャーを横断する
- ユーザーシナリオ単位で整理するため、フィーチャー構造とは独立
- `e2e/` という名前で、このディレクトリの用途が明確

## 命名規則のベストプラクティス

### ディレクトリ名の原則

**1. kebab-caseを使う**

```
✅ task-management/
✅ user-authentication/

❌ TaskManagement/
❌ userAuthentication/
```

理由: URL、ファイルシステムとの互換性

**2. フィーチャーディレクトリは単数形を使う**

```
✅ features/task/
✅ features/user/
✅ features/notification/

❌ features/tasks/
❌ features/users/
```

理由: フィーチャー名は概念としての単数形が適切

**3. shared/ 内は役割ベースで命名する**

```
✅ shared/ui/          # UIコンポーネント
✅ shared/lib/         # ライブラリ・ユーティリティ
✅ shared/api/         # API通信

❌ shared/utils/       # 汎用的すぎる
❌ shared/helpers/     # 曖昧
❌ shared/common/      # 意味不明
```

### ファイル名の原則

**1. コンポーネントファイル: PascalCase**

```
TaskCard.tsx
UserProfile.tsx
Button.tsx
```

**2. 関数ファイル: camelCase + 動詞で始める**

```
formatDate.ts
validateEmail.ts
parseCommandArguments.ts
```

**3. 型定義ファイル: PascalCase**

```
Task.ts
UserProfile.ts
```

**4. 定数ファイル: kebab-case**

```
api-endpoints.ts
error-messages.ts
config.ts
```

**5. フィーチャーのエントリポイント: index.ts**

```
features/task/index.ts      # 公開APIをエクスポート
features/user/index.ts
```

## スケーリング戦略

### フィーチャーの追加

新しい機能を追加する際は、まず既存フィーチャーに属するか新規フィーチャーとして切り出すかを判断します。

**新規フィーチャーを作成する基準**:
1. 既存フィーチャーと責務が明確に異なる
2. 独立してテスト可能
3. 他のフィーチャーへの依存なしで定義できる

**追加手順**:

```
# 1. フィーチャーディレクトリを作成
src/features/new-feature/
├── index.ts
├── components/
├── services/
└── types/

# 2. router/ にページを追加
src/router/pages/NewFeaturePage.tsx

# 3. 共通コードがあれば shared/ に追加
src/shared/types/new-common-type.ts
```

### フィーチャー内の分割

フィーチャーが大きくなった場合、サブフィーチャーに分割します:

```
# Before: 肥大化したフィーチャー
src/features/task/
├── components/     # 20ファイル以上...
├── services/       # 10ファイル以上...
└── ...

# After: サブフィーチャーに分割
src/features/task/
├── index.ts                # 公開APIの集約
├── core/                   # タスクの基本CRUD
│   ├── components/
│   └── services/
├── assignment/             # タスクの割り当て
│   ├── components/
│   └── services/
└── analytics/              # タスクの分析
    ├── components/
    └── services/
```

### ファイルサイズの管理

**ファイル分割の目安**:

- 1ファイル: 500行以下を推奨
- 500-800行: リファクタリングを検討
- 800行以上: 分割を強く推奨

## 特殊なケースの対応

### 設定ファイルの管理（該当する場合）

```
config/
├── default.ts           # デフォルト設定
└── constants.ts         # 定数定義
```

### スクリプトの管理（該当する場合）

```
scripts/
├── build.sh             # ビルドスクリプト
└── dev-tools.ts         # 開発補助スクリプト
```

## ドキュメント配置

### ドキュメントの種類と配置先

**プロジェクトルート**:

- `README.md`: プロジェクト概要
- `CONTRIBUTING.md`: 貢献ガイド
- `LICENSE`: ライセンス

**docs/ ディレクトリ**:

- `product-requirements.md`: PRD
- `functional-design.md`: 機能設計書
- `architecture.md`: アーキテクチャ設計書
- `repository-structure.md`: 本ドキュメント
- `development-guidelines.md`: 開発ガイドライン
- `glossary.md`: 用語集

**ソースコード内**:

- TSDoc/JSDocコメント: 関数・クラスの説明

## チェックリスト

- [ ] `src/` 直下が `router/`, `features/`, `shared/` の3層で構成されている
- [ ] `router/` → `features/`, `shared/` の方向のみインポートしている
- [ ] `features/` → `shared/` および他の `features/`（公開API経由）のみインポートしている
- [ ] `features/` 間のインポートが `index.ts` 経由であり、内部ファイルへの直接参照がない
- [ ] `features/` 間に循環参照がない（A→BかつB→Aがない）
- [ ] `shared/` は `router/`, `features/` からインポートしていない
- [ ] 各フィーチャーが `index.ts` で公開APIを定義している
- [ ] 命名規則が一貫している
- [ ] テストコードの配置方針が決まっている
- [ ] 共有コードの配置基準（2つ以上のフィーチャーで使用）が守られている
- [ ] スケーリング戦略が考慮されている
