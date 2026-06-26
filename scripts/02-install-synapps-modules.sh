#!/usr/bin/env bash
# synApps modules required for areaDetector IOC applications.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib.sh"
load_config

SYNAPPS_BASE="${SYNAPPS_GIT_BASE:-https://github.com/epics-modules}"

declare -A MODULES=(
  [asyn]="${ASYN_TAG}"
  [autosave]="${AUTOSAVE_TAG}"
  [busy]="${BUSY_TAG}"
  [calc]="${CALC_TAG}"
  [seq]="${SNCSEQ_TAG}"
  [sscan]="${SSCAN_TAG}"
  [iocStats]="${IOCSTATS_TAG}"
)

mkdir -p "${SUPPORT}"

for mod in "${!MODULES[@]}"; do
  tag="${MODULES[$mod]}"
  dest="${SUPPORT}/${mod}"
  url="${SYNAPPS_BASE}/${mod}.git"
  clone_or_update "${url}" "${dest}"
  checkout_tag "${dest}" "${tag}"
  build_module "${dest}"
done

echo "synApps support modules installed under ${SUPPORT}"
