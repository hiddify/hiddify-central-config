#!/bin/bash
cd $( dirname -- "$0"; )
function main(){
	systemctl status --no-pager **/*.service caddy|cat

    for s in caddy **/*.service;do
        s=${s##*/}
        s=${s%%.*}
        printf "%-30s %-30s \n" $s $(systemctl is-active $s)
    done

    echo "---------------------Finished!------------------------"

}
mkdir -p log/system/
main |& tee log/system/status.log
