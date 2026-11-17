#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Build a Kraken2 report from the filtered mappings.
process kraken_report {
    label 'medi_low'
    container params.medi_container
    publishDir path: { "${params.outdir}/${subdir}medi/kraken2" }, mode: 'copy'
    tag "$sample"

    input:
    tuple val(sample), path(k2)

    val subdir

    output:
    tuple val(sample), path("*.tsv")

    script:
    """
    kraken2-report ${params.medi_db}/taxo.k2d ${k2} ${sample}.tsv
    """

    stub:
    """
    touch ${sample}.tsv
    """
}
