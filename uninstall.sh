#!/bin/bash
function main(){
    for s in caddy **/*.service;do
        s=${s##*/}
        s=${s%%.*}
        systemctl kill $s
        systemctl disable $s            
    done
    rm -rf /etc/cron.d/hiddify*
    service cron reload
    if [[ "$1" == "purge" ]];then
        cd .. && rm -rf hiddify-central-panel
        apt remove -y caddy gunicorn python3-pip python3
        echo "We have completely removed hiddify central panel"
    fi
}

mkdir -p log/system/
main $@|& tee log/system/uninstall.log
