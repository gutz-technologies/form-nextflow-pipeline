#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Count D/G/S taxa with Bracken, one task per sample.
process count_taxa {
    label 'medi_low'
    container params.medi_container
    publishDir path: { "${params.outdir}/${subdir}medi/bracken" }, mode: 'copy'
    tag "${sample}"

    input:
    tuple val(sample), path(report)

    val subdir

    output:
    tuple val(sample), path("{D,G,S}/*.b2")

    script:
    """
    # fixk2report is level-independent, so fix the report once and reuse it.
    # A sample with nothing classified yields a 0-byte kraken report, which
    # fixk2report (fread) errors on — fall back to an empty fixed report so the
    # bracken empty-guard below emits empty .b2s instead of failing the job.
    fixk2report.R ${report} fixed_report.txt || : > fixed_report.txt
    for lev in D G S; do
        mkdir -p \$lev
        # bracken exits 1 when a level has no classified reads. Emit a 0-byte
        # .b2 instead so one empty level can't fail the whole sample, and every
        # sample yields a uniform D/G/S set. Empties are filtered out before the
        # per-level merge in MEDI.
        bracken -d ${params.medi_db} -i fixed_report.txt \
            -l \$lev -o \$lev/\${lev}_${sample}.b2 -r 150 \
            -t 10 -w \$lev/${sample}_bracken.tsv \
            || : > \$lev/\${lev}_${sample}.b2
    done
    """

    stub:
    """
    for lev in D G S; do
        mkdir -p \$lev
        echo stub > \$lev/\${lev}_${sample}.b2
    done
    """
}
