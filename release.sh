#!/bin/bash

which gitchangelog
if [[ "$?" != 0 ]];then
    pip3 install gitchangelog pystache
fi
previous_tag=$(git describe --tags $(git rev-list --tags --max-count=1))
echo "previous version was $previous_tag"
read -p "Version? (provide the next x.y.z semver) : " TAG
[[ $TAG = v* ]] && echo "incorrect tag" && exit 1
echo "${TAG}" > VERSION
gitchangelog > HISTORY.md
git add VERSION HISTORY.md
git commit -m "release: version ${TAG} 🚀"
echo "creating git tag : v${TAG}"
git tag v${TAG}
git push -u origin HEAD --tags
echo "Github Actions will detect the new tag and release the new version."