#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

cd $( dirname -- "$0"; )
source ./common/ticktick.sh 
function get_commit_version(){
    latest=$(curl -s https://api.github.com/repos/hiddify/$1/git/refs/heads/main)
    tickParse  "$latest"            
    COMMIT=``object[sha]``
    echo ${COMMIT:0:7}
}

function main(){
    hiddify=`cd hiddify-panel;python3 -m hiddifypanel all-configs`
    tickParse  "$hiddify"
    PACKAGE_MODE=``hconfigs[package_mode]``
    
    if [[ "$PACKAGE_MODE" == "develop" ]];then
        echo "you are in develop mode"
        LATEST=$(get_commit_version HiddifyPanel)
        INSTALL_DIR=$(pip show hiddifypanel |grep Location |awk -F": " '{ print $2 }')
        CURRENT=$(cat $INSTALL_DIR/hiddifypanel/VERSION)
        echo "DEVLEOP: hiddify panel version current=$CURRENT latest=$LATEST"
        if [[ "$LATEST" != "$CURRENT" ]];then
            pip3 uninstall -y hiddifypanel
            pip3 install -U git+https://github.com/hiddify/HiddifyPanel
            echo $LATEST>$INSTALL_DIR/hiddifypanel/VERSION
            echo "__version__='$LATEST'">$INSTALL_DIR/hiddifypanel/VERSION.py
        fi
    else 
        CURRENT=`pip3 freeze |grep hiddifypanel|awk -F"==" '{ print $2 }'`
        LATEST=`lastversion hiddifypanel --at pip`
        echo "hiddify panel version current=$CURRENT latest=$LATEST"
        if [[ "$CURRENT" != "$LATEST" ]];then
            echo "panel is outdated! updating...."
            pip3 install -U hiddifypanel
        fi
    fi

    
    
    CURRENT_CONFIG_VERSION=$(cat VERSION)
    if [[ "$PACKAGE_MODE" == "develop" ]];then
        LAST_CONFIG_VERSION=$(get_commit_version hiddify-central-config)
        echo "DEVELOP: Current Config Version=$CURRENT_CONFIG_VERSION -- Latest=$LAST_CONFIG_VERSION"
        if [[ "$CURRENT_CONFIG_VERSION" != "$LAST_CONFIG_VERSION" ]];then
            wget -c https://github.com/hiddify/hiddify-central-config/archive/refs/heads/main.tar.gz
            tar xvzf hiddify-central-config-main.tar.gz --strip-components=1
            rm hiddify-central-config-main.tar.gz
            echo $LAST_CONFIG_VERSION > VERSION
            bash install.sh
        fi
    else 
        LAST_CONFIG_VERSION=$(lastversion hiddify/hiddify-central-config)
        echo "Current Config Version=$CURRENT_CONFIG_VERSION -- Latest=$LAST_CONFIG_VERSION"
        if [[ "$CURRENT_CONFIG_VERSION" != "$LAST_CONFIG_VERSION" ]];then
            echo "Config is outdated! updating..."
            wget -c $(lastversion hiddify/hiddify-central-config --source)
            tar xvzf hiddify-central-config-v$LAST_CONFIG_VERSION.tar.gz --strip-components=1
            rm hiddify-central-config-v$LAST_CONFIG_VERSION.tar.gz
            bash install.sh
        fi
    fi
    if [[ "$CURRENT" != "$LATEST" ]];then
        systemctl restart hiddify-central-panel
    fi
}

mkdir -p log/system/
main |& tee log/system/update.log