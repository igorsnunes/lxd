#!/bin/bash
# gera maquina snmp: Controlador de dominio
#

echo "Copiando sources.list com repositorios non-free"
lxc file push ./conf/snmp/sources.list $1/etc/apt/sources.list --mode 0755

echo "Instalando pacotes"
lxc exec $1 -- /usr/bin/apt update
lxc exec $1 -- /usr/bin/apt upgrade -y
lxc exec $1 -- /usr/bin/apt install -y snmp snmp-mibs-downloader

echo "Copiando o arquivo de configuracao snmp.conf"
lxc file push ./conf/snmp/snmp.conf $1/etc/snmp/snmp.conf --mode 0755

echo "Copiando o arquivo testa-snmp.sh"
lxc file push ./conf/snmp/testa-snmp.sh $1/root/testa-snmp.sh --mode 0755
