# リポジトリ構造定義書 (Repository Structure Document)

> 作成日: 2026-03-08
> 対象フェーズ: MVP（ノードベースフローエディタ + 従来型画像処理ノード群）
> 対応アーキテクチャ: docs/architecture.md

---

## プロジェクト構造

```
visualinspect/
├── src-tauri/                 # Rust バックエンド（Tauri）
│   ├── src/
│   │   ├── main.rs            # エントリポイント
│   │   ├── commands/          # Tauri Commands（IPC API）
│   │   ├── db/                # SQLite アクセス層
│   │   ├── services/          # バックエンドサービス（バックアップ等）
│   │   └── ffi/               # C++ FFI バインディング
│   ├── Cargo.toml
│   └── tauri.conf.json
├── src-cpp/                   # C++ 画像処理エンジン
│   ├── include/               # ヘッダファイル
│   │   └── processors/        # プロセッサ定義ヘッダ
│   ├── src/
│   │   ├── engine/            # フロー実行エンジン
│   │   └── processors/        # 各画像処理プロセッサの実装
│   ├── tests/                 # C++ 単体テスト（Google Test）
│   └── CMakeLists.txt
├── src/                       # フロントエンド（React + TypeScript）
│   ├── app/                   # アプリ初期化・ルーティング
│   ├── features/              # フィーチャーモジュール
│   │   ├── flow-editor/       # フローエディタ（FN-001〜004, FN-006）
│   │   └── project/           # プロジェクト管理（FN-005）
│   └── shared/                # 共有コード
│       ├── ui/                # 共通UIコンポーネント
│       ├── lib/               # ユーティリティ関数
│       ├── ipc/               # Tauri IPC クライアント（Commands呼び出し）
│       ├── stores/            # 共通 Zustand ストア
│       ├── queries/           # 共通 TanStack Query 定義
│       ├── types/             # 共通型定義（グラフモデル・プロセッサ定義）
│       └── constants/         # 共通定数
├── e2e/                       # E2E テスト（Playwright）
├── docs/                      # プロジェクトドキュメント
├── scripts/                   # ビルド・開発補助スクリプト
├── .claude/                   # Claude Code 設定
├── .issue/                    # issue固有ドキュメント
├── package.json
├── vite.config.ts
├── tsconfig.json
└── CLAUDE.md
```

---

## 依存ルール

### レイヤー間のインポート制約（フロントエンド）

```
app/  →  features/  →  shared/
  │            │
  │            ├── shared/ からインポート可能
  │            └── 他の features/ から公開API経由でインポート可能（※循環禁止）
  │
  └── features/, shared/ の両方からインポート可能

shared/ → app/, features/ のいずれからもインポート不可
```

| レイヤー | インポート可能な対象 | インポート禁止の対象 |
|---|---|---|
| `app/` | `features/`, `shared/` | なし |
| `features/` | `shared/`, 他の `features/`（公開API経由・循環禁止） | `app/` |
| `shared/` | なし（自己完結） | `app/`, `features/` |

#### features/ 間のインポートルール

- **公開API（`index.ts`）経由のみ**: 他フィーチャーの内部ファイルへの直接インポートは禁止
- **循環参照の禁止**: A→B かつ B→A のような双方向依存は禁止
- **最小限の依存**: 複数フィーチャーで使う汎用コードはできる限り `shared/` に抽出する

### クロス言語の依存ルール

| 呼び出し元 | 呼び出し先 | 方法 |
|---|---|---|
| フロントエンド (TypeScript) | バックエンド (Rust) | Tauri Commands（IPC） |
| バックエンド (Rust) | 画像処理エンジン (C++) | FFI |
| フロントエンド (TypeScript) | 画像処理エンジン (C++) | 直接呼び出し禁止。必ずRust経由 |

---

## ディレクトリ詳細

### src-tauri/ (Rust バックエンド)

**役割**: Tauriアプリケーションのバックエンド。SQLiteアクセス、ファイルI/O、C++ FFI呼び出しを担う。

**構造**:

```
src-tauri/src/
├── main.rs                    # Tauri アプリ初期化
├── commands/                  # Tauri Commands（フロントエンドからのIPC API）
│   ├── mod.rs
│   ├── project_commands.rs    # プロジェクトCRUD
│   ├── flow_commands.rs       # フロー保存・読み込み
│   ├── execution_commands.rs  # フロー実行制御
│   └── export_commands.rs     # エクスポート/インポート
├── db/                        # SQLite アクセス層
│   ├── mod.rs
│   ├── connection.rs          # DB接続管理
│   ├── migrations/            # マイグレーションファイル
│   └── repositories/          # テーブルごとのCRUD
│       ├── project_repo.rs
│       ├── node_repo.rs
│       ├── connection_repo.rs
│       └── parameter_repo.rs
├── services/                  # バックエンドサービス
│   ├── backup_service.rs      # 自動バックアップ
│   └── export_service.rs      # エクスポート/インポート処理
└── ffi/                       # C++ FFI バインディング
    ├── mod.rs
    └── engine_bridge.rs       # 画像処理エンジンとのブリッジ
```

