#!/usr/bin/env bash
# ad-timepix3-deploy — regenerate ${EPICS_BASE}/setEpicsEnv.sh (PATH for caget, caput, …).
# Author: Kazimierz Gofron (ORNL)
# Copyright (c) UT-Battelle, LLC, Oak Ridge National Laboratory
# SPDX-License-Identifier: MIT
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib.sh"
load_config

install_epics_env_script

echo ""
echo "Per-shell:  source ${EPICS_BASE}/setEpicsEnv.sh"
echo "Login shells: ./scripts/setup-epics-shell.sh  (adds source line to ~/.bashrc)"
