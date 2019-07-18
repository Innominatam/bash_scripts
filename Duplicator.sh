#!/bin/bash

setTime() {
	echo "Введите время создания копии (через пробел!!!) Час Минута"
	while [[ True ]]; do
		read hour min
		if [[ $hour -gt 23 || $hour -lt 0 || $min -gt 59 || $min -lt 0 ]]; then
			echo "Введите корректные данные"
		else
			break
		fi
	done
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

setDirs() {
	echo "Что вы хотите скопировать (указывать нужно полные пути)?"
	read from
	echo "$from"
	if [ -f $from ]; then
		choosedDuplicator="tar -c"
		fromParam=""
		toParam="-f"
		echo its file
	else
		if [ -d "$from" ]; then
			choosedDuplicator="tar"
			fromParam=""
			toParam="-f"
			echo its dir
		else
			if [ -b "$from" ]; then
				choosedDuplicator="dd"
				fromParam="if"
				toParam="of"
				echo its block
			else
				echo incorrect file type
			fi
		fi
	fi
	echo "Куда вы хотите поместить копию? (укажите полный путь с названием файла)"
	read to
	while [[ True ]]; do
		if [ -f $to ]; then
			echo Такой файл уже существует!
		else
			if [ -d "$to" ]; then
				echo Это директория!
			else
				if [ -b "$to" ]; then
					echo Это блочное устройство!
				else
					break
				fi
			fi
		fi
	done
}

newAlarm() {
	setTime
	clear
	setDays
	clear
	setDirs
	clear
	crontab -l | {
		cat
		echo "$min $hour * * $days $choosedDuplicator $fromParam $from $toParam $to"
	} #| crontab -
}

delAlarm() {
	echo "Выберите будильник, который с которым нужно взаимодействовать: "
	read choose
	crontab -l | grep -v "$searchparam" | {
		cat
		crontab -l | grep "$searchparam" | sed "$choose d"
	} | crontab -
}

showDups() {
	crontab -l | grep "dd|tar" | grep -n ".*" | sed s/" \* \* "/"  "/g | sed s/"[~][/].*[/].*[/]"/"  "/
}


newAlarm


# while [[ True ]]; do
# 	clear
# 	echo "0: Просмотреть список будильников"
# 	echo "1: Установить новый будильник"
# 	echo "2: Изменить будильник"
# 	echo "3: удалить будильник"
# 	echo "4: Выход"
# 	read command
# 	clear
# 	case $command in
# 	"0")
# 		showDups
# 		read -n 1 -s -r -p "Press any key to continue"
# 		;;
# 	"1") newAlarm ;;
# 	"2")
# 		showDups
# 		delAlarm
# 		newAlarm
# 		;;
# 	"3")
# 		showDups
# 		delAlarm
# 		;;
# 	"4") break ;;
# 	*)
# 		echo "Некорректная комманда"
# 		break
# 		;;
# 	esac
# done
