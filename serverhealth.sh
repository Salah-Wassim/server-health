#!/bin/bash
# serverhealth

LOGFILE="health_server_report.log"

useddisk=$(df -h /mnt/c | tail -n 1 | awk '{print $5}')
echo "Espace disque utilisé : " $useddisk

echo "Voulez vous définir une limite ? (y/n)"

read answer

case $answer in
y|Y) while true; do
   	read -p "Entrez un nombre : " limit
   	if [[ "$limit" =~ ^[0-9]+$ ]]; then
   		echo "Limite enregistré : " $limit;
   		break
   	else
   		echo "La limite doit être un entier"
   	fi
   done;;
n|N) echo "Aucune limite défine";;
*) "Réponse incorrecte"
esac

if [[ "$useddisk" =~ ^[0-9]+%$ ]] && [ "${useddisk%\%}" -gt "$limit" ]; then
	echo "Attention l'espace disque à dépassé la limite" $useddisk
else
	echo "Espace disque OK"
fi

echo "Voulez vous rechercher un processus en cours ? (y/n)"

read process

case $process in
y|Y) ps -f -u scorpion > allprocess;;
n|N) echo "Aucun processus rechercher";;
*) echo "Réponse incorrecte"
esac

echo "Entrer le nom d'un processus (ex. : bash, sshd) : "

read entryprocess

grep "$entryprocess" allprocess

rm allprocess

echo -e "\n============================="
echo "===     Rapport Santé     ===" | tee -a "$LOGFILE"
echo "============================="
echo "Date : $(date)" | tee -a "$LOGFILE"
echo "Espace disque utilisé : $useddisk" | tee -a "$LOGFILE"
echo "Limite de l'espace disque définit : $limit" | tee -a "$LOGFILE"
echo "Process recherché : $entryprocess" | tee -a "$LOGFILE"
echo "===FIN===" | tee -a "$LOGFILE"
