#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib.sh"
load_config

mkdir -p "${GUI_ROOT}"
DEST="${PHOEBUS_HOME}"
ZIP_URL="https://github.com/ControlSystemStudio/phoebus/releases/download/v${PHOEBUS_VERSION}/${PHOEBUS_PRODUCT}"
TMP="$(mktemp -d)"

if [[ -x "${DEST}/phoebus.sh" ]]; then
  echo "Phoebus already present at ${DEST}"
else
  echo "==> Downloading Phoebus ${PHOEBUS_VERSION}"
  wget -q -O "${TMP}/phoebus.zip" "${ZIP_URL}"
  unzip -q "${TMP}/phoebus.zip" -d "${TMP}"
  # Archive usually contains a single product-* directory
  PRODUCT_DIR="$(find "${TMP}" -maxdepth 1 -type d -name 'product-*' | head -1)"
  if [[ -z "${PRODUCT_DIR}" ]]; then
    echo "Unexpected Phoebus archive layout" >&2
    exit 1
  fi
  rm -rf "${DEST}"
  mv "${PRODUCT_DIR}" "${DEST}"
fi

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

chmod +x "${DEST}/phoebus.sh"
echo "Phoebus installed: ${DEST}"
echo "Launch: ${SCRIPT_DIR}/launch-phoebus.sh"
