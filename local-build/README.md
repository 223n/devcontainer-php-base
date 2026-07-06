# DevContainer PHPローカルビルド版

プロジェクト内でDevContainer PHPベースイメージをビルドする構成

## 目次

- [DevContainer PHPローカルビルド版](#devcontainer-phpローカルビルド版)
  - [目次](#目次)
  - [1. ファイル構成](#1-ファイル構成)
  - [2. セットアップ手順](#2-セットアップ手順)
  - [3. ベースイメージの更新](#3-ベースイメージの更新)
  - [4. カスタマイズ](#4-カスタマイズ)
  - [5. GitHub Container Registry版への切り替え](#5-github-container-registry版への切り替え)
  - [6. トラブルシューティング](#6-トラブルシューティング)
  - [7. メリット](#7-メリット)
  - [8. デメリット](#8-デメリット)
  - [9. GitHub Container Registry版との比較](#9-github-container-registry版との比較)
  - [10. 推奨](#10-推奨)

## 1. ファイル構成

```text
.devcontainer/
├── Dockerfile             # プロジェクト固有設定
├── devcontainer.json      # DevContainer設定
└── build-base.sh          # ビルドスクリプト（ルートのDockerfileを参照）
```

## 2. セットアップ手順

### 2-1. ファイルの配置

このディレクトリの内容を`.devcontainer/`にコピーします。

```bash
# プロジェクトのルートから実行
cp -r local-build/* .devcontainer/
```

### 2-2. ベースイメージのビルド

```bash
cd .devcontainer
./build-base.sh
```

または、直接Dockerコマンドを実行します。

```bash
docker build -t 223n-devcontainer-php-base:latest .
```

### 2-3. DevContainerの起動

VS Codeで以下を実行します。

1. コマンドパレット（Ctrl+Shift+P / Cmd+Shift+P）を開く
1. 「Dev Containers: Reopen in Container」を実行

## 3. ベースイメージの更新

ベースイメージを変更した場合:

```bash
# 1. ベースイメージを再ビルド
cd .devcontainer
./build-base.sh

# 2. DevContainerを再ビルド
# VS Code: "Dev Containers: Rebuild Container"
```

## 4. カスタマイズ

### 4-1. プロジェクト固有のツールを追加

`Dockerfile`を編集します。

```dockerfile
FROM 223n-devcontainer-php-base:latest

# プロジェクト固有のPHP拡張を追加
RUN sudo apt-get update \
    && sudo apt-get install -y php8.5-redis \
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/*

USER vscode
```

### 4-2. Git設定の変更

ルートの`Dockerfile`を編集します。

```dockerfile
# Git グローバル設定
RUN git config --global user.name "Your Name" \
    && git config --global user.email "your-email@example.com"
```

変更後、ベースイメージを再ビルドしてください。

## 5. GitHub Container Registry版への切り替え

GitHub Container Registry版を使いたい場合、
`Dockerfile`の1行目を変更します。

```dockerfile
# 変更前
FROM 223n-devcontainer-php-base:latest

# 変更後
FROM ghcr.io/223n/devcontainer-php-base:latest
```

その後、`devcontainer.json`も変更します。

```json
{
  "name": "My CakePHP Project",
  "image": "ghcr.io/223n/devcontainer-php-base:latest",
  "runArgs": ["--name", "my-project-dev"],
  "remoteUser": "vscode"
}
```

## 6. トラブルシューティング

### 6-1. ベースイメージが見つからない

```bash
# ビルドされているか確認
docker images | grep 223n-devcontainer-php-base

# ない場合は再ビルド
cd .devcontainer
./build-base.sh
```

### 6-2. DevContainerが起動しない

```bash
# 古いコンテナーを削除
docker rm -f php-dev

# イメージを再ビルド
docker build -t 223n-devcontainer-php-base:latest .

# VS Code: "Dev Containers: Rebuild Container"
```

## 7. メリット

- オフラインでも使用可能（レジストリ不要）
- 即座に変更可能（ローカルで完結）
- デバッグが容易（ビルドログが直接見られる）

## 8. デメリット

- 初回ビルドに時間がかかる（5-10分程度）
- チームで共有しにくい（各自がビルド必要）
- ディスク容量を消費（ローカルにイメージ保存）

## 9. GitHub Container Registry版との比較

| 項目             | ローカルビルド       | GitHub Container Registry |
| ---------------- | -------------------- | ------------------------- |
| 初回セットアップ | ビルド必要（5-10分） | プル（1-2分）             |
| オフライン使用   | 可能                 | 初回プル必要              |
| チーム共有       | 各自ビルド           | 簡単                      |
| 変更の反映       | 即座                 | GitHub Actions経由        |
| ディスク使用量   | 多い                 | 少ない                    |

## 10. 推奨

- 個人開発・試験的使用: ローカルビルド版
- チーム開発・本番使用: GitHub Container Registry版
