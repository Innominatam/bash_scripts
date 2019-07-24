#!/bin/bash

setTime() {
	echo "Введите время копирования (через пробел) Час Минута"
	while true; do
		read -r hour min
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
	echo "Введите дни срабатывания (через пробел), Enter, чтобы копироание происходило ежедневно"
	fst=""
	days=""
	read -r fst
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
		days=$(echo $days | sed s/'.$'//g)
	fi
}

setDirs() {
	echo "Что вы хотите скопировать (указывать нужно полные пути)?"
	read -r from
	if [ -f "$from" ]; then
		choosedDuplicator="tar -c"
		fromParam=""
		toParam="-f"
	else
		if [ -d "$from" ]; then
			choosedDuplicator="tar"
			fromParam=""
			toParam="-f"
		else
			if [ -b "$from" ]; then
				choosedDuplicator="dd"
				fromParam="if"
				toParam="of"
			else
				echo incorrect file type
			fi
		fi
	fi
	echo "Куда вы хотите поместить копию? укажите полный путь с названием файла"
	read -r to
	while true; do
		if [ -f "$to" ]; then
			break
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

newDupl() {
	setDays
	clear
	setTime
	clear
	setDirs
	clear
	crontab -l | {
		cat
		echo "$min $hour * * $days $choosedDuplicator $fromParam $from $toParam $to #duplicator"
	} | crontab -
}

delDupl() {
	echo "Выберите будильник, который с которым нужно взаимодействовать: "
	read -r choose
	crontab -l | grep -v "#duplicator" | {
		cat
		crontab -l | grep "#duplicator" | sed "$choose d"
	} | crontab -
}

showDupls() {
	echo '#' мин час дни_недели чем_копирую что_копирую куда_копирую
	crontab -l | grep "#duplicator" | grep ".*" -n | sed s/"\*"/"  "/g | sed s/"#duplicator"//g
}

while true; do
	clear
	echo "0: Просмотреть список дубликаторов"
	echo "1: Установить новый дубликатор"
	echo "2: Изменить дубликатор"
	echo "3: удалить дубликатор"
	echo "4: Выход"
	read -r command
	clear
	case $command in
	"0")
		showDupls
		read -n 1 -s -r -p "Press any key to continue"
		;;
	"1") newDupl ;;
	"2")
		showDupls
		delDupl
		newDupl
		;;
	"3")
		showDupls
		delDupl
		;;
	"4") break ;;
	*)
		echo "Некорректная комманда"
		break
		;;
	esac
done
