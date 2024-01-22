#!/bin/bash
easy_dir="/opt/easy-rsa/"
if [[ "$EUID" -ne 0 ]]; then
	echo "This installer needs to be run with superuser privileges."
	exit
fi
apt-get update
apt-get install easy-rsa
mkdir $easy_dir
ln -s /usr/share/easy-rsa/* $easy_dir
chmod 700 $easy_dir
cd $easy_dir
./easyrsa init-pki
#Setting vars
echo "Enter Organizational fields"
read -p "COUNTRY: " COUNTRY
read -p "PROVINCE: " PROVINCE
read -p "CITY: " CITY
read -p "ORG: " ORG
read -p "EMAIL: " EMAIL
read -p "OU: " OU
echo "if [ -z "$EASYRSA_CALLER" ]; then
        echo "You appear to be sourcing an Easy-RSA 'vars' file." >&2
        echo "This is no longer necessary and is disallowed. See the section called" >&2
        echo "'How to use this file' near the top comments for more details." >&2
        return 1
fi
set_var EASYRSA_REQ_COUNTRY "\"$COUNTRY\""
set_var EASYRSA_REQ_PROVINCE "\"$PROVINCE\""
set_var EASYRSA_REQ_CITY "\"$CITY\""
set_var EASYRSA_REQ_ORG "\"$ORG\""
set_var EASYRSA_REQ_EMAIL "\"$EMAIL\""
set_var EASYRSA_REQ_OU "\"$OU\""
set_var EASYRSA_ALGO           ec
set_var EASYRSA_DIGEST         "sha256"" > vars
./easyrsa build-ca
#Setting iptables
eth=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
proto="udp"
port=1194
# OpenVpn
sudo iptables -A INPUT -i "$eth" -m state --state NEW -p "$proto" --dport "$port" -j ACCEPT
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