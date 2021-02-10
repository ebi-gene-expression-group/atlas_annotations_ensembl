#!/usr/bin/env nextflow 

// define channels 
if(params.run_selected_species == "True"){
    // select relevant species config files
    SELECTED_CONFIGS = Channel.fromPath("species_list.txt")
                              .splitCsv()
                              .flatten()
                              .map{ "${params.ensembl_species_configs}".concat("/").concat(it).concat(".config") }
} else { 
    SELECTED_CONFIGS = Channel.fromPath("${params.ensembl_species_configs}/*")
}

process run_annotations_from_ensembl {
    publishDir "${ANNOTATIONS_PATH}"

    input:
        file(config) from SELECTED_CONFIGS

    output:
        file(annotated_genes) into ANNOTATED_GENES 

    """
    annotations_from_ensembl.sh ${config}
    """
}



//process merge_gene_attributes {}


//process check_emprty_columns {}