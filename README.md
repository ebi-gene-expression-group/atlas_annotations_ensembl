# Atlas gene annotations from Ensembl

In this repository, there are underlying scripts that extract gene attributes from large JSON dumps provided by Ensembl for different species types. The gene attributes extracted from JSON are populates each attribute with its associated values in a TSV format. The final aggregated gene-annotation file is used for loading into Solr indexes as bioentities collection. Execution of tasks here require that `bin/` directory in the root of this repo is part of the path, and that the following executables are available:

- awk
- jq (1.5)


### Extract annotations from JSON dumps to TSV formatted files 

#### Entry points
`test/run_annotations_from_ensembl.sh`
The entry point to trigger the conversion of JSON Ensembl annotations to TSV formatted annotations for all the species defined in the `./annsrcs/ensembl` This script runs bsub runs on LSF cluster for each species on parallel for efficiency.`TODO: include /annsrcs/wbps`

By triggering the entry script `test/run_annotations_from_ensembl.sh` you will effectively run the script `bin/annotations_from_ensembl.sh` for each species configuration file defined in `annsrcs/ensembl`

Before running the entry point script it is important to set environmental variables as prerequisite.
```
## prerequisites - export environmental variables
## Note : These paths are used for testing purpose. While in production we need these output files to be dumped in traditional $ATLAS_PROD/bioentity_properties/annotations 
export ENSEMBL_JSON_PATH=/hps/nobackup2/production/ensembl/ensprod/search_dumps/release-101b/vertebrates/json (pilot file path provided by Mark from Ensembl for testing)
export OUTPUT_TSV_PATH=/ebi/microarray/home/suhaib/json_Ensembl/annotations
export LOG_PATH=/ebi/microarray/home/suhaib/json_Ensembl/logs
```
The truncated test output TSV file for human `test/homo_sapiens.ensgene.tsv`  For all other species that are defined in `./annsrcs/ensembl` can found in below directory
```
cd /ebi/microarray/home/suhaib/json_Ensembl/annotations
```


### Make two column TSV gene attribute files used decoration

#### Entry points

`test/run_merge_gene_attributes.sh`
This script is entry point to make column gene attributes files for several species. Effectively, this script trigger several LSF jobs for each species defined in `ANNOTATION_PATH` i.e output gene annotations path in the `Extract annotations from JSON dumps to TSV formatted files` task. Which means, the output files from `Extract annotations from JSON dumps to TSV formatted files` becomes input to `Make two column TSV gene attribute files used decoration`

Before running the entry point script it is important to set environmental variables as prerequisite.
```
## prerequisites - export environmental variables
## Note : These paths are used for testing purpose. While in production we need these output files to be dumped in traditional $ATLAS_PROD/bioentity_properties/ensembl 
export ANNOTATIONS_PATH=/ebi/microarray/home/suhaib/json_Ensembl/annotations (same as OUTPUT_TSV_PATH in the above task)
export FIELD_NAME1='ensgene'
export FIELD_NAME2='symbol'
export OUTPUT_PATH=/ebi/microarray/home/suhaib/json_Ensembl/ensembl
```

By triggering the entry point script `test/run_merge_gene_attributes.sh` this script eventually calls the `bin/annotations_from_ensembl.sh` taking desired arguments `field1` and `field2` to concatenate for all the species in `OUTPUT_TSV_PATH`

For example, make two column tsv file with attributes 'ensgene' (gene_id) and 'symbol' (gene name) that is used for decoration (rempapping of gene ids with gene names in atlas production) as shown in for human `test/homo_sapiens.ensgene.symbol.tsv` from using input file `homo_sapiens.ensgene.tsv` located in `OUTPUT_TSV_PATH`

For all other species that are defined in `./annsrcs/ensembl` can found in below directory
```
cd /ebi/microarray/home/suhaib/json_Ensembl/ensembl

```

### Debug for empty columns(gene attributes)

There will instances where gene attribute values will be missing in the E! JSON dumps. For those species and attributes values are missing can be found by running the below script 
```
export ANNOTATIONS_PATH=/ebi/microarray/home/suhaib/json_Ensembl/annotations
bash test/run_check_empty_columns.sh
```
Running this script will scan through all the TSVs column-wise to determine which column is totally empty. It will identify columns if only few or more values are missing.

### Structure

#### ./annsrcs
Annotation declared as jq query in the species wise configuration files describing the mapping of Atlas properties into bioentities collection 

#### ./bin
Executables that extract Atlas annotations in desired format.

#### ./test
Main execution run_* scripts that executes scripts in /bin. Also the source of example output tsv files. 

