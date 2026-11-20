# form-nextflow-pipeline

Bioinformatics pipeline for FORM: the [bioBakery](https://github.com/biobakery/biobakery-nextflow)
MGX workflow (KneadData → MetaPhlAn → HUMAnN 4), followed by
[MEDI](https://github.com/Gibbons-Lab/medi) food DNA quantification.

bioBakery is a git submodule (`biobakery/`) pinned to an upstream commit and
used unmodified. Design and rationale: [docs/specs/0001-biobakery-dependency-and-medi.md](docs/specs/0001-biobakery-dependency-and-medi.md).

The [documentation](docs/index.md) follows the eight FORM stages, with
[software versions](docs/reference/versions.md),
[database sources and SHA256 checksums](docs/reference/databases.md), and
[Zensical preview and publishing instructions](docs/development/documentation.md).

FORM's program-selected KneadData host reference is
[hg39T2T / GCA_009914755.4](docs/reference/kneaddata-host.md), using the
Huttenhower Lab Bowtie2 v0.2 bundle. Its six expected index checksums and
verification instructions are documented alongside the software/runtime settings.

## Getting it

```bash
git clone --recurse-submodules https://github.com/gutz-technologies/form-nextflow-pipeline.git
# or, in an existing clone:
git submodule update --init
```

`nextflow run gutz-technologies/form-nextflow-pipeline` fetches the submodule
too (`manifest.recurseSubmodules`).

## Quick start: download hg39T2T and run KneadData

This is the shortest working path. Run each command from the repository root.
Use a Linux x86-64 system with Java 17+, Nextflow 24.04+, and either Docker
(any workstation) or the Harvard FASRC modules.

FORM requires KneadData 0.12 or later, Bowtie2 2.5.5 or later, and the
hg39T2T host index. The run stops if `host_genome` lacks the
`GCA_009914755.4_T2T.*.bt2` files, or if a KneadData task reports an older
KneadData or Bowtie2.

### Where the images and databases come from

| Item | Pinned source | Pipeline parameter |
| --- | --- | --- |
| KneadData image | `public.ecr.aws/j5i5h1i5/kneaddata@sha256:87f9fe73578cffa73d30e08c90099e1fdf69831c42778d3b2a7cd7791f8ae4b3` (KneadData 0.12.1, Bowtie2 2.5.5) | set by `-profile form_docker` |
| MetaPhlAn image | `public.ecr.aws/j5i5h1i5/metaphlan@sha256:bcbba3807ce7bbfda6526dd8598232025c9cc9a3f7689b9ad639dab9d8c81787` (MetaPhlAn 4.2.5) | set by `-profile form_docker` |
| HUMAnN image | `public.ecr.aws/j5i5h1i5/humann@sha256:3d245ae23c5b5015e6ca2a16b5963c0d178fd5f0786890e7eb57fa8cf7fe2acd` (HUMAnN 4.0.0a2) | set by `-profile form_docker` |
| Host index (hg39T2T) | [Homo_sapiens_hg39_T2T_Bowtie2_v0.2.tar.gz](https://huttenhower.sph.harvard.edu/kneadData_databases/Homo_sapiens_hg39_T2T_Bowtie2_v0.2.tar.gz), 3.9 GB, step 1 below | `--host_genome` |
| MetaPhlAn database | `mpa_vJun23_CHOCOPhlAnSGB_202307`, see [MGX databases](#download-the-mgx-databases) | `--metaphlan_db` |
| HUMAnN 4 databases | ChocoPhlAn, UniRef90, utility mapping v4 alpha, see [MGX databases](#download-the-mgx-databases) | `--humann_db` |

The images are bioBakery's builds in its public ECR registry, the same registry
bioBakery's `amazon` profile uses. The Docker Hub `biobakery/*` images are older
(KneadData 0.10.0) and do not meet the minimums. Docker pulls the images on the
first run. To pull one ahead of time, run `docker pull` with the reference above.

### 1. Download the FORM host reference

Copy and run this complete block. It downloads the 3.9 GB prebuilt Bowtie2
index, checks the downloaded archive, extracts it, and checks all six index
files. Keep at least 9 GB of disk space free.

```bash
set -euo pipefail

FORM_ROOT="$(pwd -P)"
HOST_DIR="$FORM_ROOT/databases/kneaddata/hg39T2T"
ARCHIVE="Homo_sapiens_hg39_T2T_Bowtie2_v0.2.tar.gz"
URL="https://huttenhower.sph.harvard.edu/kneadData_databases/$ARCHIVE"

mkdir -p "$HOST_DIR"
cd "$HOST_DIR"
wget -c "$URL"
wget -O "$ARCHIVE.md5" "$URL.md5"
md5sum --check "$ARCHIVE.md5"
tar -xzf "$ARCHIVE"
sha256sum --check \
  "$FORM_ROOT/docs/reference/checksums/kneaddata-hg39-t2t-v0.2.sha256"
cd "$FORM_ROOT"
```

All six SHA256 checks must report `OK`. The pipeline host-reference path is now:

```text
<repository-root>/databases/kneaddata/hg39T2T
```

Pass the directory to `--host_genome`. Do not pass the archive or one `.bt2`
file.

### 2. Add the reads

Create `fastqs/` in the repository root. Put the compressed FASTQ files in that
directory. Use names such as `sample_R1.fastq.gz` and `sample_R2.fastq.gz`.

```bash
mkdir -p fastqs
```

### 3. Run KneadData

On a workstation with Docker, copy and run this command. It uses the pinned
KneadData image:

```bash
nextflow run . -profile local,form_docker \
  --readsdir "$PWD/fastqs" \
  --outdir "$PWD/kneaddata-results" \
  --host_genome "$PWD/databases/kneaddata/hg39T2T" \
  --run_qc true \
  --run_taxonomic_profiling false \
  --run_functional_profiling false \
  --run_viral_profiling false \
  --run_strain_profiling false \
  --run_medi false \
  --run_vis false \
  --run_stats false
```

On Harvard FASRC, copy and run this command:

```bash
nextflow run . -profile harvard_rc \
  --readsdir "$PWD/fastqs" \
  --outdir "$PWD/kneaddata-results" \
  --host_genome "$PWD/databases/kneaddata/hg39T2T" \
  --run_qc true \
  --run_taxonomic_profiling false \
  --run_functional_profiling false \
  --run_viral_profiling false \
  --run_strain_profiling false \
  --run_medi false \
  --run_vis false \
  --run_stats false
```

Find the cleaned reads in `kneaddata-results/kneaddata/` and the read counts in
`kneaddata-results/kneaddata/merged/kneaddata_read_count_table.tsv`. The log
must show these two lines:

```text
Version check: kneaddata 0.12.0 >= 0.12 (...)
Version check: bowtie2 2.5.5 >= 2.5.5 (...)
```

`harvard_rc` loads the `kneaddata/0.12.0-devel` module. `tufts_hpc` and `local`
without `form_docker` use the KneadData on `PATH`. For those profiles, the
version check is the only version control. Do not use `-profile amazon` for
KneadData: its image `public.ecr.aws/j5i5h1i5/kneaddata-nodb:mamba-v0.10` is no
longer in the registry.

#### What `form_docker` sets

- It pins the KneadData, MetaPhlAn, and HUMAnN images by digest.
- It sets `DXFUSE_ENABLED=false`. The images try to mount DNAnexus storage
  when they start. Without this setting, every task fails with
  `DNAnexus references: set DX_REFERENCE_PROJECT or forward DX_PROJECT_CONTEXT_ID`.
- It runs each container as your user (`-u $(id -u):$(id -g)`).
- It gives each KneadData task 8 CPUs and sets `kneaddata_options` to
  `--threads 8`. The bioBakery paired-end command does not pass `--threads`,
  so Bowtie2 and Trimmomatic otherwise use one thread. If you set
  `kneaddata_options`, include `--threads 8` in it.

`form_docker` does not supply the visualization report tools. Add
`--run_vis false`, or supply those tools through the site profile.

## Download the MGX databases

Skip this section on Harvard FASRC. The `harvard_rc` profile already supplies
these databases. The commands use the pinned images, so you do not need to
install MetaPhlAn or HUMAnN. Run them from the repository root. They need about
100 GB of free disk space.

```bash
set -euo pipefail
DB="$(pwd -P)/databases"
mkdir -p "$DB/metaphlan" "$DB/humann"
RUN="docker run --rm -u $(id -u):$(id -g) -e DXFUSE_ENABLED=false -v $DB:$DB"
MPA=public.ecr.aws/j5i5h1i5/metaphlan@sha256:bcbba3807ce7bbfda6526dd8598232025c9cc9a3f7689b9ad639dab9d8c81787
HUMANN=public.ecr.aws/j5i5h1i5/humann@sha256:3d245ae23c5b5015e6ca2a16b5963c0d178fd5f0786890e7eb57fa8cf7fe2acd

# MetaPhlAn: one index per directory
$RUN $MPA metaphlan --install --index mpa_vJun23_CHOCOPhlAnSGB_202307 --db_dir "$DB/metaphlan"

# HUMAnN 4: the pipeline reads chocophlan/, uniref/ and utility_mapping/ under --humann_db
$RUN $HUMANN humann_databases --download chocophlan full "$DB/humann/chocophlan" --update-config no
$RUN $HUMANN humann_databases --download uniref uniref90_ec_filtered_diamond "$DB/humann/uniref" --update-config no
$RUN $HUMANN humann_databases --download utility_mapping full "$DB/humann/utility_mapping" --update-config no
```

The HUMAnN downloads come from `huttenhower.sph.harvard.edu/humann_data/`
(ChocoPhlAn 44.8 GB, UniRef90 0.9 GB, utility mapping 2.8 GB). The pinned
HUMAnN 4 image offers only the EC-filtered UniRef90 DIAMOND database, so the
`uniref90_diamond` name in the bioBakery README does not work with it.

Then run the MGX pipeline with Docker:

```bash
nextflow run . -profile local,form_docker \
  --readsdir "$PWD/fastqs" \
  --outdir "$PWD/results" \
  --host_genome "$PWD/databases/kneaddata/hg39T2T" \
  --metaphlan_db "$PWD/databases/metaphlan" \
  --humann_db "$PWD/databases/humann" \
  --run_medi false --run_vis false
```

## Run the MGX pipeline on Harvard FASRC

The Harvard profile already supplies the MetaPhlAn and HUMAnN databases. This
command runs the input check, KneadData, MetaPhlAn, HUMAnN, and the visualization
report:

```bash
nextflow run . -profile harvard_rc \
  --readsdir "$PWD/fastqs" \
  --outdir "$PWD/results" \
  --host_genome "$PWD/databases/kneaddata/hg39T2T" \
  --run_medi false
```

## Full FORM pipeline with MEDI

The full command also needs a MEDI database and two MEDI food tables. Put their
absolute paths in `run.yaml`:

```yaml
medi_db: /absolute/path/to/medi-database
medi_food_matches: /absolute/path/to/food_matches.csv
medi_food_contents: /absolute/path/to/food_contents.csv
max_memory: 450.GB
```

Then run this command. It uses the hg39T2T directory created above:

```bash
nextflow run . -profile harvard_rc -params-file run.yaml \
  --readsdir "$PWD/fastqs" \
  --outdir "$PWD/results" \
  --host_genome "$PWD/databases/kneaddata/hg39T2T"
```

This command also runs MEDI. It does not run BAQLaVa or StrainPhlAn. Set
`run_viral_profiling: true` and `run_strain_profiling: true` in `run.yaml` to
run those optional branches.

The repository does not yet provide a download-and-run MEDI reference bundle.
The default MEDI images also use ARM. An x86 site must supply compatible
`medi_container` and `medi_biom_container` images. Therefore, only the
KneadData and MGX routes above are currently copy-and-run on Harvard FASRC.

The planned samplesheet and omixer-rpm modules are not implemented.

### DNAnexus launch

The DNAnexus interface has two launch inputs: `readsdir` and
`nextflow_params_file`. Put all other settings in the run YAML. Do not use
`-profile dnanexus` yet. The repository does not contain that profile. See the
[DNAnexus interface](docs/reference/dnanexus.md) for the deployment state.

## Parameters and limits

| Param | Default | Description |
|---|---|---|
| `--run_medi` | `true` | Quantify foods with MEDI |
| `--medi_input` | `humann` | Reads MEDI classifies: `humann` (HUMAnN 4 nucleotide-unaligned reads) or `kneaddata` (full cleaned reads, right after QC) |
| `--medi_db` | *required* | Full MEDI Kraken2/Bracken DB, including `taxo.k2d`, `taxonomy/` and 150 bp Bracken distributions |
| `--medi_food_matches` | *required* | MEDI food-to-taxon matches table, passed first to `quantify.R` |
| `--medi_food_contents` | *required* | MEDI food contents table, passed second to `quantify.R` |
| `--medi_container` | `colinbrislawn/medi:1.0.1` | Kraken2, Architeuthis, Bracken and MEDI tools (arm64; use `cdiener/medi:1.0.1` on x86) |
| `--medi_biom_container` | `colinbrislawn/metaphlan:4.2.4` | Python BIOM converter dependencies |
| `--medi_multiqc_container` | `ghcr.io/multiqc/multiqc:v1.22.3` | MultiQC |

FORM also changes two bioBakery defaults: `--workflow mgx` (the only one FORM
runs) and `--humann_version humann_v4a`. The `tufts_hpc` profile sets
`humann_v37`, so use `--medi_input kneaddata` there.

With `--medi_input humann`, don't pass `--remove-temp-output` in
`--humann_options` or bypass the nucleotide search: MEDI consumes
`<sample>_humann_temp/<sample>_bowtie2_unaligned.fa`. These are already QC'd,
single-end reads, so MEDI skips fastp. Both input modes give the same food
calls; Kraken2 is about 3× faster on HUMAnN's leftovers. The run stops before
profiling if any of this is misconfigured.

Outputs under `<outdir>/medi/`: per-sample Kraken2 reports and filtered
mappings, D/G/S Bracken counts, merged taxonomy and lineage counts,
`food_abundance.csv`, `food_content.csv`, three BIOM tables under `biom/`, and
`multiqc_report.html`.

The full Kraken2 database needs about **415 GB RAM**; raise `--max_memory`
above bioBakery's 128 GB default on a node that has it. The two kinds of MEDI
input reach tasks differently:

- `--medi_db` is read in place, not staged. The path must exist inside every
  task: a shared filesystem, a bind mount, or synced to each cloud worker.
- `--medi_food_matches` and `--medi_food_contents` are staged from where
  Nextflow runs: a local path on the launch node, or `s3://` / `https://`.

## How bioBakery's paths resolve

bioBakery's modules find their scripts and assets through `${projectDir}`,
which is this repo's root. Instead of editing bioBakery, `assets` links to
`biobakery/assets`, and `bin/` holds one link per entry of `biobakery/bin`
next to FORM's own scripts. After bumping the submodule:

```bash
git -C biobakery fetch && git -C biobakery checkout <upstream commit>
tests/check_links.sh --fix
```

## Tests

```bash
tests/check_links.sh     # links into biobakery/ complete, none dangling
tests/run_guards.sh      # every bad parameter combination stops the run
nextflow run tests/medi_stub.nf -stub-run -c tests/stub.config --outdir /tmp/medi-stub
```

CI (`.github/workflows/ci.yml`) runs these, plus a `-preview` of the full
MGX + MEDI graph in both input modes and a real `--check_inputs_only` run.
