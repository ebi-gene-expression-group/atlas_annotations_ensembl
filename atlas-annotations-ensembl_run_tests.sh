#!/usr/bin/env bash 

scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export PATH=$scriptDir/bin:$scriptDir/test:$scriptDir/annsrcs/ensembl:$PATH

# data extraction from E! 
export ENSEMBL_JSON_PATH="test_data"
export OUTPUT_TSV_PATH="test_data/outputs"
export config="test_data/homo_sapiens.config"
export species=$(basename $config |  sed 's/\.[^ ]*//g')

# merging gene attributes 
export FIELD_NAME1='ensgene' 
export FIELD_NAME2='symbol'






# run bats tests 
./atlas-annotations-ensembl_tests.bats


#annotations_from_ensembl.sh $config






