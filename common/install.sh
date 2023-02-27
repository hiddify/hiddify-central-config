sudo timedatectl set-timezone  Asia/Tehran
apt update
apt install -y at apt-transport-https dnsutils ca-certificates git curl wget gnupg-agent software-properties-common  iptables locales lsof cron
sudo apt -y remove needrestart apache2


echo "@reboot root /opt/hiddify-central-config/install.sh >> /opt/hiddify-config/log/system/reboot.log 2>&1" > /etc/cron.d/hiddify_reinstall_on_reboot
service cron reload


localectl set-locale LANG=C.UTF-8