#!/bin/bash

unpack_arguments () { 
    # takes in one argument and appends to options_list on 1 return status
    # takes in one argument and appends to file_args_list on 2 return status  
    # returns error code 99 on any other setup that doesnt work but this shouldn't break
    # returns options to list options
    # returns file arguments to list file_args
    arg_to_parse=$1
    echo "running unpack_arguments with $arg_to_parse"
    options_append_return_code=1
    file_args_list_append_return_code=2
    error_exit_code=99
    if [[ "${arg_to_parse:0:1}" == "-" ]]; then 
        if [[ "${arg_to_parse:1:1}" == "-" ]]; then 
            # echo "$curr_program only receives 1 character options, the argument $1 will be skipped for this run of LSS"
            return $error_exit_code
        else 
            for ((i=1; i<"${#arg_to_parse}"; i++)); do
                next_option="${arg_to_parse:$i:1}"
                options+=("$next_option")
            done
            return $options_append_return_code
        fi

    else 
        file_args+=("$arg_to_parse")
        return $file_args_list_append_return_code
    fi
}