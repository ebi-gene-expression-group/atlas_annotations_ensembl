# Atlas gene annotations from Ensembl

This repository contains scripts that extract gene attributes from large JSON dumps provided by Ensembl for a range of species. Gene attributes extracted from JSON populate the corresponding fields in an output TSV file (a gene-by-annotation table).

The final aggregated gene annotation file is loaded into Solr indexes as a bioentities collection. To run the scripts, please make sure the `/bin` directory is in the PATH. The following dependencies need to be installed: 

- awk
- jq (1.5)
- bats (for testing)

### Testing the scripts
run `atlas_annotations_ensembl_run_tests.sh` in order to execute the tests. 

### Extract annotations from JSON dumps to TSV formatted files 

#### Entry points
`test/run_annotations_from_ensembl.sh`
The entry point to trigger the conversion of JSON Ensembl annotations to TSV formatted annotations for all the species defined in the `./annsrcs/ensembl` This script runs bsub runs on LSF cluster for each species on parallel for efficiency.`TODO: include /annsrcs/wbps`

By triggering the entry script `test/run_annotations_from_ensembl.sh` you will effectively run the script `bin/annotations_from_ensembl.sh` for each species configuration file defined in `annsrcs/ensembl`

Before running the entry point script it is important to set environmental variables as prerequisite.
```
## prerequisites - export environmental variables
## Note : These paths are used for testing purpose. While in production, we need these output files to be dumped in traditional $ATLAS_PROD/bioentity_properties/annotations 
export ENSEMBL_JSON_PATH=/hps/nobackup2/production/ensembl/ensprod/search_dumps/release-101b/vertebrates/json (pilot file path provided by Mark from Ensembl for testing)
export ANNOTATIONS_PATH=/ebi/microarray/home/suhaib/json_Ensembl/annotations
export LOG_PATH=/ebi/microarray/home/suhaib/json_Ensembl/logs
```
The truncated test output TSV file for human is in `test/homo_sapiens.ensgene.tsv`.  
For all other species that are defined in `./annsrcs/ensembl`, annotations can be found in this directory:

```
/ebi/microarray/home/suhaib/json_Ensembl/annotations
```

### Make two column TSV gene attributes file used for decoration

#### Entry points

`test/run_merge_gene_attributes.sh`
This script is entry point to make column gene attributes files for several species. Effectively, this script trigger several LSF jobs for each species defined in `ANNOTATION_PATH` i.e output gene annotations path in the `Extract annotations from JSON dumps to TSV formatted files` task. Which means, the output files from `Extract annotations from JSON dumps to TSV formatted files` becomes input to `Make two column TSV gene attribute files used decoration`

Before running the entry point script it is important to set environmental variables as prerequisite.
```
## prerequisites - export environmental variables
## Note : These paths are used for testing purpose. While in production we need these output files to be dumped in traditional $ATLAS_PROD/bioentity_properties/ensembl 
export ANNOTATIONS_PATH=/ebi/microarray/home/suhaib/json_Ensembl/annotations
export GENE_ATTRIBUTES_PATH=/ebi/microarray/home/suhaib/json_Ensembl/ensembl
```

By triggering the entry point script `test/run_merge_gene_attributes.sh` this script eventually calls the `bin/merge_gene_attributes.sh` taking desired arguments `field1` and `field2` to concatenate for all the species in `OUTPUT_TSV_PATH`

For example, make two column tsv file with attributes 'ensgene' (gene_id) and 'symbol' (gene name) that is used for decoration (rempapping of gene ids with gene names in atlas production) as shown in for human `test/homo_sapiens.ensgene.symbol.tsv` from using input file `homo_sapiens.ensgene.tsv` located in `OUTPUT_TSV_PATH`

For all other species that are defined in `./annsrcs/ensembl` can found in below directory
```
cd /ebi/microarray/home/suhaib/json_Ensembl/ensembl

```

### Debug for empty columns(gene attributes)

There will be instances where gene attribute values will be missing in the E! JSON dumps. For those species and attributes, the missing values can be found by running the script below:
```
export ANNOTATIONS_PATH=/ebi/microarray/home/suhaib/json_Ensembl/annotations
bash test/run_check_empty_columns.sh
```
Running this script will scan through all the TSVs column-wise to determine which column is totally empty. It will not identify columns if only few or more values are missing.


### [WIP] Microarray array designs test queries

```
export ENSEMBL_JSON_PATH=/hps/nobackup2/production/ensembl/ensprod/search_dumps/release-101b/vertebrates/json
bash test/test_array_design_queries.sh
```

### Structure

#### ./annsrcs
Annotation declared as jq query in the species-wise configuration files. These files describe the mapping of Atlas properties into the bioentities collection. 

#### ./bin
Executables that extract Atlas annotations in a desired format.

#### ./test
Main execution run_* scripts that executes scripts in /bin. Also the source of example output tsv files. 

