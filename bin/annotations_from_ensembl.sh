#!/usr/bin/env bash

scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


IFS="
"

config=$1
species=$(basename $config |  sed 's/\.[^ ]*//g')

[ ! -z ${ENSEMBL_JSON_PATH+x} ] || (echo "Env var ENSEMBL_JSON_PATH not defined." && exit 1)

## load property fields
while read property_field; do 
	export $property_field; 
done < $config

if [ ! -s "$JSON_FILE_PATH/$species/${species}_genes.json" ]; then
   echo "ERROR : $JSON_FILE_PATH/$species/${species}_genes.json doesn't exist"
fi

# header file
cat $config | grep 'property' | awk -F"=" '{ print $1 }' | sed 's/property_//g' | tr '\n' '\t' > $species.ensgene.tsv

for k in $(cat "$ENSEMBL_JSON_PATH/$species/${species}_genes.json" | jq -cn --stream 'fromstream(1|truncate_stream(inputs))' | head -n2); do 
 
	ensgene=$(echo "$k" | jq "$property_ensgene")
	echo "ensgene - $ensgene"
	
	#mirbase_accession=$(echo "$k" | jq  "$property_mirbase_accession")
	#echo "mirbase_accession - $mirbase_accession"
	
    #ortholog=$(echo "$k" | jq  "$property_ortholog")
	#echo "ortholog - $ortholog"
	
    symbol=$(echo "$k" | jq "$property_symbol")
    echo "symbol - $symbol"

    goterm=$(echo "$k" | jq "$property_goterm")
    echo "goterm - $goterm"
    
    ensfamily=$(echo "$k" | jq "$property_ensfamily")
    echo "ensfamily - $ensfamily"
    
    uniprot=$(echo "$k" | jq "$property_uniprot")
    echo "uniprot - $uniprot"
    
    description=$(echo "$k" | jq "$property_description")
	echo "description - $description"
	
	ensprotein=$(echo "$k" | jq "$property_ensprotein")
	echo "ensprotein - $ensprotein"
	
	interpro=$(echo "$k" | jq "$property_interpro")
	echo "interpro - $interpro"
	
	gene_biotype=$(echo "$k" | jq "$property_gene_biotype")
    echo "gene_biotype - $gene_biotype"
    
	embl=$(echo "$k" | jq "$property_embl")
	echo "embl - $embl"
	
	#mirbase_id=$(echo "$k" | jq  "$property_mirbase_id")
	#echo "mirbase_id - $mirbase_id"
	
    hgnc_symbol=$(echo "$k" | jq "$property_hgnc_symbol")
	echo "hgnc_symbol - $hgnc_symbol"
 
	ensfamily_description=$(echo "$k" | jq "$property_ensfamily_description")
    echo "ensfamily_description - $ensfamily_description"
       
    enstranscript=$(echo "$k" | jq "$property_enstranscript")
	echo "enstranscript - $enstranscript"	
	
	interproterm=$(echo "$k" | jq "$property_interproterm")
	echo "interproterm - $interproterm"
	
	refseq=$(echo "$k" | jq "$property_refseq")
	echo "refseq - $refseq"
	
	entrezgene=$(echo "$k" | jq "$property_entrezgene")
	echo "entrezgene - $entrezgene"

	go=$(echo "$k" | jq "$property_go")
    echo "go - $go"
	
	synonym=$(echo "$k" | jq "$property_synonym")
	echo "synonym - $synonym"
	
	echo -e "\n$ensgene\tmirbase_accession\tortholog\t$symbol\t$goterm\t$ensfamily\t$uniprot\t$description\t$ensprotein\t$interpro\t$gene_biotype\t$embl\tmirbase_id\t$hgnc_symbol\t$ensfamily_description\t$enstranscript\t$interproterm\t$refseq\t$entrezgene\t$go\t$synonym" | sed 's/"//g' >> $species.ensgene.tsv
	echo -e "\n########################\n";
done 
