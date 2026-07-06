#!/usr/bin/env bash
# synApps modules required for areaDetector IOC applications.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib.sh"
load_config

SYNAPPS_BASE="${SYNAPPS_GIT_BASE:-https://github.com/epics-modules}"

# Build order: calc depends on sscan; keep leaf modules before calc.
MODULES=(
  asyn:"${ASYN_TAG}"
  autosave:"${AUTOSAVE_TAG}"
  busy:"${BUSY_TAG}"
  seq:"${SNCSEQ_TAG}"
  sscan:"${SSCAN_TAG}"
  calc:"${CALC_TAG}"
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
  build_module "${dest}"
done

echo "synApps support modules installed under ${SUPPORT}"
