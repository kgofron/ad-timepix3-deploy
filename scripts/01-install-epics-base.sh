#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib.sh"
load_config

REPO_URL="${EPICS_BASE_REPO:-https://github.com/epics-base/epics-base.git}"
DEST="${EPICS_BASE}"

clone_or_update "${REPO_URL}" "${DEST}"
checkout_tag "${DEST}" "${EPICS_BASE_TAG}"

epics_env
echo "==> Building EPICS Base at ${DEST}"
make -C "${DEST}" -j"${MAKE_JOBS}"

echo "EPICS Base ready. Source: source ${DEST}/setEpicsEnv.sh"
