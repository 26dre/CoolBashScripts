#!/bin/bash                                                                                       

long_bytes_position=5; 
if [[ "$#" == 0 ]]; then 
    echo "Running LSS command with 0 arguments"
    ls -l | sort -k$long_bytes_position -nr

else
	echo "LSS received $# arguments"
fi

ls_param=""
file_params=()

for arg in "$@"; do 
    if [[ "${arg:0:1}" == "-" ]]; then 
        ls_param="${arg:1:1}"
    else
        file_params+=("$arg")
    fi
done

# basic_inputs="a A b B f F L N n 1 x S k" 


# --author requires moving long_bytes_position + 1
# -i       requires moving long_bytes_position + 1
# -G       requires moving long_bytes_position - 1
# -h       requires changing sort command to sort by human readable
# -o       requires running ls   with -o command instead of -l AND long_bytes_position - 1 
# -g       requires running ls   with -g                       AND moving long_bytes_position - 1 
# -sk      requires running ls   with -sk command in addition to everything else
# I        requires running ls   with the next argument also being passed into ls
# -r       requires running sort with -r command               AND long_bytes_position - 1 


# long_bytes_inc="i l"

case "$ls_param" in 
    i ) 
        ((long_bytes_position++))
        ;;
    g | G | o )
        ((long_bytes_position--))
        ;;
    * ) echo "Did not find anything that requires incrementing or decrementing the long_bytes_position_variable" ;; 
esac

case $ls_param in 
    a | A | b | B | f | F | L | N | n | 1 | x | S | k | i | G | sk)
        ls -l -$ls_param "${file_params[*]}" | sort  -k$long_bytes_position -nr
        ;;
    g | o )
        ls -$ls_param "${file_params[*]}" | sort  -k$long_bytes_position -nr
        ;;
    I )
        ls -I "${file_params[*]}"  | sort  -k$long_bytes_position -nr 
        ;;
    r )
        ls -l ${file_params[*]}  | sort  -nk$long_bytes_position  
        echo "got to here"
        ;;
        
esac
    
    


