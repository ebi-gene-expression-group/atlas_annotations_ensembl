# Atlas gene annotations from Ensembl

This repository contains scripts that extract gene attributes from Ensembl JSON dumps for a range of species. Gene attributes extracted from JSON populate the corresponding fields of an output TSV file (a gene-by-annotation table).

The final aggregated gene annotation file is loaded into Solr indexes as a bioentities collection. To run the scripts, please make sure the `/bin` directory is in the PATH. The following dependencies need to be installed: 

- awk
- jq (1.5)
- bats (testing)
- nextflow (workflow execution)

### Required env variables
The following environment variables need to be defined for the scripts to run correctly: 
```
export ENSEMBL_JSON_PATH=path/to/json/files
export ANNOTATIONS_PATH=path/to/produced/annotation/file
export GENE_ATTRIBUTES_PATH=path/to/produced/gene/attributes
export LOG_PATH=path/to/log/files
```

### Testing the scripts
run `atlas_annotations_ensembl_run_tests.sh` in order to execute the tests. Test outputs will be stored in `test_data/outputs`. 

### Extract annotations from JSON dumps to TSV formatted files 

```
annotations_from_ensemb.sh <config_file>
```
`config_file` is defined on a per-species basis and encodes necessary jq quries to extract corresponding fields from JSON. See `data/annsrcs/ensembl` for a full list of config files. Output file will be stored under `$ANNOTATIONS_PATH`.

The truncated test output TSV file for human is in `example_outputs/homo_sapiens.ensgene.tsv`.  

See truncated version of JSON file in `test_data/homo_sapiens`. 

### Make two column TSV gene attributes file (used for decoration)

```
merge_gene_attributes.sh <annotation_file> <field_name1> <field_name2>
```
- `annotation_file` is a gene annotation TSV file produced as an output of `annotations_from_ensemb.sh`
- `field_name1` is gene ID (e.g. ensgene)
- `field_name2` is corresponding gene name (e.g. symbol) used for rempapping of gene ids with gene names in atlas production

See example output in `test/homo_sapiens.ensgene.symbol.tsv` produced from input file `homo_sapiens.ensgene.tsv`. 

### Debug for empty columns (gene attributes)

There will be instances where gene attribute values will be missing in the E! JSON dumps. For those attributes, the missing values can be determined by running the script below:
```
check_empty_columns.sh <annotation_file> 
```
- `annotation_file` is a TSV file with gene annotations produced by `annotations_from_ensemb.sh`

Output log files will be placed under `$LOG_PATH`. Run `grep 'emptycol' < log_file` to get empty columns. 

Running this script will scan through the TSV column-wise and determine which columns are empty. It will not identify pertially empty columns.


### [WIP] Microarray array designs test queries

```
test_array_design_queries.sh
```

## Workflow execution 
It is important to keep in mind that this repository will need to be scaled for a large number of species and heavy JSON files. The Nextflow workflow addresses this by organising the scripts into a pipeline. To execute the workflow, run the following: 
```
nextflow run main.nf -profile <profile> -ensembl_species_configs <ensembl_species_configs> 
```
Where profile is either `local` or `cluster` depending on execution environment. 

Workflow parameters (see `nextflow.config`):
- `run_selected_species`: determines if computation needs to be run for selected species only (if True, need to provide txt file with desired species).
- `ensembl_species_configs`: path to dir with config files 
- `ensembl_species_list`: TXT file with species which need to be analysed. See example at `data/species_list.txt`. 
- `gene_id_col` and `gene_name_col`: field names for `merge_gene_attributes.sh`.

### Structure

#### data/annsrcs
Annotation declared as jq query in the species-wise configuration files. These files describe the mapping of Atlas properties into the bioentities collection. 

#### ./bin
Executables that extract Atlas annotations in a desired format.



