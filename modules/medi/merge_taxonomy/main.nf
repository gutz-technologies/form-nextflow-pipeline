#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Merge nonempty Bracken tables across samples, one task per rank.
process merge_taxonomy {
    label 'medi_low'
    container params.medi_container
    publishDir path: { "${params.outdir}/${subdir}medi/merged" }, mode: 'copy'
    tag "$level"

    input:
    tuple val(level), path(reports)

    val subdir

    output:
    tuple val(level), path("${level}_merged.csv")

    script:
    """
    architeuthis merge ${reports} --out ${level}_merged.csv
    """

    stub:
    """
    touch ${level}_merged.csv
    """
}
