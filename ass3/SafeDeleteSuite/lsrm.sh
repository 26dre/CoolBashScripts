#!/bin/bash                                                                                       
# if [[ -d $TRASH ]]; then
#     ls -lR "$TRASH"
#     exit 0
# else
#     echo "Could not find Trash. Check you trash directory to make sure that it is set up and that TRASH variable is set up"
#     exit 1
# fi

ls_trash() {
    for file in "$TRASH"/*; do
        [ -e "$file" ] || continue  # Skip if no files exist

        # Extract original filename by decoding base64
        decoded_name=$(basename "$file" | base64 --decode 2>/dev/null)

        # Use ls -l to get file details
        file_info=$(ls -l "$file" | awk '{for(i=1; i<NF; i++) printf $i " "; }')
        if [[ -d "$file" ]] ; then 
            file_info=$(echo "$file_info" | tail -n +2)
        fi


        # Print ls output with decoded filename
        printf "%s %s\n" "$file_info" "$decoded_name"
    done
}

ls_trash