#!/bin/bash

function cleanup()
{
    rm -rf "${tmp_dir}" 
    trap - 0 1 2 3 15 
}
chmod +x "$0"
script_name=$(basename "$0")
c_file="${script_name}.c"
out_file="${script_name}.out"

tmp_dir="/tmp/awkawk3000"
if [ ! -d "$tmp_dir" ]; then 
    mkdir "$tmp_dir"
fi


gcc "$c_file" -o "${tmp_dir}/${out_file}"
trap cleanup 0 1 2 3 15
"${tmp_dir}/${out_file}" "$@"
cleanup








