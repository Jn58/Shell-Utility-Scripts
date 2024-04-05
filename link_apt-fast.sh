#!/bin/bash
# Install command
# curl https://raw.githubusercontent.com/Jn58/Shell-Utility-Scripts/main/link_apt-fast.sh | sh

set -e

if [ $(id -u) -ne 0 ]; then
    SUDO="sudo "
else
    SUDO=""
fi

APT_GET=$(${SUDO}which apt-get)
if [ -L $APT_GET ]; then
    LINK=$(${SUDO}readlink $APT_GET)
    if [ $(${SUDO}basename $LINK) = "apt-fast" ]; then
        echo 'apt-fast is already applied'
        exit 0
    else
        echo '$LINK is linked to apt-get'
        exit 1
    fi
fi


APT_PATH=$(${SUDO}dirname $APT_GET)
FAST_PATH=$(${SUDO}bash -c "echo \$PATH | cut -d: -f 1")

if [ $APT_PATH = $FAST_PATH ]; then
    echo "apt-get is in first \$PATH";
    exit 1;
fi

if ! ${SUDO}which apt-fast; then
    if ! ${SUDO}which add-apt-repository; then
        ${SUDO}apt-get update;
        ${SUDO}apt-get install -y software-properties-common;
    fi
    ${SUDO}add-apt-repository -y ppa:apt-fast/stable
    ${SUDO}apt-get update;
    ${SUDO}bash -c "DEBIAN_FRONTEND=noninteractive apt-get install -y apt-fast";
fi

if ${SUDO}grep "^_APTMGR=" /etc/apt-fast.conf; then
    ${SUDO}sed -i "s|^_APTMGR=.*|_APTMGR=${APT_GET}|" /etc/apt-fast.conf;
else
    ${SUDO}tee -a "_APTMGR=${APT_GET}" /etc/apt-fast.conf;
fi
if ${SUDO}grep "^DOWNLOADBEFORE=" /etc/apt-fast.conf; then
    ${SUDO}sed -i "s|^DOWNLOADBEFORE=.*|DOWNLOADBEFORE=true|" /etc/apt-fast.conf;
else
    ${SUDO}tee -a "DOWNLOADBEFORE=true" /etc/apt-fast.conf;
fi
NUM=$(nproc)
if ${SUDO}grep "^_MAXNUM=" /etc/apt-fast.conf; then
    ${SUDO}sed -i "s|^_MAXNUM=.*|_MAXNUM=${NUM}|" /etc/apt-fast.conf;
else
    ${SUDO}tee -a "_MAXNUM=${NUM}" /etc/apt-fast.conf;
fi
if ${SUDO}grep "^_SPLITCON=" /etc/apt-fast.conf; then
    ${SUDO}sed -i "s|^_SPLITCON=.*|_SPLITCON=${NUM}|" /etc/apt-fast.conf;
else
    ${SUDO}tee -a "_SPLITCON=${NUM}" /etc/apt-fast.conf;
fi
if [ $NUM -gt 16 ]; then
    NUM=16
fi
if ${SUDO}grep "^_MAXCONPERSRV=" /etc/apt-fast.conf; then
    ${SUDO}sed -i "s|^_MAXCONPERSRV=.*|_MAXCONPERSRV=${NUM}|" /etc/apt-fast.conf;
else
    ${SUDO}tee -a "_MAXCONPERSRV=${NUM}" /etc/apt-fast.conf;
fi

${SUDO}ln -s $(${SUDO}which apt-fast) $FAST_PATH/apt-get
${SUDO}ln -s $(${SUDO}which apt-fast) $FAST_PATH/apt
