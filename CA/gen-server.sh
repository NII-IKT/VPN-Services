#!/bin/bash

servername=$1
path_pki="/home/user-ca/easy-rsa-master/easyrsa3/"
path_ftp="/home/user-ca/share/servers/"

#проверка на то, что нам пришел ожидаемый параметр
if [ $# == 0 ]
then
	echo "строка аргумента пустая"
	exit 1
fi

#проверка на дублирование сертификатов
if [ -d $path_ftp$servername ]
then
	echo "такой сервер уже существует"
	exit 1
fi

#создаем папку для сертификата и ключа сервера
mkdir $path_ftp$servername
cd $path_pki

#генерируем публичный сертификат и приватный ключ сервера
./easyrsa build-server-full $servername

#размещаем все по директориям
cp "$path_pki"pki/issued/"$servername".crt  $path_ftp$servername
cp "$path_pki"pki/private/"$servername".key $path_ftp$servername

cp "$path_pki"pki/crl.pem /home/user-ca/share/base/