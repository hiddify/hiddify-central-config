#!/bin/bash
cd $( dirname -- "$0"; )
echo "we are going to install :)"
export DEBIAN_FRONTEND=noninteractive
if [ "$(id -u)" -ne 0 ]; then
        echo 'This script must be run by root' >&2
#        exit 1

fi

source ./common/ticktick.sh

function set_config_from_hpanel(){

        hiddify=`cd hiddify-panel;python3 -m hiddifypanel all-configs`
        tickParse  "$hiddify"
        tickVars

        function setenv () {
                echo $1=$2
                export $1="$2"
        }
        
        setenv FIRST_SETUP ``hconfigs[first_setup]``
        setenv DB_VERSION ``hconfigs[db_version]``

        setenv BASE_PROXY_PATH ``hconfigs[proxy_path]``

        
        setenv DECOY_DOMAIN ``hconfigs[decoy_domain]``
        setenv ENABLE_FIREWALL ``hconfigs[firewall]``
        setenv ENABLE_NETDATA ``hconfigs[netdata]``
        setenv ENABLE_AUTO_UPDATE ``hconfigs[auto_update]``

        setenv SERVER_IP `curl --connect-timeout 1 -s https://v4.ident.me/`
        setenv SERVER_IPv6 `curl  --connect-timeout 1 -s https://v6.ident.me/`

        function get () {
                group=$1
                index=`printf "%012d" "$2"` 
                member=$3
                
                var="__tick_data_${group}_${index}_${member}";
                echo ${!var}
        }

        MAIN_DOMAIN=
        for i in $(seq 0 ``domains.length()``); do
                domain=$(get domains $i domain)
                MAIN_DOMAIN="$domain;$MAIN_DOMAIN"
        done

        setenv MAIN_DOMAIN $MAIN_DOMAIN


}


function runsh() {          
        command=$1
        if [[ $3 == "false" ]];then
                command=uninstall.sh
        fi
        pushd $2 >>/dev/null 
        # if [[ $? != 0]];then
        #         echo "$2 not found"
        # fi
        if [[ $? == 0 && -f $command ]];then
                echo "==========================================================="
                echo "===$command $2"
                echo "==========================================================="        
                bash $command
        fi
        popd >>/dev/null
}

function do_for_all() {
        systemctl daemon-reload
        runsh $1.sh common
        runsh $1.sh caddy
}

function check_installation_ok(){
    for s in caddy hiddify-central-panel;do
        if [[ "$(systemctl is-active $s)" != "active" ]];then
            sleep 5
            if [[ "$(systemctl is-active $s)" != "active" ]];then
                >&2 echo "Error! Important Service $s can not be activated"
                exit 2
            fi
        fi
    done
}

function main(){
        export MODE="$1"
        export SQLALCHEMY_DATABASE_URI='sqlite:////opt/hiddify-central-config/hiddify-panel/database.db'
        runsh install.sh hiddify-panel
        set_config_from_hpanel
        if [[ $DB_VERSION == "" ]];then
                >&2 echo "ERROR!!!! There is an error in the installation of python panel. Exit...."
                exit 1
        fi
        
        if [[ -z "$DO_NOT_INSTALL" || "$DO_NOT_INSTALL" == false  ]];then
                do_for_all install
                systemctl daemon-reload
        fi

        if [[ -z "$DO_NOT_RUN" || "$DO_NOT_RUN" == false ]];then
                do_for_all run       
        fi

        check_installation_ok

        echo ""
        echo ""
        bash status.sh
        echo "==========================================================="
        echo "Finished! Thank you for helping Iranians to skip filternet."
        echo "Please open the following link in the browser for client setup"
        
        echo `cd hiddify-panel;python3 -m hiddifypanel admin-links`
        
        echo "---------------------Finished!------------------------"

        systemctl restart hiddify-central-panel
}

mkdir -p log/system/
main $@|& tee log/system/0-install.log
