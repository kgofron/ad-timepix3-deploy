#!/usr/bin/env bash
# Write ${EPICS_BASE}/setEpicsEnv.sh (PATH, LD_LIBRARY_PATH for caget, caput, …).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib.sh"
load_config

install_epics_env_script

echo ""
echo "Per-shell:  source ${EPICS_BASE}/setEpicsEnv.sh"
echo "Login shells: ./scripts/setup-epics-shell.sh  (adds source line to ~/.bashrc)"
