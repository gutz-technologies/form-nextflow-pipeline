# 6. StrainPhlAn

StrainPhlAn builds cohort strain phylogenies from the marker evidence produced
by MetaPhlAn. It is a branch from MetaPhlAn, rather than a consumer of HUMAnN or
BAQLaVa results.

**State:** FORM exposes `--run_strain_profiling` through bioBakery. It is off by
default and requires `--run_taxonomic_profiling true`. The pinned local route
is not runnable as shipped; see [Known integration gaps](#known-integration-gaps).

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

The MetaPhlAn image contains these tools. The
[software inventory](../reference/software-inventory.json) records its digest
and package builds. The local FORM profile pins this image for MetaPhlAn, but
currently does not assign it to the two StrainPhlAn tasks.

## Databases and sources

| Reference | Selected identity | SHA256 |
| --- | --- | --- |
| MetaPhlAn marker metadata `.pkl` | Must match `mpa_vOct22_CHOCOPhlAnSGB_202403` and the profiling index files | **Pending** — `strainphlan-markers` in the [database catalog](../reference/databases.md#strainphlan) |
| Optional clade/reference genomes | Run-specific selection, if supplied | **Pending for any selected genomes**; record accessions and checksums in the run manifest |

Use the exact `.pkl` that matches the [MetaPhlAn index](03-metaphlan.md#databases-and-sources)
used to align the reads. Both marker extraction and tree inference need that
file explicitly in the pinned runtime; do not rely on `latest`. The `.pkl` is a
reference database. Pinned `sample2markers.py` reads `.sam.bz2` and writes
per-sample `.json.bz2` consensus markers. Those markers are run outputs.

## Known integration gaps

| Current workflow | Required for a validated local run |
| --- | --- |
| `form_docker` does not select an image for `sample2markers` or `strainphlan`. | Assign the locked MetaPhlAn image to both tasks. Its tree executable is `strainphlan`, not `strainphlan.py`. |
| The marker task expects `<sample>.pkl` and does not pass a database. The tree task uses an absent `NO_DB` placeholder. | Pass the same database `.pkl` to both tools. Normalize the marker output to `<sample>.json.bz2` and preserve the sample ID in the tree. |
| The tree task passes obsolete flags and falls back to literal `all` if no clade is selected. | Use the pinned CLI (`-d`, `-o`, `-n`, `-c`, `--phylophlan_mode`). Require one explicit species-level genome bin (SGB), such as a `t__SGB` identifier from the pinned database, for the first validation run. |
| The tree file is optional in the workflow's output declaration. | Require a nonempty, parseable Newick tree for the requested clade. An output directory or consensus files alone do not prove that inference succeeded. |

## Two-sample validation target

StrainPhlAn 4.2.5 requires at least **four total samples plus reference genomes**
as input and at least **four retained entries** after marker filtering. Two
metagenomes alone cannot produce a tree with this release.

1. Run the production Nextflow workflow on two distinct real shotgun samples.
   Disable unrelated branches for this check. Verify the
   [MetaPhlAn outputs](03-metaphlan.md#expected-outputs) for both samples.
2. Choose a shared SGB with sufficient marker coverage in both samples. Add at
   least two distinct reference assemblies for that SGB. In the pinned CLI,
   `-r` accepts reference FASTAs; the current FORM branch does not document a
   supported reference input for this run. Record assembly accessions and
   file checksums and keep the pinned tool's marker filters unchanged.
3. After the integration gaps are fixed, require two readable `<sample>.json.bz2`
   files under `strainphlan/markers/` and a Newick tree under
   `strainphlan/<clade>/` with both sample IDs and at least two reference tips.
   If either sample is filtered out, or fewer than two reference tips remain,
   report that the fixture did not qualify. Do not count a partial run as
   validation.

This check is pending. It would validate the local taxonomy-to-strain branch,
not HUMAnN, BAQLaVa, MEDI, or reports.

## Sources

- [StrainPhlAn documentation](https://github.com/biobakery/MetaPhlAn/wiki/StrainPhlAn-4).
- [Pinned `sample2markers.py` source](https://github.com/biobakery/MetaPhlAn/blob/bd764e4cedce407a5daeea38bc072b19b521548d/metaphlan/utils/sample2markers.py).
- [Pinned `strainphlan` source](https://github.com/biobakery/MetaPhlAn/blob/bd764e4cedce407a5daeea38bc072b19b521548d/metaphlan/strainphlan.py).
- [Measured MetaPhlAn image evidence](../reference/software-inventory.json).
