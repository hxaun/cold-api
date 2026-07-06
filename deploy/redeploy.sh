#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

COMPOSE_FILE="${1:-docker-compose.service-only.yml}"
ENV_FILE="${ENV_FILE:-.env}"
IMAGE_NAME="${IMAGE_NAME:-coldapi:latest}"
GOPROXY_VALUE="${GOPROXY:-https://goproxy.cn,direct}"
GOSUMDB_VALUE="${GOSUMDB:-sum.golang.google.cn}"

if [ ! -f "${SCRIPT_DIR}/${COMPOSE_FILE}" ]; then
    echo "[ERROR] Compose file not found: ${SCRIPT_DIR}/${COMPOSE_FILE}" >&2
    exit 1
fi

if [ ! -f "${SCRIPT_DIR}/${ENV_FILE}" ]; then
    echo "[ERROR] Env file not found: ${SCRIPT_DIR}/${ENV_FILE}" >&2
    echo "Create it first, for example:" >&2
    echo "  cp ${SCRIPT_DIR}/.env.example ${SCRIPT_DIR}/${ENV_FILE}" >&2
    exit 1
fi

echo "[1/4] Pulling latest code"
git -C "${REPO_ROOT}" pull

echo "[2/4] Building image: ${IMAGE_NAME}"
docker build \
    -t "${IMAGE_NAME}" \
    --build-arg GOPROXY="${GOPROXY_VALUE}" \
    --build-arg GOSUMDB="${GOSUMDB_VALUE}" \
    -f "${REPO_ROOT}/Dockerfile" \
    "${REPO_ROOT}"

echo "[3/4] Recreating services with ${COMPOSE_FILE}"
docker compose \
    --env-file "${SCRIPT_DIR}/${ENV_FILE}" \
    -f "${SCRIPT_DIR}/${COMPOSE_FILE}" \
    up -d --force-recreate --remove-orphans

echo "[4/4] Current service status"
docker compose \
    --env-file "${SCRIPT_DIR}/${ENV_FILE}" \
    -f "${SCRIPT_DIR}/${COMPOSE_FILE}" \
    ps

echo ""
echo "Redeploy complete."
echo "Logs:"
echo "  docker compose --env-file ${SCRIPT_DIR}/${ENV_FILE} -f ${SCRIPT_DIR}/${COMPOSE_FILE} logs -f coldapi"
