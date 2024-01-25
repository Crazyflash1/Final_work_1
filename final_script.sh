#!/bin/bash
#variables
. ./variables
var

eth=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)

if [[ "$EUID" -ne 0 ]]; then
	echo "This installer needs to be run with superuser privileges."
	exit
fi

read -p "Port [1194]: " port
read -p "Protocol [UDP]: " protocol
read -p "IP adress server": ip

#chown -R root:root /etc/openvpn/server/easy-rsa/

sudo cp /opt/server.crt $VPN_SERVER_DIR
sudo cp /opt/ca.crt $VPN_SERVER_DIR
sudo cp /opt/ca.crt $KEY_DIR
openvpn --genkey secret /etc/openvpn/server/ta.key
#sudo cp ta.key $VPN_SERVER_DIR
cp /etc/openvpn/server/ta.key $KEY_DIR
cp /opt/make_config.sh $CLIENTS_DIR

# Generate server.conf
	echo "port $port
proto $protocol
dev tun
ca ca.crt
cert server.crt
key server.key
dh none
cipher AES-256-GCM
auth SHA256
tls-crypt ta.key
server 10.8.0.0 255.255.255.0
push \"redirect-gateway def1 bypass-dhcp\"
ifconfig-pool-persist /var/log/openvpn/ipp.txt
keepalive 10 120
user nobody
group nogroup
persist-key
persist-tun
verb 3
explicit-exit-notify 1
status /var/log/openvpn/openvpn-status.log" > $VPN_SERVER_DIR/server.conf

echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sudo sysctl -p

# Generate base.conf
	echo "client
dev tun
proto $protocol
remote $ip $port
resolv-retry infinite
nobind
user nobody
group nogroup
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-GCM
auth SHA256
key-direction 1
verb 3" > $CLIENTS_DIR/base.conf

sudo systemctl -f enable openvpn-server@server.service
sudo systemctl start openvpn-server@server.service

#Setting iptables

# OpenVpn
sudo iptables -A INPUT -i "$eth" -m state --state NEW -p "$protocol" --dport "$port" -j ACCEPT
# Allow TUN interface connection to OpenVpn server
sudo iptables -A INPUT -i tun+ -j ACCEPT
# Allow TUN interface connection to be forwarded through other interface
sudo iptables -A FORWARD -i tun+ -j ACCEPT
sudo iptables -A FORWARD -i tun+ -o "$eth" -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i "$eth" -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT
# NAT the VPN client traffic to the internet
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o "$eth" -j MASQUERADE
#оpen http,ssh,dns,vpn
sudo iptables -A INPUT -p tcp -m multiport --dports 22,53,80,443 -j ACCEPT
sudo iptables -A INPUT -p udp --dport "$port" -j ACCEPT
#close input
sudo iptables -P INPUT DROP
#dns
sudo iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
#enable connect
sudo iptables -A INPUT -m state --state ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -p icmp -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
#enable local host
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT
#download iptables-persistent
sudo apt-get install iptables-persistent
#save setting in file /etc/iptables/rules.v4
sudo service netfilter-persistent save
