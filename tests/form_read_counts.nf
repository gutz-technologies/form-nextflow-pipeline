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
    FORM.out.checksums.toList().subscribe { files ->
        if (!params.run_qc || params.check_inputs_only) {
            assert files.isEmpty(): "Unexpected checksum files: ${files}"
        } else {
            assert files.size() == 1: "Expected one checksums.md5: ${files}"
            def checksums = files[0]
            assert checksums.name == 'checksums.md5'
            def lines = checksums.readLines().findAll { it }
            assert lines && lines.every { it ==~ /^[0-9a-f]{32}  \S+\.fastq\.gz$/ }: lines
            def names = lines.collect { (it =~ /^[0-9a-f]{32}  (\S+)$/)[0][1] }
            def sorted = names.clone().sort()
            assert names == sorted: "Checksum lines are not sorted by file name: ${names}"
            def dir = new File(checksums.parent.toString())
            def proc = ['md5sum', '-c', 'checksums.md5'].execute(null, dir)
            def out = new StringBuffer()
            def err = new StringBuffer()
            proc.waitForProcessOutput(out, err)
            assert proc.exitValue() == 0: "md5sum -c failed in ${dir}:\n${out}\n${err}"
        }
        log.info 'FORM checksum output OK'
    }
}
