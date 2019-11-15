#!/bin/bash
#
if [ $# -eq 1 ]
	then
	echo "Aplicando o update em $1"
		lxc exec $1 -- /usr/bin/apt install -y rsyslog
		lxc file push ./rsyslog.conf $1/etc/
else
		echo "Sintaxe: instala-rsyslog.sh nome-do-container"
fi
