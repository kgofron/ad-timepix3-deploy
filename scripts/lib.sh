#!/usr/bin/env bash
# Common helpers for deploy scripts.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

load_config() {
  local site="${REPO_ROOT}/config/site.env"
  local versions="${REPO_ROOT}/config/versions.env"
  if [[ ! -f "${site}" ]]; then
    echo "Missing ${site} — copy config/site.env.example to config/site.env" >&2
    exit 1
  fi
  # shellcheck disable=SC1090
  source "${site}"
  # shellcheck disable=SC1090
  source "${versions}"
  : "${EPICS_ROOT:?}"
  : "${SUPPORT:?}"
  : "${EPICS_BASE:?}"
  : "${AREA_DETECTOR:?}"
  : "${EPICS_HOST_ARCH:?}"
  if [[ -z "${MAKE_JOBS:-}" ]]; then
    MAKE_JOBS="$(nproc)"
  fi
}

epics_env() {
  export EPICS_BASE
  if [[ -f "${EPICS_BASE}/setEpicsEnv.sh" ]]; then
    # shellcheck disable=SC1091
    source "${EPICS_BASE}/setEpicsEnv.sh"
  fi
}

clone_or_update() {
  local url="$1"
  local dest="$2"
  local branch="${3:-}"
  local depth="${GIT_DEPTH:-1}"
  if [[ -d "${dest}/.git" ]]; then
    echo "==> Updating ${dest}"
    git -C "${dest}" fetch --tags origin
    if [[ -n "${branch}" ]]; then
      git -C "${dest}" checkout "${branch}"
      git -C "${dest}" pull --ff-only origin "${branch}" || true
    fi
  else
    echo "==> Cloning ${url} -> ${dest}"
    local args=()
    if [[ "${depth}" != "0" ]]; then
      args+=(--depth "${depth}")
    fi
    if [[ -n "${branch}" ]]; then
      args+=(-b "${branch}")
    fi
    git clone "${args[@]}" "${url}" "${dest}"
  fi
}

checkout_tag() {
  local dest="$1"
  local tag="$2"
  echo "==> Checking out ${tag} in ${dest}"
  git -C "${dest}" fetch --tags origin
  git -C "${dest}" checkout "${tag}"
}

build_module() {
  local top="$1"
  echo "==> Building ${top}"
  epics_env
  make -C "${top}" -j"${MAKE_JOBS}" install
}

render_template() {
  local template="$1"
  local dest="$2"
  mkdir -p "$(dirname "${dest}")"
  sed \
    -e "s|@SUPPORT@|${SUPPORT}|g" \
    -e "s|@EPICS_BASE@|${EPICS_BASE}|g" \
    -e "s|@AREA_DETECTOR@|${AREA_DETECTOR}|g" \
    -e "s|@ADTIMEPix3_DIRNAME@|${ADTIMEPix3_DIRNAME}|g" \
    -e "s|@ADTIMEPix3_HOME@|${ADTIMEPix3_HOME}|g" \
    "${template}" > "${dest}"
  echo "Wrote ${dest}"
}

install_areadetector_configure() {
  local cfg="${REPO_ROOT}/config/areaDetector"
  mkdir -p "${AREA_DETECTOR}/configure"

  render_template \
    "${cfg}/RELEASE_LIBS.local.template" \
    "${AREA_DETECTOR}/configure/RELEASE_LIBS.local"

  render_template \
    "${cfg}/RELEASE_PRODS.local.template" \
    "${AREA_DETECTOR}/configure/RELEASE_PRODS.local"

  render_template \
    "${cfg}/CONFIG_SITE.local.template" \
    "${AREA_DETECTOR}/configure/CONFIG_SITE.local"

  if [[ -d "${ADTIMEPix3_HOME}" ]]; then
    render_template \
      "${cfg}/ADTimePix3_RELEASE.local.template" \
      "${ADTIMEPix3_HOME}/configure/RELEASE.local"
    render_template \
      "${cfg}/ADTimePix3_RELEASE.local.template" \
      "${ADTIMEPix3_HOME}/iocs/tpx3IOC/configure/RELEASE.local"
  fi
}

install_synapps_release_local() {
  local module_top="$1"
  local template="${REPO_ROOT}/config/synApps/RELEASE.local.template"
  local dest="${module_top}/configure/RELEASE.local"
  render_template "${template}" "${dest}"
}

# True when module at tag is already installed (skip rebuild on re-run).
synapps_module_installed() {
  local tag="$1"
  local dest="$2"
  local stamp="${dest}/.deploy-installed"
  local lib="${dest}/lib/${EPICS_HOST_ARCH}"
  if [[ "${FORCE_SYNAPPS_REBUILD:-}" == "1" ]]; then
    return 1
  fi
  [[ -f "${stamp}" ]] || return 1
  grep -qxF "${tag}" "${stamp}" || return 1
  [[ -d "${lib}" ]] || return 1
  [[ -n "$(ls -A "${lib}" 2>/dev/null)" ]]
}

mark_synapps_installed() {
  local tag="$1"
  local dest="$2"
  echo "${tag}" > "${dest}/.deploy-installed"
}

install_release_local() {
  local example="${REPO_ROOT}/config/RELEASE.local.example"
  local dest="$1"
  mkdir -p "$(dirname "${dest}")"
  if [[ ! -f "${dest}" ]]; then
    cp "${example}" "${dest}"
    echo "Installed ${dest} from example — review paths."
  fi
}
