#!/usr/bin/env bats 

@test "Annotations from ensembl" {
    run rm -f $ANNOTATIONS_PATH/homo_sapiens.ensgene.tsv && annotations_from_ensembl.sh $config
    echo "status = ${status}"
    echo "output = ${output}"
    [ "$status" -eq 0 ]
    [ -f $ANNOTATIONS_PATH/homo_sapiens.ensgene.tsv ]
}

@test "Merge gene attributes" { 
    run rm -f $GENE_ATTRIBUTES_PATH/${species}.${col1}.${col2}.tsv && merge_gene_attributes.sh $ANNOTATIONS_PATH/homo_sapiens.ensgene.tsv  $FIELD_NAME1 $FIELD_NAME2 
    echo "status = ${status}"
    echo "output = ${output}"
    [ "$status" -eq 0 ]
    [ -f $ANNOTATIONS_PATH/${species}.${FIELD_NAME1}.${FIELD_NAME2}.tsv ]
}


