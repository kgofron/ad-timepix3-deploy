#!/usr/bin/env bash
# ad-timepix3-deploy — clone and build ADTimePix3_mpx3 MediPix3 driver (kgofron fork).
# Author: Kazimierz Gofron (ORNL)
# Copyright (c) UT-Battelle, LLC, Oak Ridge National Laboratory
# SPDX-License-Identifier: MIT
# Requires asyn >= R4-45 and ADCore with destructible driver support.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib.sh"
load_config

DEST="${ADTIMEPix3_HOME:-${AREA_DETECTOR}/${ADTIMEPix3_DIRNAME}}"

clone_or_update "${ADTIMEPix3_REPO}" "${DEST}" "${ADTIMEPix3_BRANCH}"

# Driver RELEASE.local + refresh umbrella RELEASE_* (includes ADTIMEPIX path)
install_areadetector_configure

# Bundled tpx3Support (CPR 1.14.2, nlohmann/json) builds with the driver
build_module "${DEST}"

echo "ADTimePix3_mpx3 built at ${DEST}"
echo "IOC: ${DEST}/iocs/tpx3IOC/iocBoot/iocTimePix"
echo "Screens: ${DEST}/tpx3App/op/bob/"
