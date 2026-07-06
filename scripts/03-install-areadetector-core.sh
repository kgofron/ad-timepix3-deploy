#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib.sh"
load_config

mkdir -p "${AREA_DETECTOR}"

# areaDetector umbrella (configure/Makefile only — not all drivers)
AREA_TOP_REPO="${AREA_DETECTOR_TOP_REPO:-https://github.com/areaDetector/areaDetector.git}"
if [[ ! -f "${AREA_DETECTOR}/configure/CONFIG_SITE" ]]; then
  echo "==> Cloning areaDetector top-level tree (configure + Makefile)"
  clone_or_update "${AREA_TOP_REPO}" "${AREA_DETECTOR}/_top"
  rsync -a "${AREA_DETECTOR}/_top/configure/" "${AREA_DETECTOR}/configure/"
  rsync -a "${AREA_DETECTOR}/_top/Makefile" "${AREA_DETECTOR}/" 2>/dev/null || true
  rm -rf "${AREA_DETECTOR}/_top"
fi

# RELEASE_PRODS.local, RELEASE_LIBS.local, CONFIG_SITE.local for /epics/support/areaDetector
install_areadetector_configure

ADSUPPORT_REPO="${ADSUPPORT_REPO:-https://github.com/areaDetector/ADSupport.git}"
ADCORE_REPO="${ADCORE_REPO:-https://github.com/areaDetector/ADCore.git}"

clone_or_update "${ADSUPPORT_REPO}" "${AREA_DETECTOR}/ADSupport"
checkout_tag "${AREA_DETECTOR}/ADSupport" "${ADSUPPORT_TAG}"
build_module "${AREA_DETECTOR}/ADSupport"

clone_or_update "${ADCORE_REPO}" "${AREA_DETECTOR}/ADCore"
checkout_tag "${AREA_DETECTOR}/ADCore" "${ADCORE_TAG}"
build_module "${AREA_DETECTOR}/ADCore"

install_adcore_ioc_boot_files

echo "ADSupport and ADCore built under ${AREA_DETECTOR}"
