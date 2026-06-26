#!/usr/bin/env bash
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
echo "  source ${EPICS_BASE:-/epics/epics-base}/setEpicsEnv.sh"
echo "  Edit IOC SERVER_URL in config/site.env, then: ${SCRIPT_DIR}/launch-ioc.sh"
