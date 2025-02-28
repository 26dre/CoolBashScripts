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



echo "Awk program = $AWK_PROGRAM"
echo "FILENAME = $FILENAME"

# AWK_VAR_DECLS is declared such that you can add to a string and set those values in awk
# the assumption is that the number of fields is relatively small therefore passing them in is not all that complicated



interpret_first_line () {
    echo "Interpreting the first line to set the field values..."
    AWK_VAR_DECLS=$(awk -F'\t' 'NR == 1 { for (i = 1; i <= NF; i++) printf "-v %s=$%d ", $i, i }' "$FILENAME")
    echo "Var declarations = $AWK_VAR_DECLS"
}

interpret_first_line
echo "Variable declarations $AWK_VAR_DECLS"
# AWK_CMD_TO_RUN="awk $AWK_VAR_DECLS -F$DELIMITER 'NR > 1 {$AWK_PROGRAM}' $FILENAME"
# echo "$AWK_CMD_TO_RUN"
awk $AWK_VAR_DECLS -F"$DELIMITER" 'NR > 1 {$AWK_PROGRAM}' "$FILENAME"

# AWK_CMD_TO_RUN
