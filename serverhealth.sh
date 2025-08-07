#!/bin/bash
# serverhealth

LOGFILE="health_server_report.log"
LIMIT="limit_disk.log"

used_disk() {
	df -h /mnt/c | tail -n 1 | awk '{print $5}'
}

useddisk=$(used_disk)

if [[ -z $useddisk ]]; then
	echo "Erreur lors de la récupération de l'espace disque"
	exit 1
fi

saved_limit=$(cat $LIMIT)

echo "Espace disque utilisé : " $useddisk

if [[ -n $saved_limit ]]; then
	echo "Limite disque enregistré : " $saved_limit
fi

read -p "Voulez vous (re) définir une limite ? (y/n) : " answer

case $answer in
y|Y) while true; do
   	read -p "Entrez un nombre : " limit
   	if [[ "$limit" =~ ^[0-9]+$ ]]; then
		echo $limit > $LIMIT
   		echo "Limite enregistré : " $limit;
   		break
   	else
   		echo "La limite doit être un entier"
   	fi
   done;;
n|N) echo "Aucune limite défine";;
*) "Réponse incorrecte"
esac

if [[ "$useddisk" =~ ^[0-9]+%$ ]] && [ "${useddisk%\%}" -gt "${limit:-$saved_limit}" ]; then
	echo "Attention l'espace disque à dépassé la limite" used_disk
else
	echo "Espace disque OK"
fi

read -p "Voulez vous rechercher un processus en cours ? (y/n) : " process

case $process in
y|Y)
	ps -f -u scorpion > allprocess
	read -p "Entrer le nom d'un processus (ex. : bash, sshd) : " entryprocess
	grep "$entryprocess" allprocess
	rm allprocess;;
n|N) echo "Aucun processus rechercher";;
*) echo "Réponse incorrecte"
esac

cpu_load(){
	top -b -n 1 | head -n 3 | grep "%Cpu(s)"
}

display_cpu_load=$(cpu_load)

if [[ -z $display_cpu_load ]]; then
	echo "Erreur lors de la récupération de la charge du CPU"
fi

read -p "Souhaitez-vous vérifier la charge du CPU ? (y/n) : " cpu_answer

case "$cpu_answer" in
y|Y)
	echo $display_cpu_load
	is_cpu_load_view="Consulté";;
n|N) echo "Charge CPU non consulté";;
*) echo "Réponse incorrecte"
esac

echo -e "\n============================="
echo "===     Rapport Santé     ==="
echo "============================="
echo "Date : $(date)"
echo "Espace disque utilisé : $useddisk"
echo "Limite de l'espace disque définit : ${limit:-$saved_limit}"
echo "Process recherché : ${entryprocess:-aucun}"
echo "Charge CPU : ${is_cpu_load_view:-non consulté}"
echo "===FIN==="

read -p "Souhaitez-vous enregistrer ce rapport ? (y/n) : " save

case "$save" in
y|Y)
	{
	  echo -e "\n=============================";
	  echo "===     Rapport Santé     ===";
	  echo "=============================";
	  echo "Date : $(date)";
	  echo "Espace disque utilisé : $useddisk";
	  echo "Limite de l'espace disque définit : ${limit:-$saved_limit}";
	  echo "Process recherché : ${entryprocess:-aucun}";
	  echo "Charge CPU : ${is_cpu_load_view:-non consulté}"
          echo "===FIN===";
	} >> $LOGFILE
	echo "Rapport enregistré dans health_server_report.log";;
n|N)
	echo "Rapport non enregistrer, au revoir !"
	exit 0;;
*)
	echo "Réponse incorrecte"
esac
