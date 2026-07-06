# DevContainer PHP Base Image

[![PHPベースイメージのビルドとリリース](https://github.com/223n/devcontainer-php-base/actions/workflows/build-image.yml/badge.svg)](https://github.com/223n/devcontainer-php-base/actions/workflows/build-image.yml)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

CakePHP開発向けカスタムDevContainerベースイメージ

## 目次

- [DevContainer PHP Base Image](#devcontainer-php-base-image)
  - [目次](#目次)
  - [1. 概要](#1-概要)
  - [2. 含まれるツール](#2-含まれるツール)
  - [3. 使い方](#3-使い方)
  - [4. ビルド](#4-ビルド)
  - [5. カスタマイズ](#5-カスタマイズ)
  - [6. 更新](#6-更新)
  - [7. バージョン管理](#7-バージョン管理)

## 1. 概要

Debian 13（trixie）+ PHP 8.5 + Node.js 26をベースとした
CakePHP開発環境用Dockerイメージです。

VS CodeのDevContainer機能で使用することを想定しています。

MySQL/nginxは含まれていません。
各プロジェクトのdocker-composeで別コンテナーとして構成してください。

## 2. 含まれるツール

### 2-1. PHP関連

- PHP 8.5（CLI + FPM）
  - Debian 13公式リポジトリには含まれないため、Ondřej Surý のAPTリポジトリ（deb.sury.org）から導入
- Composer 2.x
- PHP拡張:
  - intl、mbstring、xml（CakePHP必須）
  - mysql、sqlite3（データベース接続）
  - curl、zip、gd、bcmath、opcache（実用上推奨）

### 2-2. システムツール

- Git
- curl、wget
- vim、nano
- direnv
- sqlite3
- MySQLクライアント
- jq、zip、unzip
- bash-completion
- GitHub CLI（gh）

### 2-3. Node.js関連

- Node.js 26
- npm（Node.js付属）

### 2-4. ユーザー設定

- ユーザー名: `vscode`
- UID/GID: 1000
- sudoアクセス: 有効

### 2-5. Git設定

```bash
user.name = 223n
user.email = 223n@223n.tech
core.autocrlf = input
core.eol = lf
init.defaultBranch = master
```

## 3. 使い方

### 3-1. GitHub Container Registryから使用

`.devcontainer/devcontainer.json`:

```json
{
  "name": "My CakePHP Project",
  "image": "ghcr.io/223n/devcontainer-php-base:latest",
  "runArgs": ["--name", "my-project-dev"],
  "remoteUser": "vscode",
  "workspaceFolder": "/workspaces/${localWorkspaceFolderBasename}",
  "customizations": {
    "vscode": {
      "extensions": [
        "bmewburn.vscode-intelephense-client",
        "xdebug.php-debug"
      ]
    }
  }
}
```

### 3-2. ローカルでビルド

```bash
docker build -t 223n-devcontainer-php-base:latest .
```

`.devcontainer/devcontainer.json`:

```json
{
  "name": "My CakePHP Project",
  "image": "223n-devcontainer-php-base:latest",
  "runArgs": ["--name", "my-project-dev"],
  "remoteUser": "vscode"
}
```

## 4. ビルド

### 4-1. GitHub Actionsでビルド

GitHub Actionsの手動実行（workflow_dispatch）で
ビルドとリリースを行います。

### 4-2. 手動ビルド

```bash
# ビルド
docker build -t ghcr.io/223n/devcontainer-php-base:latest .

# プッシュ（要認証）
docker push ghcr.io/223n/devcontainer-php-base:latest
```

## 5. カスタマイズ

プロジェクト固有の設定が必要な場合は、
このイメージをベースにカスタマイズできます。

```dockerfile
FROM ghcr.io/223n/devcontainer-php-base:latest

# プロジェクト固有のPHP拡張を追加
RUN sudo apt-get update \
    && sudo apt-get install -y php8.5-redis \
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/*

# プロジェクト固有の設定
WORKDIR /workspaces/your-project
```

## 6. 更新

ベースイメージを更新した場合:

```bash
# ローカルイメージの更新
docker pull ghcr.io/223n/devcontainer-php-base:latest

# DevContainerの再ビルド
# VS Code: "Dev Containers: Rebuild Container"
```

## 7. バージョン管理

- `latest`: 最新の安定版
- `1.0.0`: 完全バージョン
- `1.0`: マイナーバージョン
- `1`: メジャーバージョン
- `sha-<commit-sha>`: 特定コミット
