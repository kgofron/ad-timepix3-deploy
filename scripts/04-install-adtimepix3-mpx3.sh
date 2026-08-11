#!/usr/bin/env bash
# ad-timepix3-deploy — clone and build ADTimePix3 MediPix3-capable driver (kgofron fork / R1-7-0).
# Author: Kazimierz Gofron (ORNL)
# Copyright (c) UT-Battelle, LLC, Oak Ridge National Laboratory
# SPDX-License-Identifier: MIT
# Requires asyn >= R4-45 and ADCore with destructible driver support.
# Upstream PR: https://github.com/areaDetector/ADTimePix3/pull/15
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib.sh"
load_config

DEST="${ADTIMEPix3_HOME:-${AREA_DETECTOR}/${ADTIMEPix3_DIRNAME}}"
REF="${ADTIMEPix3_TAG:-${ADTIMEPix3_BRANCH:-master}}"

# Clone/update on branch for fetchability; then pin to TAG when set.
if [[ -n "${ADTIMEPix3_TAG:-}" ]]; then
  clone_or_update "${ADTIMEPix3_REPO}" "${DEST}" "${ADTIMEPix3_BRANCH:-master}"
  checkout_tag "${DEST}" "${ADTIMEPix3_TAG}"
else
  clone_or_update "${ADTIMEPix3_REPO}" "${DEST}" "${REF}"
fi

# Driver RELEASE.local + refresh umbrella RELEASE_* (includes ADTIMEPIX path)
install_areadetector_configure

# Bundled tpx3Support (CPR 1.14.2, nlohmann/json) builds with the driver
build_module "${DEST}"

echo "ADTimePix3 built at ${DEST} (ref ${REF})"
echo "IOC: ${DEST}/iocs/tpx3IOC/iocBoot/iocTimePix"
echo "Screens: ${DEST}/tpx3App/op/bob/"
echo "Upstream merge status: https://github.com/areaDetector/ADTimePix3/pull/15"
