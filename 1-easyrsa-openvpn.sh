#!/bin/bash
#variables
. ./variables
var
if [[ "$EUID" -ne 0 ]]; then
	echo "This installer needs to be run with superuser privileges."
	exit
fi
# install easy-rsa и openvpn
apt-get update
apt-get install easy-rsa openvpn
mkdir -p $KEY_DIR $OUTPUT_DIR $EASY_RSA_DIR
cp variables /opt/clients/
ln -s /usr/share/easy-rsa/* $EASY_RSA_DIR
cd $EASY_RSA_DIR
./easyrsa init-pki
#create req and key 
./easyrsa gen-req server nopass
cp /opt/easy-rsa/pki/private/server.key $VPN_SERVER_DIR
