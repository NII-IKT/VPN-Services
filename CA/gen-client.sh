#!/bin/bash

username=$1
path_pki="/home/user-ca/easy-rsa-master/easyrsa3/"
path_ftp="/home/user-ca/share/clients/"

#проверка на то, что нам пришел ожидаемый параметр
if [ $# == 0 ]
then
	echo "Ошибка. Строка аргумента пустая."
	exit 1
fi

#проверка на дублирование сертификатов
if [ -d $path_ftp$username ]
then
	echo "Ошибка. Такой пользователь уже существует."
	exit 1
fi

#создаем папку для сертификата и ключа пользователя
mkdir $path_ftp$username
cd $path_pki

#генерируем публичный сертификат и приватный ключ пользователя
./easyrsa build-client-full $username nopass

#размещаем все по директориям
cp "$path_pki"pki/crl.pem /home/user-ca/share/base/
cp "$path_pki"pki/issued/"$username".crt  $path_ftp$username
cp "$path_pki"pki/private/"$username".key $path_ftp$username