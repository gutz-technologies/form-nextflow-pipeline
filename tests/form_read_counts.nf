#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// Integration check: run with the KneadData quickstart inputs and flags.
include { FORM } from '../workflows/form.nf'

workflow {
    FORM()
    FORM.out.read_count_table.toList().subscribe { tables ->
        if (!params.run_qc || params.check_inputs_only) {
            assert tables.isEmpty(): "Unexpected read-count tables: ${tables}"
        } else {
            assert tables.size() == 1: "Expected one read-count table: ${tables}"
            def table = tables[0]
            assert table.name == 'kneaddata_read_count_table.tsv'
            def lines = table.readLines()
            assert lines.size() > 1 && lines[0].startsWith('Sample\t'): lines
        }
        log.info 'FORM read-count output OK'
    }
}
