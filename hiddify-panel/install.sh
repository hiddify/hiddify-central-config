
systemctl kill hiddify-admin.service
systemctl disable hiddify-admin.service

for req in pip3 gunicorn python3 hiddifypanel lastversion jq;do
    which $req
    if [[ "$?" != 0 ]];then
            apt update
            apt install -y python3-pip gunicorn jq
            pip3 install pip
            pip3 install -U hiddifypanel lastversion
            break
    fi
done



ln -sf $(which gunicorn) /usr/bin/gunicorn


python3 -m hiddifypanel init-db
python3 -m hiddifypanel set-setting -k is_parent -v True

ln -sf $(pwd)/hiddify-central-panel.service /etc/systemd/system/hiddify-central-panel.service
systemctl enable hiddify-central-panel.service
systemctl daemon-reload
echo "*/10 * * * * root $(pwd)/update_usage.sh" > /etc/cron.d/hiddify_usage_update
service cron reload

systemctl start hiddify-central-panel.service
systemctl status hiddify-central-panel.service

