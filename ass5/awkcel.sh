#!/bin/bash
# This is a front-end to awk(1), which allows NAMED COLUMNS to be accessed as variables.
# USAGE: awkcel {any standard awk program} FILENAME
# This script expects exactly two arguments.
# The first argument is an awk program that allows use of variables as described below.
# The second argument is an input file with a constant number of tab-separated columns.
# Any line that starts with a hash ("#") is assumed a comment, and discarded.
# The first (non-comment) line is the HEADER.
# The HEADER line contains tab-separated names of the columns.
# These column names must be valid awk(1) variable names.
# Each subsequent line must have the same number of tab-separated columns as the HEADER.
# COLUMNS SHOULD NOT BE EMPTY: behavior is undefined if any line has two adjacent tabs.
# Upon each line of input, values can be accessed using the name defined in the HEADER.
# For fun I may add a little if statement depending on the type of file but that is not relevant for this assignment

DELIMITER="\t"
AWK_PROGRAM="$1"
FILENAME="$2"

DEBUGGING_PRINTS_LOCATION="\dev\null"
if [ $# -eq 3 ]; then
    DEBUGGING_PRINTS_LOCATION="\dev\stderr"
fi

{
    echo "Curr program = $0"
    echo "Awk program = $AWK_PROGRAM" 
    echo "FILENAME = $FILENAME"
} >$DEBUGGING_PRINTS_LOCATION

# AWK_VAR_DECLS is declared such that you can add to a string and set those values in awk
# the assumption is that the number of fields is relatively small therefore passing them in is not all that complicated



interpret_first_line () {
    echo "Interpreting the first line to set the field values..." >$DEBUGGING_PRINTS_LOCATION
    # AWK_VAR_DECLS=$(awk -F'\t' 'NR == 1 { for (i = 1; i <= NF; i++) printf "-v %s=\"$%d\" ", $i, i }' "$FILENAME")
    AWK_VAR_DECLS=$(awk -F'\t' 'NR == 1 { for (i = 1; i <= NF; i++) printf "%s ", $i }' "$FILENAME")

    AWK_VAR_DECLS="${AWK_VAR_DECLS::-1}"
    

    AWK_PROGRAM=$(echo "$AWK_PROGRAM" | awk -v s1="$AWK_VAR_DECLS" '
BEGIN {
    split(s1, search, " ")  
}
{

    for (i = 1; i < length(search); i++) {
        print "search[" i "] = " search[i] > "/dev/stderr";
    }
    printf "Search length = %d\n", length(search) > "/dev/stderr"; 
    SEARCH_LEN = length(search);


    in_quotes = 0;
    n = split($0, tokens, /([[:space:]]+|[^[:alnum:]_]+)/, seps);  
    combined_idx = 1;
    
    for (i = 1; i <= n; i++) {
        combined[combined_idx++] = tokens[i];
        if (i < n) {
            combined[combined_idx++] = seps[i];
        }
    }
    for (i = 1; i <= length(combined); i++) {
        if (index(combined[i], "\"")){
            in_quotes = !in_quotes;
            if (in_quotes) print "\tENTERING QUOTES" > "/dev/stderr";  
            if (!in_quotes) print "\tLEAVING QUOTES" > "/dev/stderr";  
        }
        print "combined[" i "] = " combined[i] > "/dev/stderr";
    }
    print "" > "/dev/stderr"
    
    for (i = 1; i <= length(combined); i++) {
        if (index(combined[i], "\"")){
            in_quotes = !in_quotes;  
        }
        if (in_quotes) {
            printf "%s", combined[i];
            continue;
        } else {
            for (j = 1; j <= SEARCH_LEN; j++) { 
                printf "\tComparing %s to %s\n", combined[i], search[j] > "/dev/stderr";
                if (combined[i] == search[j]) {
                    # printf "CONFIRMED SIMILARITY: %s == %s\n", combined[i], search[j] > "/dev/stderr";
                    combined[i] = "$" j; 
                    break;
                }
            }
            printf "%s ", combined[i];
        }
    }
    printf "\n" > "/dev/stderr";
    print "Pre processed awk program below: " >  "/dev/stderr"
    for (i = 1; i <= length(combined); i++) {
        if (index(combined[i], "\"")){
            in_quotes = !in_quotes;  
        }
        if (in_quotes) {
            # printf "%s", combined[i] > "/dev/stderr";
        } else {
            # printf "%s ", combined[i] > "/dev/stderr";
        }
    }
    printf "\nHOLY SHIT DEAR GOD\n" > "/dev/stderr";
    printf "\047"
    for (i = 1; i <= length(combined); i++) {
        printf "%s", combined[i];
    }
    printf "\n";
}')

    echo "Pre processed awk program: $AWK_PROGRAM" >$DEBUGGING_PRINTS_LOCATION 

}

interpret_first_line
# FULL_AWK_CMD="-F'$DELIMITER' 'NR == 1 { next } $AWK_PROGRAM' $FILENAME"
# EXCLUDING_FILE_NAME=-F'$DELIMITER' "'NR == 1 { next } $AWK_PROGRAM'" 
SKIP_AWK_PROG="NR == 1 { next } $AWK_PROGRAM"
FULL_CMD=$(echo "-F'$DELIMITER'" "'$SKIP_AWK_PROG'" "$FILENAME")
{
    echo SKIP_AWK_PROG="$SKIP_AWK_PROG"
    echo EXCLUDING_FILE_NAME = "$EXCLUDING_FILE_NAME" 
    echo "FULL_CMD = $FULL_CMD"
    echo "WANTED = ""-F'$DELIMITER'" "'$SKIP_AWK_PROG'" "$FILENAME"
    echo "But what if"
    echo "awk $FULL_CMD"
    
    
    declare -p FULL_CMD
} >$DEBUGGING_PRINTS_LOCATION


# awk "$FULL_CMD"
awk -F"$DELIMITER" "$SKIP_AWK_PROG" "$FILENAME"
# awk  -F'\t' 'NR == 1 { next } $2=="00000"{print $1, "is the prof"} $2!="00000"{ print $1, "must be a TA or Reader or Student and got grade", int($3+0.5)}' name-studnum.tsv


# working command
#'studentNum=="00000"{print name, "is the prof"} studentNum!="00000"{ print name, "must be a TA or Reader or Student and got grade", int(grade+0.5)}'
# awk -v name=1 -F'\t' 'NR == 1 { next } 
# $2 == "00000" { print $name, "is the prof" } 
# $2 != "00000" { print $name, "must be a TA or Reader or Student and got grade", int($3 + 0.5) }' name-studnum.tsv

# Want to model things as the command above


