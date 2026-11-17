#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Stub run of the MEDI subworkflow on its own, with no databases or tools.
// bioBakery's MGX modules have no stub: blocks, so the full pipeline cannot be
// stub-run; this checks MEDI's wiring and published files instead.
//
//   nextflow run tests/medi_stub.nf -stub-run -c tests/stub.config --outdir <dir>

include { MEDI } from '../subworkflows/medi.nf'

workflow {
    reads = Channel.of('sampleA', 'sampleB').map { s ->
        def f = file("${workDir}/stub-input/${s}_bowtie2_unaligned.fa")
        f.parent.mkdirs()
        f.text = ">r1\nACGT\n"
        tuple(s, f)
    }
    MEDI(reads, '')
}
