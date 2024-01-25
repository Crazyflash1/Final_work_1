#!/bin/bash

apt install prometheus

iptables -A INPUT -p tcp -m multiport --dports 9100,9176 -j ACCEPT
service netfilter-persistent save
wget https://go.dev/dl/go1.21.6.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.21.6.linux-amd64.tar.gz
wget https://github.com/kumina/openvpn_exporter/archive/v0.3.0.tar.gz
tar xzf v0.3.0.tar.gz
cd openvpn_exporter-0.3.0/
/usr/local/go/bin/go build -o /usr/local/bin/openvpn_exporter main.go
openvpn_exporter -openvpn.status_paths "/var/log/openvpn/openvpn-status.log" &> /dev/null

echo "[Unit]
Description=Prometheus OpenVPN Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/openvpn_exporter

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/openvpn_exporter.service

systemctl daemon-reload
systemctl enable --now openvpn_exporter.service
systemctl restart prometheus