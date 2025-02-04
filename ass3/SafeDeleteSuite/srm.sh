#!/bin/bash                                                                                       

if [[ "$#" == 0  ]] ; then 
    echo "Ran srm with 0 arguments"
fi

determine_trash_existence () { 
    echo "TRASH = $TRASH"
    if [[ -z "$TRASH" ]] ; then
        echo "TRASH environment variable is not set up. Please set up TRASH variable and .trash/ directory"
        return 1
    fi
    if [[ -d "$TRASH" ]]; then
        echo "TRASH variable existence confirmed and set up at $TRASH"
        return 0
    else   
        echo "TRASH variable set up but directory to house trash environment does not exist"
        return 2
    fi
}
determine_trash_existence 
curr_program="srm"
options=()
file_args=()
unpack_arguments () { 
    # takes in one argument and appends to options_list on 1 return status
    # takes in one argument and appends to file_args_list on 2 return status  
    # returns error code 99 on any other setup that doesnt work but this shouldn't break
    arg_to_parse=$1
    echo "running unpack_arguments with $arg_to_parse"
    options_append_return_code=1
    file_args_list_append_return_code=2
    error_exit_code=99
    if [[ "${arg_to_parse:0:1}" == "-" ]]; then 
        if [[ "${arg_to_parse:1:1}" == "-" ]]; then 
            echo "$curr_program only receives 1 character options, the argument $1 will be skipped for this run of LSS"
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

for arg in "$@"; do
    unpack_arguments "$arg"
    if [[ $? == 99 ]]; then
        echo "Something went wrong when passing in $arg"
        echo "Continuing run without $arg"
    fi
done
echo "Resulting file_args = ${file_args[*]}"

if [[ ${#options[@]} -gt 0 ]] ; then
    echo "Running rm with $*"
    rm "$@"
fi







process_file_to_delete () {
    file_to_del=$1

    file_full_name="$PWD/$file_to_del"
    echo "Full file name = $file_full_name"
    encoded_file_name=$(echo -n "$file_full_name" | base64)
    if [[ -f "$TRASH/$encoded_file_name" ]]; then
        echo "Attempting to srm a file that already exists in trash. Please delete trashed file first"
        return 1
    elif [[ -d "$TRASH/$encoded_file_name" ]]; then
        echo "Attempting to srm a directory that already exists in trash. Please delete trashed directory first"
        return 2
    fi
    mv "$file_full_name" "$encoded_file_name"
    mv "$encoded_file_name" "$TRASH"
    return 0
}


files_to_delete=()
get_files_to_delete () { 
    local files=("$@")
    echo "Running get_files_to_delete with argument: ${files[*]}"
    for file_arg in "${files[@]}"; do
        echo "Expanding argument \"$file_arg\""
        tmp_files_to_delete=($file_arg)

        # echo "Files to delete = ${files_to_delete[*]}"
        for file in "${tmp_files_to_delete[@]}"; do
            if [[ -f "$file" ]]; then 
                files_to_delete+=("$file")
            elif [[ -d "$file" ]]; then
                files_to_delete+=("$file")
            fi
        done
    done
}
if [[ $? != 0 ]] ; then 
    echo "Could not find trash. Exiting now"
    exit 1
fi
echo "${file_args[@]}"
get_files_to_delete "${file_args[@]}"
echo "List of files to delete = ${files_to_delete[*]}"

for file_to_del in "${files_to_delete[@]}"; do
    process_file_to_delete "$file_to_del"
done







