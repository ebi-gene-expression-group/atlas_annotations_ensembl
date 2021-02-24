#!/usr/bin/env bash

scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export PATH=$scriptDir/../bin:$scriptDir/../test:$scriptDir/../annsrcs/ensembl:$PATH

IFS="
"

[ ! -z ${ENSEMBL_JSON_PATH+x} ] || (echo "Env var ENSEMBL_JSON_PATH not defined." && exit 1)

## finding microarray technologies (AGILENT/ILLUMINA) in species_probes.json file
jq -cn --indent 2 --stream 'fromstream(1|truncate_stream(inputs)) | .arrays | map(select(.array_vendor | test("(AGILENT)|(ILLUMINA)"; "i"))))' \
			 "$ENSEMBL_JSON_PATH/$species/${species}_probes.json" 

cat "$ENSEMBL_JSON_PATH/$species/${species}_probes.json"| jq -cn --stream 'fromstream(1|truncate_stream(inputs)) | .arrays | map(select(.array_vendor | test("(AGILENT)"; "i"))) | map(.design_id) | .[]'


## chipset in the probsets.json in top 10000 rows
jq -cn --stream 'fromstream(1|truncate_stream(inputs))' "$ENSEMBL_JSON_PATH/$species/${species}_probes.json" | head -n10000 | jq .arrays[].array_chip | grep -v '"CODELINK"\|"OneArray"'


## Probes under transcript. Genes file have probes from Affy only, agilent and illumina are missing.
cat "$ENSEMBL_JSON_PATH/$species/${species}_genes.json" | jq -cn --indent 2 --stream 'fromstream(1|truncate_stream(inputs)) | .transcripts[].probes[].vendor' | sort -u

