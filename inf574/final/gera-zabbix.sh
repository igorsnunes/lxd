#!/bin/bash
# documentacao de referencia: https://www.zabbix.com/documentation/4.4/manual
#
# gera maquina zabbix
#

echo "Copiando sources.list com repositorios non-free"
lxc file push ./conf/zabbix/sources.list $1/etc/apt/sources.list --mode 0755

echo "Atualizando pacotes e instalando wget"
lxc exec $1 -- /usr/bin/apt update
lxc exec $1 -- /usr/bin/apt upgrade -y
lxc exec $1 -- /usr/bin/apt install -y wget

echo "Adicionando repositorio zabbix 4.4"
lxc exec  $1 --  wget https://repo.zabbix.com/zabbix/4.4/debian/pool/main/z/zabbix-release/zabbix-release_4.4-1+stretch_all.deb
lxc exec  $1 --  dpkg -i zabbix-release_4.4-1+stretch_all.deb
lxc exec  $1 -- rm zabbix-release_4.4-1+stretch_all.deb
lxc exec  $1 -- /usr/bin/apt update

echo "Instalando zabbix server"
lxc exec $1 --  /usr/bin/apt install -y zabbix-server-mysql

echo "Copiando o arquivo de configuracao zabbix_server.conf"
lxc file push ./conf/zabbix/zabbix_server.conf $1/etc/zabbix/zabbix_server.conf --mode 0644

echo "Instalando frontend do zabbix"
lxc exec $1 --  /usr/bin/apt install -y zabbix-frontend-php zabbix-apache-conf

echo "Copiando o arquivo de configuracao php.ini"
lxc file push ./conf/zabbix/php.ini $1/etc/php/7.0/apache2/php.ini --mode 0644

echo "Copiando o arquivo configura-zabbix-server.sh"
lxc file push ./conf/zabbix/configura-zabbix-server.sh $1/root/configura-zabbix-server.sh --mode 0755

echo "Instalando o agente zabbix no servidor"
lxc exec $1 --  /usr/bin/apt install -y zabbix-agent
