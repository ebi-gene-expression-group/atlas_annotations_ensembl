#!/usr/bin/env bash

## This script takes two field name that is defined in merged annotation file as args and exports file extracting two fields names
## example make tsv of 
# 'ensgene' and 'enstranscript' or 
# 'ensgene' and 'symbol' i.e gene_id and gene_name ( we use these file for redocaration of gene and transctipt file in GXA and SCXA)

scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

IFS="
"


annotation_file=$1
col1=$2
col2=$3

species=$(basename $annotation_file |  sed 's/\.[^ ]*//g')

output_annotation_file=$GENE_ATTRIBUTES_PATH/${species}.${col1}.${col2}.tsv

rm -rf $output_annotation_file
touch $output_annotation_file

## extract column number of the atrribute
col_num1=$(cat $annotation_file | head -n1 | tr '\t' '\n' | grep -nw "$col1" | sed 's/\:.*//g')
col_num2=$(cat $annotation_file | head -n1 | tr '\t' '\n' | grep -nw "$col2" | sed 's/\:.*//g')

if [[ ! -z "$col_num1" ]] && [[ ! -z "col_num2" ]]; then
    joined_cols=$(cat $annotation_file | cut -f"$col_num1,$col_num2" -d $'\t' | awk 'NF > 0' | awk '{if (NR!=1) {print}}')
else 
    echo "ERROR: $col1 or $col2 column is missing in $annotation_file"
    exit 1
fi     

echo -e "$joined_cols" \
 | while IFS=$'\t' read -r line; do
	
	    primary_id=$(echo -e $line | awk -F '\t' '{ print $1 }')
		num_of_values=$(echo -e $line | awk -F'\t' '{ print $2 }' | tr '@@' '\n' | sed '/^ *$/d' | wc -l)

        if [ "$num_of_values" -gt 1 ]; then	
            secondary_ids=$(echo -e $line | awk -F '\t' '{ print $2 }' | tr '@@' '\n' | sed '/^$/d')
            
           echo -e "$secondary_ids" \
           | while read secondary_id; do
            	paste <(echo "$primary_id") <(echo "$secondary_id") -d '\t' >> $output_annotation_file
            done 

        else
            secondary_id=$(echo -e $line | awk -F '\t' '{ print $2 }')
            paste <(echo "$primary_id") <(echo "$secondary_id") -d '\t' >> $output_annotation_file
        fi   
        
	done
