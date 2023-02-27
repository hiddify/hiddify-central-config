

function add2iptables(){
  iptables -C $1 || echo "adding rule $1" && iptables -I $1
}

add2iptables "INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT"
add2iptables "INPUT -i lo -j ACCEPT"
add2iptables "INPUT -p tcp --dport 443 -j ACCEPT"
add2iptables "INPUT -p udp --dport 53 -j ACCEPT"
add2iptables "INPUT -p tcp --dport 80 -j ACCEPT"
add2iptables "INPUT -p tcp --dport 22 -j ACCEPT"
mkdir -p /etc/iptables/
 if [[ $ENABLE_FIREWALL == true ]]; then
  iptables -P INPUT DROP
  iptables-save > /etc/iptables/rules.v4 
else 
  iptables -P INPUT ACCEPT
  iptables-save > /etc/iptables/rules.v4 
fi



if [[ $ENABLE_AUTO_UPDATE == true ]]; then
  echo "0 3 * * * root $(pwd)/../update.sh" > /etc/cron.d/hiddify_auto_update
  service cron reload
else
  rm -rf /etc/cron.d/hiddify_auto_update
  service cron reload
fi