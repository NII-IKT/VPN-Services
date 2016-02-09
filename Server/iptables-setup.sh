#!/bin/bash

## все далаем от рута, заходим так sudo su
## даем права на исполнение chmod +x iptables-setup.sh
## проверяем что есть три икса с помощью ls -l
## запускаем через точку ./iptables-setup.sh
## смотрим что получилось через iptables -L -V
## сохраняем наш конфиг service iptables save

IPT="/sbin/iptables"

# Очищаем правила и удаляем цепочки
$IPT -F
$IPT -X

$IPT -P INPUT DROP
$IPT -P FORWARD DROP
$IPT -P OUTPUT DROP

TCP_PORTS="5729"
UDP_PORTS="1194"

#обратная петля
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT

#установленные соединения
$IPT -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

#открываем порты
$IPT -A INPUT -p tcp -m multiport --dport $TCP_PORTS -j ACCEPT
$IPT -A INPUT -p udp -m multiport --dport $UDP_PORTS -j ACCEPT

#это для пинга
$IPT -A INPUT -p icmp -m icmp --icmp-type echo-reply -j ACCEPT 


#и наконец-то, для openVpn
#for xen or KVM
#iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
#iptables -A FORWARD -s 10.8.0.0/24 -j ACCEPT
#iptables -A FORWARD -j REJECT
#iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
#for OpenVZ
#iptables -t nat -A POSTROUTING -o venet0 -j SNAT --to <b>a.b.c.d</b>
#iptables -A FORWARD -i venet0 -o tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT
#iptables -A FORWARD -i tun0 -o venet0 -j ACCEPT
