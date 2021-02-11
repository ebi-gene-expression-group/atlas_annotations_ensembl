#!/bin/bash

[ ! -z ${LOG_PATH+x} ] || (echo "Env var LOG_PATH not defined." && exit 1)

annotation_file=$1

ncols=$(cat $annotation_file | head -n1 | wc -w)
nrows=$(cat $annotation_file | wc -l)

for i in $(seq 1 $ncols); do
    echo -e "\n####\n";
    echo "$annotation_file";
    col_name=$(cat $annotation_file | cut -f${i} | head -n1);
    echo "col-$col_name";
    echo "col-$i";
    empty_lines=$(cat $annotation_file | cut -f${i} | grep -E --line-number '^\s*$' | wc -l)
    echo "empty-lines -$empty_lines";

    if [ "$empty_lines" -eq "$(($nrows-1))" ];then
        echo "$annotation_file - $col_name - emptycol"
    fi
done

