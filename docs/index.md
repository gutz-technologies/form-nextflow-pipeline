# FORM pipeline

FORM orchestrates a pinned bioBakery workflow and downstream analyses for
metagenomic reads. This documentation follows the intended analysis order and
records the software, major dependencies, database sources, and SHA256 evidence
for each component.

## Start here

- [Run MetaPhlAn with Docker](stages/03-metaphlan.md#quickstart-run-metaphlan-with-docker)
- [Build a StrainPhlAn tree with Docker](stages/06-strainphlan.md#quickstart-build-a-strain-tree)

Both quickstarts include downloads, example inputs, commands, and expected outputs.

## Pipeline stages

| Order | Component | Role | Integration state |
| --- | --- | --- | --- |
| 1 | [Samplesheet building](stages/01-samplesheet.md) | Discover reads and construct a validated sample manifest | FORM module planned |
| 2 | [KneadData](stages/02-kneaddata.md) | Read quality control and host depletion | Imported through bioBakery |
| 3 | [MetaPhlAn](stages/03-metaphlan.md) | Microbial taxonomic profiles and marker alignments | Validated locally with Docker |
| 4 | [HUMAnN](stages/04-humann.md) | Functional profiles and nucleotide-unaligned reads | Imported through bioBakery; unaligned-read export present in the pinned submodule (`48a1eaa`, `4466d89`); deployment validation pending |
| 5 | [BAQLaVa](stages/05-baqlava.md) | Viral profiling | Present in the pinned bioBakery submodule (optional branch); DNAnexus validation pending |
| 6 | [StrainPhlAn](stages/06-strainphlan.md) | Cohort strain phylogenies | Optional branch; validated locally with Docker; DNAnexus validation pending |
| 7 | [MEDI](stages/07-medi.md) | Food DNA and nutrient estimates | FORM modules present; DNAnexus validation pending |
| 8 | [omixer-rpm](stages/08-omixer-rpm.md) | Gut-Brain Module abundance and coverage | FORM module planned |

The order above is the documentation order. The workflow can run independent
branches concurrently:

```mermaid
flowchart TD
    F[Reads folder] --> S[1. Samplesheet building]
    S --> K[2. KneadData]
    K --> M[3. MetaPhlAn]
    K --> H[4. HUMAnN]
    M --> H
    K --> B[5. BAQLaVa]
    M --> B
    M --> T[6. StrainPhlAn]
    H --> D[7. MEDI]
    H --> G[8. omixer-rpm / GBMs]
```

## Reproducibility baseline

The program-selected KneadData host reference is
[hg39T2T / GCA_009914755.4](reference/kneaddata-host.md), using the Huttenhower
Lab Bowtie2 v0.2 bundle. Its six expected index checksums are recorded in a
downloadable manifest.

This first inventory was recorded on **2026-11-19** while the upstream input
and read-export interfaces were being updated. Run `git submodule status biobakery`
from the FORM checkout to see its pinned bioBakery revision. The inspected
DNAnexus images are candidates from the neighboring deployment, not a validated FORM release.

- [Software versions](reference/versions.md) distinguishes installed versions,
  recipe constraints, source commits, and image tags.
- [Databases and checksums](reference/databases.md) lists every major reference,
  including explicit gaps where the exact deployed bytes are unavailable.
- [Provenance and verification](reference/provenance.md) explains how to reproduce
  the inventory and fill those gaps.
- [DNAnexus interface](reference/dnanexus.md) describes the single `dnanexus`
  profile and the reads-folder/YAML launch interface.

Historical implementation decisions remain under [Design history](specs/index.md).

## Documentation site

The site uses Zensical with searchable navigation, light and dark themes, and
GitHub Pages deployment through GitHub Actions. See
[Writing and publishing docs](development/documentation.md) to preview or update it.
