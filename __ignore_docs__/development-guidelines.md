# 開発ガイドライン (Development Guidelines)

> 作成日: 2026-03-08
> 対応アーキテクチャ: docs/architecture.md
> 対応リポジトリ構造: docs/repository-structure.md

---

## コーディング規約

### 命名規則

#### TypeScript

**変数・関数**:
```typescript
// 変数: camelCase、名詞または名詞句
const selectedNode = getNodeById(nodeId);
const connectionList = flow.connections;

// 関数: camelCase、動詞で始める
function calculateFlowExecutionOrder(flow: Flow): Node[] { }
function validateConnection(source: Port, target: Port): boolean { }

// 定数: UPPER_SNAKE_CASE
const MAX_UNDO_STEPS = 20;
const DEFAULT_CANVAS_ZOOM = 1.0;

// Boolean: is, has, should, can で始める
const isExecuting = false;
const hasUnsavedChanges = true;
const canConnect = checkPortCompatibility(sourcePort, targetPort);
```

**コンポーネント・型**:
```typescript
// コンポーネント: PascalCase
function FlowCanvas({ flow }: FlowCanvasProps) { }
function NodeLibraryPanel() { }

// 型・インターフェース: PascalCase
interface FlowEditorState { }
type PortDataType = 'image' | 'number' | 'boolean' | 'judgmentResult';

// Props型: コンポーネント名 + Props
interface FlowCanvasProps { }
interface PropertyPanelProps { }
```

**フック**:
```typescript
// use + 動詞/名詞
function useFlowEditor() { }
function useUndoRedo() { }
function useNodeSearch(query: string) { }
```

**ストア**:
```typescript
// camelCase + Store
const flowEditorStore = create<FlowEditorState>(() => ({ }));
const uiStore = create<UIState>(() => ({ }));
```

#### Rust

```rust
// 変数・関数: snake_case
fn save_project(project: &Project) -> Result<(), DbError> { }
let flow_definition = load_flow(project_id)?;

// 構造体・列挙型: PascalCase
struct ProjectData { }
enum ExecutionStatus { Running, Completed, Error }

// 定数: UPPER_SNAKE_CASE
const MAX_PROJECTS: usize = 50;

// モジュール: snake_case
mod project_commands;
mod flow_commands;
```

#### C++

```cpp
// 関数: snake_case
void execute_flow(const FlowDefinition& flow);
cv::Mat apply_gaussian_blur(const cv::Mat& input, int kernel_size);

// クラス: PascalCase
class ProcessorBase { };
class GaussianBlurProcessor : public ProcessorBase { };

// メンバ変数: snake_case + 末尾アンダースコア
class ProcessorBase {
  std::string type_id_;
  std::vector<PortDefinition> input_ports_;
};

// 定数・マクロ: UPPER_SNAKE_CASE
constexpr int DEFAULT_KERNEL_SIZE = 3;
```

### コードフォーマット

**TypeScript**:
- インデント: 2スペース
- 行の長さ: 最大100文字
- セミコロン: あり
- クォート: シングルクォート
- 末尾カンマ: あり
- ツール: Prettier（設定は `.prettierrc` で管理）

**Rust**:
- `rustfmt` のデフォルト設定に従う

**C++**:
- インデント: 2スペース
- ツール: `clang-format`（設定は `.clang-format` で管理）

### コメント規約

**原則**: コードを見れば分かる「何をしているか」ではなく、「なぜそうしているか」を書く。

```typescript
// ✅ 良い例: 理由や背景を説明
// React Flowは内部でノードIDを文字列として扱うため、UUIDを文字列で保持する
const nodeId: string = generateUUID();

// OpenCVのデフォルトカーネルサイズは奇数である必要がある
const kernelSize = ensureOdd(userInput);

// ❌ 悪い例: コードの内容をそのまま繰り返す
// ノードIDを生成する
const nodeId: string = generateUUID();
```

**TSDoc（公開API・サービス・複雑なロジック）**:
```typescript
/**
 * フロー定義のバリデーションを実行する
 *
 * @param flow - 検証対象のフロー定義
 * @returns バリデーションエラーの配列。エラーがなければ空配列
 */
function validateFlow(flow: Flow): ValidationError[] { }
```

**不要なコメントは書かない**:
- 自明な型定義へのコメント
- ファイルヘッダーのボイラープレート
- 変更履歴（Gitで管理する）

