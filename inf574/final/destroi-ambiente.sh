#/bin/bash

for i in `lxc ls | awk  '{print $2}'`; do  
	if [ $i != "debian9padrao" ]; then 
		lxc exec $i -- poweroff ;
		lxc delete $i; 
	else echo $i;
       	fi;
done
