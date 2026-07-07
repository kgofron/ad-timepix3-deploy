#!/usr/bin/env bash
# ad-timepix3-deploy — run full EPICS / areaDetector / Phoebus install pipeline.
# Author: Kazimierz Gofron (ORNL)
# Copyright (c) UT-Battelle, LLC, Oak Ridge National Laboratory
# SPDX-License-Identifier: MIT
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib.sh"
load_config

run() {
  echo ""
  echo "########################################"
  echo "# $*"
  echo "########################################"
  "$@"
}

run "${SCRIPT_DIR}/00-install-prerequisites-ubuntu24.sh"
run "${SCRIPT_DIR}/01-install-epics-base.sh"
run "${SCRIPT_DIR}/02-install-synapps-modules.sh"
run "${SCRIPT_DIR}/03-install-areadetector-core.sh"
run "${SCRIPT_DIR}/04-install-adtimepix3-mpx3.sh"
run "${SCRIPT_DIR}/05-install-phoebus.sh"

echo ""
echo "Deployment complete."
echo "  source ${EPICS_BASE}/setEpicsEnv.sh    # caget, caput, …"
echo "  ./scripts/setup-epics-shell.sh        # optional: add to ~/.bashrc"
echo "  Edit IOC SERVER_URL in config/site.env, then: ${SCRIPT_DIR}/launch-ioc.sh"