### エラーハンドリング

#### フロントエンド（TypeScript）

**原則**:
- UI境界でエラーをキャッチし、ユーザーに適切なフィードバックを返す
- ビジネスロジック層では型安全なエラーを使用する
- エラーを握りつぶさない

```typescript
// ドメイン固有のエラー型を定義
class FlowValidationError extends Error {
  constructor(
    message: string,
    public readonly nodeId: string,
    public readonly errorType: 'connection' | 'parameter' | 'cycle'
  ) {
    super(message);
    this.name = 'FlowValidationError';
  }
}

// IPC呼び出しのエラーハンドリング
async function saveProject(project: Project): Promise<void> {
  try {
    await invoke('save_project', { project });
  } catch (error) {
    if (error instanceof Error) {
      console.error(`プロジェクト保存エラー: ${error.message}`);
    }
    throw error; // 呼び出し元でUIフィードバックを処理
  }
}
```

#### バックエンド（Rust）

```rust
// Result型を一貫して使用
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AppError {
    #[error("プロジェクトが見つかりません: {0}")]
    ProjectNotFound(String),
    #[error("データベースエラー: {0}")]
    DatabaseError(#[from] rusqlite::Error),
    #[error("画像処理エラー: {0}")]
    ProcessingError(String),
}

// Tauri Commandsでは Result<T, String> で返す
#[tauri::command]
fn save_project(project: ProjectData) -> Result<(), String> {
    do_save(project).map_err(|e| e.to_string())
}
```

#### C++

```cpp
// 例外を使用せず、戻り値でエラーを返す（FFI境界の安全性）
struct ProcessorResult {
  bool success;
  cv::Mat output;
  std::string error_message;
};

ProcessorResult apply_processor(const cv::Mat& input, const std::string& type_id) {
  if (input.empty()) {
    return { false, cv::Mat(), "入力画像が空です" };
  }
  // 処理...
}
```

### 型定義

**TypeScript の原則**:
- `any` の使用は原則禁止。やむを得ない場合は `unknown` を使用し、型ガードで絞り込む
- 共有型は `src/shared/types/` に配置
- フィーチャー固有の型は `src/features/[name]/types/` に配置

```typescript
// ✅ 良い例: 判別可能なユニオン型
type PortDataType = 'image' | 'number' | 'boolean' | 'judgmentResult';

interface Port {
  id: string;
  dataType: PortDataType;
  direction: 'input' | 'output';
}

// ❌ 悪い例
interface Port {
  id: string;
  dataType: string;  // 型安全でない
  direction: string;
}
```

---

## Git運用ルール

### ブランチ戦略

**ブランチ種別**:
- `main`: リリース可能な状態を常に維持
- `feature/{issue番号}-{簡潔な説明}`: 新機能開発
- `fix/{issue番号}-{簡潔な説明}`: バグ修正
- `refactor/{対象}`: リファクタリング
- `docs/{対象}`: ドキュメント変更

**フロー**:
```
main
  ├─ feature/12-flow-editor-canvas
  ├─ feature/15-node-library-panel
  ├─ fix/18-connection-validation
  └─ docs/update-architecture
```

**ルール**:
- `main` への直接コミットは禁止。PRを経由する
- ブランチはissue単位で作成する
- マージ後のブランチは削除する

### コミットメッセージ規約

**フォーマット（Conventional Commits）**:
```
<type>(<scope>): <subject>

<body>
```

**Type**:
| type | 用途 |
|---|---|
| `feat` | 新機能の追加 |
| `fix` | バグ修正 |
| `docs` | ドキュメントの変更 |
| `style` | コードフォーマット（動作に影響しない変更） |
| `refactor` | リファクタリング（機能追加もバグ修正もしない変更） |
| `test` | テストの追加・修正 |
| `chore` | ビルド設定、依存関係の更新等 |

**Scope（任意）**: 変更対象を示す。
- `frontend`, `backend`, `cpp`, `flow-editor`, `project`, `ipc`, `db` 等

**例**:
```
feat(flow-editor): ノード間の接続バリデーションを実装

ポートのデータ型チェックと循環検出を追加。
- PortDataTypeの一致チェック
- 深さ優先探索による循環検出
- エラー時のビジュアルフィードバック

Closes #24
```

```
fix(backend): プロジェクト保存時のトランザクション不整合を修正

ノードとパラメータの保存を単一トランザクションで実行するように変更。

Closes #31
```

