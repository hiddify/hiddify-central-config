#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

cd $( dirname -- "$0"; )
 
function main(){
    CURRENT=`pip3 freeze |grep hiddifypanel|awk -F"==" '{ print $2 }'`
    LATEST=`lastversion hiddifypanel --at pip`

    echo "hiddify panel version current=$CURRENT latest=$LATEST"

    if [[ "$CURRENT" != "$LATEST" ]];then
        echo "panel is outdated! updating...."
        pip3 install -U hiddifypanel
    fi

    LAST_CONFIG_VERSION=$(lastversion hiddify/hiddify-central-config)
    CURRENT_CONFIG_VERSION=$(cat VERSION)
    echo "Current Config Version=$CURRENT_CONFIG_VERSION -- Latest=$LAST_CONFIG_VERSION"
    if [[ "$CURRENT_CONFIG_VERSION" != "$LAST_CONFIG_VERSION" ]];then
        echo "Config is outdated! updating..."
        wget -c $(lastversion hiddify/hiddify-central-config --source)
        tar xvzf hiddify-central-config-v$LAST_CONFIG_VERSION.tar.gz --strip-components=1
        rm hiddify-central-config-v$LAST_CONFIG_VERSION.tar.gz
        bash install.sh
    fi

    if [[ "$CURRENT" != "$LATEST" ]];then
        systemctl restart hiddify-central-panel
    fi
}

mkdir -p log/system/
main |& tee log/system/update.log