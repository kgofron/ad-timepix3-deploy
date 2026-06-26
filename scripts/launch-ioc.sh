#!/usr/bin/env bash
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

cd "${IOC_DIR}"
echo "Starting IOC in ${IOC_DIR}"
echo "  PREFIX=${IOC_PREFIX}  SERVER_URL=${SERVER_URL}"
echo "Ensure Serval is running before acquire."

# Optional: patch st_base.cmd SERVER_URL via env (site-specific st.cmd may override)
export SERVER_URL
./st.cmd