### プルリクエストプロセス

**作成前のチェック**:
- [ ] 全てのテストがパス
- [ ] Lintエラーがない（`eslint`, `clippy`）
- [ ] 型チェックがパス（`tsc --noEmit`, `cargo check`）
- [ ] フォーマットが適用済み（`prettier`, `rustfmt`, `clang-format`）
- [ ] 競合が解決されている

**PRテンプレート**:
```markdown
## 概要
[変更内容の簡潔な説明]

## 変更理由
[なぜこの変更が必要か、対応するissue番号]

## 変更内容
- [変更点1]
- [変更点2]

## テスト
- [ ] ユニットテスト追加/更新
- [ ] 手動テスト実施

## スクリーンショット（UI変更の場合）
[画像]

## 関連Issue
Closes #[Issue番号]
```

**レビュープロセス**:
1. セルフレビュー（diff を確認し、不要な変更がないか確認）
2. CI（自動テスト・Lint）がパス
3. レビュアーによるレビュー
4. フィードバック対応
5. 承認後にSquash Mergeで `main` にマージ

---

## テスト戦略

### テストの種類とカバレッジ目標

| テスト種別 | フレームワーク | 対象 | カバレッジ目標 |
|---|---|---|---|
| フロントエンド単体テスト | Vitest | ストア、サービス、バリデーション、フック | 80%以上（UIコンポーネントを除くロジック部分） |
| C++単体テスト | Google Test | 各画像処理プロセッサ | 各プロセッサの正常系・異常系を網羅 |
| 統合テスト | Vitest | IPC経由のフロントエンド⇔バックエンド連携 | 主要CRUDパスを網羅 |
| E2Eテスト | Playwright | ユーザーシナリオ全体 | 主要ユーザーフローを網羅 |

### フロントエンド単体テスト

```typescript
describe('flowEditorStore', () => {
  describe('addNode', () => {
    it('ノードをフローに追加し、Undo履歴に記録する', () => {
      const store = createFlowEditorStore();
      const node = createTestNode('gaussianBlur');

      store.getState().addNode(node);

      expect(store.getState().flow.nodes).toHaveLength(1);
      expect(store.getState().canUndo).toBe(true);
    });
  });

  describe('addConnection', () => {
    it('ポートの型が一致しない場合、接続を拒否する', () => {
      const store = createFlowEditorStore();
      const imagePort = createTestPort('output', 'image');
      const numberPort = createTestPort('input', 'number');

      const result = store.getState().addConnection(imagePort, numberPort);

      expect(result.success).toBe(false);
      expect(result.error?.errorType).toBe('connection');
    });
  });
});
```

```typescript
describe('ValidationService', () => {
  it('循環する接続を検出する', () => {
    const flow = createFlowWithCycle();

    const errors = ValidationService.validate(flow);

    expect(errors).toContainEqual(
      expect.objectContaining({ errorType: 'cycle' })
    );
  });

  it('未接続の必須入力ポートを検出する', () => {
    const flow = createFlowWithDisconnectedPort();

    const errors = ValidationService.validate(flow);

    expect(errors).toContainEqual(
      expect.objectContaining({ errorType: 'disconnected' })
    );
  });
});
```

### C++単体テスト

```cpp
TEST(GaussianBlurProcessorTest, AppliesBlurWithValidInput) {
  cv::Mat input = cv::imread("test_data/sample.png");
  GaussianBlurProcessor processor;
  processor.set_parameter("kernelSize", 5);

  auto result = processor.execute(input);

  ASSERT_TRUE(result.success);
  ASSERT_EQ(result.output.size(), input.size());
}

TEST(GaussianBlurProcessorTest, ReturnsErrorForEmptyInput) {
  cv::Mat empty;
  GaussianBlurProcessor processor;

  auto result = processor.execute(empty);

  ASSERT_FALSE(result.success);
  ASSERT_FALSE(result.error_message.empty());
}
```

### E2Eテスト

```typescript
test('フロー構築から実行まで', async ({ page }) => {
  // プロジェクト作成
  await page.click('[data-testid="new-project-button"]');

  // ノードライブラリから入力ノードをドラッグ&ドロップ
  await page.dragAndDrop(
    '[data-testid="node-imageFileInput"]',
    '[data-testid="flow-canvas"]'
  );

  // ノードを接続
  await page.dragAndDrop(
    '[data-testid="port-output-0"]',
    '[data-testid="port-input-1"]'
  );

  // フロー実行
  await page.click('[data-testid="execute-button"]');
  await expect(page.locator('[data-testid="execution-status"]'))
    .toHaveText('完了');
});
```

