#!/bin/bash

if [[ $# > 0 ]]; then
	echo "Incorrect Input: Received $# arguments when 0 should be given"; 
	exit 1
fi
bash whoson.sh | wc | awk '{print $1}'