**命名規則**: snake_case（Rust標準）

---

### src-cpp/ (C++ 画像処理エンジン)

**役割**: OpenCVを使用した画像処理アルゴリズムの実行。プロセッサごとに処理関数を実装。

**構造**:

```
src-cpp/
├── include/
│   ├── engine.h               # フロー実行エンジンAPI
│   └── processors/            # プロセッサヘッダ
│       ├── processor_base.h   # プロセッサ基底クラス
│       ├── input.h            # 入力系プロセッサ
│       ├── preprocessing.h    # 前処理系プロセッサ
│       ├── filtering.h        # フィルタリング系
│       ├── binarization.h     # 二値化系
│       ├── edge_detection.h   # エッジ検出系
│       ├── morphology.h       # 形状処理系
│       ├── matching.h         # マッチング系
│       └── judgment.h         # 判定系
├── src/
│   ├── engine/
│   │   ├── flow_executor.cpp  # フロー実行エンジン
│   │   └── processor_registry.cpp # プロセッサレジストリ（typeIdディスパッチ）
│   └── processors/
│       ├── input/
│       │   ├── camera_input.cpp
│       │   └── image_file_input.cpp
│       ├── preprocessing/
│       │   ├── grayscale.cpp
│       │   ├── resize.cpp
│       │   ├── rotate_flip.cpp
│       │   ├── crop.cpp
│       │   └── normalize.cpp
│       ├── filtering/
│       │   ├── gaussian_blur.cpp
│       │   ├── median_filter.cpp
│       │   └── sharpness.cpp
│       ├── binarization/
│       │   ├── otsu.cpp
│       │   ├── adaptive.cpp
│       │   └── threshold.cpp
│       ├── edge_detection/
│       │   ├── canny.cpp
│       │   ├── sobel.cpp
│       │   └── laplacian.cpp
│       ├── morphology/
│       │   ├── dilate.cpp
│       │   ├── erode.cpp
│       │   ├── opening.cpp
│       │   ├── closing.cpp
│       │   └── contour_detection.cpp
│       ├── matching/
│       │   └── template_matching.cpp
│       └── judgment/
│           ├── threshold_judge.cpp
│           ├── area_judge.cpp
│           └── count_judge.cpp
├── tests/                     # Google Test
│   ├── test_flow_executor.cpp
│   └── processors/
│       ├── test_gaussian_blur.cpp
│       └── ...
└── CMakeLists.txt
```

**命名規則**: snake_case（C++標準）

---

### src/ (フロントエンド)

**役割**: React + TypeScriptによるUI。フローエディタとプロジェクト管理の2つのフィーチャーモジュールで構成。

#### src/app/ (アプリ初期化)

```
src/app/
├── App.tsx                    # ルートコンポーネント
├── routes.tsx                 # ルーティング定義
├── providers.tsx              # プロバイダー集約（QueryClient, etc.）
└── pages/
    ├── StartPage.tsx          # SCR-001: スタート画面
    └── EditorPage.tsx         # SCR-002: メインエディタ画面
```

#### src/features/ (フィーチャーモジュール)

フィーチャーはアプリケーションのドメイン単位で分割する。機能設計書のFN-001〜004・FN-006はすべてフローエディタという単一ドメインに属するため、`flow-editor` フィーチャーに統合する。FN-005（プロジェクト管理）は独立したドメイン・別画面（SCR-001）を持つため分離を維持する。

