#!/bin/bash


num_errors=0
for arg in "$@"; do 
	echo "Attemting to make $arg executable"
	chmod +x "$arg" || ((num_errors++))
done

exit $num_errors


