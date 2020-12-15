#!/usr/bin/env bash

scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export PATH=$scriptDir/../bin:$scriptDir/../test:$scriptDir/../annsrcs/ensembl:$PATH

IFS="
"
[ ! -z ${ANNOTATION_PATH+x} ] || (echo "Env var ANNOTATION_PATH not defined." && exit 1)
[ ! -z ${FIELD_NAME1+x} ] || (echo "Env var FIELD_NAME1 not defined." && exit 1)
[ ! -z ${FIELD_NAME2+x} ] || (echo "Env var FIELD_NAME2 not defined." && exit 1)
[ ! -z ${OUTPUT_PATH+x} ] || (echo "Env var OUTPUT_PATH not defined." && exit 1)

for species_file in $(find $ANNOTATION_PATH -type f); do
  echo "extracting from $FIELD_NAME1 - $FIELD_NAME2 $species_file"
  merge_gene_attributes.sh $species_file $FIELD_NAME1 $FIELD_NAME2 
done