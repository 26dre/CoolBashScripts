#!/bin/bash                                                                                       

long_bytes_position=5; 
base_ls_cmd="ls -l";
tail_cmd="tail -n +2";
base_sort_cmd="sort -nk$long_bytes_position";
base_sort_cmd_reversed="$base_sort_cmd -r";

# testing
# echo $base_sort_cmd;
# echo $base_sort_cmd_reversed;


if [[ "$#" == 0 ]]; then 
    # echo "Running LSS command with 0 arguments"
    $base_ls_cmd | $tail_cmd | $base_sort_cmd_reversed
else
	echo "LSS received $# arguments"
fi

options_list=()
file_args_list=()

unpack_arguments () { 
    # takes in one argument and appends to options_list on 1 return status
    # takes in one argument and appends to file_args_list on 2 return status  
    # returns error code 99 on any other setup that doesnt work but this shouldn't break
    arg_to_parse=$1
    echo $arg_to_parse
    options_apend_return_code=1
    file_args_list_append_return_code=2
    error_exit_code=99
    if [[ "${arg_to_parse:0:1}" == "-" ]]; then 
        if [[ "${arg_to_parse:1:1}" == "-" ]]; then 
            echo "LSS only receives 1 character options, the argument $1 will be skipped for this run of LSS"
            return $error_exit_code
        else 
            for ((i=1; i<"${#arg_to_parse}"; i++)); do
                next_option="${arg_to_parse:$i:1}"
                options_list+=($next_option)
            done
            return $options_apend_return_code
        fi

    else # we are looking at a file type here
        file_args_list+=("$arg_to_parse")
        return $file_args_list_append_return_code
    fi
}


for arg in $@; do
    unpack_arguments $arg
done
echo "Options list = ${options_list[@]}"
shift $options_list
echo "Options list shifted = ${options_list[@]}"
echo "Arguments list = ${file_args_list[@]}"

# determine_options
# for option in "${options_list[@]}"; do


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
        ls -l -$ls_param ${file_params[*]} | sort  -k$long_bytes_position -nr
        ;;
    g | o )
        ls -$ls_param ${file_params[*]} | sort  -k$long_bytes_position -nr
        ;;
    I )
        ls -I ${file_params[*]}  | sort  -k$long_bytes_position -nr 
        ;;
    r )
        echo "Running with -r"
        ls -l ${file_params[*]}  | sort  -nk$long_bytes_position  
        ;;
        
esac
    
    


