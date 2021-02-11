#!/usr/bin/env bash

scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

IFS="
"
config=$1
species=$(basename $config |  sed 's/\.[^ ]*//g')

## check env variables
[ -z ${ENSEMBL_JSON_PATH+x} ] && echo "Env var ENSEMBL_JSON_PATH not defined." && exit 1
[ -z ${ANNOTATIONS_PATH+x} ] && echo "Env var ANNOTATIONS_PATH not defined." && exit 1

## export property fields
while read property_field; do 
  export $property_field; 
done < $config

if [ ! -s "$ENSEMBL_JSON_PATH/$species/${species}_genes.json" ]; then
   echo "ERROR : $ENSEMBL_JSON_PATH/$species/${species}_genes.json doesn't exist" && exit 1
fi


## print multiple values for a field with separator '@@'
mutiple_values_with_separator () {
  json_row=$1
  property_field=$2

  number_of_values=$(echo "$json_row" | jq -r "$property_field" | wc -l)

  if [ $number_of_values -gt 1 ]; then
    echo "$json_row" | jq -r "$property_field" | uniq | awk -F'\n' -v ORS='@@' '{print $1}' | sed 's/.\{2\}$//'
  else
    echo "$json_row" | jq -r "$property_field"
  fi  
}

output_tsv=${species}.ensgene.tsv

# header file
cat $config | grep 'property' | awk -F"=" '{ print $1 }' | sed 's/property_//g' | tr '\n' '\t' > $output_tsv

jq -cn --stream 'fromstream(1|truncate_stream(inputs))' "$ENSEMBL_JSON_PATH/$species/${species}_genes.json" \
| while read k; do

  ensgene=$(mutiple_values_with_separator "$k" "$property_ensgene")
  echo "ensgene - $ensgene"
  
  mirbase_accession=$(mutiple_values_with_separator "$k" "$property_mirbase_accession")
  echo "mirbase_accession - $mirbase_accession"
  
  #ortholog=$(mutiple_values_with_separator "$k" "$property_ortholog")
  #echo "ortholog - $ortholog"
  
  symbol=$(mutiple_values_with_separator "$k" "$property_symbol")
  echo "symbol - $symbol"

  goterm=$(mutiple_values_with_separator "$k" "$property_goterm")
  echo "goterm - $goterm"
  
  ensfamily=$(mutiple_values_with_separator "$k" "$property_ensfamily")
  echo "ensfamily - $ensfamily"
  
  uniprot=$(mutiple_values_with_separator "$k" "$property_uniprot")
  echo "uniprot - $uniprot"
  
  description=$(mutiple_values_with_separator "$k" "$property_description")
  echo "description - $description"
  
  ensprotein=$(mutiple_values_with_separator "$k" "$property_ensprotein")
  echo "ensprotein - $ensprotein"
  
  interpro=$(mutiple_values_with_separator "$k" "$property_interpro")
  echo "interpro - $interpro"
  
  gene_biotype=$(mutiple_values_with_separator "$k" "$property_gene_biotype")
  echo "gene_biotype - $gene_biotype"
  
  embl=$(mutiple_values_with_separator "$k" "$property_embl")
  echo "embl - $embl"
  
  mirbase_id=$(mutiple_values_with_separator "$k" "$property_mirbase_id")
  echo "mirbase_id - $mirbase_id"
  
  hgnc_symbol=$(mutiple_values_with_separator "$k" "$property_hgnc_symbol")
  echo "hgnc_symbol - $hgnc_symbol"
 
  ensfamily_description=$(mutiple_values_with_separator "$k" "$property_ensfamily_description")
  echo "ensfamily_description - $ensfamily_description"
     
  enstranscript=$(mutiple_values_with_separator "$k" "$property_enstranscript")
  echo "enstranscript - $enstranscript"   
  
  interproterm=$(mutiple_values_with_separator "$k" "$property_interproterm")
  echo "interproterm - $interproterm"
  
  refseq=$(mutiple_values_with_separator "$k" "$property_refseq")
  echo "refseq - $refseq"
  
  entrezgene=$(mutiple_values_with_separator "$k" "$property_entrezgene")
  echo "entrezgene - $entrezgene"

  go=$(mutiple_values_with_separator "$k" "$property_go")
  echo "go - $go"
  
  synonym=$(mutiple_values_with_separator "$k" "$property_synonym")
  echo "synonym - $synonym"
  
  echo -e "\n$ensgene\tmirbase_accession\tortholog\t$symbol\t$goterm\t$ensfamily\t$uniprot\t$description\t$ensprotein\t$interpro\t$gene_biotype\t$embl\tmirbase_id\t$hgnc_symbol\t$ensfamily_description\t$enstranscript\t$interproterm\t$refseq\t$entrezgene\t$go\t$synonym" | sed 's/"//g' >> $output_tsv
  echo -e "\n########################\n";
done 

## remove spaces between lines
#TODO: uncomment this before merging
sed -i '/^ *$/d' $output_tsv
