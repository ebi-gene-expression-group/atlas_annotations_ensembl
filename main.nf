#!/usr/bin/env nextflow 

// define channels 
if(params.run_selected_species == "True"){
    // select config files for specified species
    SELECTED_ANNOTATED_CONFIGS = Channel.fromPath(params.ensembl_species_list)
                              .splitCsv()
                              .flatten()
                              .map{ tuple("${params.ensembl_species_configs}".concat("/").concat(it).concat(".config"), it) }
    
} else { 
    SELECTED_ANNOTATED_CONFIGS = Channel.fromPath("${params.ensembl_species_configs}/*")
                                        .map{ tuple(it, it.baseName) }
}

// extract annotations from JSON files
println "${ANNOTATIONS_PATH}"
println "${ENSEMBL_JSON_PATH}"

process run_annotations_from_ensembl {
    
    publishDir "${ANNOTATIONS_PATH}"
    
    conda "${baseDir}/envs/jq.yml"

    memory { 16.GB * task.attempt }
    maxRetries 3
    errorStrategy { task.attempt<=3 ? 'retry' : 'ignore' }

    input:
        tuple val(config), val(species) from SELECTED_ANNOTATED_CONFIGS

    output:
        tuple file("${species}.ensgene.tsv"), val(species) into ANNOTATED_GENES
        file("${species}.ensgene.tsv") into CHECK_EMPTY_COLS

    """
    annotations_from_ensembl.sh "${config}"
    """
}

// merge gene attributes 
gene_id_col = params.gene_id_col
gene_name_col = params.gene_name_col
process merge_gene_attributes { 

    publishDir "${GENE_ATTRIBUTES_PATH}"
    conda "${baseDir}/envs/jq.yml"

    memory { 8.GB * task.attempt }
    maxRetries 3
    errorStrategy { task.attempt<=3 ? 'retry' : 'ignore' }

    input:
        tuple file(annotation), val(species) from ANNOTATED_GENES
    
    output:
        file("${species}.${gene_id_col}.${gene_name_col}_genes.tsv")

    
    """
    merge_gene_attributes.sh "${annotation}" "${gene_id_col}" "${gene_name_col}"
    mv ${species}.${gene_id_col}.${gene_name_col}.tsv ${species}.${gene_id_col}.${gene_name_col}_genes.tsv
    """
}

process check_empty_columns {
    
    publishDir "${LOG_PATH}"

    memory { 8.GB * task.attempt }
    maxRetries 3
    errorStrategy { task.attempt<=3 ? 'retry' : 'ignore' }
    
    input:
        file(annotation) from CHECK_EMPTY_COLS

    output: 
        file("${annotation}.log") into CHECKED_ANNOTATIONS

    """
    check_empty_columns.sh ${annotation} > ${annotation}.log_tmp
    mv ${annotation}.log_tmp ${annotation}.log
    """
}
