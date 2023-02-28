#!/bin/bash
cd $( dirname -- "$0"; )
HEIGHT=15
WIDTH=60
CHOICE_HEIGHT=4
BACKTITLE="Welcome to Hiddify Central Panel"
TITLE="Hiddify Central Panel"
MENU="Choose one of the following options:"

OPTIONS=(status "View status of system"
         apply_configs "Apply the changed configs"
         install "Reinstall"
         upgrade "Upgrade "
         uninstall "Uninstall"
         admin "Show admin link"
         )

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear

if [[ "$CHOICE" == "" ]];then
    exit
elif [[ "$CHOICE" == "admin" ]];then
    (cd hiddify-panel; python3 -m hiddifypanel admin-links)
else
    bash $CHOICE.sh
fi