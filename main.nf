#!/usr/bin/env nextflow 

// define channels 
if(params.run_selected_species == "True"){
    // select relevant species config files
    SELECTED_CONFIGS = Channel.fromPath(params.ensembl_species_list)
                              .splitCsv()
                              .flatten()
                              .map{ "${params.ensembl_species_configs}".concat("/").concat(it).concat(".config") }
} else { 
    SELECTED_CONFIGS = Channel.fromPath("${params.ensembl_species_configs}/*")
}

// extract annotations from JSON files
println "${ANNOTATIONS_PATH}"
println "${ENSEMBL_JSON_PATH}"

process run_annotations_from_ensembl {
    publishDir "${ANNOTATIONS_PATH}"

    memory { 8.GB * task.attempt }
    maxRetries 3
    errorStrategy { task.attempt<=3 ? 'retry' : 'finish' }

    input:
        val(config) from SELECTED_CONFIGS

    output:
        file("*.ensgene.tsv") into ANNOTATED_GENES
        file("*.ensgene.tsv") into CHECK_EMPTY_COLS

    """
    annotations_from_ensembl.sh "${config}"
    """
}

// merge gene attributes 
GENE_ID_COL = Channel.from(params.gene_id_col)
GENE_NAME_COL = Channel.from(params.gene_name_col)

process merge_gene_attributes { 
    publishDir "${GENE_ATTRIBUTES_PATH}"

    memory { 8.GB * task.attempt }
    maxRetries 3
    errorStrategy { task.attempt<=3 ? 'retry' : 'finish' }

    input:
        file(annotation) from ANNOTATED_GENES
        val(gene_id_col) from GENE_ID_COL
        val(gene_name_col) from GENE_NAME_COL
    
    output:
        file("*.${gene_id_col}.${gene_name_col}.tsv")

    
    """
    merge_gene_attributes.sh "${annotation}" "${gene_id_col}" "${gene_name_col}"
    """
}

process check_empty_columns {
    publishDir "${LOG_PATH}"

    memory { 8.GB * task.attempt }
    maxRetries 3
    errorStrategy { task.attempt<=3 ? 'retry' : 'finish' }
    
    input:
        file(annotation) from CHECK_EMPTY_COLS

    output: 
        file("${annotation}.log") into CHECKED_ANNOTATIONS

    """
    check_empty_columns.sh ${annotation} > ${annotation}.log
    """
}
