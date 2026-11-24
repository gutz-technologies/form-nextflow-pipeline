# 6. StrainPhlAn

StrainPhlAn builds cohort strain phylogenies from the marker evidence produced
by MetaPhlAn. It is a branch from MetaPhlAn, rather than a consumer of HUMAnN or
BAQLaVa results.

**State:** The local `local,form_docker` MGX run produced a tree with both real
samples and both reference genomes. `--run_strain_profiling` is off by default
and requires `--run_taxonomic_profiling true`. See
[Two-sample validation](#two-sample-validation) for the tested scope.

## Quickstart: build a strain tree

Follow the [MetaPhlAn quickstart](03-metaphlan.md#quickstart-run-metaphlan-with-docker)
to set up the database, download the two public example read sets, and create
`docker.config`. You do not need to run MetaPhlAn separately. Stay in the same
Bash shell at the checkout root.

### 1. Download two reference genomes

The example uses `t__SGB15318` and two *Faecalibacterium duncaniae* RefSeq
assemblies: [GCF_010509575.1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_010509575.1/)
and [GCF_000162015.1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000162015.1/).
Paste this block to download, verify, and unpack both FASTAs (about 2 MB to
download).

```bash
(
  set -euo pipefail
  mkdir -p "$FORM_RUN/refs"
  cd "$FORM_RUN/refs"
  ncbi=https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF
  ref1=GCF_010509575.1_ASM1050957v1
  ref2=GCF_000162015.1_ASM16201v1
  curl -fL --retry 3 -o GCF_010509575.1.fna.gz "$ncbi/010/509/575/$ref1/${ref1}_genomic.fna.gz"
  curl -fL --retry 3 -o GCF_000162015.1.fna.gz "$ncbi/000/162/015/$ref2/${ref2}_genomic.fna.gz"
  md5sum -c <<'EOF'
c79a31a1cb536771b2b7d605428fb222  GCF_010509575.1.fna.gz
37cddaabe02936ed77617e5b77ff6310  GCF_000162015.1.fna.gz
EOF
  gzip -dc GCF_010509575.1.fna.gz > GCF_010509575.1.fna
  gzip -dc GCF_000162015.1.fna.gz > GCF_000162015.1.fna
)
```

### 2. Run and find the tree

This command runs MetaPhlAn and then StrainPhlAn. If you already ran the
MetaPhlAn quickstart with the same inputs, add `-resume` to reuse its outputs.

```bash
REFS="$FORM_RUN/refs"
NXF_VER=24.10.0 nextflow -c "$FORM_RUN/docker.config" run . \
  -profile local,form_docker -work-dir "$FORM_RUN/work" \
  --readsdir "$FORM_RUN/reads" --outdir "$FORM_RUN/results" \
  --check_inputs true --fail_on_bad_inputs true --run_qc false \
  --run_taxonomic_profiling true --metaphlan_db "$METAPHLAN_DB" \
  --run_strain_profiling true \
  --strainphlan_clades t__SGB15318 \
  --strainphlan_references "$REFS/GCF_010509575.1.fna,$REFS/GCF_000162015.1.fna" \
  --strainphlan_phylophlan_mode fast \
  --run_functional_profiling false --run_viral_profiling false \
  --run_medi false --run_vis false --run_stats false --log_versions false
```

Open `strainphlan/t__SGB15318/output/RAxML_bestTree.t__SGB15318.StrainPhlAn4.tre`
in `$FORM_RUN/results`. Look for both `SRR` sample IDs and both `GCF_` reference
accessions. The per-sample marker files are in `strainphlan/markers/`.

### Use your own samples

Set `--strainphlan_clades` to an explicit `t__SGB` identifier from the pinned
MetaPhlAn database that your samples share. Supply local reference FASTAs for
that clade as a comma-separated list. Use a unique filename for each FASTA.
You may omit `--strainphlan_references` with at least four samples, but the tool
still needs four entries after marker filtering.

The marker `.pkl` defaults to `<metaphlan_db>/<metaphlan_index>.pkl`. If you set
`--strainphlan_db`, pass the matching `.pkl` beside its Bowtie2 shards.

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
and package builds. The `form_docker` profile uses the same pinned image for
MetaPhlAn, `sample2markers`, and `strainphlan`.

## Databases and sources

| Reference | Selected identity | SHA256 |
| --- | --- | --- |
| MetaPhlAn marker metadata `.pkl` | Must match `mpa_vOct22_CHOCOPhlAnSGB_202403` and the profiling index files | **Pending** — `strainphlan-markers` in the [database catalog](../reference/databases.md#strainphlan) |
| Reference genomes | Run-specific FASTAs for the selected SGB | Record assembly accessions and file checksums in the run manifest. |

Use the exact `.pkl` that matches the [MetaPhlAn index](03-metaphlan.md#databases-and-sources)
used to align the reads. Both marker extraction and tree inference need that
file explicitly in the pinned runtime; do not rely on `latest`. The `.pkl` is a
reference database. Pinned `sample2markers.py` reads `.sam.bz2` and writes
per-sample `.json.bz2` consensus markers. Those markers are run outputs.

## Two-sample validation

StrainPhlAn 4.2.5 requires at least **four total samples plus reference genomes**
as input and at least **four retained entries** after marker filtering. Two
metagenomes alone cannot produce a tree with this release.

The FORM MGX rerun reused the [two-sample MetaPhlAn outputs](03-metaphlan.md#two-sample-validation)
with Nextflow 24.10.0 and the pinned 4.2.5 image. Both marker tasks produced
readable `.json.bz2` files under `strainphlan/markers/`: 8,986 consensus markers
for `SRR6468541` and 5,748 for `SRR6468545`.

The tree task ran offline with the read-only database mount and default marker
filters. It retained 199 markers for `t__SGB15318` and emitted a parseable Newick
at `strainphlan/t__SGB15318/output/RAxML_bestTree.t__SGB15318.StrainPhlAn4.tre`.
The tree contained exactly four tips: both sample IDs and the two RefSeq
assemblies `GCF_010509575.1` and `GCF_000162015.1`.

The branch also rejected `all` as a clade and rejected the two-sample run
without references before launching the tree task. This validates local MGX
only; other profiles and entry points were not tested.

## Sources

- [StrainPhlAn documentation](https://github.com/biobakery/MetaPhlAn/wiki/StrainPhlAn-4).
- [Pinned `sample2markers.py` source](https://github.com/biobakery/MetaPhlAn/blob/bd764e4cedce407a5daeea38bc072b19b521548d/metaphlan/utils/sample2markers.py).
- [Pinned `strainphlan` source](https://github.com/biobakery/MetaPhlAn/blob/bd764e4cedce407a5daeea38bc072b19b521548d/metaphlan/strainphlan.py).
- [Measured MetaPhlAn image evidence](../reference/software-inventory.json).
