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

pva_lib="${DEST}/lib/${EPICS_HOST_ARCH}/libpvData.a"
if [[ ! -f "${pva_lib}" ]]; then
  echo "ERROR: ${pva_lib} not found after EPICS Base build." >&2
  echo "ADCore (WITH_PVA=YES) needs EPICS 7 PVA — rebuild base or check EPICS_HOST_ARCH." >&2
  exit 1
fi

echo "EPICS Base ready. Source: source ${DEST}/setEpicsEnv.sh"
