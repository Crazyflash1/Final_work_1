#!/bin/bash
sudo cp ~/server.crt /etc/openvpn/server/
sudo cp ~/ca.crt /etc/openvpn/server/
mkdir -p ~/clients/keys ~/clients/files
cp ~/ca.crt ~/clients/keys/
sudo cp ~/easy-rsa/pki/private/server.key /etc/openvpn/server/
openvpn --genkey --secret ta.key
sudo cp ta.key /etc/openvpn/server/
cp ta.key ~/clients/keys/