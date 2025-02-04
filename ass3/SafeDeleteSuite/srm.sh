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

if [[ ${#options[@]} -gt 0 ]] ; then
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
    # echo "export TRASH=~/.trash" >> "$existing_config_file" 
    # # shellcheck source=/dev/null
    # source "$existing_config_file"
}
# handle_empty_trash_variable () {

#     trash_path=$(echo "$TRASH")
#     if [[ -z "$trash_path" ]]; then
#         echo "You have an empty TRASH variable"
#         echo "May a TRASH variable be set up for you? (y/n)"
#         user_in=""
#         read user_in
#         user_in=$(echo "$user_in" | tr '[:upper:]' '[:lower:]')
#         echo "user_in = $user_in"
#         if [[ "$user_in" == "y" ]]; then 
#             setup_user_trash
#         else
#             echo "Terminating this run of $curr_program, no TRASH path declared"
#             return 1
#         fi
#     fi
    
# }

determine_trash_existence () { 
    trash_path=$(echo "$TRASH")
    if [[ -z "$trash_path" ]] ; then
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




process_file_to_delete () {
    file_to_del=$1

    echo "TRASH = $TRASH"
    file_full_name="$PWD/$file_to_del"
    echo "Full file name = $file_full_name"
    if [[ -f "$TRASH/$file_full_name" ]]; then
        echo "Attempting to srm a file that already exists in trash. Please delete trashed file first"
        return 1
    elif [[ -d "$TRASH/$file_full_name" ]]; then
        echo "Attempting to srm a directory that already exists in trash. Please delete trashed directory first"
        return 2
    fi
    mv "$file_full_name" "$TRASH"
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
determine_trash_existence
echo "${file_args[@]}"
get_files_to_delete "${file_args[@]}"
echo "List of files to delete = ${files_to_delete[*]}"

for file_to_del in "${files_to_delete[@]}"; do
    process_file_to_delete "$file_to_del"
done







