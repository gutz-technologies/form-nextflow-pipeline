# 6. StrainPhlAn

StrainPhlAn builds cohort strain phylogenies from the marker evidence produced
by MetaPhlAn. It is a branch from MetaPhlAn, rather than a consumer of HUMAnN or
BAQLaVa results.

**State:** available in the neighboring bioBakery deployment; integration and
validation against the updated FORM pin are pending.

## Software and major dependencies

| Component | Installed version | Role |
| --- | --- | --- |
| StrainPhlAn | **4.2.5**, reported by `strainphlan --version` | Strain reconstruction; distributed with MetaPhlAn |
| MetaPhlAn | 4.2.5 | Marker database and supporting commands |
| Python | 3.8.20 | Runtime |
| PhyloPhlAn | 3.1.1 | Phylogenetic workflow |
| MUSCLE | 5.3 | Multiple sequence alignment |
| RAxML | 8.2.13 | Tree inference |
| BLAST | 2.17.0 | Sequence search |
| SAMtools | 1.25 | Alignment handling |
| Biopython | 1.83 | Sequence handling |

This stage shares
`public.ecr.aws/j5i5h1i5/metaphlan:4.2.5-nodb-dnanexus-r1`
with MetaPhlAn. The [software inventory](../reference/software-inventory.json)
records that image's digest and package builds. Installed tools listed here are
available dependencies; the selected PhyloPhlAn mode/configuration determines
which executables a particular run invokes.

## Databases and sources

| Reference | Selected identity | SHA256 |
| --- | --- | --- |
| MetaPhlAn marker metadata `.pkl` | Must match `mpa_vOct22_CHOCOPhlAnSGB_202403` and the profiling index files | **Pending** — `strainphlan-markers` in the [database catalog](../reference/databases.md#strainphlan) |
| Optional clade/reference genomes | Run-specific selection, if supplied | **Pending for any selected genomes**; record accessions and checksums in the run manifest |

The marker metadata and Bowtie2 index originate from the same MetaPhlAn
database release. Do not independently update one without recording the matching
release for the other. Sample-derived consensus markers are run outputs, not an
external reference release.

## Sources

- [StrainPhlAn documentation](https://github.com/biobakery/MetaPhlAn/wiki/StrainPhlAn-4).
- [Measured MetaPhlAn image evidence](../reference/software-inventory.json).
