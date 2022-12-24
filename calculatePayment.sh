#!/bin/bash


numArgs="$#"

usage="Usage : calculatePayment.sh <valid_file_name> [More_Files] ... <money>"
fail=0

if [ $numArgs -lt 2 ]; then
 	fail=1
 	
elif  [[ ! "${!#}" =~ ^[0-9]+(\.[0-9]+)?$ ]] ; then
	fail=2

elif [ true ]; then
	for file in ${@:1:(($#-1))}
		do
		if [ ! -f $file ]; then
			echo "File does not exist : $file" >&2
			fail=3
		elif [[ ! $file == *.txt ]]; then
			echo "File does not exist : $file" >&2
			fail=3
		fi	
	done
fi

case $fail in
	1) echo "Number of parameters received : $numArgs" >&2 
		echo "$usage" 
		exit ;;
	2) echo "Not a valid number : ${!#}" >&2  
		echo "$usage" 
		exit ;;
	3) echo "$usage" 
		exit ;;
esac

payment=${!#}
check_num='?[0-9]+(\.[0-9]*)?'

echo "" > toPay.txt
for file in ${@:1:(($#-1))}
	do
	grep -E -o $check_num $file | while read -r line;
	do
		echo $line >> toPay.txt
	done 
	
done
toPay=0
for line in `cat toPay.txt`;
do
	toPay="$(echo "$toPay+$line" | bc -l)"
done

echo -n "Total purchase price : "
printf "%.2f\n" $toPay
change=$(echo $payment - $toPay | bc -l | sed -e 's/^\./0./' -e 's/^-\./-0./');

if [ ${change:0:1} == "-" ]; then
	echo -n "You need to add "
	printf "%.2f" ${change:1}
	echo " shekel to pay the bill"
	
elif [ $change == "0" ]; then
	echo "Exact payment"
else 
	echo -n "Your change is "
	printf "%.2f" $change 
	echo " shekel"
fi

exit
