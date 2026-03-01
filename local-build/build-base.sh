#!/bin/bash
# ========================================
# DevContainer PHPベースイメージビルドスクリプト
# ========================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}/.."
BASE_IMAGE_NAME="223n-devcontainer-php-base"
BASE_IMAGE_TAG="latest"

echo "========================================="
echo "DevContainer PHPベースイメージのビルド"
echo "========================================="
echo ""
echo "イメージ名: ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}"
echo ""

# Dockerfileが存在するか確認
if [ ! -f "${PROJECT_ROOT}/Dockerfile" ]; then
    echo "❌ エラー: Dockerfile が見つかりません"
    exit 1
fi

# ベースイメージのビルド
echo "🔨 PHPベースイメージをビルドしています..."
docker build \
    -f "${PROJECT_ROOT}/Dockerfile" \
    -t "${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}" \
    "${PROJECT_ROOT}"

echo ""
echo "✅ PHPベースイメージのビルドが完了しました！"
echo ""
echo "イメージ情報:"
docker images "${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}"
echo ""
echo "📝 次のステップ:"
echo "  1. VS Codeで 'Dev Containers: Rebuild Container' を実行"
echo "  2. または、docker-compose を使用する場合は再起動"
echo ""
