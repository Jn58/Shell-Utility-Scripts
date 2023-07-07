#!/bin/bash

set -e
if [ ! "$BASH_VERSION" ] ; then
    exec /bin/bash "$0" "$@"
fi

set -eE -o functrace

failure() {
  local lineno=$1
  local msg=$2
  echo "Failed at $lineno: $msg"
}

trap 'failure ${LINENO} "$BASH_COMMAND"' ERR

sudo apt-get update && sudo apt-get install bash-completion curl tar bzip2 zstd

ARCH=$(uname -m)
OS=$(uname)

if [[ "$OS" == "Linux" ]]; then
  PLATFORM="linux"
  if [[ "$ARCH" == "aarch64" ]]; then
    ARCH="aarch64";
  elif [[ $ARCH == "ppc64le" ]]; then
    ARCH="ppc64le";
  else
    ARCH="64";
  fi
fi

if [[ "$OS" == "Darwin" ]]; then
  PLATFORM="osx";
  if [[ "$ARCH" == "arm64" ]]; then
    ARCH="arm64";
  else
    ARCH="64"
  fi
fi

mkdir -p ~/.local/bin
curl -Ls https://micro.mamba.pm/api/micromamba/$PLATFORM-$ARCH/latest | tar -xvj -C ~/.local/bin/ --strip-components=1 bin/micromamba
PREFIXLOCATION="~/micromamba"
~/.local/bin/micromamba shell init -p $PREFIXLOCATION
