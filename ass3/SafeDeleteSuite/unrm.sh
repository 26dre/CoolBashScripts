#!/bin/bash                                                                                       
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
if [[ $? != 0 ]] ; then 
    echo "Could not find trash. Exiting now"
    exit 1
fi

curr_program="unrm"
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
done

process_file_to_return () {
    file_to_return=$1

    file_full_name="$PWD/$file_to_return"
    encoded_file_name=$(echo -n "$file_full_name" | base64)
    directory_to_return_to=$(dirname "$file_full_name")
    echo "Full file name = $file_full_name"
    if [[ -z "$directory_to_return_to" ]]; then
        echo "Could not find file path to restore to."
        return 3
    elif [[ -f $file_full_name ]]; then
        echo "Attempting to restore a file that already exists in current folder. Please delete current file before restoring"
        return 1
    elif [[ -d "$TRASH/$file_full_name" ]]; then
        echo "Attempting to restore a directory that already exists in current folder. Please delete current directory before restoring"
        return 2
    elif [[ -f "$TRASH/$file_full_name" || -d  "$TRASH/$file_full_name" ]]; then
        mv "$TRASH/$encoded_file_name" "$directory_to_return_to"
        mv "$directory_to_return_to/$encoded_file_name" "$(basename "$file_full_name")"
        return 0
    fi
}

files_to_unremove=()
get_files_to_unremove () { 
    local files=("$@")
    echo "Running get_files_to_delete with argument: ${files[*]}"
    for file_arg in "${files[@]}"; do
        echo "Expanding argument \"$file_arg\""
        tmp_files_to_delete=($file_arg)

        # echo "Files to delete = ${files_to_delete[*]}"
        for file in "${tmp_files_to_delete[@]}"; do
            if [[ -f "$file" ]]; then 
                files_to_unremove+=("$file")
            elif [[ -d "$file" ]]; then
                files_to_unremove+=("$file")
            fi
        done
    done
}

get_files_to_unremove "${file_args[@]}"
for file in "${files_to_unremove[@]}"; do 
    process_file_to_return "$file"
done