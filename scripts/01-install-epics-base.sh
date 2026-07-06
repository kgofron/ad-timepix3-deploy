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

echo "==> Initializing EPICS Base submodules (PVA: pvData, pvAccess, qsrv, …)"
submodule_args=(--init --recursive)
if [[ "${GIT_DEPTH:-1}" != "0" ]]; then
  submodule_args+=(--depth "${GIT_DEPTH:-1}")
fi
git -C "${DEST}" submodule update "${submodule_args[@]}"

epics_env
echo "==> Building EPICS Base at ${DEST}"
make -C "${DEST}" -j"${MAKE_JOBS}"

pva_lib="${DEST}/lib/${EPICS_HOST_ARCH}/libpvData.a"
if [[ ! -f "${pva_lib}" ]]; then
  echo "ERROR: ${pva_lib} not found after EPICS Base build." >&2
  echo "PVA submodules may be empty — run: git -C ${DEST} submodule update --init --recursive" >&2
  echo "Then rebuild: make -C ${DEST} -j\$(nproc)" >&2
  exit 1
fi

echo "EPICS Base ready. Source: source ${DEST}/setEpicsEnv.sh"
