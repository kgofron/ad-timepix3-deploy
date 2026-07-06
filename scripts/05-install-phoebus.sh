#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib.sh"
load_config

mkdir -p "${GUI_ROOT}"
DEST="${PHOEBUS_HOME}"

install_phoebus_product

SETTINGS="${DEST}/settings.ini"
EXAMPLE="${REPO_ROOT}/config/phoebus-settings.ini.example"
if [[ ! -f "${SETTINGS}" ]]; then
  cp "${EXAMPLE}" "${SETTINGS}"
  # Point Phoebus at site bob tree + driver screens
  sed -i "s|@BOB_ROOT@|${BOB_ROOT}|g" "${SETTINGS}"
  sed -i "s|@ADTIMEPix3_BOB@|${ADTIMEPix3_HOME}/tpx3App/op/bob|g" "${SETTINGS}"
fi

# Deploy simplified main screens from this repo
mkdir -p "${BOB_ROOT}"
if [[ -d "${REPO_ROOT}/bob" ]]; then
  rsync -a "${REPO_ROOT}/bob/" "${BOB_ROOT}/"
fi

echo "Phoebus ready: ${DEST} (source: ${PHOEBUS_SOURCE:-github})"
echo "Launch: ${SCRIPT_DIR}/launch-phoebus.sh"
