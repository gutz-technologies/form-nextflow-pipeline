#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Add taxonomic lineages to the merged D/G/S tables.
process add_lineage {
    label 'medi_low'
    container params.medi_container
    publishDir path: { "${params.outdir}/${subdir}medi" }, mode: 'copy'
    tag "$level"

    input:
    tuple val(level), path(merged)

    val subdir

    output:
    tuple val(level), path("${level}_counts.csv")

    script:
    """
    architeuthis lineage ${merged} --data-dir ${params.medi_db}/taxonomy --out ${level}_counts.csv
    """

    stub:
    """
    touch ${level}_counts.csv
    """
}
