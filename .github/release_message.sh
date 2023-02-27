#!/usr/bin/env bash
previous_tag=$(git describe --tags $(git rev-list --tags --max-count=1))
git shortlog "${previous_tag}.." | sed 's/^./    &/'
