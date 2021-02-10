#!/usr/bin/env bats 

@test "Annotations from ensembl" {
    run rm -f $ANNOTATIONS_PATH/homo_sapiens.ensgene.tsv && annotations_from_ensembl.sh $config
    
    echo "status = ${status}"
    echo "output = ${output}"

    [ "$status" -eq 0 ]
    [ -f $ANNOTATIONS_PATH/homo_sapiens.ensgene.tsv ]
}

@test "Merge gene attributes" { 
    run rm -f $GENE_ATTRIBUTES_PATH/${species}.${field_name1}.${field_name2}.tsv && merge_gene_attributes.sh $annotation_file $field_name1 $field_name2 
    
    echo "status = ${status}"
    echo "output = ${output}"
    
    [ "$status" -eq 0 ]
    [ -f $GENE_ATTRIBUTES_PATH/${species}.${field_name1}.${field_name2}.tsv ]
}

@test "Check empty columns" {
    run check_empty_columns.sh 

    echo "status = ${status}"
    echo "output = ${output}"

    [ "$status" -eq 0 ]
}

