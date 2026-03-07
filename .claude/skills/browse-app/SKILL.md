---
name: browse-app
description: MCPのChrome DevToolsを使ってアプリにログインし、指定ページのスクリーンショットを取得するスキル。
allowed-tools: Read, Bash, mcp__chrome-devtools__navigate_page, mcp__chrome-devtools__take_snapshot, mcp__chrome-devtools__take_screenshot, mcp__chrome-devtools__click, mcp__chrome-devtools__fill, mcp__chrome-devtools__fill_form, mcp__chrome-devtools__wait_for, mcp__chrome-devtools__list_pages, mcp__chrome-devtools__evaluate_script, mcp__chrome-devtools__press_key, mcp__chrome-devtools__select_page, mcp__chrome-devtools__new_page, mcp__chrome-devtools__hover
---

# browse-app: アプリ画面の自動ログイン & スクリーンショット取得

開発中のアプリにChrome DevTools MCP経由で自動ログインし、指定ページのスクリーンショットを取得するスキル。

## 実行手順

### Step 1: 認証情報の読み込み

`.env.local`をReadツールで読み取り、以下の環境変数を取得する:

- `DEV_LOGIN_EMAIL`
- `DEV_LOGIN_PASSWORD`

**値が未設定の場合**: ユーザーに`.env.local`への設定を促して中断する。

### Step 2: devサーバーの稼働確認

Bashで以下を実行して開発サーバーの稼働を確認:

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000
```

- **200系レスポンス**: 正常、次のステップへ
- **それ以外 or 接続エラー**: ユーザーに`pnpm dev`の実行を促して中断

### Step 3: Chromiumの接続確認

Bashで以下を実行してヘッドレスChromiumの稼働を確認:

```bash
curl -s http://127.0.0.1:9222/json/version
```

- **正常レスポンス**: 次のステップへ
- **接続エラー**: 以下の起動手順を案内して中断:
  ```
  Chromiumが起動していません。以下のコマンドで起動してください:
  chromium --headless --remote-debugging-port=9222 --no-sandbox &
  ```

### Step 4: ログインフロー

以下の順序でログインを実行する:

1. `navigate_page`で`http://localhost:3000/login`へ遷移
2. `take_snapshot`でページ構造を取得し、フォーム要素のuidを特定
3. `fill`でメールアドレスフィールド（`email`）にDEV_LOGIN_EMAILを入力
4. `fill`でパスワードフィールド（`password`）にDEV_LOGIN_PASSWORDを入力
5. ログインボタン（テキスト「ログイン」）を`click`
6. `wait_for`でダッシュボードへの遷移を確認（テキスト「ダッシュボード」またはURL内の`/dashboard`）

**ログイン失敗時**: `take_screenshot`を撮影し、画面のエラー内容をユーザーに報告する。

### Step 5: ページ遷移とスクリーンショット取得

- ユーザーが指定したURLがある場合、`navigate_page`で遷移
- 指定がない場合、ダッシュボード（`/dashboard`）のまま
- `take_snapshot`でページ構造を取得
- `take_screenshot`でスクリーンショットを取得
- 必要に応じてユーザーの追加操作指示（クリック、スクロール等）に従う

## ログインページの構造（参考）

- パス: `/login`
- フォームフィールド:
  - `email`（InputField, type="email", placeholder="your@email.com"）
  - `password`（InputField, type="password", placeholder="••••••••"）
- 送信ボタン: `Button type="submit"`（テキスト「ログイン」）
- 認証方式: Supabase `signInWithPassword`
- 成功時リダイレクト: `/dashboard`

## 注意事項

- 認証情報は`.env.local`から読み取り、ハードコードしない
- ログイン後のセッションはブラウザタブに紐づくため、同一タブで操作を続ける
- ページ遷移後は毎回`take_snapshot`で最新のDOM構造を取得してからUID参照する
