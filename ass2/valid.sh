#!/bin/bash

usr_in=$1
error_code=0
if [[ -z "$1" ]]; then 
	echo "No arguments provided. 1 should be provided."; 
	error_code=1
elif [[ "#$" -gt 1 ]]; then
	echo "Too many arguments provided. 1 should be provided."
	error_code=2
elif [[ "$usr_in" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then 
	echo yes
else 
	echo no
fi

exit $error_code
