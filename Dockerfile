# ========================================
# カスタムDevContainer PHPベースイメージ
# Debian 13 (trixie) + PHP 8.5 + Node.js 26
# User: vscode
# ========================================

ARG TAG=trixie-slim
FROM debian:${TAG}

# Composerをマルチステージビルドでコピー
COPY --from=composer/composer:2-bin /composer /usr/bin/composer

# メタデータ
LABEL org.opencontainers.image.source="https://github.com/223n/devcontainer-php-base"
LABEL org.opencontainers.image.description="Custom DevContainer PHP base image with PHP 8.5 + Node.js 26 on Debian 13"
LABEL org.opencontainers.image.licenses="MIT"

# 非対話的インストールの設定
ENV DEBIAN_FRONTEND=noninteractive

# Node.js バージョン設定
# NOTE: LTSバージョンは https://nodejs.org/en/download で確認
ARG NODE_VERSION=26.4.0

# 基本パッケージのインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    # 開発ツール
    git \
    curl \
    wget \
    vim \
    nano \
    ca-certificates \
    gnupg \
    # ビルドツール
    build-essential \
    # データベース
    sqlite3 \
    default-mysql-client \
    # シェル環境
    direnv \
    bash-completion \
    openssh-client \
    # 日本語ロケール
    locales \
    # その他便利ツール
    jq \
    zip \
    unzip \
    xz-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# PHP 8.5 + 拡張パッケージのインストール
# NOTE: PHP 8.5 は Debian 13 trixie 公式リポジトリに含まれないため、
#       Ondřej Surý の APT リポジトリ（deb.sury.org）を追加して導入する
RUN curl -fsSL https://packages.sury.org/php/apt.gpg \
      -o /usr/share/keyrings/deb.sury.org-php.gpg \
    && chmod go+r /usr/share/keyrings/deb.sury.org-php.gpg \
    && printf '%s\n' \
      "Types: deb" \
      "URIs: https://packages.sury.org/php/" \
      "Suites: trixie" \
      "Components: main" \
      "Signed-By: /usr/share/keyrings/deb.sury.org-php.gpg" \
      > /etc/apt/sources.list.d/php.sources \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    # PHP本体
    php8.5-fpm \
    php8.5-cli \
    # CakePHP 5.x 必須拡張
    php8.5-intl \
    php8.5-mbstring \
    php8.5-xml \
    # データベース接続
    php8.5-mysql \
    php8.5-sqlite3 \
    # 実用上推奨の拡張
    # NOTE: PHP 8.5 では OPcache が標準ビルドに統合され php8.5-common に同梱されるため、
    #       独立した php8.5-opcache パッケージは存在しない（cli/fpm 導入時に自動で有効化）
    php8.5-curl \
    php8.5-zip \
    php8.5-gd \
    php8.5-bcmath \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# GitHub CLI のインストール
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && printf '%s\n' \
      "Types: deb" \
      "URIs: https://cli.github.com/packages" \
      "Suites: stable" \
      "Components: main" \
      "Architectures: $(dpkg --print-architecture)" \
      "Signed-By: /usr/share/keyrings/githubcli-archive-keyring.gpg" \
      > /etc/apt/sources.list.d/github-cli.sources \
    && apt-get update \
    && apt-get install -y --no-install-recommends gh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Node.js 26 のインストール（公式バイナリを直接ダウンロード）
# NOTE: NodeSourceリポジトリのGPG署名（SHA1）がDebian Trixieで拒否されるため、
#       公式バイナリを直接インストールする方式に変更（2026年2月以降の対応）
RUN ARCH=$(dpkg --print-architecture) \
    && case "${ARCH}" in \
         amd64) NODE_ARCH="x64" ;; \
         arm64) NODE_ARCH="arm64" ;; \
         *) echo "Unsupported architecture: ${ARCH}" && exit 1 ;; \
       esac \
    && curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz" \
       -o /tmp/node.tar.xz \
    && tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 \
    && rm /tmp/node.tar.xz \
    && ln -sf /usr/local/bin/node /usr/local/bin/nodejs \
    && node --version \
    && npm --version

# 日本語ロケールを生成・設定
RUN sed -i '/ja_JP.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG=ja_JP.UTF-8
ENV LANGUAGE=ja_JP:ja
ENV LC_ALL=ja_JP.UTF-8

# vscodeユーザーの作成
RUN groupadd --gid 1000 vscode \
    && useradd --uid 1000 --gid 1000 -m -s /bin/bash vscode \
    && apt-get update \
    && apt-get install -y sudo \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/vscode \
    && chmod 0440 /etc/sudoers.d/vscode \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# vscodeユーザーに切り替え
USER vscode

# Git グローバル設定
RUN git config --global user.name "223n" \
    && git config --global user.email "223n@223n.tech" \
    && git config --global core.autocrlf input \
    && git config --global core.eol lf \
    && git config --global init.defaultBranch master \
    && git config --global pull.rebase false \
    && git config --global core.editor "nano"

# gitの安全なディレクトリに追加（vscodeユーザー用）
RUN git config --global --add safe.directory /workspace

# direnv自動読み込み設定
RUN echo 'eval "$(direnv hook bash)"' >> ~/.bashrc

# bash補完の有効化
RUN echo '[ -f /etc/bash_completion ] && . /etc/bash_completion' >> ~/.bashrc

# プロンプトのカスタマイズ（オプション）
RUN echo 'export PS1="\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ "' >> ~/.bashrc

# 作業ディレクトリの設定
WORKDIR /home/vscode

# デフォルトシェル
SHELL ["/bin/bash", "-c"]

# バージョン確認用
RUN php --version && composer --version && node --version && npm --version && git --version && gh --version

# ヘルスチェック
HEALTHCHECK NONE

# デフォルトコマンド
CMD ["/bin/bash"]
