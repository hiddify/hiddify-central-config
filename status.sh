#!/bin/bash
function main(){
	systemctl status --no-pager caddy hiddify-panel|cat

    echo "---------------------Finished!------------------------"

}
mkdir -p log/system/
main |& tee log/system/status.log
