#!/usr/bin/env bash
# ad-timepix3-deploy — start Phoebus with site settings.ini.
# Author: Kazimierz Gofron (ORNL)
# Copyright (c) UT-Battelle, LLC, Oak Ridge National Laboratory
# SPDX-License-Identifier: MIT
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib.sh"
load_config

SCREEN="${1:-}"

if [[ ! -x "${PHOEBUS_HOME}/phoebus.sh" ]]; then
  echo "Phoebus not installed — run 05-install-phoebus.sh" >&2
  exit 1
fi

ARGS=(-settings "${PHOEBUS_HOME}/settings.ini")
if [[ -n "${SCREEN}" ]]; then
  ARGS+=(-resource "${SCREEN}")
fi

exec "${PHOEBUS_HOME}/phoebus.sh" "${ARGS[@]}"
