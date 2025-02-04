du_trash () {
    for file in "$TRASH"/*; do
        [ -e "$file" ] || continue  

        # Extract original filename by decoding base64
        
        decoded_name=$(basename "$file" | base64 --decode 2>/dev/null)

        file_info=$(du -h "$file" | awk '{for(i=1; i<NF; i++) printf $i " "; }')

        printf "%s%s\n" "$file_info" "$decoded_name"

    done  
}

ls_trash

if [[ -d $TRASH ]]; then
    du_trash 
    exit 0
else
    echo "Could not find Trash. Check you trash directory to make sure that it is set up and that TRASH variable is set up"
    exit 1
fi