### テスト命名規則

**フロントエンド**: 日本語で「何が起きるか」を記述する。
```typescript
it('ノードをフローに追加し、Undo履歴に記録する', () => { });
it('ポートの型が一致しない場合、接続を拒否する', () => { });
```

**C++**: `テスト対象_条件_期待結果` のパターン。
```cpp
TEST(GaussianBlurProcessorTest, AppliesBlurWithValidInput) { }
TEST(GaussianBlurProcessorTest, ReturnsErrorForEmptyInput) { }
TEST(FlowExecutorTest, ExecutesNodesInTopologicalOrder) { }
```

### モック・スタブの使用

**原則**:
- Tauri IPC呼び出しはモック化する
- Zustandストアはテスト用インスタンスを作成する
- 画像ファイルはテスト用の小さな画像を使用する

```typescript
// Tauri invokeのモック
vi.mock('@tauri-apps/api/core', () => ({
  invoke: vi.fn(),
}));

// Zustandストアのテスト用インスタンス
function createTestStore(initialState?: Partial<FlowEditorState>) {
  return createStore<FlowEditorState>()((set) => ({
    ...defaultState,
    ...initialState,
  }));
}
```

---

## コードレビュー基準

### レビューポイント

**機能性**:
- [ ] 要件（issue仕様書）を満たしているか
- [ ] エッジケースが考慮されているか（空配列、未選択状態、大量データ等）
- [ ] エラーハンドリングが適切か

**アーキテクチャ準拠**:
- [ ] レイヤー間の依存ルールに違反していないか（UIレイヤー → IPC直接呼び出し等）
- [ ] フィーチャー間のインポートルールに違反していないか
- [ ] 状態管理の使い分けが適切か（Zustand vs TanStack Query）

**可読性**:
- [ ] 命名がこのガイドラインの規則に沿っているか
- [ ] 複雑なロジックに「なぜ」のコメントがあるか

**パフォーマンス**:
- [ ] 不要な再レンダリングがないか（React）
- [ ] 画像データの不必要なコピーがないか（C++）
- [ ] IPC呼び出しが最小限か

**セキュリティ**:
- [ ] ファイルアクセスがTauriスコープ内か
- [ ] ユーザー入力のバリデーションが適切か

### レビューコメントの書き方

**優先度を明示する**:
- `[必須]`: マージ前に修正が必要
- `[推奨]`: 修正が望ましいが、ブロッキングではない
- `[提案]`: 検討してほしいアイデア
- `[質問]`: 理解のための質問

```markdown
// ✅ 良い例
[必須] この接続バリデーションでは循環検出が漏れています。
ValidationService.detectCycle() を呼び出す必要があります。

[提案] このコンポーネントは80行を超えています。
NodeLibraryPanel と NodeSearchBar に分割すると読みやすくなりそうです。

// ❌ 悪い例
これは良くないです。
```

---

## 開発環境セットアップ

### 必要なツール

| ツール | バージョン | 用途 | インストール方法 |
|---|---|---|---|
| Node.js | 22.x LTS | フロントエンドビルド | `mise install node@22` |
| Rust | stable | Tauriバックエンド | `mise install rust@latest` |
| CMake | 3.x | C++ビルド | `apt install cmake` |
| OpenCV | 4.x | 画像処理ライブラリ | `apt install libopencv-dev` |

### セットアップ手順

```bash
# 1. リポジトリのクローン
git clone <repository-url>
cd visualinspect

# 2. フロントエンド依存関係のインストール
npm install

# 3. Rust依存関係のビルド
cd src-tauri && cargo build && cd ..

# 4. C++画像処理エンジンのビルド
cd src-cpp && mkdir build && cd build && cmake .. && make && cd ../..

# 5. 開発サーバーの起動
npm run tauri dev
```

### 推奨エディタ設定

**VS Code拡張**:
- ESLint
- Prettier
- rust-analyzer
- C/C++ (Microsoft)
- Tauri

**設定**:
- Format on Save: 有効
- Default Formatter: Prettier（TypeScript）、rustfmt（Rust）、clang-format（C++）
