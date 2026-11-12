#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Filter Kraken2 mappings by consistency, entropy and multiplicity.
process architeuthis_filter {
    label 'medi_low'
    container params.medi_container
    publishDir path: { "${params.outdir}/${subdir}medi/architeuthis" }, mode: 'copy'
    tag "$sample"

    input:
    tuple val(sample), path(k2)

    val subdir

    output:
    tuple val(sample), path("${sample}_filtered.k2")

    script:
    """
    # architeuthis exits 1 when there are no mappings to filter. Emit an empty
    # _filtered.k2 instead so the sample flows on (kraken_report → count_taxa)
    # tracked-but-empty rather than being dropped from MEDI by errorStrategy.
    architeuthis mapping filter ${k2} \
        --data-dir ${params.medi_db}/taxonomy \
        --min-consistency 0.95 --max-entropy 0.1 \
        --max-multiplicity 4 \
        --out ${sample}_filtered.k2 \
        || : > ${sample}_filtered.k2
    """

    stub:
    """
    touch ${sample}_filtered.k2
    """
}
