#!/usr/bin/env bash

scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export PATH=$scriptDir/../bin:$scriptDir/../test:$scriptDir/../annsrcs/ensembl:$PATH

IFS="
"
[ ! -z ${ANNOTATION_PATH+x} ] || (echo "Env var ANNOTATION_PATH not defined." && exit 1)

check_empty_columns.sh > /tmp/logs.txt && cat /tmp/logs.txt | grep 'emptycol'

## remove temp logs
rm -rf /tmp/ogs.txt