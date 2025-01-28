#!/bin/bash

if [[ $# > 0 ]]; then
	echo "Incorrect Input: Received $# arguments when 0 should be given"; 
	exit 1
fi
for name in $(who | awk '{print $1}' | sort -u); do 
	groups "$name" | grep ugrad | awk '{print $1}' 
done
