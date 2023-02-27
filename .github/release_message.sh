#!/usr/bin/env bash
pip3 install gitchangelog pystache 2>&1 /dev/null

previous_release=$(curl --silent "https://api.github.com/repos/hiddify/hiddify-central-config/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
current=$(cat VERSION)
gitchangelog "${previous_release}..v$current"
