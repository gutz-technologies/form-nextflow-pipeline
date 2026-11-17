#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Classify reads (HUMAnN unaligned FASTA or KneadData FASTQ) with the MEDI Kraken2 database.
process kraken {
    label 'medi_kraken'
    container params.medi_container
    // Reports only: the per-read .k2 is as large as the input on full reads.
    publishDir path: { "${params.outdir}/${subdir}medi/kraken2/raw" }, mode: 'copy', pattern: '*.tsv'
    tag "$sample"

    input:
    tuple val(sample), path(reads)

    val subdir

    output:
    tuple val(sample), path("*.k2"), path("*.tsv")

    script:
    def gzip = reads.name.endsWith('.gz') ? '--gzip-compressed' : ''
    """
    kraken2 \\
        --db ${params.medi_db} \\
        --confidence 0.3 \\
        --threads ${task.cpus} \\
        --memory-mapping \\
        ${gzip} \\
        --output ${sample}.k2 \\
        --report ${sample}.tsv \\
        ${reads}
    """

    stub:
    """
    touch ${sample}.k2 ${sample}.tsv
    """
}
