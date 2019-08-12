#!/bin/bash
# testa o ambiente criado
#
IP4="10.10.10.10 10.10.10.100 10.10.20.100 10.10.20.10 10.10.10.200"
IP6="2001:db8:2018:A::10 2001:db8:2018:A::100 2001:db8:2018:B::100 2001:db8:2018:B::10"

testa_conectividade() {
	for i in $1; do
		lxc exec A2 -- /bin/ping$2 -c 3 $i > /dev/null && \
			lxc exec A2 -- /usr/sbin/traceroute -n $i > /dev/null
		if [ $? -eq 0 ]; then
			echo "Conectividade com $i : ok "
		else
			echo "Conectividade com $i : FALHA"
		fi
	done
}

echo "verificando conectividade IPv4 a partir de A2"
testa_conectividade "$IP4"
testa_conectividade "$IP6" 6

echo "verificando DNS a partir de A2"
lxc exec A2 -- /usr/bin/host www.debian.org
