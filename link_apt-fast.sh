#!/bin/sh

set -e

APT_GET=$(which apt-get)
if [ -L $APT_GET ]; then
    LINK=$(readlink $APT_GET)
    if [ $(basename $LINK) == "apt-fast" ]; then
        echo 'apt-fast is already applied'
        exit 0
    else
        echo '$LINK is linked to apt-get'
        exit 1
    fi
fi

if [ $(id -u) -ne 0 ]; then
    exec sudo /bin/sh "$0" "$@"
fi

APT_PATH=$(dirname $APT_GET)
FAST_PATH=$(echo $PATH | cut -d: -f 1)

if [ $APT_PATH == $FAST_PATH ]; then
    echo "apt-get is in first \$PATH";
    exit 1;
fi

if ! which apt-fast; then
    if ! which add-apt-repository; then
        apt-get update;
        apt-get install -y software-properties-common;
    fi
    add-apt-repository -y ppa:apt-fast/stable
    apt-get update;
    DEBIAN_FRONTEND=noninteractive apt-get install -y apt-fast;
    if grep "^_APTMGR=" /etc/apt-fast.conf; then
        sed -i "s|^_APTMGR=.*|_APTMGR=${APT_GET}|" /etc/apt-fast.conf;
    else 
        echo "_APTMGR=${APT_GET}" >> /etc/apt-fast.conf;
    fi
    if grep "^DOWNLOADBEFORE=" /etc/apt-fast.conf; then
        sed -i "s|^DOWNLOADBEFORE=.*|DOWNLOADBEFORE=true|" /etc/apt-fast.conf;
    else
        echo "DOWNLOADBEFORE=true" >> /etc/apt-fast.conf;
    fi
    NUM=$(nproc)
    if grep "^_MAXNUM=" /etc/apt-fast.conf; then
        sed -i "s|^_MAXNUM=.*|_MAXNUM=${NUM}|" /etc/apt-fast.conf;
    else 
        echo "_MAXNUM=${NUM}" >> /etc/apt-fast.conf;
    fi
    if grep "^_SPLITCON=" /etc/apt-fast.conf; then
        sed -i "s|^_SPLITCON=.*|_SPLITCON=${NUM}|" /etc/apt-fast.conf;
    else 
        echo "_SPLITCON=${NUM}" >> /etc/apt-fast.conf;
    fi
    if grep "^_MAXCONPERSRV=" /etc/apt-fast.conf; then
        sed -i "s|^_MAXCONPERSRV=.*|_MAXCONPERSRV=${NUM}|" /etc/apt-fast.conf;
    else 
        echo "_MAXCONPERSRV=${NUM}" >> /etc/apt-fast.conf;
    fi
fi

ln -s $(which apt-fast) $FAST_PATH/apt-get
