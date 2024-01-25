# Final_work_1
сервер сертификации 158.160.107.29
vpn сервер 158.160.111.237

1.Создание сервера с удостоверяющим центром Easy-RSA.
1.11 Создать виртуальную машину с постоянным IP адресом и подключением по SSH.
1.12 Установить пакет easyrsa-infrastructure_0.1-1_all.deb
1.13 Запустить скрипт opt/install-easyrsa-infrastructure.sh
2.Создание vpn сервера.
2.11 Создать виртуальную машину с постоянным IP адресом и подключением по SSH.
2.12 Установить vpn-server_0.1-1_all.deb
2.13 Запустить скрипт /opt/1-easyrsa-openvpn.sh
2.14 Передать на сервер сертификации файл /opt/easy-rsa/pki/reqs/server.req
2.15 На сервере сертификации подписать ./easyrsa sign-req server server
2.16 Передать на vpn сервер сертификат server.crt
2.17 Запустить скрипт final_script.sh
3. Создание клиентов
3.11 На vpn сервере запустить ./easyrsa gen-req `имя_клиента` nopass 
3.12 Передать запрос *.req на сервер сертификации
3.13 Подписать ./easyrsa sign-req client `имя_клиента` и передать *.crt на vpn сервер
3.14 Запустить скрипт make_config.sh и передать клиенту файл /opt/clients/files/*.ovpn
4.Создание prometheus сервера
4.11 Создать виртуальную машину с постоянным IP адресом и подключением по SSH.
4.12 Передать prometheus-server_0.1-1_all.deb
4.13 Запустить скрипт /opt/prometheus_install.sh
4.14 На сервер сертификации передать скрипт install-prometheus.sh и запустить
4.15 На сервер vpn передать vpn-prometheus.sh и запустить
