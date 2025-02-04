if [[ -d $TRASH ]]; then
    du -h "${TRASH:?}"/*
    exit 0
else
    echo "Could not find Trash. Check you trash directory to make sure that it is set up and that TRASH variable is set up"
    exit 1
fi