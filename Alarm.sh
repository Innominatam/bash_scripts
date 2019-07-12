#!/bin/bash

#mpg321 clementina rhythmbox amarok mplayer

#Поиск плееров
searchparam="Alarm"

setMusic() {
	Musiclist=$(ls ~/Alarm/Alarm_Music | grep -n ".*")
	if [[ $Musiclist == "" ]]; then
		echo Нет музыки в папке
	else
		echo "$Musiclist"
		Musiclist=($Musiclist)
		echo Выберите одну из песен
		read num
		chosedMusic=$(echo ${Musiclist[$num - 1]} | sed s/[0-9]*':'//)
		echo $chosedMusic
	fi
}

setPlayer() {
	playerlist=$(apt list --installed 2>~/null| grep "^mpg321/\|^clementina/\|^rhythmbox/\|^amarok/\|^mplayer/" 2>~/err.out| sed "s/[/].*//g" | grep -n ".*")
	if [[ $playerlist == "" ]]; then
		installPlayser
	else
		echo "$playerlist"
		playerlist=($playerlist)
		echo Выберите один из плееров
		read num
		echo ${playerlist[$num - 1]}
		chosedPlayer=$(echo ${playerlist[$num - 1]} | sed s/[0-9]*':'//)
		echo $chosedPlayer
	fi
}

installPlayser() {
	sudo apt install mplayer
	chosedPlayer="mplayer"
}

setDays() {
	echo "1: Monday"
	echo "2: Tuesday"
	echo "3: Wednesday"
	echo "4: Thursday"
	echo "5: Friday"
	echo "6: Saturday"
	echo "7: Sunday"
	echo "Введите Дни срабатывания (через пробел!!!), Enter, чтобы будильник срабатывал ежедневно"
	fst=""
	days=""
	read fst
	if [[ $fst == "" ]]; then
		days="*"
	else
		for var in $fst; do
			case $var in
			"1") days+="MON," ;;
			"2") days+="TUE," ;;
			"3") days+="WED," ;;
			"4") days+="THU," ;;
			"5") days+="FRI," ;;
			"6") days+="SAT," ;;
			"7") days+="SUN," ;;
			*) ;;
			esac
		done
		days=$(echo "$days" | sed s/'.$'//g)
	fi
}

newAlarm() {
	echo "Введите время срабатывания (через пробел!!!) Час Минута"
	while [[ True ]]; do
		read hour min
		if [[ $hour -gt 23 || $hour -lt 0 || $min -gt 59 || $min -lt 0 ]]; then
			echo "Введите корректные данные"
		else
			break
		fi
	done
	clear
	setDays
	clear
	setPlayer
	clear
	setMusic
	clear
	crontab -l | { cat; echo "$min $hour * * $days $chosedPlayer ~/$searchparam/Alarm_Music/$chosedMusic"; } | crontab -
}

delAlarm() {
	echo "Выберите будильник, который с которым нужно взаимодействовать: "
	read choose
	crontab -l | grep -v "$searchparam" | {
		cat
		crontab -l | grep "$searchparam" | sed "$choose d"
	} | crontab -
}

showAlarms() {
	#echo "№:минута"$'\t'"час"
	crontab -l | grep Alarm | grep -n ".*" | sed s/" \* \* "/"  "/g | sed s/"[~][/].*[/].*[/]"/"  "/
}

while [[ True ]]; do
	clear
	echo "0: Просмотреть список будильников"
	echo "1: Установить новый будильник"
	echo "2: Изменить будильник"
	echo "3: удалить будильник"
	echo "4: Выход"
	read command
	clear
	case $command in
	"0")
		showAlarms
		read -n 1 -s -r -p "Press any key to continue"
		;;
	"1") newAlarm ;;
	"2")
		showAlarms
		delAlarm
		newAlarm
		;;
	"3")
		showAlarms
		delAlarm
		;;
	"4") break ;;
	*)
		echo "Некорректная комманда"
		break
		;;
	esac
done
