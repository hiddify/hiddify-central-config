#!/bin/bash
cd $( dirname -- "$0"; )
HEIGHT=15
WIDTH=60
CHOICE_HEIGHT=4
BACKTITLE="Welcome to Hiddify Central Panel (config version=$(cat VERSION))"
TITLE="Hiddify Central Panel"
MENU="Choose one of the following options:"

OPTIONS=(admin "Show admin link"
         status "View status of system"
         log "view system logs"
         apply_configs "Apply the changed configs"
         install "Reinstall"
         update "Update "
         uninstall "Uninstall"
         disable "Disable showing this window on startup"
         enable "enable showing this window on startup"
         )

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
echo "Hiddify: Command $CHOICE"
echo "=========================================="
case $CHOICE in 
    "") exit;;
    'log')
        W=() # define working array
        while read -r line; do # process file by file
            size=$(ls -lah log/system/$line | awk -F " " {'print $5'})
            W+=($line "$size")
        done < <( ls -1 log/system )
        LOG=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${W[@]}" \
                2>&1 >/dev/tty)
        clear
        echo -e "\033[0m"
        less +G "log/system/$LOG"
    ;;
    "enable")
        echo "/opt/hiddify-central-config/menu.sh">>~/.bashrc
        echo "cd /opt/hiddify-central-config/">>~/.bashrc
        ;;
    "disable")
        sed -i "s|/opt/hiddify-central-config/menu.sh||g" ~/.bashrc
        sed -i "s|cd /opt/hiddify-central-config/||g" ~/.bashrc
        ;;
    "admin")
        (cd hiddify-panel; python3 -m hiddifypanel admin-links)   
        ;;
    "status")
        bash status.sh |less +G
        ./menu.sh
        exit
        ;;
    *)
        bash $CHOICE.sh
esac

read -p "Press any key to return to menu, press 'q' to exit" -n 1 key
if [[ $key == 'q' ]];then
    echo ""
    exit; 
fi

./menu.sh