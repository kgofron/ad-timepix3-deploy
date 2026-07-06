#!/usr/bin/env bash
# Ubuntu 24.04 packages for EPICS Base, areaDetector, ADTimePix3 (C++17), Phoebus.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib.sh"
load_config

if [[ "$(id -u)" -ne 0 ]]; then
  SUDO=sudo
else
  SUDO=
fi

echo "==> Installing Ubuntu 24.04 build prerequisites"
${SUDO} apt-get update
${SUDO} apt-get install -y \
  build-essential \
  git \
  wget \
  curl \
  ca-certificates \
  unzip \
  pkg-config \
  re2c \
  libreadline-dev \
  libncurses-dev \
  libtiff-dev \
  libxml2-dev \
  zlib1g-dev \
  libjpeg-dev \
  libbz2-dev \
  liblzma-dev \
  libssl-dev \
  libcurl4-openssl-dev \
  openjdk-17-jre-headless \
  openjdk-17-jdk-headless

echo "==> Prerequisites installed."
