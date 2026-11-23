# 3. MetaPhlAn

MetaPhlAn estimates microbial taxonomic abundances and produces marker alignments.
In FORM's shotgun workflow, MetaPhlAn consumes cleaned FASTQ files when
KneadData is enabled. Its taxonomic profiles feed HUMAnN and BAQLaVa. Its
compressed SAM alignments feed [StrainPhlAn](06-strainphlan.md).

**State:** FORM runs the bioBakery MetaPhlAn module and pins the 4.2.5 image in
`local,form_docker`. A real-sample run through all taxonomy outputs is still
pending. See [Local run checks](#local-run-checks) for known blockers.

## Software and major dependencies

| Component | Installed version | Role |
| --- | --- | --- |
| MetaPhlAn | **4.2.5** | Taxonomic profiling |
| Python | 3.8.20 | Runtime |
| Bowtie2 | 2.5.5 | Marker alignment |
| SAMtools | 1.25 | Alignment handling |
| NumPy | 1.24.4 | Numerical operations |
| pandas | 2.0.3 | Tables |
| SciPy | 1.10.1 | Scientific computing |
| Biopython | 1.83 | Sequence handling |

Inspected image:
`public.ecr.aws/j5i5h1i5/metaphlan:4.2.5-nodb-dnanexus-r1`.
See its registry digest and package build identifiers in the
[software inventory](../reference/software-inventory.json).

## Databases and sources

| Reference | Selected identity | Download | SHA256 |
| --- | --- | --- | --- |
| Marker metadata | `mpa_vOct22_CHOCOPhlAnSGB_202403.tar` — contains the `.pkl` and marker FASTA | [Archive](https://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/mpa_vOct22_CHOCOPhlAnSGB_202403.tar) · [MD5](https://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/mpa_vOct22_CHOCOPhlAnSGB_202403.md5) | **Pending SHA256**; distributor MD5 `91d57912faab6bfd3526a49d9e83da8c` |
| Bowtie2 index | `mpa_vOct22_CHOCOPhlAnSGB_202403_bt2.tar` — contains the `.bt2l` files | [Archive](https://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/bowtie2_indexes/mpa_vOct22_CHOCOPhlAnSGB_202403_bt2.tar) · [MD5](https://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/bowtie2_indexes/mpa_vOct22_CHOCOPhlAnSGB_202403_bt2.md5) | **Pending SHA256**; distributor MD5 `6618ecfbed7f2964b9185b0c6f090020` |

One MetaPhlAn index needs **both** archives, extracted into the same directory:
the marker `.tar` provides the `.pkl`, and `bowtie2_indexes/..._bt2.tar` provides
the `.bt2l` index. These are the URLs the MetaPhlAn database installer uses. All
four public URLs returned successful ranged downloads on 2026-11-20. The
neighboring deployment uses corrected extracted indexes in its project reference
folder; the public MD5 files do not verify that project copy. Capture a manifest
of the files actually used by the run.

MetaPhlAn's software version, its database release, and the workflow's
`metaphlan_version` CLI compatibility setting are different identifiers. FORM
locks them to MetaPhlAn 4.2.5, `mpa_vOct22_CHOCOPhlAnSGB_202403`, and
`metaphlan_v4`. The run refuses another MetaPhlAn index unless the explicit FORM
index check is disabled. Record all three when validating a run.

## Local run checks

1. Download both archives and check each distributor MD5 before extraction.
   Extract both archives into one directory that you choose. Pass that
   directory, not either archive, to `--metaphlan_db`.
2. Check for the nonempty `.pkl` and all six large-index shards. Set
   `METAPHLAN_DB` to the absolute path of the extracted directory:

   ```bash
   index=mpa_vOct22_CHOCOPhlAnSGB_202403
   (
     set -eu
     test -s "${METAPHLAN_DB:?Set METAPHLAN_DB to the database directory}/$index.pkl"
     for shard in 1 2 3 4 rev.1 rev.2; do
       test -s "$METAPHLAN_DB/$index.$shard.bt2l"
     done
   )
   ```

3. When using Docker, make the database readable at the same absolute path
   inside the task container. Use a read-only bind in your local launch
   configuration. FORM passes `--metaphlan_db` as a command argument, not a
   staged input. If the container reports a missing database, inspect the bind
   and shard names before downloading again. For the pinned CLI, include
   `--offline` in `--metaphlan_options` to fail instead of attempting an install.
4. Check the species-count task. It runs even with reports disabled. The
   pinned MetaPhlAn image does not supply `count_features.py`, and the current
   local profile does not provide it separately. Per-sample profiles may exist
   even if the workflow fails at this step.

## Expected outputs

Paths are relative to `--outdir`. `<index>` is the database release above.

| Output | Path |
| --- | --- |
| Per-sample taxonomic profile | `metaphlan/<index>/<sample>_profile_<index>.tsv` |
| Per-sample compressed alignment | `metaphlan/bzip/<sample>_<index>.sam.bz2` |
| Cohort abundance table | `metaphlan/merged_metaphlan_profiles.tsv` |
| Cohort species counts | `metaphlan/merged/metaphlan_species_counts_table.tsv` |

For a two-sample check, use two distinct real read sets. Require both
profiles, both readable compressed alignments, and both sample IDs in the
cohort outputs. Record the image digest, database release and checksums. A
MetaPhlAn profile alone does not establish that a sample has enough marker
coverage for a StrainPhlAn tree.

## Sources

- [MetaPhlAn source and database installation](https://github.com/biobakery/MetaPhlAn).
- [Container environment recipe snapshot](https://github.com/Hugemiler/biobakery-containers/blob/a8d779ba245722b9806bc9431391b1c59141f279/packages/metaphlan/4.2.5/nodb/environment.yaml).
- [Measured image evidence](../reference/software-inventory.json).
