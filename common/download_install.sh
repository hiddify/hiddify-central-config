#!/bin/sh
export DEBIAN_FRONTEND=noninteractive
if [ "$(id -u)" -ne 0 ]; then
        echo 'This script must be run by root' >&2
        exit 1
fi

echo "we are going to download needed files:)"
GITHUB_REPOSITORY=hiddify-central-config
GITHUB_USER=hiddify
GITHUB_BRANCH_OR_TAG=main

if [ ! -d "/opt/$GITHUB_REPOSITORY" ];then
        apt update
        apt upgrade -y
        apt install -y git
        git clone https://github.com/$GITHUB_USER/$GITHUB_REPOSITORY/  /opt/$GITHUB_REPOSITORY
        cd /opt/$GITHUB_REPOSITORY
        git checkout $GITHUB_BRANCH_OR_TAG
fi 

cd /opt/$GITHUB_REPOSITORY
bash install.sh