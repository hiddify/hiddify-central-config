
systemctl kill hiddify-admin.service
systemctl disable hiddify-admin.service

for req in pip3 gunicorn;do
    which $req
    if [[ "$?" != 0 ]];then
            apt update
            apt install -y python3-pip gunicorn
            pip3 install pip
            pip3 install -U hiddifypanel
            break
    fi
done

CURRENT=`pip index versions hiddifypanel|grep INSTALLED|awk -F": " '{ print $2 }'`
LATEST=`pip index versions hiddifypanel|grep LATEST|awk -F": " '{ print $2 }'`

if [[ "$CURRENT" != "$LATEST"]];then
    pip3 install -U hiddifypanel
fi

ln -sf $(which gunicorn) /usr/bin/gunicorn

python3 -m hiddifypanel init-db
python3 -m hiddifypanel set-setting -k is_parent -v True

ln -sf $(pwd)/hiddify-panel.service /etc/systemd/system/hiddify-panel.service
systemctl enable hiddify-panel.service
systemctl daemon-reload
echo "*/10 * * * * root $(pwd)/update_usage.sh" > /etc/cron.d/hiddify_usage_update
service cron reload

systemctl start hiddify-panel.service
systemctl status hiddify-panel.service

