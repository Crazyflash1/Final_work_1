#!/bin/bash
#load variables
. ./variables
var
# устанавливаем easy-rsa и openvpn
apt-get update
apt-get install easy-rsa openvpn
mkdir -p $KEY_DIR $OUTPUT_DIR $EASY_RSA_DIR
ln -s /usr/share/easy-rsa/* $EASY_RSA_DIR
cd $EASY_RSA_DIR
./easyrsa init-pki
#создание файл запроса сертификата и ключ
./easyrsa gen-req server nopass
