#!/usr/bin/env bash
# ad-timepix3-deploy — download and configure Phoebus (SNS or GitHub product).
# Author: Kazimierz Gofron (ORNL)
# Copyright (c) UT-Battelle, LLC, Oak Ridge National Laboratory
# SPDX-License-Identifier: MIT
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
DRIVER_BOB="${ADTIMEPix3_HOME}/tpx3App/op/bob"
MODEL_PATHS="${BOB_ROOT}:${DRIVER_BOB}"

if [[ ! -f "${SETTINGS}" ]]; then
  cp "${EXAMPLE}" "${SETTINGS}"
fi
# Always refresh display search paths (site bob + driver op/bob)
sed -i "s|@BOB_ROOT@|${BOB_ROOT}|g" "${SETTINGS}"
sed -i "s|@ADTIMEPix3_BOB@|${DRIVER_BOB}|g" "${SETTINGS}"
if grep -q '^org.csstudio.display/model/paths=' "${SETTINGS}"; then
  sed -i "s|^org.csstudio.display/model/paths=.*|org.csstudio.display/model/paths=${MODEL_PATHS}|" "${SETTINGS}"
fi

# Deploy site bob tree from this repo
mkdir -p "${BOB_ROOT}"
if [[ -d "${REPO_ROOT}/bob" ]]; then
  rsync -a "${REPO_ROOT}/bob/" "${BOB_ROOT}/"
fi

# ADCore R3-15 .bob screens from built checkout (replaces any legacy vendored .opi)
install_adcore_phoebus_bob

# Expert embeds (ADSetup, Acquire, Detector, Mpx3Status, …) from driver checkout
EXPERT_BOB="${BOB_ROOT}/ADet/R3-15/ADTimePix3/R1-0"
if [[ -d "${DRIVER_BOB}" ]]; then
  mkdir -p "${EXPERT_BOB}"
  rsync -a \
    --exclude 'MediPix3/MediPix3.bob' \
    --exclude 'TimePix3.bob' \
    "${DRIVER_BOB}/" "${EXPERT_BOB}/"
  echo "Expert driver embeds synced: ${EXPERT_BOB}"
else
  echo "WARN: ${DRIVER_BOB} missing — run 04-install-adtimepix3-mpx3.sh for Expert ADSetup/Acquire panels" >&2
fi

echo "Phoebus ready: ${DEST} (source: ${PHOEBUS_SOURCE:-sns})"
echo "Launch: ${SCRIPT_DIR}/launch-phoebus.sh"
