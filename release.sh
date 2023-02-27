#!/bin/bash

which gitchangelog
if [[ "$?" != 0 ]];then
    pip3 install gitchangelog
fi
previous_tag=$(git tag --sort=-creatordate | sed -n 2p)
echo "previous version was $previous_tag"
read -p "Version? (provide the next x.y.z semver) : " TAG
echo "${TAG}" > VERSION
gitchangelog > HISTORY.md
git add hiddifypanel/VERSION HISTORY.md
git commit -m "release: version ${TAG} 🚀"
echo "creating git tag : ${TAG}"
git tag ${TAG}
git push -u origin HEAD --tags
echo "Github Actions will detect the new tag and release the new version."