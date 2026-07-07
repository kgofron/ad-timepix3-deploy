#!/usr/bin/env bash
# ad-timepix3-deploy — common helpers for deploy scripts.
# Author: Kazimierz Gofron (ORNL)
# Copyright (c) UT-Battelle, LLC, Oak Ridge National Laboratory
# SPDX-License-Identifier: MIT
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
  export EPICS_BASE EPICS_HOST_ARCH
  if [[ -f "${EPICS_BASE}/setEpicsEnv.sh" ]]; then
    # shellcheck disable=SC1091
    source "${EPICS_BASE}/setEpicsEnv.sh"
  else
    local bin="${EPICS_BASE}/bin/${EPICS_HOST_ARCH}"
    local lib="${EPICS_BASE}/lib/${EPICS_HOST_ARCH}"
    export PATH="${bin}:${PATH}"
    export LD_LIBRARY_PATH="${lib}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
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
    -e "s|@EPICS_HOST_ARCH@|${EPICS_HOST_ARCH}|g" \
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

install_asyn_config_site_local() {
  local module_top="$1"
  local template="${REPO_ROOT}/config/synApps/CONFIG_SITE.local.asyn.template"
  local dest="${module_top}/configure/CONFIG_SITE.local"
  cp "${template}" "${dest}"
  echo "Wrote ${dest}"
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

# EPICS Base does not ship setEpicsEnv.sh — site script adds bin/ to PATH (caget, caput, …).
install_epics_env_script() {
  local template="${REPO_ROOT}/config/setEpicsEnv.sh.template"
  local dest="${EPICS_BASE}/setEpicsEnv.sh"
  if [[ ! -d "${EPICS_BASE}" ]]; then
    echo "Missing ${EPICS_BASE} — run 01-install-epics-base.sh first" >&2
    exit 1
  fi
  render_template "${template}" "${dest}"
  chmod +x "${dest}"
}

# Download and unpack Phoebus product (GitHub tar.gz or SNS product-sns zip).
install_phoebus_product() {
  local dest="${PHOEBUS_HOME}"
  local source="${PHOEBUS_SOURCE:-sns}"
  local tmp extract product_dir jdk_dir url archive

  if [[ -x "${dest}/phoebus.sh" ]]; then
    echo "Phoebus already present at ${dest}"
    return 0
  fi

  tmp="$(mktemp -d)"
  extract="${tmp}/extract"
  mkdir -p "${extract}"

  case "${source}" in
    sns)
      url="${PHOEBUS_SNS_URL}"
      archive="${tmp}/phoebus.zip"
      echo "==> Downloading SNS Phoebus from ${url}"
      wget -O "${archive}" "${url}"
      if [[ ! -s "${archive}" ]] || [[ "$(stat -c%s "${archive}")" -lt 1000000 ]]; then
        echo "SNS Phoebus download failed or archive too small — check VPN/network" >&2
        rm -rf "${tmp}"
        exit 1
      fi
      unzip -q "${archive}" -d "${extract}"
      ;;
    github)
      url="https://github.com/ControlSystemStudio/phoebus/releases/download/v${PHOEBUS_VERSION}/${PHOEBUS_GITHUB_PRODUCT}"
      archive="${tmp}/phoebus.tar.gz"
      echo "==> Downloading Phoebus ${PHOEBUS_VERSION} from GitHub"
      wget -O "${archive}" "${url}"
      if [[ ! -s "${archive}" ]]; then
        echo "GitHub Phoebus download failed: ${url}" >&2
        rm -rf "${tmp}"
        exit 1
      fi
      tar xzf "${archive}" -C "${extract}"
      ;;
    *)
      echo "Unknown PHOEBUS_SOURCE=${source} (use github or sns)" >&2
      rm -rf "${tmp}"
      exit 1
      ;;
  esac

  product_dir="$(find "${extract}" -maxdepth 1 -type d \( -name 'product-sns-*' -o -name 'product-*' \) | head -1)"
  if [[ -z "${product_dir}" ]] || [[ ! -f "${product_dir}/phoebus.sh" ]]; then
    echo "Unexpected Phoebus archive layout under ${extract}" >&2
    rm -rf "${tmp}"
    exit 1
  fi

  jdk_dir="${extract}/jdk"
  rm -rf "${dest}"
  mv "${product_dir}" "${dest}"

  if [[ -d "${jdk_dir}" ]]; then
    rm -rf "${GUI_ROOT}/jdk"
    mv "${jdk_dir}" "${GUI_ROOT}/jdk"
    echo "Installed bundled JDK at ${GUI_ROOT}/jdk"
  fi

  chmod +x "${dest}/phoebus.sh"
  rm -rf "${tmp}"
  echo "Phoebus product installed at ${dest}"
}

# ADCore ships EXAMPLE_* iocBoot files; site copies are gitignored (areaDetector install guide).
install_adcore_ioc_boot_files() {
  local ioc_boot="${AREA_DETECTOR}/ADCore/iocBoot"
  local pair src_name dst_name src dst

  for pair in \
    "EXAMPLE_commonPlugins.cmd:commonPlugins.cmd" \
    "EXAMPLE_commonPlugin_settings.req:commonPlugin_settings.req"
  do
    src_name="${pair%%:*}"
    dst_name="${pair##*:}"
    src="${ioc_boot}/${src_name}"
    dst="${ioc_boot}/${dst_name}"
    if [[ ! -f "${src}" ]]; then
      echo "Missing ${src} — ADCore iocBoot not installed?" >&2
      exit 1
    fi
    if [[ -f "${dst}" ]]; then
      echo "Keeping existing ${dst}"
    else
      cp "${src}" "${dst}"
      echo "Copied ${src_name} -> ${dst_name} under ${ioc_boot}"
    fi
  done
}
