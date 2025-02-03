#!/bin/bash                                                                                       

long_bytes_position=5; 
if [[ "$#" == 0 ]]; then 
    echo "Running LSS command with 0 arguments"
    ls -l | sort -k$long_bytes_position -nr

else
	echo "received $# arguments"
fi