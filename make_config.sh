#!/bin/bash
#variables
. ./variables
var

BASE_CONFIG=/opt/clients/base.conf
echo "OpenVPN is already installed."
echo
echo "Select an option:"
	echo "   1) Add a new client"
	echo "   2) Exit"
	read -p "Option: " option
until [[ "$option" =~ ^[1-2]$ ]]; do
		echo "$option: invalid selection."
		read -p "Option: " option
	done
	case "$option" in
		1)
			echo	
			read -p "Enter client name: " client
			cp /opt/easy-rsa/pki/private/${client}.key ${KEY_DIR}
			cat ${BASE_CONFIG} \
			<(echo -e '<ca>') \
			${KEY_DIR}/ca.crt \
			<(echo -e '</ca>\n<cert>') \
			${KEY_DIR}/${client}.crt \
			<(echo -e '</cert>\n<key>') \
			${KEY_DIR}/${client}.key \
			<(echo -e '</key>\n<tls-crypt>') \
			${KEY_DIR}/ta.key \
			<(echo -e '</tls-crypt>') \
			> ${OUTPUT_DIR}/${client}.ovpn
			echo "$client added. Configuration available in:" ${OUTPUT_DIR}"$client.ovpn"
			exit
			;;
		2)
			echo "Goodbay"
			exit
			;;
	esac