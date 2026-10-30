#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Quantify food abundance and content from the lineage tables.
process quantify {
    label 'medi_low'
    container params.medi_container
    publishDir path: { "${params.outdir}/${subdir}medi" }, mode: 'copy'
    tag "quantify"

    input:
    path files
    path foods_file_path, stageAs: 'food_matches/*'
    path food_contents_file_path, stageAs: 'food_contents/*'

    val subdir

    output:
    tuple path("food_abundance.csv"), path("food_content.csv")

    script:
    """
    quantify.R ${foods_file_path} ${food_contents_file_path} ${files}
    """

    stub:
    """
    touch food_abundance.csv food_content.csv
    """
}
