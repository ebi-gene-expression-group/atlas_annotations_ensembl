#!/bin/bash

[ -z ${LOG_PATH+x} ] && echo "Env var LOG_PATH not defined." && exit 1

annotation_file=$1

ncols=$(cat $annotation_file | head -n1 | wc -w) 
nrows=$(cat $annotation_file | wc -l)

for i in $(seq 1 $ncols); do
    col_name=$(cat $annotation_file | cut -f ${i} | head -n1);
    echo "Column name: $col_name";
    echo "Column number: $i";
    empty_lines=$(cat $annotation_file | cut -f ${i} | grep -E --line-number '^\s*$' | wc -l)
    echo "Number of empty lines: $empty_lines";

    warn_num=$(($nrows / 2))
    if [ "$empty_lines" -eq "$(($nrows-1))" ]; then
        echo "Error: Column $col_name in $(basename $annotation_file) is empty"
    elif [ "$empty_lines" -gt "$warn_num" ];then
        echo "Warning: Column $col_name in $(basename $annotation_file) is at least half-empty"
    fi 
    echo -e "#####################";

done

