#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// One checksum file for the FASTQ files KneadData publishes under kneaddata/.
//
// bioBakery publishes those files from the task directory and does not emit
// them. The paired cleaned channel is the concatenated FASTQ, and publishDir
// drops that file. publishDir itself is asynchronous, so this collects the
// task outputs instead of reading the published directory.
//
// Paired-end publishes four named files. Other FASTQ files in that task
// directory (trimmed intermediates, the concatenated file) are not published.
// Single-end publishes every `${sample}_kneaddata*.fastq.gz`.

def readPath(reads) {
    if (reads instanceof List || reads.getClass().isArray()) {
        if (reads.size() != 1)
            error "ERROR: expected one cleaned FASTQ path, got ${reads}"
        return file(reads[0])
    }
    return file(reads)
}

def publishedKneaddataFastqs(meta, reads) {
    def readFile = readPath(reads)
    def dir = readFile.parent
    def sample = meta.id.toString()
    if (meta.paired_end) {
        return ['paired_1', 'paired_2', 'unmatched_1', 'unmatched_2']
            .collect { kind -> file("${dir}/${sample}_kneaddata_${kind}.fastq.gz") }
            .findAll { it.exists() }
    }
    def prefix = "${sample}_kneaddata"
    def names = file(dir).list()
    if (!names)
        return []
    return names
        .findAll { name -> name.startsWith(prefix) && name.endsWith('.fastq.gz') }
        .collect { name -> file("${dir}/${name}") }
}

process kneaddata_checksums {
    tag 'checksums'
    publishDir path: { "${params.outdir}/kneaddata" }, mode: 'copy', overwrite: true

    input:
    path fastqs

    output:
    path 'checksums.md5', emit: checksums

    script:
    """
    ${moduleDir}/../../bin/kneaddata_checksums.sh
    """

    stub:
    '''
    touch checksums.md5
    '''
}

workflow KNEADDATA_CHECKSUMS {
    take:
    cleaned   // [ [id, paired_end], cleaned reads ], one item per sample

    main:
    fastqs = cleaned.flatMap { meta, reads ->
        def found = publishedKneaddataFastqs(meta, reads)
        if (!found)
            error "ERROR: KneadData published no FASTQ for sample ${meta.id} (looked in ${readPath(reads).parent})."
        found
    }.collect()

    kneaddata_checksums(fastqs)

    emit:
    checksums = kneaddata_checksums.out.checksums
}