```
src/features/flow-editor/              # FN-001〜004, FN-006: フローエディタ
├── index.ts                           # 公開API
├── components/
│   ├── FlowCanvas.tsx                 # React Flowキャンバス
│   ├── FlowCanvas.test.tsx
│   ├── CustomNode.tsx                 # カスタムノードコンポーネント
│   ├── CustomEdge.tsx                 # カスタムエッジコンポーネント
│   ├── FlowToolbar.tsx               # ツールバー（実行・保存等）
│   ├── NodeLibraryPanel.tsx           # ノードライブラリパネル
│   ├── NodeCategoryList.tsx           # カテゴリ別ノード一覧
│   ├── NodeSearchBar.tsx              # ノード検索バー
│   ├── PropertyPanel.tsx              # プロパティパネル
│   ├── ParameterForm.tsx              # パラメータ編集フォーム
│   ├── PreviewImage.tsx               # プレビュー画像表示
│   └── ExecutionStatus.tsx            # 実行状態表示
├── hooks/
│   ├── useFlowEditor.ts              # フロー編集操作フック
│   ├── useUndoRedo.ts                # Undo/Redoフック
│   ├── useNodeSearch.ts              # ノード検索フック
│   ├── useParameterEdit.ts           # パラメータ編集フック
│   └── useFlowExecution.ts           # フロー実行フック
├── services/
│   ├── ExecutionService.ts            # フロー実行サービス
│   ├── ValidationService.ts           # フローバリデーションサービス
│   └── ValidationService.test.ts
├── stores/
│   └── flowEditorStore.ts            # 編集状態Zustandストア
└── types/
    ├── FlowEditorTypes.ts
    └── ValidationTypes.ts
```

```
src/features/project/                  # FN-005: プロジェクト管理
├── index.ts
├── components/
│   ├── ProjectList.tsx
│   ├── ProjectCreateDialog.tsx
│   └── SaveConfirmDialog.tsx
├── hooks/
│   └── useProject.ts
└── queries/
    └── projectQueries.ts             # TanStack Query定義
```

#### src/shared/ (共有コード)

```
src/shared/
├── ui/                                # 共通UIコンポーネント
│   ├── Button.tsx
│   ├── Modal.tsx
│   ├── Tooltip.tsx
│   └── Panel.tsx
├── lib/                               # ユーティリティ関数
│   ├── uuid.ts
│   └── dateFormat.ts
├── ipc/                               # Tauri IPC クライアント
│   ├── client.ts                      # Tauri invoke ラッパー
│   ├── projectCommands.ts             # プロジェクト関連コマンド
│   ├── flowCommands.ts                # フロー関連コマンド
│   └── executionCommands.ts           # 実行関連コマンド
├── stores/                            # 共通 Zustand ストア
│   └── uiStore.ts                     # UI状態（モーダル開閉等）
├── queries/                           # 共通 TanStack Query 定義
│   └── queryClient.ts                 # QueryClient設定
├── types/                             # 共通型定義
│   ├── graph.ts                       # グラフモデル層の型（Node, Connection, Flow等）
│   ├── processor.ts                   # プロセッサ定義層の型（ProcessorDefinition等）
│   └── common.ts                      # 汎用型
└── constants/                         # 共通定数
    └── processorRegistry.ts           # プロセッサ定義レジストリ（フロントエンド側）
```

---

### e2e/ (E2Eテスト)

**役割**: Playwrightによるアプリケーション全体のシナリオテスト。

```
e2e/
├── flow-construction.test.ts          # フロー構築シナリオ
├── parameter-adjustment.test.ts       # パラメータ調整・プレビュー
├── flow-execution.test.ts             # フロー実行・結果確認
├── project-management.test.ts         # プロジェクト保存・読み込み
└── project-export-import.test.ts      # エクスポート・インポート
```

**命名規則**: `[シナリオ名].test.ts`（kebab-case）

---

### docs/ (ドキュメント)

```
docs/
├── ideas/                             # アイデアメモ・技術調査
│   └── 20260307-factory-image-inspection-memo.md
├── product-requirements.md            # プロダクト要求定義書
├── functional-design.md               # 機能設計書
├── data-model.md                      # データモデル設計書
├── architecture.md                    # アーキテクチャ設計書
├── repository-structure.md            # リポジトリ構造定義書（本ドキュメント）
├── development-guidelines.md          # 開発ガイドライン
└── glossary.md                        # 用語集
```

---

## ファイル配置規則

### ソースファイル

| ファイル種別 | 配置先 | 命名規則 | 例 |
|---|---|---|---|
| ページコンポーネント | `src/app/pages/` | PascalCase + `Page` | `EditorPage.tsx` |
| フィーチャーコンポーネント | `src/features/[name]/components/` | PascalCase | `FlowCanvas.tsx` |
| 共通UIコンポーネント | `src/shared/ui/` | PascalCase | `Button.tsx` |
| カスタムフック | `src/features/[name]/hooks/` | camelCase, `use`接頭辞 | `useFlowEditor.ts` |
| サービス | `src/features/[name]/services/` | PascalCase + `Service` | `ValidationService.ts` |
| Zustandストア | `src/features/[name]/stores/` | camelCase + `Store` | `flowEditorStore.ts` |
| TanStack Query定義 | `src/features/[name]/queries/` | camelCase + `Queries` | `projectQueries.ts` |
| IPC クライアント | `src/shared/ipc/` | camelCase + `Commands` | `projectCommands.ts` |
| 型定義 | `src/shared/types/` or `src/features/[name]/types/` | camelCase | `graph.ts` |
| Tauri Command | `src-tauri/src/commands/` | snake_case + `_commands` | `project_commands.rs` |
| DBリポジトリ | `src-tauri/src/db/repositories/` | snake_case + `_repo` | `project_repo.rs` |
| C++プロセッサ | `src-cpp/src/processors/[category]/` | snake_case | `gaussian_blur.cpp` |

