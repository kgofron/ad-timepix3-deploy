#!/usr/bin/env bash
# ad-timepix3-deploy — boot ADTimePix3 IOC (iocTimePix).
# Author: Kazimierz Gofron (ORNL)
# Copyright (c) UT-Battelle, LLC, Oak Ridge National Laboratory
# SPDX-License-Identifier: MIT
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib.sh"
load_config
epics_env

IOC_DIR="${ADTIMEPix3_HOME}/iocs/tpx3IOC/iocBoot/iocTimePix"
if [[ ! -d "${IOC_DIR}" ]]; then
  echo "IOC not found at ${IOC_DIR} — run 04-install-adtimepix3-mpx3.sh first" >&2
  exit 1
fi

STARTUP="${IOC_STARTUP:-}"
if [[ -z "${STARTUP}" ]]; then
  if [[ -f "${IOC_DIR}/st_mpx3.cmd" ]]; then
    STARTUP=st_mpx3.cmd
  else
    STARTUP=st.cmd
  fi
fi

STARTUP_PATH="${IOC_DIR}/${STARTUP}"
if [[ ! -f "${STARTUP_PATH}" ]]; then
  echo "IOC startup script not found: ${STARTUP_PATH}" >&2
  echo "Set IOC_STARTUP in config/site.env (e.g. st_mpx3.cmd or st.cmd)" >&2
  exit 1
fi

cd "${IOC_DIR}"
echo "Starting IOC in ${IOC_DIR}"
echo "  startup=${STARTUP}  PREFIX=${IOC_PREFIX} (site.env; PV prefix is set in ${STARTUP})  SERVER_URL=${SERVER_URL}"
echo "Ensure Serval is running before acquire."

export SERVER_URL
exec "./${STARTUP}"
