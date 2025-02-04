#!/bin/bash                                                                                       

if [[ "$#" == 0  ]] ; then 
    echo "Ran srm with 0 arguments"
fi
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

if [[ ${#options[@]} != 0 ]] ; then
    echo "Running rm with $*"
    rm "$@"
fi

setup_user_trash () {
    echo "Setting up user TRASH variable"
    # save_cwd=$(pwd)
    echo "Checking out HOME directory ( $HOME )"
    # ls $HOME | grep 
    existing_config_file=""
    if [[ -f "$HOME/.bash_profile" ]] ; then 
        existing_config_file="$HOME/.bash_profile" 
    elif [[ -f "$HOME/.bashrc" ]] ; then 
        existing_config_file="$HOME/.bashrc" 
    elif [[ -f "$HOME/.profile" ]]; then
        existing_config_file="$HOME/.profile" 
    fi

    echo "Found existing config file $existing_config_file"
    
    # mkdir ~/.trash
    # echo "TRASH=~/.trash" >> "$existing_config_file" 
    # # shellcheck source=/dev/null
    # source "$existing_config_file"
}
handle_empty_trash_variable () {

    trash_path=$(echo "$TRASH")
    if [[ -z "$trash_path" ]]; then
        echo "You have an empty TRASH variable"
        echo "May a TRASH variable be set up for you? (y/n)"
        user_in=""
        read user_in
        user_in=$(echo "$user_in" | tr '[:upper]' '[:lower]')
        if [[ "$user_in" == "y" ]]; then 
            setup_user_trash
        else
            echo "Terminating this run of $curr_program, no TRASH path declared"
            return 1
        fi
    fi
    
}




process_file_to_delete () {
    file_to_del=$1
    # trash_path=$2
    # trash_path=$(echo "$TRASH")
}


files_to_delete=()
get_files_to_delete () { 
    local files=("$1")
    echo "Running get_files_to_delete with argument: ${files[*]}"
    for file in "${files[@]}"; do
        echo "Expanding argument \"$file\""
        echo "running ls $file"
        tmp_files_to_delete="$(ls $file)"
        echo "Files to delete = ${files_to_delete[*]}"
        files_to_delete+=("${tmp_files_to_delete[@]}")
    done
}
# handle_empty_trash_variable
echo "${file_args[@]}"
get_files_to_delete "${file_args[@]}"
echo "List of files to delete = ${files_to_delete[*]}"






