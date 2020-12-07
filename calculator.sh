#!/bin/bash

# Домашняя работа по BASH
#  ✔ Написать калькулятор скрипт calculator.sh который будет работать как с целочисленными значениями так и значениями с плавающей точкой.
#  ✔ Калькулятор должен принимать арифметическое выражение в качестве входного параметра ( например $bash > calculator.sh 10.5/3)
#  ✔ Калькулятор должен делать проверку арифметического выражения и если на вход калькулятора пришли символы отличные от цифр, знаков арифметических действий, то калькулятор должен отобразить ошибку и завершиться с кодом 128. Также не забываем возвращать код 0 по успешному завершению скрипта.
#  ✔ При реализации калькулятора надо использовать функции
#  ✔ Функции должны быть сгруппированы и вынесены в отдельные файлы и подключены в основном скрипте калькулятора  calculator.sh
#  ✔ Нельзя использовать AWK, bc для выполнения арифметических операций внутри калькулятора
#  ✔ Выкладывайте свою работу себе в гитхаб под именем gl-basecamp-bash, по желанию доабавляйте ascii cinema

DEC_POINT_COUNT=0
FLOATING=0

is_operable() {
	if [[ $1 =~ ^[+-]?[0-9]*\.[0-9]+$ ]]; then
		update_global_float $1
	elif [[ $1 =~ ^[+-]?[0-9]+$ ]]; then
		:
	elif [[ $1 =~ ^[-+x\/] ]]; then
		:
	else
		exit 128
	fi
}


update_global_float() {
	num=$1
	dec=${num#*.}
	if [ $DEC_POINT_COUNT -lt ${#dec} ]; then
		DEC_POINT_COUNT=${#dec}
	else
		DEC_POINT_COUNT=$DEC_POINT_COUNT
	fi
	FLOATING=1
}

apply_coefficient() {
	if [[ $1 =~ ^[+-]?[0-9]*\.[0-9]+$ ]]; then
		num=$1
		decimal=${num#*.}    
		integer=${num%.*}
		dec_points_count=${#decimal}
		if [ $integer -eq 0 ]; then
			number=$((decimal))
		else
			number=$((integer*10**$dec_points_count + decimal))
		fi
	else
		number=$(($1*10**$DEC_POINT_COUNT))
	fi
}


if [ \( $# -lt 3 \) -o \( $(($# % 2)) -eq 0 \) ]
then
    echo "usage (integers): ./calculator.sh number op number [ op number ] ..."
    echo "usage (float): ./calculator.sh number op number"
    echo "use x or '*' for multiplication"
    echo "for float division at least 1 of the operands must be in floating point notation"
    exit 1
fi
for i in "$@"
do
	if is_operable $i; then
		:
	fi
done
if [ $FLOATING -gt 0 ]; then
	apply_coefficient $1
	first=$number
	apply_coefficient $3
	third=$number
	if [[ $2 = [x] ]]; then
    	DEC_POINT_COUNT=$((DEC_POINT_COUNT + 1 ))
		ANS=$(($first ${2//x/*} $third ))
		printf %.${DEC_POINT_COUNT}f "$((10**$DEC_POINT_COUNT * $ANS/10**$DEC_POINT_COUNT))e-${DEC_POINT_COUNT}"
		echo
		exit 0
    elif [[ $2 = [/] ]]; then
    	printf %.${DEC_POINT_COUNT}f "$((10**$DEC_POINT_COUNT * $first/$third))e-${DEC_POINT_COUNT}"
    	echo
    	exit 0
	else
		ANS=$(($first $2 $third ))
    fi
	printf %.${DEC_POINT_COUNT}f "$((10**$DEC_POINT_COUNT * $ANS/10**$DEC_POINT_COUNT))e-${DEC_POINT_COUNT}"
	echo
	exit 0
else
	ANS=$(($1 ${2//x/*} $3))
	shift 3
	while [ $# -gt 0 ]
	do
	   ANS=$((ANS ${1//x/*} $2))
	   shift 2
	done
	echo $ANS
fi
exit 0
	