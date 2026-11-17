#!/usr/bin/env nextflow
nextflow.enable.dsl=2
// bioBakery's tool steps send their versions to the `versions` topic.
nextflow.preview.topic = true

include { FORM }       from './workflows/form.nf'
include { run_header } from './biobakery/modules/utils/version_log/main.nf'

workflow {

    log.info run_header()

    // ── bioBakery's checks for an MGX run ─────────────────────────────────
    // bioBakery keeps these inline in its own main.nf, which cannot be
    // included, so they are repeated here for the one workflow FORM runs.
    if (params.workflow != 'mgx')
        error "ERROR: FORM runs the mgx workflow only (got ${params.workflow})."
    if (!params.readsdir)
        error "ERROR: --readsdir is required. Example: --readsdir /path/to/fastqs"
    if (params.check_inputs_only && !params.check_inputs)
        error "ERROR: --check_inputs_only true needs --check_inputs true."

    // ── MEDI ──────────────────────────────────────────────────────────────
    if (params.run_medi) {
        if (!(params.medi_input in ['humann', 'kneaddata']))
            error "ERROR: medi_input must be humann or kneaddata (got ${params.medi_input})."
        if (params.medi_input == 'kneaddata' && !params.run_qc)
            error "ERROR: medi_input kneaddata requires run_qc true."
        if (params.medi_input == 'humann' && !params.run_functional_profiling)
            error "ERROR: medi_input humann requires run_functional_profiling true."
        if (params.medi_input == 'humann' && params.humann_version != 'humann_v4a')
            error "ERROR: medi_input humann requires humann_version humann_v4a."
        def missing = ['medi_db', 'medi_food_matches', 'medi_food_contents'].findAll { !params[it] }
        if (missing)
            error "ERROR: run_medi requires: " + missing.collect { "--${it}" }.join(', ')
    }

    // With medi_input humann, MEDI consumes HUMAnN's retained nucleotide-unaligned reads.
    if (params.run_medi && params.medi_input == 'humann' && (params.humann_options ?: '').contains('--remove-temp-output')) {
        error "ERROR: run_medi requires HUMAnN temp reads; remove --remove-temp-output from humann_options."
    }
    // Bypassing the nucleotide search means HUMAnN never writes those reads.
    if (params.run_medi && params.medi_input == 'humann' &&
        (params.humann_bypass_nucleotide_search || (params.humann_options ?: '').contains('--bypass-nucleotide-search'))) {
        error "ERROR: medi_input humann needs HUMAnN's nucleotide-unaligned reads; drop the nucleotide-search bypass or use --medi_input kneaddata."
    }

    FORM()
}

// Repeat the input check's result as the last thing the run prints, as
// bioBakery's main.nf does (copied from there, MGX only).
workflow.onComplete {
    if (!params.check_inputs) return

    def checkdir = "${params.outdir}/input_check"
    def started  = workflow.start.toInstant().toEpochMilli()
    def list = file("${checkdir}/mgx_failed_samples.txt")
    if (!list.exists() || list.lastModified() < started) return
    def failed = list.readLines().findAll { it }
    if (!failed) {
        log.info "Input check [mgx]: no samples were left out."
        return
    }
    def table = file("${checkdir}/mgx_input_check.tsv")
    def why = table.exists()
        ? table.readLines().drop(1).collect { it.split('\t', -1) }.findAll { it[2] != 'PASS' }
            .groupBy { it[0] }.collectEntries { s, rows -> [s, rows.collect { "${it[1]}: ${it[4]}" }.unique().join('; ')] }
        : [:]
    def shown = failed.take(50).collect { "  ${it}  --  ${why[it] ?: ''}" }
    log.warn "Input check [mgx]: ${failed.size()} sample(s) were " +
             (params.fail_on_bad_inputs ? "bad, and the run was stopped" : "left out of this run") + ":\n" +
             shown.join('\n') +
             (failed.size() > 50 ? "\n  ... and ${failed.size() - 50} more" : '') +
             "\n  Full list: ${list}\n  Details:   ${table}"
}
