#!/bin/bash                                                                                       

long_bytes_position=5; 
if [[ "$#" == 0 ]]; then 
    echo "Running LSS command with 0 arguments"
    ls -l | sort -k$long_bytes_position -nr
else
	echo "received $# arguments"
fi

ls_params=()
# change_made=1
# unpack_args_and_append () {
#     length=${#arg};
#     if [["$length" <= 1 || "${arg:0:1}" != "-"]]; then 
#         change_made=0
    


# }
# i=0
# for arg in "$@"; do
#     $((i++))
file_paths=()
for arg in "$@"; do 
    if [[ "${arg:0:1}"]]; then # in the passing parameters to the LS command form
        for ((i=1; i<"${#arg}"; i++)) do
            ls_params+=("${arg:$i:1}")
        # ls_params+=("${arg:1:1}")
    else # in the passing file paths place
        file_paths+=("$arg")
    
