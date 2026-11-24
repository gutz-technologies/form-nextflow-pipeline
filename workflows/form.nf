#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { MGX  } from '../biobakery/workflows/mgx.nf'
include { MEDI } from '../subworkflows/medi.nf'

// bioBakery MGX, unmodified, then MEDI on the reads MGX hands back.
workflow FORM {

    main:
    MGX()

    // ── KneadData minimum versions ────────────────────────────────────────
    // bioBakery's KneadData tasks report `kneaddata --version` and
    // `bowtie2 --version` to the versions topic. Stop the run if either is
    // older than FORM's minimum, so no later stage uses its reads.
    if (params.run_qc && !params.check_inputs_only) {
        def minimum = [kneaddata: params.form_min_kneaddata, bowtie2: params.form_min_bowtie2]
        channel.topic('versions')
            .filter { proc, tool, version -> tool in minimum.keySet() }
            .unique { proc, tool, version -> [tool, version] }
            .subscribe { proc, tool, version ->
                if (versionBelow(version.toString(), minimum[tool].toString()))
                    error "ERROR: ${tool} ${version} in ${proc} is older than FORM's minimum ${minimum[tool]}. " +
                          "Use the pinned image (-profile <site>,form_docker) or raise the site's ${tool} version."
                log.info "Version check: ${tool} ${version} >= ${minimum[tool]} (${proc})"
            }
    }

    // ── Food DNA quantification (MEDI) ────────────────────────────────────
    if (params.run_medi && !params.check_inputs_only) {
        // humann: HUMAnN's nucleotide-unaligned reads (a small FASTA, but MEDI
        // waits for HUMAnN). kneaddata: the full cleaned reads, straight after QC.
        medi_reads = params.medi_input == 'kneaddata'
            ? MGX.out.cleaned.map { meta, r -> tuple(meta.id, r) }
            : MGX.out.unaligned_reads
        MEDI(medi_reads, '')
    }

    emit:
    read_count_table = MGX.out.read_counts
}

// True when version `got` is older than `min`. Compares the leading numeric
// fields (0.12.0 vs 0.12, 2.5.5 vs 2.5.5); a version with no number is older.
def versionBelow(String got, String min) {
    def nums = { String v -> (v =~ /\d+/).findAll().collect { it as int } }
    def g = nums(got), m = nums(min)
    if (!g) return true
    for (int i = 0; i < Math.max(g.size(), m.size()); i++) {
        int a = i < g.size() ? g[i] : 0
        int b = i < m.size() ? m[i] : 0
        if (a != b) return a < b
    }
    return false
}
