#!/usr/bin/env bash
# Write areaDetector configure/RELEASE_*.local and CONFIG_SITE.local for this site.
# Paths come from config/site.env (default: /epics/support/areaDetector).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib.sh"
load_config

install_areadetector_configure

echo ""
echo "areaDetector configure ready under ${AREA_DETECTOR}/configure/"
echo "  RELEASE_LIBS.local   — ADSupport, ADCore, driver library builds"
echo "  RELEASE_PRODS.local  — IOC builds (synApps + ADTIMEPIX)"
echo "  CONFIG_SITE.local    — ADSupport library flags (Ubuntu 24.04)"
if [[ -d "${ADTIMEPix3_HOME}" ]]; then
  echo "  ${ADTIMEPix3_HOME}/configure/RELEASE.local"
fi
