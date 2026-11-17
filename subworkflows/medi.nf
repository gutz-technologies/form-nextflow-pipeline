#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { kraken } from '../modules/medi/kraken/main.nf'
include { architeuthis_filter } from '../modules/medi/architeuthis_filter/main.nf'
include { kraken_report } from '../modules/medi/kraken_report/main.nf'
include { count_taxa } from '../modules/medi/count_taxa/main.nf'
include { merge_taxonomy } from '../modules/medi/merge_taxonomy/main.nf'
include { add_lineage } from '../modules/medi/add_lineage/main.nf'
include { quantify } from '../modules/medi/quantify/main.nf'
include { convert_medi_to_biom } from '../modules/medi/convert_medi_to_biom/main.nf'
include { multiqc } from '../modules/medi/multiqc/main.nf'

// HUMAnN's nucleotide-unaligned reads are already QC'd, single-end FASTA.
// No fastp, study metadata, mapping mode or skipCompleted re-injection.
workflow MEDI {
    take:
    reads   // Channel: [sample, bowtie2_unaligned.fa]
    subdir

    main:
    kraken_out = kraken(reads, subdir)
    filtered = architeuthis_filter(kraken_out.map { sample, k2, _report -> tuple(sample, k2) }, subdir)
    reports = kraken_report(filtered, subdir)
    counts = count_taxa(reports, subdir)

    // Each sample yields D/G/S files; empty levels cannot be merged.
    by_level = counts.flatMap { _sample, files ->
        files.findAll { it.size() > 0 }.collect { f -> tuple(f.parent.name, f) }
    }.groupTuple()
    merged = merge_taxonomy(by_level, subdir)
    lineage = add_lineage(merged, subdir)
    taxonomy = lineage.map { _level, f -> f }.collect().filter { it.size() > 0 }

    // Stubs need no real DB or food tables. Use a bundled placeholder only
    // for the staged table inputs; the real scripts always get the user files.
    foods = workflow.stubRun ? file("${projectDir}/assets/NO_FILE") : file(params.medi_food_matches)
    contents = workflow.stubRun ? file("${projectDir}/assets/NO_FILE") : file(params.medi_food_contents)
    food = quantify(taxonomy, foods, contents, subdir)
    biom = convert_medi_to_biom(food, subdir)
    qc = multiqc(reports.map { _sample, f -> f }.collect().filter { it.size() > 0 }, subdir)

    emit:
    food_abundance = food.map { abundance, _content -> abundance }
    food_content = food.map { _abundance, content -> content }
    taxonomy_counts = lineage
    bioms = biom
    qc_report = qc
}
