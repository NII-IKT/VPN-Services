#!/bin/bash
# проверяем права рута
if [ "$(id -u)" != 0 ]
then
	echo "Этот скрипт нужно запускать с полномочиями root"
	exit 1
fi

#Проверяем ОС
if [ "$(lsb_release -si)" != "Ubuntu" ] && [ "$(lsb_release -si)" != "Debian" ]
then
	echo "Этот скипт нужно запускать на Ubuntu или Debian"
	exit 1
fi

#сраза обновляем apt-get
apt-get update

#ставим ssh сервер
apt-get -y install openssh-server

#ставим конфиг для ssh сервера
cp ./sshd_config /etc/ssh/sshd_config
chmod +x /etc/ssh/sshd_config

#ставим fail2ban для защиты от брутфорса
apt-get -y install fail2ban

#ставим конфиг для fail2ban
cp ./jail.conf /etc/fail2ban/jail.conf
chmod +x /etc/fail2ban/jail.conf

#добавляем нового пользователя и группу от имени которого будет работать openvpn
adduser --system --no-create-home --home /nonexistent --disabled-login --group openvpn

#ставим OpenVPN Server и необходимый для него ssl
apt-get -y install openvpn openssl
#ставим нашу конфигурацию ssl
cp ./openssl.cnf /etc/openvpn/openssl.cnf
#ставим нашу конфигурацию openvpn
cp ./server.conf /etc/openvpn/server.conf
#нужно копировать файл отзыва сертификатов
cp ./crl.pem /etc/openvpn/crl.pem
#нужно скопировать сертификат удостоверяющего ценнтра
cp ./ca.crt /etc/openvpn/ca.crt
#нужно скопировать файл Диффи-Хелмана
cp ./dh.pem /etc/openvpn/dh.pem
#скопировать публичный и приватный ключи сервера
cp ./Server-01.crt /etc/openvpn/Server-01.crt
cp ./Server-01.key /etc/openvpn/Server-01.key
#нужно скопировать скрипт для авторизации
cp ./verify-cn /etc/openvpn/verify-cn
#теперь нужно всем файлам в папке дать права на чтение
chmod -R +r /etc/openvpn/
#а скипту еще и на исполнение
chmod +x /etc/openvpn/verify-cn

#нужно включить маршрутизацию
echo "net.ipv4.ip_forward = 1" |  tee -a /etc/sysctl.conf
echo "1" > /proc/sys/net/ipv4/ip_forward

#запускаем скрипт настаройки брандмауэра
iptables-setup.sh
#перезагружаемся
shutdown -r now