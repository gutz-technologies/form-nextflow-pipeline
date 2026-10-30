#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Summarise filtered Kraken2 reports with MultiQC.
process multiqc {
    label 'medi_low'
    container params.medi_multiqc_container
    publishDir path: { "${params.outdir}/${subdir}medi" }, mode: 'copy'
    tag "multiqc"

    input:
    path reports

    val subdir

    output:
    path("multiqc_report.html")

    script:
    """
    multiqc . -f
    """

    stub:
    """
    touch multiqc_report.html
    """
}
