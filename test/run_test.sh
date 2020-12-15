#!/usr/bin/env bash

scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export PATH=$scriptDir/../bin:$scriptDir/../test:$scriptDir/../annsrcs/ensembl:$PATH

IFS="
"

[ ! -z ${ENSEMBL_JSON_PATH+x} ] || (echo "Env var ENSEMBL_JSON_PATH not defined." && exit 1)
[ ! -z ${OUTPUT_TSV_PATH+x} ] || (echo "Env var OUTPUT_TSV_PATH not defined." && exit 1)
[ ! -z ${LOG_PATH+x} ] || (echo "Env var LOG_PATH not defined." && exit 1)


for species_config in $(find $scriptDir/../annsrcs/ensembl -type f); do
	
  species=$(basename $species_config |  sed 's/\.[^ ]*//g')

  rm -rf ${LOG_PATH}/${species}_config.err ${LOG_PATH}/${species}_config.out
  touch ${LOG_PATH}/${species}_config.out ${LOG_PATH}/${species}_config.err

  bsub -M 10000 -P bigmem -e ${LOG_PATH}/${species}_config.err -o ${LOG_PATH}/${species}_config.out "annotations_from_ensembl.sh $species_config"

done
