#!/bin/bash
#Подгружаем переменные
. ./Downloads/variables
var
# устанавливаем easy-rsa и openvpn
sudo apt-get update 
sudo apt-get install easy-rsa openvpn
#mkdir ~/easy-rsa/
ln -s /usr/share/easy-rsa/* $EASY_RSA_DIR
chmod 700 $EASY_RSA_DIR
cd $EASY_RSA_DIR
./easyrsa init-pki
#создание файл запроса сертификата и ключ
cd $EASY_RSA_DIR
./easyrsa gen-req server nopass
