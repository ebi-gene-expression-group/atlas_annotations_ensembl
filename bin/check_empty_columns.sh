#!/bin/bash

[ ! -z ${ANNOTATIONS_PATH+x} ] || (echo "Env var ANNOTATIONS_PATH not defined." && exit 1)


pushd ${ANNOTATION_PATH}

for species in $(ls ); do

    ncols=$(cat $species | head -n1 | wc -w)
    nrows=$(cat $species | wc -l)
    
    for i in $(seq 1 $ncols); do
        echo -e "\n####\n";
        echo "$species";
        col_name=$(cat $species | cut -f${i} | head -n1);
        echo "col-$col_name";
        echo "col-$i";
        empty_lines=$(cat $species | cut -f${i} | grep -E --line-number '^\s*$' | wc -l)
        echo "empty-lines -$empty_lines";

        if [ "$empty_lines" -eq "$(($nrows-1))" ];then
            echo "$species - $col_name - emptycol"
        fi
    done

done