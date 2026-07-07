#!/usr/bin/env bash
# ad-timepix3-deploy — add source setEpicsEnv.sh to ~/.bashrc (idempotent).
# Author: Kazimierz Gofron (ORNL)
# Copyright (c) UT-Battelle, LLC, Oak Ridge National Laboratory
# SPDX-License-Identifier: MIT
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib.sh"
load_config

install_epics_env_script

MARKER="# EPICS environment (ad-timepix3-deploy)"
SOURCE_LINE="source ${EPICS_BASE}/setEpicsEnv.sh"
RC="${HOME}/.bashrc"

if [[ ! -f "${RC}" ]]; then
  touch "${RC}"
fi

if grep -qF "${SOURCE_LINE}" "${RC}" 2>/dev/null; then
  echo "Already configured in ${RC}"
else
  {
    echo ""
    echo "${MARKER}"
    echo "${SOURCE_LINE}"
  } >> "${RC}"
  echo "Appended to ${RC}:"
  echo "  ${SOURCE_LINE}"
  echo "Open a new login shell or: source ${RC}"
fi
