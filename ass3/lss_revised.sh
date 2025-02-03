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

echo "Arguments received: $@"
for arg in "$@"; do 
    echo "$arg"
done

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
        echo "Appending $arg_to_parse to file_args_list"
        file_args_list+=("$arg_to_parse")
        return $file_args_list_append_return_code
    fi
}


for arg in "$@"; do
    echo "Arg received: $arg"
    unpack_arguments "$arg"
done
echo "Options list = ${options_list[@]}"
# echo "Options list shifted = ${options_list[@]:1}"
echo "Arguments list = ${file_args_list[@]}"

# determine_options
contains () {
    # determines if you can find needle ($1) in a haystack ($2)
    # returns 1 if contains, returns 0 if not found
    needle=$1
    haystack=$2
    echo "Attempting to find $needle in ${haystack[@]}"
    case $needle in 
        "${haystack[@]}" )
            return 1
            ;;
        * )
            return 0
            ;;
    esac
}
show_ascending=0
ls_options=()
sort_options=()
deal_with_option () {
   option=$1 
   case $option in 
        a | A | b | B | c | d | F | H | L | k | l | n | p | q | Q | T | x | 1)
            ls_options+=("-$option")
            ;;

        C | f | m | S)
            echo "$option does not work when long form listing of ls occurs, $option will be skipped in this run of LSS"
            ;;

        u | t | X )
            echo "$option does not work as it will have no effect on the final output. $option will be skipped in this run of lss"
            ;;
        g | G | o )
            ((long_bytes_position--))
            ls_options+=("-$option")
            ;;
        i | s | Z )
            ((long_bytes_position++))
            ls_options+=("-$option")
            ;;
        h )
            sort_options+=("-$option")
            ls_options+=("-$option")
            ;;
        I )
            ls_options+=("-$option")
            ls_options+=("${file_args_list[0]}")
            file_args_list=("${file_args_list[@]:1}")
            ;;
        r )
            show_ascending=1
            ;;
        R )
            echo "Removed $option because this input is unnecessarily complicated and hard to implement"
            ;;
        * )
            echo "$option is not one of the original ls functions, and was therefore skipped"
            ;;
   esac
}


for option in "${options_list[@]}"; do
    deal_with_option $option
done

echo "ls_options list = ${ls_options[@]}"
echo "sort_options list = ${sort_options[@]}"
echo "arguments list = ${file_args_list[@]}"


if contains -o ${ls_options[@]} ; then
    echo "Contains -o"
else 
    echo "Does not contain"
fi


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



    


