#!/usr/bin/env bash 

scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export PATH=$scriptDir/bin:$scriptDir/test:$scriptDir/annsrcs/ensembl:$PATH

# data extraction from E! 
export ENSEMBL_JSON_PATH="test_data"
export ANNOTATIONS_PATH="test_data/outputs/annotations"
export GENE_ATTRIBUTES_PATH="test_data/outputs/gene_attributes"
export LOG_PATH="test_data/outputs"
export config="test_data/homo_sapiens.config"
export species=$(basename $config |  sed 's/\.[^ ]*//g')

# merging gene attributes
export annotation_file=$ANNOTATIONS_PATH/homo_sapiens.ensgene.tsv 
export field_name1='ensgene' 
export field_name2='symbol'

[ ! -d "$ANNOTATIONS_PATH" ] && mkdir -p "$ANNOTATIONS_PATH"
[ ! -d "$GENE_ATTRIBUTES_PATH" ] && mkdir -p "$GENE_ATTRIBUTES_PATH"

# run bats tests 
./atlas_annotations_ensembl_tests.bats
