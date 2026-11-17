#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { MGX  } from '../biobakery/workflows/mgx.nf'
include { MEDI } from '../subworkflows/medi.nf'

// bioBakery MGX, unmodified, then MEDI on the reads MGX hands back.
workflow FORM {

    main:
    MGX()

    // ── Food DNA quantification (MEDI) ────────────────────────────────────
    if (params.run_medi && !params.check_inputs_only) {
        // humann: HUMAnN's nucleotide-unaligned reads (a small FASTA, but MEDI
        // waits for HUMAnN). kneaddata: the full cleaned reads, straight after QC.
        medi_reads = params.medi_input == 'kneaddata'
            ? MGX.out.cleaned.map { meta, r -> tuple(meta.id, r) }
            : MGX.out.unaligned_reads
        MEDI(medi_reads, '')
    }
}
