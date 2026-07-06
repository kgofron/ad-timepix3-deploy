#!/usr/bin/env bash
# synApps modules required for areaDetector IOC applications.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib.sh"
load_config

SYNAPPS_BASE="${SYNAPPS_GIT_BASE:-https://github.com/epics-modules}"

# Build order from configure/RELEASE dependencies — see config/synApps/README.md
MODULES=(
  seq:"${SNCSEQ_TAG}"
  sscan:"${SSCAN_TAG}"
  calc:"${CALC_TAG}"
  asyn:"${ASYN_TAG}"
  autosave:"${AUTOSAVE_TAG}"
  busy:"${BUSY_TAG}"
  iocStats:"${IOCSTATS_TAG}"
)

mkdir -p "${SUPPORT}"

for entry in "${MODULES[@]}"; do
  mod="${entry%%:*}"
  tag="${entry#*:}"
  dest="${SUPPORT}/${mod}"
  url="${SYNAPPS_BASE}/${mod}.git"
  clone_or_update "${url}" "${dest}"
  checkout_tag "${dest}" "${tag}"
  install_synapps_release_local "${dest}"
  if synapps_module_installed "${tag}" "${dest}"; then
    echo "==> Skipping ${mod} (${tag} already installed)"
    continue
  fi
  build_module "${dest}"
  mark_synapps_installed "${tag}" "${dest}"
done

echo "synApps support modules installed under ${SUPPORT}"
