#!/bin/bash                                                                                       

long_bytes_position=5; 
if [-z "$#"]; then 
    echo "Running LSS command with 0 arguments"
    ls -l | sort -k$long_bytes_position -nr

fi