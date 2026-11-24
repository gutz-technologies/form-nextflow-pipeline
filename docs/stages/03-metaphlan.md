# 3. MetaPhlAn

MetaPhlAn estimates microbial taxonomic abundances and produces marker alignments.
In FORM's shotgun workflow, MetaPhlAn consumes cleaned FASTQ files when
KneadData is enabled. Its taxonomic profiles feed HUMAnN and BAQLaVa. Its
compressed SAM alignments feed [StrainPhlAn](06-strainphlan.md).

**State:** The local `local,form_docker` taxonomy run passed on two public
shotgun samples with MetaPhlAn 4.2.5, `--offline`, and a read-only database.
See [Two-sample validation](#two-sample-validation) for the revisions and results.

## Quickstart: run MetaPhlAn with Docker

Use Linux x86-64 with at least 8 CPUs and 32 GB of RAM. Install
[Docker Engine](https://docs.docker.com/engine/install/) and
[Nextflow](https://www.nextflow.io/docs/latest/install.html) (tested with
24.10.0 and Java 21). Run `docker info` to check that your user can reach
Docker. You also need `curl`, `tar`, and `md5sum`.

Run these blocks in the **same Bash shell**, from the root of a FORM checkout
with its submodule initialized (`git submodule update --init`). Use an SSD with
at least 100 GB free for the database, example reads, and run files. To use an
external SSD, set `FORM_RUN` to an absolute path on it before step 1. Use a path
without spaces or commas.

### 1. Download the database once

The two archives total about 23 GB and require roughly 45 GB with both archives
and extracted files present. If you already have the matching extracted index,
set `METAPHLAN_DB` to its absolute path before running this block. The download
is skipped if the marker file and all six shards are already present.

```bash
export FORM_RUN="${FORM_RUN:-$(pwd -P)/phlan-run}"
export METAPHLAN_DB="${METAPHLAN_DB:-$FORM_RUN/db/metaphlan}"
(
  set -euo pipefail
  index=mpa_vOct22_CHOCOPhlAnSGB_202403
  url=https://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases
  mkdir -p "$FORM_RUN/reads" "$METAPHLAN_DB"
  db_ready() {
    for suffix in pkl 1.bt2l 2.bt2l 3.bt2l 4.bt2l rev.1.bt2l rev.2.bt2l; do
      test -s "$METAPHLAN_DB/$index.$suffix" || return 1
    done
  }
  if ! db_ready; then
    mkdir -p "$FORM_RUN/downloads"
    cd "$FORM_RUN/downloads"
    curl -fL --retry 3 -C - -o "$index.tar" "$url/$index.tar"
    curl -fL --retry 3 -C - -o "${index}_bt2.tar" "$url/bowtie2_indexes/${index}_bt2.tar"
    printf '%s  %s\n' \
      91d57912faab6bfd3526a49d9e83da8c "$index.tar" \
      6618ecfbed7f2964b9185b0c6f090020 "${index}_bt2.tar" | md5sum -c -
    tar -xf "$index.tar" -C "$METAPHLAN_DB"
    tar -xf "${index}_bt2.tar" -C "$METAPHLAN_DB"
  fi
  db_ready
)
```

### 2. Add reads

Put your **host-depleted, paired-end** shotgun FASTQs in `$FORM_RUN/reads`,
using names like `sample_R1.fastq.gz` and `sample_R2.fastq.gz`. This quickstart
skips host depletion. For unprocessed reads, run [KneadData](02-kneaddata.md)
first.

To try the public example instead, leave that folder empty and paste the block
below. It downloads about 6.7 GB of paired reads for
[SRR6468541](https://www.ebi.ac.uk/ena/browser/view/SRR6468541) and
[SRR6468545](https://www.ebi.ac.uk/ena/browser/view/SRR6468545) from ENA.
These are the same accessions as the validation runs, which used FASTQs exported
from SRA.

```bash
(
  set -euo pipefail
  cd "$FORM_RUN/reads"
  ena=https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR646
  curl -fL --retry 3 -C - -o SRR6468541_R1.fastq.gz "$ena/001/SRR6468541/SRR6468541_1.fastq.gz"
  curl -fL --retry 3 -C - -o SRR6468541_R2.fastq.gz "$ena/001/SRR6468541/SRR6468541_2.fastq.gz"
  curl -fL --retry 3 -C - -o SRR6468545_R1.fastq.gz "$ena/005/SRR6468545/SRR6468545_1.fastq.gz"
  curl -fL --retry 3 -C - -o SRR6468545_R2.fastq.gz "$ena/005/SRR6468545/SRR6468545_2.fastq.gz"
  md5sum -c <<'EOF'
8cf6d65ce13810dd8f2e1b33ad1cdb97  SRR6468541_R1.fastq.gz
af60c145e84b846aecd7f2e5124c34a2  SRR6468541_R2.fastq.gz
4fc7387cb5fe146afb924d40402667ad  SRR6468545_R1.fastq.gz
ae0ce28f05713d7425370a1ee7a37f27  SRR6468545_R2.fastq.gz
EOF
)
```

### 3. Run and check the outputs

The config mounts the database at the same path in Docker, read-only.
Docker can pull the pinned image on first use, but MetaPhlAn runs with
`--offline` and will not download an index. To get a tree as well as profiles,
create this config, then use the [StrainPhlAn run command](06-strainphlan.md#quickstart-build-a-strain-tree)
instead of running MetaPhlAn separately.

```bash
mkdir -p "$FORM_RUN/tmp"
export TMPDIR="$FORM_RUN/tmp"
tee "$FORM_RUN/docker.config" >/dev/null <<'EOF'
docker.runOptions = '-u $(id -u):$(id -g) -e DXFUSE_ENABLED=false --network none --mount type=bind,source=' + System.getenv('METAPHLAN_DB') + ',target=' + System.getenv('METAPHLAN_DB') + ',readonly'
params.metaphlan_options = '--offline'
EOF
```

```bash
NXF_VER=24.10.0 nextflow -c "$FORM_RUN/docker.config" run . \
  -profile local,form_docker -work-dir "$FORM_RUN/work" \
  --readsdir "$FORM_RUN/reads" --outdir "$FORM_RUN/results" \
  --check_inputs true --fail_on_bad_inputs true --run_qc false \
  --run_taxonomic_profiling true --metaphlan_db "$METAPHLAN_DB" \
  --run_strain_profiling false \
  --run_functional_profiling false --run_viral_profiling false \
  --run_medi false --run_vis false --run_stats false --log_versions false
```

Open `$FORM_RUN/results/metaphlan/merged_metaphlan_profiles.tsv` for the merged
abundances, or `metaphlan/merged/metaphlan_species_counts_table.tsv` under the
same results directory for one species count per sample. If the database appears
missing, check `METAPHLAN_DB` and the Docker bind before downloading again.

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

## Two-sample validation

FORM `c057a38` with bioBakery `e80e455` produced both sample profiles, both
compressed SAM alignments, the merged abundance table, and the species-count
table. Read QC and all other analysis branches were disabled. The run used the
existing `mpa_vOct22_CHOCOPhlAnSGB_202403` database without downloads.

| SRA run | Reported species |
| --- | ---: |
| `SRR6468541` | 193 |
| `SRR6468545` | 144 |

## Sources

- [MetaPhlAn source and database installation](https://github.com/biobakery/MetaPhlAn).
- [Container environment recipe snapshot](https://github.com/Hugemiler/biobakery-containers/blob/a8d779ba245722b9806bc9431391b1c59141f279/packages/metaphlan/4.2.5/nodb/environment.yaml).
- [Measured image evidence](../reference/software-inventory.json).
