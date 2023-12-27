eth=$1
proto=$2
port=$3
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
#открываем порты http,ssh,dns,vpn
sudo iptables -A INPUT -p tcp -m multiport --dports 22,53,80,443 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 1194 -j ACCEPT
#закрываем входящий трафик
sudo iptables -P INPUT DROP
#dns
sudo iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
#разрешить уже установленные соединения
sudo iptables -A INPUT -m state --state ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -p icmp -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
#разрешение локал хоста
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT
#скачиваем iptables-persistent
sudo apt-get install iptables-persistent
#сохраняем правила в файл /etc/iptables/rules.v4
sudo service netfilter-persistent save
