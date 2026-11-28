#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// Lay out KneadData task directories and collect checksums.md5.
// Paired tasks also write files that publishDir does not keep.
//
// This file lives in tests/, so Nextflow uses tests/bin on PATH.
// tests/bin/kneaddata_checksums.sh points at the repository script.
//
//   nextflow run tests/kneaddata_checksums.nf -c tests/stub.config --outdir <dir>

include { KNEADDATA_CHECKSUMS } from '../modules/kneaddata/checksums.nf'

process fake_paired_kneaddata {
    tag "$sample"

    input:
    val sample

    output:
    tuple val(sample), path("${sample}_concatenated.fastq.gz")

    script:
    """
    echo "${sample} paired1" | gzip -c > ${sample}_kneaddata_paired_1.fastq.gz
    echo "${sample} paired2" | gzip -c > ${sample}_kneaddata_paired_2.fastq.gz
    echo "${sample} unmatched1" | gzip -c > ${sample}_kneaddata_unmatched_1.fastq.gz
    echo "${sample} unmatched2" | gzip -c > ${sample}_kneaddata_unmatched_2.fastq.gz
    echo "${sample} trimmed" | gzip -c > ${sample}_kneaddata.trimmed.fastq.gz
    echo "${sample} concat" | gzip -c > ${sample}_concatenated.fastq.gz
    echo "${sample} raw" | gzip -c > ${sample}_R1.fastq.gz
    echo "${sample} log" > ${sample}_kneaddata.log
    """
}

process fake_single_kneaddata {
    tag "$sample"

    input:
    val sample

    output:
    tuple val(sample), path("${sample}_kneaddata.fastq.gz")

    script:
    """
    echo "${sample} main" | gzip -c > ${sample}_kneaddata.fastq.gz
    echo "${sample} contam" | gzip -c > ${sample}_kneaddata_contam.fastq.gz
    echo "${sample} raw" | gzip -c > ${sample}.fastq.gz
    echo "${sample} log" > ${sample}_kneaddata.log
    """
}

workflow {
    paired = fake_paired_kneaddata(Channel.of('sampleB', 'sampleA'))
        .map { sample, reads -> [ [id: sample, paired_end: true], reads ] }
    single = fake_single_kneaddata(Channel.of('sampleC'))
        .map { sample, reads -> [ [id: sample, paired_end: false], reads ] }

    KNEADDATA_CHECKSUMS(paired.mix(single))
}
