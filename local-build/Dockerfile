# ========================================
# プロジェクト固有のDevContainer設定
# PHPベースイメージを使用
# ========================================

# ローカルビルド版のPHPベースイメージを使用
ARG TAG=latest
FROM 223n-devcontainer-php-base:${TAG}

# GitHub Container Registry版を使用する場合はコメントを切り替え
# FROM ghcr.io/223n/devcontainer-php-base:${TAG}

# プロジェクト固有の設定やツールがあればここに追加
# 例: RUN composer global require some-project-specific-tool

# ユーザーはベースイメージで設定済み (vscode)
USER vscode

# デフォルトシェル
SHELL ["/bin/bash", "-c"]
