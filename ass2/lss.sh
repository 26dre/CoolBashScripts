#!/bin/bash

if [[ $# > 0 ]]; then
	echo "Expected to run with no arguments. Exectues on current directory only"
	exit 1
fi
ls -lS	

