# Final_work_1
сервер сертификации 158.160.107.29
vpn сервер 158.160.111.237

1.Создание сервера с удостоверяющим центром Easy-RSA.
1.1 Создать виртуальную машину с постоянным IP адресом и подключением по SSH.
#1.11 Запустить команду chmod 700 на скрипты.
#1.Установить sudo apt-get install dh-make devscripts
#	mkdir safety-0.1 | cp iptables.sh safety-0.1/ | cp rkhunter.sh safety-0.1/ | cd safety-0.1/ | dh_make --indep --createorig | vim install | debuild -us -uc
#Установить пакет sudo dpkg -i safety_0.1-1_all.deb
#Архивирование пакета tar -czf safety.tar.gz название_файлов. Распаковка tar -xvf safety.tar.gz
#Скопировать install-easyrsa-infrastructure.sh и deb-пакет easy_0.1-1_all.deb
#Запустить скрипт install-easyrsa-infrastructure.sh
#1.12 Запустить скрипт для настройки фаервола. usr/bin/iptables.sh
1.13 Запустить скрипт для установки и проверки антивирусом. usr/bin/rkhunter.sh
#1.14 Запустить скрипт для установки и настройки easy-rsa. usr/bin/easy-rsa.sh
2.Создание vpn сервера.
2.1 Создать виртуальную машину с постоянным IP адресом и подключением по SSH.
#2.11 Скопировать deb пакеты и скрипты для впн сервера.
2.21 Установить openvpn и easy-rsa из скрипта. 1-easyrsa-openvpn.sh
2.22 Передать запрос на подпись *.req на сервер сертификации в папку ~/easy-rsa/pki/reqs/
2.23 На сервере сертификации запустить скрипт с параметрами ./easyrsa import-req ~/easy-rsa/pki/reqs/server.req server
2.24 Подписать ./easyrsa sign-req server server
2.24 Передать с сервера сертификации ~/easy-rsa/pki/issued/server.crt и ~/easy-rsa/pki/ca.crt на vpn сервер и положить в домашнюю директорию.
2.25 На vpn сервере запустить скрипт 2-copy-crt-server.sh
2.25 Для создания клиентских сертификатов и ключей запустить ./easyrsa gen-req ivanov nopass
2.26 Ключ скопировать cp pki/private/petrov.key ~/clients/keys/
2.26 Передать запрос на подпись pki/reqs/*.req на сервер сертификации в папку ~/easy-rsa/pki/reqs/
2.26 На сервере сертификации запустить скрипт с параметрами ./easyrsa import-req ~/easy-rsa/pki/reqs/ivanov.req ivanov
2.27 Подписать ./easyrsa sign-req client ivanov
Передать с сервера сертификации ~/easy-rsa/pki/issued/ivanov.crt
2.27 На впн сервере скопировать подписанный ivanov.crt и pki/private/ivanov.key в ~/clients/keys/
2.3 Настраиваем openvpn
2.30 установить deb-пакет vpn-setting_0.1-1_all
#2.31 sudo cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf /etc/openvpn/server/ | sudo vim #/etc/openvpn/server/server.conf
	push "redirect-gateway def1 bypass-dhcp"
	tls-crypt ta.key
	cipher AES-256-GCM
	auth SHA256
	;dh dh2048.pem
	dh none
	user nobody
	group nogroup
2.32 Разрешить маршрутизацию трафика.
Запустить скрипт sudo 3-iptables-vpn.sh eth0 udp 1194 (параметры из ip a)
sudo vim /etc/sysctl.conf
	раскомментировать строку net.ipv4.ip_forward=1
sudo sysctl -p

#2.33 Добавить в автозагрузку sudo systemctl -f enable openvpn-server@server.service
#sudo systemctl start openvpn-server@server.service
#2.34 Клиентские конфигурации mkdir -p ~/clients/files
#	sudo cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf ~/clients/base.conf
#	sudo vim ~/clients/base.conf
		remote 158.160.111.237 1194
		user nobody
		group nogroup
		;ca ca.crt
		;cert client.crt
		;key client.key
		;tls-crypt ta.key 1
		cipher AES-256-GCM
		auth SHA256
		key-direction 1
#	cp make_config.sh ~/clients | chmod 700 ~/clients/make_config.sh 
#	cd ~/clients/
права на папку keys клиента, а не root 
	sudo chown crazyflash:crazyflash ~/clients/*
2.35 Создание ovpn файла клиента
	./make_config.sh ivanov
	передать *.ovpn файл клиенту для подключения.
