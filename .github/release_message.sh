#!/usr/bin/env bash
pip3 install gitchangelog pystache 2>&1 /dev/null

previous_tag=$(git describe --tags $(git rev-list --tags --max-count=1))
current=$(cat VERSION)
gitchangelog "${previous_tag}..v$current"
