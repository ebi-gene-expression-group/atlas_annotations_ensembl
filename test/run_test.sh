#!/usr/bin/env bash

scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export PATH=$scriptDir/../bin:$scriptDir/../test:$scriptDir/../annsrcs/ensembl:$PATH

IFS="
"
for species_config in $(find $scriptDir/../annsrcs/ensembl -type f); do
   annotations_from_ensembl.sh $species_config
done
