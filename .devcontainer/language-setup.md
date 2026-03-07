# 開発言語のセットアップガイド

このdevcontainerは **mise** (統合バージョンマネージャー) を使用しているため、必要な言語を後から自由にインストール・管理できます。

## mise の基本的な使い方

### サポートされている言語を確認

```bash
mise plugins ls-remote
```

### 言語のインストール

```bash
# Python
mise install python@3.12
mise install python@3.11
mise global python@3.12  # デフォルトバージョンを設定

# Node.js
mise install node@22
mise install node@20
mise global node@22

# Go
mise install go@1.23
mise global go@1.23

# Ruby
mise install ruby@3.3
mise global ruby@3.3

# Deno
mise install deno@latest
mise global deno@latest

# Bun
mise install bun@latest
mise global bun@latest

# その他の言語も同様にインストール可能
```

### AWS CLI のインストール

```bash
mise install awscli@latest
mise global awscli@latest

# または公式バイナリを直接インストール
sudo apt update && sudo apt install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip
```

### プロジェクト単位でバージョンを管理

プロジェクトルートに `.tool-versions` ファイルを作成:

```
python 3.12.0
node 22.0.0
go 1.23.5
```

または `.mise.toml` ファイル:

```toml
[tools]
python = "3.12"
node = "22"
go = "1.23"
```

これにより、そのディレクトリに入ると自動的にバージョンが切り替わります。

### インストール済みのバージョンを確認

```bash
mise list
```

### 利用可能なバージョンを確認

```bash
mise ls-remote python
mise ls-remote node
mise ls-remote go
```

### バージョンの切り替え

```bash
# グローバル（ユーザー全体）
mise global python@3.11

# ローカル（現在のディレクトリのみ）
mise local python@3.11

# シェルセッション内のみ
mise shell python@3.11
```

## よくある使用例

### TypeScript/React プロジェクト

```bash
mise install node@22
mise global node@22
```

### Python プロジェクト

```bash
mise install python@3.12
mise global python@3.12
```

### Go プロジェクト

```bash
mise install go@1.23
mise global go@1.23
```

### AWS Lambda (複数言語)

```bash
mise install python@3.11 node@20 awscli@latest
mise global python@3.11 node@20 awscli@latest
```

### Flutter 開発

```bash
mise install flutter@latest
mise global flutter@latest
# Dockerfile末尾のFlutter用依存関係のコメントを解除してリビルド
```

## 詳細情報

- 公式ドキュメント: https://mise.jdx.dev/
- GitHub: https://github.com/jdx/mise