### テストファイル

| テスト種別 | 配置先 | 命名規則 | 例 |
|---|---|---|---|
| フロントエンド単体テスト | テスト対象と同じディレクトリ | `[対象].test.ts(x)` | `FlowCanvas.test.tsx` |
| フロントエンド統合テスト | テスト対象と同じディレクトリ | `[対象].integration.test.ts` | `ExecutionService.integration.test.ts` |
| C++単体テスト | `src-cpp/tests/` | `test_[対象].cpp` | `test_gaussian_blur.cpp` |
| E2Eテスト | `e2e/` | `[シナリオ].test.ts` | `flow-construction.test.ts` |

---

## 命名規則

### ディレクトリ名

- **フロントエンド**: kebab-case（例: `flow-editor/`, `project/`）
- **Rust**: snake_case（Rust標準。例: `commands/`, `repositories/`）
- **C++**: snake_case（例: `processors/`, `edge_detection/`）

### ファイル名

| 言語 | 種別 | 規則 | 例 |
|---|---|---|---|
| TypeScript | コンポーネント | PascalCase | `FlowCanvas.tsx` |
| TypeScript | フック | camelCase, `use`接頭辞 | `useFlowEditor.ts` |
| TypeScript | ストア | camelCase + `Store` | `flowEditorStore.ts` |
| TypeScript | ユーティリティ | camelCase | `dateFormat.ts` |
| TypeScript | エントリポイント | `index.ts` | `index.ts` |
| Rust | すべて | snake_case | `project_commands.rs` |
| C++ | すべて | snake_case | `gaussian_blur.cpp` |

---

## スケーリング戦略

### 新しいプロセッサ（ノード種別）の追加

1. `src-cpp/src/processors/[category]/` に処理実装を追加
2. `src-cpp/include/processors/` にヘッダを追加
3. `src-cpp/src/engine/processor_registry.cpp` にtypeIdマッピングを登録
4. `src/shared/constants/processorRegistry.ts` にフロントエンド側定義を追加
5. `src-cpp/tests/` にテストを追加

グラフモデル層、フロントエンドのフィーチャーモジュールの変更は不要。

### 新しいフロントエンドフィーチャーの追加

1. `src/features/[feature-name]/` にディレクトリを作成
2. `index.ts` で公開APIを定義
3. 必要に応じて `components/`, `hooks/`, `stores/`, `queries/` を配置

### フィーチャーの肥大化への対応

フィーチャー内のファイル数が多くなった場合、サブフィーチャーに分割:

```
src/features/flow-editor/
├── index.ts                   # 公開APIの集約
├── canvas/                    # キャンバス操作（FlowCanvas, CustomNode, CustomEdge等）
├── node-library/              # ノードライブラリパネル
├── property-panel/            # プロパティパネル・プレビュー
├── execution/                 # フロー実行制御
└── validation/                # フローバリデーション
```

### ファイルサイズの管理

- 1ファイル: 500行以下を推奨
- 500-800行: リファクタリングを検討
- 800行以上: 分割を強く推奨

---

## 特殊ディレクトリ

### .issue/ (issue固有ドキュメント)

**役割**: 各issueのライフサイクル全体に関わるドキュメントを保持

```
.issue/
└── {issue番号}/
    ├── （実装前）変更仕様書、影響範囲分析
    ├── （実装中）作業リスト（タスク分解・進捗管理）
    └── （実装後）レビュー結果、品質検証ドキュメント
```

### .claude/ (Claude Code設定)

**役割**: Claude Code設定とカスタマイズ

```
.claude/
├── commands/
├── skills/
└── agents/
```

---

## 除外設定

### .gitignore

- `node_modules/`
- `dist/`
- `target/` （Rust ビルド出力）
- `build/` （C++ ビルド出力）
- `.env`
- `.issue/`
- `*.log`
- `.DS_Store`
- `*.db` （SQLiteデータベース）
- `backups/`

### .prettierignore, .eslintignore

- `dist/`
- `node_modules/`
- `.issue/`
- `coverage/`
- `src-tauri/`
- `src-cpp/`
