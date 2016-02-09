#!/bin/bash
#скритп для автоматического развертывания CA

#проверка на то, что скипт запущен с правами суперпользователя
if [ "$(id -u)" != 0 ]
then
	echo "Этот скрипт нужно запускать с полномочиями root"
	exit 1
fi

#проверка на то, что скрипт запущен в ожидаемом окружении
if [ "$(lsb_release -si)" != "Ubuntu" ] && [ "$(lsb_release -si)" != "Debian" ]
then
	echo "Этот скипт нужно запускать на Ubuntu или Debian"
	exit 1
fi

#обновляем индексы пакетов до последней версии в репозиториях
apt-get update

#проводим синхронизацию по времени
apt-get -y install ntpdate ntp
service ntp stop
ntpdate pool.ntp.org
service ntp start

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

#добавляем пользователя с пониженными правами для управления CA !!здесь будет необходимо дважды ввести пароль нового пользователя
adduser --gecos "" user-ca

#устанавливаем zip для работы с архивами
apt-get -y install zip

#копируем скрипт, который будет отвечать за генерирование пользовательских сертификатов и ключей
cp ./gen-client.sh /home/user-ca/gen-client.sh

#копируем еще один скрипт, который будет отвечать за генерирование серверных сертификатов и ключей
cp ./gen-server.sh /home/user-ca/gen-server.sh

#создадим несколько полезных директорий (в последствии их можно вынести из домашнего каталога пользователя user-ca)
mkdir /home/user-ca/share/
mkdir /home/user-ca/share/base/
mkdir /home/user-ca/share/servers/
mkdir /home/user-ca/share/clients/

cd /home/user-ca/

#загружаем утилиту easy-rsa с сайта
wget https://github.com/OpenVPN/easy-rsa/archive/master.zip
unzip master.zip

#теперь необходимо создать инфраструктуру публичных ключей PKI

#переходим в нужную директорию
cd /home/user-ca/easy-rsa-master/easyrsa3

#создаем PKI
./easyrsa init-pki

#создаем удостоверяющий центр без пароля (в последствии можно сделать CA с паролем, однако это осложняет автоматическую генерацию сертификатов и ключей для пользователей и серверов)
./easyrsa build-ca nopass

#сразу скопируем нужный файл в нашу share папку
cp /home/user-ca/easy-rsa-master/easyrsa3/pki/ca.crt /home/user-ca/share/base/ca.crt

#создаем файл отзыва сертификатов
./easyrsa gen-crl

#аналогичего скопируем нужный нам файл в share папку
cp /home/user-ca/easy-rsa-master/easyrsa3/pki/crl.pem /home/user-ca/share/base/crl.pem

#устанавливаем права на все файлы в домашнем каталоге пользователя user-ca
chown -R user-ca:user-ca /home/user-ca/

#перезагружаемся !!можно опустить
shutdown -r now