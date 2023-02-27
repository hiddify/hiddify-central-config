#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

cd $( dirname -- "$0"; )
 
function main(){
    git branch
    changed=0
    git pull --dry-run 2>&1 | grep -q -v 'Already up-to-date.' && changed=1

    (cd  hiddify-panel; bash install.sh)

    if [[ "$changed" == "1" ]];then
        echo "Updating system"
        
        # rm hiddify-panel/hiddify-panel.service&&git checkout hiddify-central-panel/hiddify-panel.service 
        
        git pull
        bash install.sh
    else 
        echo "No update is needed"
    fi
    if [[ "$CURRENT" != "$LATEST" ]];then
        systemctl restart hiddify-central-panel
    fi
}

mkdir -p log/system/
main |& tee log/system/update.log