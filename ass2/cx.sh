#!/bin/bash


num_errors=0
for arg in "$@"; do 
	echo "Attemting to make $arg executable"
	if [ -f "$arg" ] ; then
		chmod +x "$arg" 
		echo "Successfully made file $arg executable"
	else
		echo "File $arg does not exist, unable to make executable";
		((num_errors++))
	fi
done

exit $num_errors


