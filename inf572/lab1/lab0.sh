#!/bin/bash
OSSH=openssh-server
FKE=newkey
KEY=/tmp/$FKE
if [ ! -z $1 ]; then
	for cs in A1 A2 R B1; do
		if [ "$1" = "$cs" ]; then
			echo "Preparando container $cs"
			CNT="$1"
			break
		fi
	done
else
	echo "container nao especificado"
	exit 2
fi

[ -z $CNT ] && echo "Container $1 invalido." && exit 3

echo "Verificando se $OSSH ja foi instalado em $CNT."
lxc exec $CNT -- /usr/bin/dpkg -l | grep $OSSH > /dev/null

if [ $? -eq 0 ]; then
	echo "openssh-server ja instalado. Prosseguindo ..."
else
	echo "Instalando ssh."
	lxc exec $CNT -- /usr/bin/apt install -y $OSSH
fi


if [ ! -f $KEY ] ; then
	echo "Gerando chave publica e privada e limpando arquivo known_hosts."
	ssh-keygen -b 2048 -t rsa -f $KEY  -N ""
else
	echo "Chave $KEY ja criada previamente. Prosseguindo..."
fi

echo "Removendo arquivo known_hosts."
rm -rf /root/.ssh/known_hosts

echo "Criando diretorio ~/.ssh na maquina"
lxc exec $CNT -- mkdir -p /root/.ssh
lxc exec $CNT -- chmod 700 /root/.ssh

echo "Autorizando acesso root sem senha." 
lxc file  push  $KEY.pub  $CNT/root/.ssh/
lxc exec $CNT -- mv /root/.ssh/$FKE.pub  /root/.ssh/authorized_keys
lxc exec $CNT -- chmod 600 /root/.ssh/authorized_keys
lxc exec $CNT -- rm -rf /root/.ssh/$FKE.pub

echo "Para logar no container $CNT:"
echo "ssh -i $KEY root@ipde$CNT"
