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

resolve_phoebus_screen() {
  local screen="$1"
  local candidate

  if [[ -z "${screen}" ]]; then
    return 0
  fi

  if [[ -f "${screen}" ]]; then
    echo "${screen}"
    return 0
  fi

  for candidate in \
    "${ADTIMEPix3_HOME}/tpx3App/op/bob/${screen}" \
    "${BOB_ROOT}/${screen}" \
    "${BOB_ROOT}/main/${screen}"
  do
    if [[ -f "${candidate}" ]]; then
      echo "${candidate}"
      return 0
    fi
  done

  echo "Phoebus screen not found: ${screen}" >&2
  echo "  ${ADTIMEPix3_HOME}/tpx3App/op/bob/" >&2
  echo "  ${BOB_ROOT}/" >&2
  ls -1 "${ADTIMEPix3_HOME}/tpx3App/op/bob/"*.bob 2>/dev/null | head -5 >&2 || true
  exit 1
}

SCREEN="${1:-${PHOEBUS_DEFAULT_SCREEN:-}}"

if [[ ! -x "${PHOEBUS_HOME}/phoebus.sh" ]]; then
  echo "Phoebus not installed — run 05-install-phoebus.sh" >&2
  exit 1
fi

ARGS=(-settings "${PHOEBUS_HOME}/settings.ini")
if [[ -n "${SCREEN}" ]]; then
  RESOLVED="$(resolve_phoebus_screen "${SCREEN}")"
  echo "Opening ${RESOLVED}"
  ARGS+=(-resource "${RESOLVED}")
fi

exec "${PHOEBUS_HOME}/phoebus.sh" "${ARGS[@]}"
