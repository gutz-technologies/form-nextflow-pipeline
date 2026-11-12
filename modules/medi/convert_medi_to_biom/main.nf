#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Convert food abundance, nutrients and compounds to BIOM.
process convert_medi_to_biom {
    label 'medi_low'
    container params.medi_biom_container
    publishDir path: { "${params.outdir}/${subdir}medi/biom" }, mode: 'copy'
    tag "medi"

    input:
    tuple path(food_abundance), path(food_content)

    val subdir

    output:
    tuple path("medi_food_abundance.biom"), path("medi_food_content_nutrients.biom"), path("medi_food_content_compounds.biom")

    script:
    """
    # Convert food abundance to BIOM
    medi_csv_to_biom.py ${food_abundance} medi_food_abundance.biom --type abundance

    # Convert food content to BIOM (creates both nutrients and compounds files)
    medi_csv_to_biom.py ${food_content} medi_food_content.biom --type content
    """

    stub:
    """
    touch medi_food_abundance.biom medi_food_content_nutrients.biom medi_food_content_compounds.biom
    """
}
