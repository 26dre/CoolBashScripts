#!/bin/bash

error_code=0
if [[ $# > 0 ]]; then 
	echo "Too many arguments passed in. Expected to run solely on current directory"
	error_code=1
else
	ls | wc | awk '{print $1}'
fi
exit $error_code

