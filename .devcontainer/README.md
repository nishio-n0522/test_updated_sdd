# devcontainer 設定について（2026/02/07 作成）

devcontainer.jsonとDocker設定（Dockerfile、docker-compose.yml）で定義

**基本的な使い分け**

Docker設定の役割：「コンテナ自体の定義」 - 実行環境の構築

- イメージベースの選択
- システムパッケージのインストール
- 永続的な設定
- 本番環境でも使える汎用的な設定

devcontainer.jsonの役割：「開発体験の定義」 - 開発者向けの便利機能

- エディタの拡張機能
- ポートフォワーディング
- 開発用のセットアップコマンド
- 開発者固有の設定

**関連資料**

[`devcontainer.json`の仕様](https://containers.dev/implementors/json_schema/)

## 基本情報

### `name`

コンテナの表示名です。UI上でわかりやすい名前をつけます。

```json
{
  "name": "Try spec driven development"
}
```

## Features（機能追加）

### `features`

コンテナに追加機能をインストールします。事前定義された機能を簡単に追加できます。

```json
{
  "features": {
    "ghcr.io/devcontainers/features/node:1": {
      "version": "18"
    },
    "ghcr.io/devcontainers/features/python:1": {
      "version": "3.11"
    }
  }
}
```

### `overrideFeatureInstallOrder`

Featuresのインストール順序を制御します。依存関係がある場合に使用。

```json
{
  "overrideFeatureInstallOrder": [
    "ghcr.io/devcontainers/features/common-utils",
    "ghcr.io/devcontainers/features/docker-in-docker"
  ]
}
```

## ポートフォワーディング

### `forwardPorts`

コンテナのポートをホストマシンに転送します。

```json
{
  "forwardPorts": [3000, 8000, "localhost:5432"]
}
```

### `portsAttributes`

各ポートの動作を細かく設定します。

```json
{
  "portsAttributes": {
    "3000": {
      "label": "Frontend",
      "onAutoForward": "openBrowser",
      "protocol": "https"
    },
    "8000": {
      "label": "API Server",
      "onAutoForward": "notify"
    }
  }
}
```

**onAutoForwardの値:**

- `notify`: 通知のみ表示
- `openBrowser`: ブラウザで自動的に開く
- `openPreview`: VS Code内でプレビュー
- `silent`: 何もしない
- `ignore`: 転送しない

### `otherPortsAttributes`

明示的に指定していないポートのデフォルト動作を設定。

```json
{
  "otherPortsAttributes": {
    "onAutoForward": "ignore"
  }
}
```

## ユーザー設定

### `remoteUser`

コンテナ内でプロセスを実行するユーザー名。

```json
{
  "remoteUser": "node"
}
```

### `updateRemoteUserUID`

LinuxでコンテナユーザーのUID/GIDをホストユーザーと同期させるかどうか。

```json
{
  "updateRemoteUserUID": true
}
```

## 環境変数

### `remoteEnv`

コンテナ内で設定される環境変数。

```json
{
  "remoteEnv": {
    "NODE_ENV": "development",
    "API_URL": "http://localhost:8000",
    "PATH": "${containerEnv:PATH}:/custom/bin"
  }
}
```

## ライフサイクルコマンド

実行順序: `initializeCommand` → `onCreateCommand` → `updateContentCommand` → `postCreateCommand` → `postStartCommand` → `postAttachCommand`

### `initializeCommand`

**ホストマシン上**で実行。コンテナ作成前に毎回実行されます。

```json
{
  "initializeCommand": "npm install"
}
```

### `onCreateCommand`

コンテナ作成時に**一度だけ**実行。初期セットアップに使用。

```json
{
  "onCreateCommand": "pip install -r requirements.txt"
}
```

### `updateContentCommand`

ワークスペースの内容が更新された時に実行。

```json
{
  "updateContentCommand": "npm ci"
}
```

### `postCreateCommand`

コンテナ作成後に実行。データベースのマイグレーションなどに使用。

```json
{
  "postCreateCommand": "npm run db:migrate"
}
```

### `postStartCommand`

コンテナ起動時に毎回実行。サービスの起動などに使用。

```json
{
  "postStartCommand": "npm run dev"
}
```

### `postAttachCommand`

エディタがコンテナにアタッチした後に実行。

```json
{
  "postAttachCommand": "echo 'Container ready!'"
}
```

**コマンドの形式:**

```json
{
  // 文字列（シェルで実行）
  "postCreateCommand": "npm install && npm run build",

  // 配列（シェルなしで実行）
  "postCreateCommand": ["npm", "install"],

  // オブジェクト（並列実行）
  "postCreateCommand": {
    "server": "npm run dev",
    "worker": "npm run worker"
  }
}
```

### `waitFor`

UIが起動する前にどのコマンドまで待つかを指定。

```json
{
  "waitFor": "postCreateCommand"
}
```

### `userEnvProbe`

ユーザー環境変数の取得方法。

```json
{
  "userEnvProbe": "loginInteractiveShell"
}
```

## ハードウェア要件

### `hostRequirements`

実行に必要なホストマシンのスペックを定義。

```json
{
  "hostRequirements": {
    "cpus": 4,
    "memory": "8gb",
    "storage": "32gb",
    "gpu": true
  }
}
```

GPUの詳細指定:

```json
{
  "hostRequirements": {
    "gpu": {
      "cores": 4,
      "memory": "8gb"
    }
  }
}
```

## カスタマイゼーション

### `customizations`

エディタ固有の設定。VS Codeの拡張機能などを指定。

```json
{
  "customizations": {
    "vscode": {
      "extensions": ["dbaeumer.vscode-eslint", "esbenp.prettier-vscode"],
      "settings": {
        "editor.formatOnSave": true
      }
    }
  }
}
```

## チームで共有する設定と個人設定の方法について

```
.devcontainer/
├── devcontainer.json          ← チーム全員で共有（Git管理）
├── Dockerfile                 ← チーム全員で共有（Git管理）
└── devcontainer.local.json    ← 個人用設定（Git除外）
```

## 方法1: devcontainer.local.json（推奨）

### 仕組み

VS Codeは自動的に`devcontainer.local.json`を読み込み、`devcontainer.json`の設定を**上書き**します。

### 設定方法

**1. .gitignoreに追加**

```gitignore
# .gitignore
.devcontainer/devcontainer.local.json
```

**2. チーム共有設定（devcontainer.json）**

```jsonc
{
  "name": "sdd-template",
  "build": {
    "dockerfile": "Dockerfile",
  },
  "remoteUser": "node",

  // チーム全員に必要な最小限の設定
  "features": {
    "ghcr.io/devcontainers/features/github-cli:1": {},
  },

  "customizations": {
    "vscode": {
      "extensions": [
        // 全員に必要な拡張機能のみ
        "dbaeumer.vscode-eslint",
        "ms-azuretools.vscode-docker",
      ],
    },
  },
}
```

**3. 個人用設定（devcontainer.local.json）**

```jsonc
{
  // 個人的に追加したい機能
  "features": {
    "ghcr.io/stu-bell/devcontainer-features/claude-code:0": {},
    "ghcr.io/devcontainers/features/common-utils:2": {
      "installZsh": true,
      "installOhMyZsh": true,
      "configureZshAsDefaultShell": true,
      "username": "node",
    },
  },

  // 個人的なマウント
  "mounts": [
    "source=${localWorkspaceFolder}/.navi/cheats,target=/home/node/.local/share/navi/cheats,type=bind",
    "source=${localEnv:HOME}/.gitconfig,target=/home/node/.gitconfig,type=bind,readonly",
  ],

  "customizations": {
    "vscode": {
      "extensions": [
        // 個人的に使いたい拡張機能
        "eamodio.gitlens",
        "pkief.material-icon-theme",
        "usernamehw.errorlens",
        "github.copilot",
      ],
      "settings": {
        // 個人的な設定
        "workbench.iconTheme": "material-icon-theme",
        "editor.fontSize": 14,
      },
    },
  },
}
```

### マージの仕組み

VS Codeは自動的に両方のファイルをマージします：

```
devcontainer.json（ベース）
      +
devcontainer.local.json（個人設定で上書き）
      ↓
最終的な設定
```

**配列の場合（extensions、mountsなど）:**
→ **追加される**（上書きではなく）

**オブジェクトの場合（settings）:**
→ **マージされる**

**プリミティブな値（name、remoteUserなど）:**
→ **上書きされる**

## 方法2: dotfilesリポジトリ

個人的なシェル設定やツールを管理する方法。

### 仕組み

```
GitHub
└── あなたのdotfilesリポジトリ
    ├── .zshrc
    ├── .gitconfig
    └── install.sh
          ↓
    Dev Container起動時に自動cloneして適用
```

### 設定方法

**1. dotfilesリポジトリを作成**

```
https://github.com/yourusername/dotfiles
├── .zshrc
├── .bashrc
├── .gitconfig
└── install.sh
```

**2. devcontainer.jsonで指定**

```jsonc
{
  "name": "sdd-template",
  "build": {
    "dockerfile": "Dockerfile",
  },
  "remoteUser": "node",

  // チーム共有設定
  "features": {
    "ghcr.io/devcontainers/features/github-cli:1": {},
  },

  "customizations": {
    "vscode": {
      "extensions": ["dbaeumer.vscode-eslint"],
    },
  },
}
```

**3. VS Codeの設定（個人のsettings.json）**

```jsonc
{
  // VS Codeの設定（ローカル）
  "dotfiles.repository": "yourusername/dotfiles",
  "dotfiles.targetPath": "~/dotfiles",
  "dotfiles.installCommand": "~/dotfiles/install.sh",
}
```

**4. install.shの例**

```bash
#!/bin/bash

# シンボリックリンクを作成
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig

# 追加のツールをインストール
if command -v npm &> /dev/null; then
    npm install -g tldr
fi

echo "Dotfiles installed!"
```

これで、どのDev Containerを開いても自動的に個人設定が適用されます。

## 方法3: VS Codeの設定同期

### ユーザー設定（settings.json）

`Ctrl+,` → 歯車アイコン → "settings.json"

```jsonc
{
  // すべてのDev Containerで適用される個人設定
  "terminal.integrated.fontSize": 14,
  "editor.fontSize": 14,
  "workbench.colorTheme": "Default Dark+",

  // Dev Container固有の設定
  "dev.containers.defaultExtensions": ["eamodio.gitlens", "github.copilot"],
}
```

## 実践例

### チーム構成

```
チームメンバー:
- Aさん: Copilot使用、zsh好き
- Bさん: Copilot未使用、bash好き
- Cさん: Claude Code使用
```

### チーム共有（devcontainer.json）

```jsonc
{
  "name": "sdd-template",
  "build": {
    "dockerfile": "Dockerfile",
  },
  "remoteUser": "node",

  // 全員に必要な最小限
  "features": {
    "ghcr.io/devcontainers/features/github-cli:1": {},
  },

  "forwardPorts": [3000],

  "postCreateCommand": "npm install",

  "customizations": {
    "vscode": {
      "extensions": [
        // プロジェクトに必須
        "dbaeumer.vscode-eslint",
        "ms-azuretools.vscode-docker",
      ],
    },
  },
}
```

### Aさんの個人設定（devcontainer.local.json）

```jsonc
{
  "features": {
    // zshを追加
    "ghcr.io/devcontainers/features/common-utils:2": {
      "installZsh": true,
      "installOhMyZsh": true,
      "configureZshAsDefaultShell": true,
      "username": "node",
    },
  },

  "customizations": {
    "vscode": {
      "extensions": [
        "github.copilot", // Aさんだけ使用
        "eamodio.gitlens",
      ],
    },
  },
}
```

### Bさんの個人設定（devcontainer.local.json）

```jsonc
{
  // bashのまま、追加機能なし
  "customizations": {
    "vscode": {
      "extensions": ["eamodio.gitlens"],
    },
  },
}
```

### Cさんの個人設定（devcontainer.local.json）

```jsonc
{
  "features": {
    // Claude Codeを追加
    "ghcr.io/stu-bell/devcontainer-features/claude-code:0": {},
  },

  "mounts": [
    // 個人的なチートシート
    "source=${localWorkspaceFolder}/.navi/cheats,target=/home/node/.local/share/navi/cheats,type=bind",
  ],

  "customizations": {
    "vscode": {
      "extensions": ["pkief.material-icon-theme"],
    },
  },
}
```

## .gitignoreの設定

```.gitignore
# Dev Container個人設定
.devcontainer/devcontainer.local.json
.devcontainer/*.local.json

# 個人的なチートシート
.navi/

# VS Code個人設定（チームでWorkspace設定を共有する場合は除外）
.vscode/settings.json
```

## チーム向けREADME

**README.md:**

```markdown
## 開発環境

### 必須設定（全員）

プロジェクトルートで以下を実行：
\`\`\`bash
code .
\`\`\`
VS Codeが起動したら「Reopen in Container」をクリック

### 個人設定（任意）

個人的な設定を追加したい場合は、`.devcontainer/devcontainer.local.json`を作成してください。
このファイルはGitで管理されません。

例：
\`\`\`jsonc
{
"features": {
"ghcr.io/devcontainers/features/common-utils:2": {
"installZsh": true,
"installOhMyZsh": true
}
},
"customizations": {
"vscode": {
"extensions": [
"github.copilot"
]
}
}
}
\`\`\`
```

## まとめ

| 方法                        | 用途                               | 管理場所     |
| --------------------------- | ---------------------------------- | ------------ |
| **devcontainer.json**       | チーム全員で共有                   | Git管理      |
| **devcontainer.local.json** | プロジェクト固有の個人設定         | Git除外      |
| **dotfiles**                | すべてのプロジェクトで使う個人設定 | 別リポジトリ |
| **VS Code settings.json**   | エディタ全体の個人設定             | ローカル     |

**推奨アプローチ:**

1. **チーム共有**: 最小限の必須設定だけを`devcontainer.json`に
2. **個人設定**: `devcontainer.local.json`で追加
3. **シェル設定**: dotfilesリポジトリで管理

これで、チームの設定を壊さずに個人の好みも反映できます！
