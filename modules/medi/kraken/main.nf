#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Classify HUMAnN nucleotide-unaligned reads with the MEDI Kraken2 database.
process kraken {
    label 'medi_kraken'
    container params.medi_container
    publishDir path: { "${params.outdir}/${subdir}medi/kraken2/raw" }, mode: 'copy'
    tag "$sample"

    input:
    tuple val(sample), path(reads)

    val subdir

    output:
    tuple val(sample), path("*.k2"), path("*.tsv")

    script:
    """
    kraken2 \\
        --db ${params.medi_db} \\
        --confidence 0.3 \\
        --threads ${task.cpus} \\
        --memory-mapping \\
        --output ${sample}.k2 \\
        --report ${sample}.tsv \\
        ${reads}
    """

    stub:
    """
    touch ${sample}.k2 ${sample}.tsv
    """
}
