#!/bin/bash
# gera um container com nginx e libera acesso para a porta 8080
#  
[ $# -lt 1 ] && echo "paramentro errado" && exit 1

echo "Iniciando container"
lxc list $1 | grep $1 
if [ $? -ne 0 ]; then
	lxc start $1
	echo "Aguardando 5 segundos para inicialização"
	sleep 5
fi

### NGINX
echo "Instalando e configurando nginx"
lxc exec $1 -- apt update
lxc exec $1 -- apt upgrade -y
lxc exec $1 -- apt install -y nginx

###
# redirecionando a porta 8080 para o servidor na porta 80 no container nginx
lxc config device add $1 myport8080 proxy listen=tcp:0.0.0.0:8080 connect=tcp:0.0.0.0:80

WWW1=192.168.30.2
WWW2=192.168.30.3

echo "upstream myapp1 {" > /tmp/nginx.conf
echo "server $WWW1;" >> /tmp/nginx.conf
echo "server $WWW2;" >> /tmp/nginx.conf
echo "}" >> /tmp/nginx.conf
echo "" >> /tmp/nginx.conf
echo "server {" >> /tmp/nginx.conf
echo "listen 80;" >> /tmp/nginx.conf
echo "location / {" >> /tmp/nginx.conf
echo "proxy_pass http://myapp1;" >> /tmp/nginx.conf
echo "}" >> /tmp/nginx.conf
echo "}" >> /tmp/nginx.conf

lxc exec $1 -- unlink /etc/nginx/sites-enabled/default
lxc file push /tmp/nginx.conf $1/etc/nginx/sites-available/reverse-proxy.conf
lxc exec $1 -- ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/reverse-proxy.conf

lxc exec $1 -- service nginx configtest
lxc exec $1 -- service nginx restart

