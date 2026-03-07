FROM mcr.microsoft.com/devcontainers/base:debian-12

# ユーザー名
ARG USERNAME=vscode

# Install basic development tools
RUN apt update && apt install -y \
    # シェル作業の基本
    less \
    man-db \
    tldr \
    sudo \
    # テキスト編集
    vim \
    nano \
    # バージョン管理
    git \
    # HTTP通信
    curl \
    wget \
    # ビルドツール
    build-essential \
    bash-completion \
    # 言語ビルド用の共通依存ライブラリ
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    # 日本語サポート
    locales \
    fonts-noto-cjk \
    fonts-noto-cjk-extra \
    # その他便利ツール
    tmux \
    zip \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 日本語ロケール生成
RUN sed -i 's/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen ja_JP.UTF-8

# mise (統合バージョンマネージャー) のインストール
RUN curl https://mise.run | sh
ENV PATH="/root/.local/bin:$PATH"

# vscode ユーザーに mise をインストール
RUN sudo -u $USERNAME sh -c 'curl https://mise.run | sh'
RUN echo 'eval "$(/home/'$USERNAME'/.local/bin/mise activate bash)"' >> /home/$USERNAME/.bashrc

# Git公式の補完スクリプトをダウンロード
RUN curl -o /usr/share/bash-completion/completions/git \
    https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash

# bash-completionを有効化
RUN echo "source /usr/share/bash-completion/bash_completion" >> /home/$USERNAME/.bashrc

# Set `DEVCONTAINER` environment variable to help with orientation
ENV DEVCONTAINER=true
