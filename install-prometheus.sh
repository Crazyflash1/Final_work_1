#!/bin/bash

sudo apt install prometheus
iptables -A INPUT -p tcp -m multiport --dports 9100 -j ACCEPT
sudo service netfilter-persistent save
