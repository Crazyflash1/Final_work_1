#!/bin/bash
#load variables
. ./variables
var
cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf $VPN_SERVER_DIR
cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf $BASE_CONFIG
#setting server.conf
if [ -f "$VPN_SERVER_DIR" ] && [ -f "$BASE_CONFIG" ];
then
        sed -i 's/dh dh2048.pem/dh none/' $VPN_SERVER_DIR
        sed -i 's/;push "redirect-gateway def1 bypass-dhcp"/push "redirect-gateway def1 bypass-dhcp"/' $VPN_SERVER_DIR
        sed -i 's/tls-auth ta.key 0/tls-crypt ta.key/' $VPN_SERVER_DIR
        sed -i 's/cipher AES-256-CBC/cipher AES-256-GCM \nauth SHA256/' $VPN_SERVER_DIR
        sed -i 's/;user nobody/user nobody/' $VPN_SERVER_DIR
        sed -i 's/;group nobody/group nogroup/' $VPN_SERVER_DIR
        sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
#setting base.conf
        sed -i 's/remote my-server-1 1194/remote 158.160.111.237 1194/' $BASE_CONFIG
        sed -i 's/;user nobody/user nobody/' $BASE_CONFIG
        sed -i 's/;group nobody/group nogroup/' $BASE_CONFIG
        sed -i 's/ca ca.crt/;ca ca.crt/' $BASE_CONFIG
        sed -i 's/cert client.crt/;cert client.crt/' $BASE_CONFIG
        sed -i 's/key client.key/;key client.key/' $BASE_CONFIG
        sed -i 's/tls-auth ta.key 1/;tls-auth ta.key 1/' $BASE_CONFIG
        sed -i 's/cipher AES-256-CBC/cipher AES-256-GCM \nauth SHA256\nkey-direction 1/' $BASE_CONFIG
        echo "Setting server.conf and base.conf successfully created!"
        exit 0
else
        echo "File server.conf and base.conf not found!"
        exit 1
fi
