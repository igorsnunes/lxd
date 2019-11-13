#!/bin/bash
#
if [ $# -eq 1 ]
	then
	echo "Aplicando o update em $1"
		lxc exec $1 -- /usr/bin/apt install -y apt-transport-https
		lxc exec $1 -- /usr/bin/apt install -y wget
		lxc exec $1 -- /usr/bin/wget https://packages.graylog2.org/repo/packages/graylog-3.1-repository_latest.deb
		lxc exec $1 -- /usr/bin/dpkg -i ./graylog-3.1-repository_latest.deb
		lxc exec $1 -- /usr/bin/apt update
		lxc exec $1 -- /usr/bin/apt install -y graylog-server
else
		echo "Sintaxe: install-apache-php.sh nome-do-container"
fi
