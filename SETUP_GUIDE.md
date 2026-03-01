# DevContainer PHPベースイメージ セットアップガイド

2つの使用方法を提供します。

## 目次

- [DevContainer PHPベースイメージ セットアップガイド](#devcontainer-phpベースイメージ-セットアップガイド)
  - [目次](#目次)
  - [1. パターン1: GitHub Container Registry版（推奨）](#1-パターン1-github-container-registry版推奨)
  - [2. パターン2: ローカルビルド版](#2-パターン2-ローカルビルド版)
  - [3. 比較表](#3-比較表)
  - [4. 推奨フロー](#4-推奨フロー)
  - [5. トラブルシューティング](#5-トラブルシューティング)
  - [6. 更新方法](#6-更新方法)
  - [7. 質問・サポート](#7-質問サポート)

---

## 1. パターン1: GitHub Container Registry版（推奨）

複数プロジェクトで使用する場合やチーム開発に最適

### 1-1. セットアップ手順

#### 1-1-1. ステップ1: GitHubリポジトリの作成

1. GitHubで新規リポジトリ作成

- リポジトリ名: `devcontainer-php-base`
- 公開設定: Private（またはPublic）

#### 1-1-2. ステップ2: ファイルの配置

以下のファイルをリポジトリに配置します。

```text
devcontainer-php-base/
├── Dockerfile
├── .github/
│   └── workflows/
│       └── build-image.yml
└── README.md
```

#### 1-1-3. ステップ3: GitHubにプッシュ

```bash
cd devcontainer-php-base
git init
git add .
git commit -m "Add: DevContainer PHPベースイメージの初期設定"
git branch -M master
git remote add origin git@github.com:223n/devcontainer-php-base.git
git push -u origin master
```

#### 1-1-4. ステップ4: GitHub Actionsの確認

GitHubリポジトリの「Actions」タブで
自動ビルドが実行されることを確認します。

#### 1-1-5. ステップ5: プロジェクトで使用

`your-project/.devcontainer/devcontainer.json`:

```json
{
  "name": "My CakePHP Project",
  "image": "ghcr.io/223n/devcontainer-php-base:latest",
  "runArgs": ["--name", "my-project-dev"],
  "remoteUser": "vscode",
  "customizations": {
    "vscode": {
      "extensions": [
        "bmewburn.vscode-intelephense-client",
        "xdebug.php-debug"
      ]
    }
  },
  "forwardPorts": [8765],
  "postCreateCommand": "composer install --no-interaction 2>/dev/null || true",
  "postStartCommand": "bash -c 'if [ ! -f .envrc ]; then cp .envrc.template .envrc; fi && direnv allow && echo \"DevContainer ready!\"'"
}
```

#### 1-1-6. ステップ6: Container Registryの公開設定（必要に応じて）

プライベートイメージの場合、GitHubで認証が必要です。

1. GitHub Personal Access Token作成

- Settings > Developer settings > Personal access tokens
- `read:packages`権限を付与

1. Dockerでログイン:

```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u 223n --password-stdin
```

### 1-2. メリット

- 複数プロジェクトで共有可能
- チーム全体で同じ環境
- 起動が高速（ビルド不要）
- CI/CDで自動更新

### 1-3. デメリット

- 初回設定がやや複雑
- GitHubアカウント必要
- プライベートイメージは認証必要

---

## 2. パターン2: ローカルビルド版

単一プロジェクトで使用する場合や、試験的に使いたい場合に最適

### 2-1. セットアップ手順

#### 2-1-1. ステップ1: ファイルの配置

`local-build/`の内容を`.devcontainer/`にコピーします。

```bash
cd your-project
cp -r /path/to/local-build/* .devcontainer/
```

#### 2-1-2. ステップ2: ベースイメージのビルド

```bash
cd .devcontainer
./build-base.sh
```

#### 2-1-3. ステップ3: DevContainerの起動

VS Codeで「Dev Containers: Reopen in Container」を実行します。

### 2-2. メリット

- オフラインで使用可能
- 即座に変更可能
- GitHubアカウント不要

### 2-3. デメリット

- 初回ビルドに時間がかかる（5-10分）
- プロジェクトごとにビルド必要
- ディスク容量を消費

---

## 3. 比較表

| 項目                 | GitHub Container Registry | ローカルビルド            |
| -------------------- | ------------------------- | ------------------------- |
| セットアップ時間     | 初回: 1-2分（プル）       | 初回: 5-10分（ビルド）    |
| 複数プロジェクト共有 | 簡単                      | 各プロジェクトでビルド    |
| チーム共有           | 簡単                      | 各自ビルド必要            |
| オフライン使用       | 初回プル必要              | 完全オフライン可          |
| 変更の反映           | GitHub Actions経由        | 即座                      |
| ディスク使用量       | 少ない                    | 多い                      |
| GitHub必要           | 必要                      | 不要                      |
| 推奨用途             | 本番・チーム開発          | 個人・試験的使用          |

---

## 4. 推奨フロー

### 4-1. ローカルビルド版で試す

```bash
# 1. ローカルビルド版でセットアップ
cd .devcontainer
./build-base.sh

# 2. 動作確認
# VS Code: "Dev Containers: Reopen in Container"

# 3. 問題なければ本格運用へ
```

### 4-2. 本格運用時はGitHub Container Registry版へ移行

```bash
# 1. GitHubリポジトリ作成
# 2. Dockerfileをプッシュ
# 3. devcontainer.jsonを更新

# 変更前
"build": { "dockerfile": "Dockerfile" }

# 変更後
"image": "ghcr.io/223n/devcontainer-php-base:latest"
```

---

## 5. トラブルシューティング

### 5-1. GitHub Container Registryからプルできない

```bash
# 認証確認
docker login ghcr.io

# イメージの存在確認
docker pull ghcr.io/223n/devcontainer-php-base:latest
```

### 5-2. ローカルビルドが失敗する

```bash
# Dockerデーモン確認
docker ps

# ディスク容量確認
docker system df

# キャッシュクリア
docker system prune -a
```

---

## 6. 更新方法

### 6-1. GitHub Container Registry版

1. `Dockerfile`を編集
1. GitHubにプッシュ
1. GitHub Actionsで自動ビルド
1. プロジェクトで`docker pull`実行

### 6-2. ローカルビルド版

1. `Dockerfile`を編集
1. `./build-base.sh`実行
1. VS Code:「Dev Containers: Rebuild Container」

---

## 7. 質問・サポート

問題が発生した場合:

1. このガイドのトラブルシューティングを確認
1. `local-build/README.md`または`README.md`を参照
1. GitHubでIssueを作成
