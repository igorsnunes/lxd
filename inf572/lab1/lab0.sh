#!/bin/bash
OSSH=openssh-server
FKE=newkey
KEY=/tmp/$FKE

echo "Verificando se $OSSH ja foi instalado."
lxc exec R -- /usr/bin/dpkg -l | grep $OSSH > /dev/null

if [ $? -eq 0 ]; then
	echo "openssh-server ja instalado. Prosseguindo ..."
else
	echo "Instalando ssh."
	lxc exec R -- /usr/bin/apt install -y $OSSH
fi


if [ ! -f $KEY ] ; then
	echo "Gerando chave publica e privada."
	ssh-keygen -b 2048 -t rsa -f $KEY  -N ""
else
	echo "Chave $KEY ja criada previamente. Prosseguindo..."
fi

echo "Criando diretorio ~/.ssh na maquina"
lxc exec R -- mkdir -p /root/.ssh
lxc exec R -- chmod 700 /root/.ssh

echo "Autorizando acesso root sem senha." 
lxc file  push  $KEY.pub  R/root/.ssh/
lxc exec R -- mv /root/.ssh/$FKE.pub  /root/.ssh/authorized_keys
lxc exec R -- chmod 600 /root/.ssh/authorized_keys
lxc exec R -- rm -rf /root/.ssh/$FKE.pub

echo "Para logar no container:"
echo "ssh -i $KEY root@10.10.20.100"
