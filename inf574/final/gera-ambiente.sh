#!/bin/bash
# gera o ambiente
#
#

function interface_gen() {
	F="/tmp/interfaces"
	echo "auto lo" > $F
	echo "iface lo inet loopback" >> $F
	while [ ! -z $1 ]; do
		echo "auto $1" >> $F
		echo "iface $1 inet static" >> $F; shift
		echo "address $1" >> $F; shift
		echo "gateway $1" >> $F; shift
	done;

}

# arg1 vmname
# arg2 network
# arg3 interface
# arg4 ip
# arg5 gateway

function vm_gen() {
	echo "Criando a maquina $1"
	lxc copy debian9padrao $1
	echo "Ligando interface eth0 na rede interna"
	lxc network attach $2 $1 $3
	echo "Copiando configuracao de rede"
	interface_gen $3 $4 $5
	lxc file push /tmp/interfaces $1/etc/network/interfaces
}

echo "Criando redes "
lxc network create DMZ ipv4.address=192.168.20.254/24 ipv4.nat=false ipv4.dhcp=false
lxc network create RSERVERS ipv4.address=192.168.30.254/24 ipv4.nat=false ipv4.dhcp=false
lxc network create RWEB ipv4.address=192.168.40.254/24 ipv4.nat=false ipv4.dhcp=false

## DNS AUTH
vm_gen "DNSAUTH" "DMZ" "eth0" "192.168.20.4" "192.168.20.1"

### PROXY
vm_gen "PROXY" "DMZ" "eth0" "192.168.20.3" "192.168.20.1"

### SSHS
vm_gen "SSHS" "DMZ" "eth0" "192.168.20.2" "192.168.20.1"


### WWW1
vm_gen "WWW1" "RWEB" "eth0" "192.168.30.2" "192.168.30.1"

### WWW2
vm_gen "WWW2" "RWEB" "eth0" "192.168.30.3" "192.168.30.1"


### SLOG
vm_gen "SLOG" "RSERVERS" "eth0" "192.168.40.2" "192.168.30.1"

### DNSREC
vm_gen "DNSREC" "RSERVERS" "eth0" "192.168.40.3" "192.168.30.1"


### R2
echo "Criando roteador R2"
lxc copy debian9padrao R2

### R1
echo "Criando roteador R1"
lxc copy debian9padrao R1


echo "Ligando interfaces de R1"
lxc network attach DMZ R1 eth1
lxc network attach R2 R1 eth2 ## REVER! TEM QUE LIGAR EM F2
#lxc network attach F1 R1 eth3 ## REVER! TEM QUE LIGAR EM F1


echo "Ligando interfaces de R2"
lxc network attach RWEB R2 eth1
lxc network attach RSERVERS R2 eth2
lxc network attach R1 R2 eth3 ## rever, tem que ligar no firewall

echo "Copiando configuracoes"
interface_gen "eth1" "192.168.20.1" "ipdainternet" "eth2" "192.168.40.1" "ipdainternet" "eth3" "ipdainternet" "ipdainternet"# REVER
lxc file push /tmp/interfaces R1/etc/network/interfaces

interface_gen "eth1" "192.168.20.1" "ipdainternet" "eth2" "192.168.40.1" "ipdainternet" # REVER
lxc file push /tmp/interfaces R1/etc/network/interfaces


echo "Iniciando containers"
for i in "DNSAUTH" "PROXY" "SSHS" "WWW1" "WWW2" "SLOG" "DNSREC" "R2" "R1"
do
	lxc start $i
done
echo "Aguardando 10 segundos para garantir que R esta no ar"
sleep 10
