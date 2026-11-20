# 7. MEDI

MEDI classifies food-derived reads and estimates food abundance and nutrient
content. FORM owns the MEDI process modules and connects them to bioBakery
outputs.

**State:** modules and workflow wiring are present. DNAnexus container selection,
reference staging, and an end-to-end deployment run still need validation.

## Software and major dependencies

| Component | Version evidence | Role |
| --- | --- | --- |
| MEDI | Image tag **1.0.1**; installed distribution/source correspondence not yet inspected | Food quantification scripts |
| Kraken2 | **2.1.3** in the upstream 1.0.1 environment | Read classification |
| Bracken | **2.6.0** in that environment | Abundance estimation; FORM uses 150 bp distributions |
| Architeuthis | **>=0.5.0**, exact installed version pending | Mapping filtering, taxonomy merge, lineage |
| Python | **>=3.8** upstream constraint; exact runtime pending | Python helpers |
| R / data.table / Biostrings | Exact installed versions pending | Quantification and taxonomy helpers |
| pandas / NumPy / biom-format / HDF5 | Exact installed versions pending | FORM CSV-to-BIOM conversion |
| MultiQC | **1.22.3** FORM image tag | Standalone FORM report process |

FORM currently defaults to `colinbrislawn/medi:1.0.1`,
`colinbrislawn/metaphlan:4.2.4` for BIOM conversion, and
`ghcr.io/multiqc/multiqc:v1.22.3`. The README identifies the first two images
as ARM builds, so their digests, platform, and installed dependencies must be
verified or replaced for the selected DNAnexus workers.

The upstream MEDI environment requests MultiQC `>=1.28.0`; that is distinct
from FORM's separate reporting image. Upstream environment constraints describe
the source release and do not prove the contents of either MEDI Docker image.

## Databases and sources

| Reference | Required identity | SHA256 |
| --- | --- | --- |
| MEDI Kraken2/Bracken database | Full database including `taxo.k2d`, taxonomy, and 150 bp Bracken distributions | **Pending** — `medi-kraken` |
| Food-to-taxon table | Exact `medi_food_matches` CSV | **Pending** — `medi-food-matches` |
| Food contents table | Exact `medi_food_contents` CSV | **Pending** — `medi-food-contents` |

See the [MEDI database catalog](../reference/databases.md#medi). The upstream
project describes constructing references from food matches, NCBI sequences,
taxonomy, and decoys. An exact snapshot/build identifier is required because
re-running that construction against current sources can change the database.

## Inputs, outputs, and resources

The default `medi_input: humann` consumes HUMAnN's nucleotide-unaligned reads;
`medi_input: kneaddata` uses the full cleaned reads. Outputs include per-sample
Kraken reports, Bracken counts, lineage tables, food abundance/content CSVs,
three BIOM tables, and a MultiQC report.

FORM currently requests about **415 GB RAM** for the Kraken process before
resource caps are applied. The reference path is read directly inside tasks,
so it needs explicit worker staging and adequate disk as well as memory.

## Sources

- [MEDI 1.0.1 source](https://github.com/Gibbons-Lab/medi/tree/c1166dc491e221dc3f182adecc16e2b1239affa7).
- [MEDI 1.0.1 environment constraints](https://github.com/Gibbons-Lab/medi/blob/c1166dc491e221dc3f182adecc16e2b1239affa7/medi.yml).
- [FORM MEDI workflow](https://github.com/gutz-technologies/form-nextflow-pipeline/blob/main/subworkflows/medi.nf).
