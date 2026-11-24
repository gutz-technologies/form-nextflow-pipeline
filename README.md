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
cd form-nextflow-pipeline
```

In an existing checkout, run:

```bash
git submodule update --init --recursive
```

`nextflow run gutz-technologies/form-nextflow-pipeline` fetches the submodule
too (`manifest.recurseSubmodules`).

## Quick start: download hg39T2T and run KneadData

Run these commands in the same Bash shell from the repository root. Use
Linux x86-64 with at least 8 CPUs and 16 GB RAM. Install
[Docker Engine](https://docs.docker.com/engine/install/) and
[Nextflow](https://www.nextflow.io/docs/latest/install.html) (use Nextflow 24.10
with Java 17 or later). Run `docker info` to check that your user can access
Docker. You'll also need `wget`, `tar`, `md5sum`, and `sha256sum`.

FORM requires KneadData 0.12 or later, Bowtie2 2.5.5 or later, and the
hg39T2T host index. The run stops if `host_genome` lacks the
`GCA_009914755.4_T2T.*.bt2` files, or if a KneadData task reports an older
KneadData or Bowtie2.

### Where the images and databases come from

| Item | Pinned source | Pipeline parameter |
| --- | --- | --- |
| KneadData image | [ECR repository](https://gallery.ecr.aws/j5i5h1i5/kneaddata): `public.ecr.aws/j5i5h1i5/kneaddata@sha256:87f9fe73578cffa73d30e08c90099e1fdf69831c42778d3b2a7cd7791f8ae4b3` (package 0.12.1; CLI 0.12.0; Bowtie2 2.5.5) | set by `-profile form_docker` |
| MetaPhlAn image | [ECR repository](https://gallery.ecr.aws/j5i5h1i5/metaphlan): `public.ecr.aws/j5i5h1i5/metaphlan@sha256:bcbba3807ce7bbfda6526dd8598232025c9cc9a3f7689b9ad639dab9d8c81787` (MetaPhlAn 4.2.5) | set by `-profile form_docker` |
| HUMAnN image | [ECR repository](https://gallery.ecr.aws/j5i5h1i5/humann): `public.ecr.aws/j5i5h1i5/humann@sha256:3d245ae23c5b5015e6ca2a16b5963c0d178fd5f0786890e7eb57fa8cf7fe2acd` (HUMAnN 4.0.0a2) | set by `-profile form_docker` |
| Host index (hg39T2T) | [Homo_sapiens_hg39_T2T_Bowtie2_v0.2.tar.gz](https://huttenhower.sph.harvard.edu/kneadData_databases/Homo_sapiens_hg39_T2T_Bowtie2_v0.2.tar.gz), 3.9 GB, step 1 below | `--host_genome` |
| MetaPhlAn database | [`mpa_vOct22_CHOCOPhlAnSGB_202403.tar`](https://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/mpa_vOct22_CHOCOPhlAnSGB_202403.tar) and its [MD5 file](https://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/mpa_vOct22_CHOCOPhlAnSGB_202403.md5) | `--metaphlan_db` |
| HUMAnN 4 databases | Direct v4-alpha ChocoPhlAn, EC-filtered UniRef90, and utility-mapping archives in [MGX databases](#download-the-mgx-databases) | `--humann_db` |

The image versions come from the Hugemiler container set recorded in the
[software inventory](docs/reference/software-inventory.json). They take priority
over generic bioBakery defaults and site-module versions. Docker pulls each
image on its first run. The Docker Hub `biobakery/*` images are older and are
not FORM runtime images.

### 1. Download the FORM host reference

Copy and run this complete block. It downloads the 3.9 GB prebuilt Bowtie2
index, checks the downloaded archive, extracts it, and checks all six index
files. Keep at least 9 GB of disk space free. To store the database on an SSD
or reuse an existing copy, set `HOST_DIR` to its absolute directory path before
running the block. Use a path without spaces or commas.

```bash
export HOST_DIR="${HOST_DIR:-$(pwd -P)/databases/kneaddata/hg39T2T}"
(
  set -eu
  checksums="$(pwd -P)/docs/reference/checksums/kneaddata-hg39-t2t-v0.2.sha256"
  archive=Homo_sapiens_hg39_T2T_Bowtie2_v0.2.tar.gz
  url="https://huttenhower.sph.harvard.edu/kneadData_databases/$archive"
  mkdir -p "$HOST_DIR"
  cd "$HOST_DIR"
  if ! sha256sum --check --status "$checksums" 2>/dev/null; then
    wget -c "$url"
    wget -O "$archive.md5" "$url.md5"
    md5sum --check "$archive.md5"
    tar -xzf "$archive"
  fi
  sha256sum --check "$checksums"
)
```

Continue only when all six SHA256 checks report `OK`. Pass the directory
`$HOST_DIR` to `--host_genome`, not the archive or a single `.bt2` file.

### 2. Add the reads

To try FORM without bringing your own reads, use the two small paired-end
examples bundled with the bioBakery submodule:

```bash
export READS_DIR="$(pwd -P)/biobakery/tests/data/rawfastq"
```

For your own run, set `READS_DIR` to the absolute directory path of your
compressed FASTQs instead. Use paired filenames such as `sample_R1.fastq.gz`
and `sample_R2.fastq.gz`.

### 3. Run KneadData

This block uses the pinned KneadData image and mounts the host index
read-only, even if you keep it outside the repository.

```bash
tee kneaddata-docker.config >/dev/null <<'EOF'
docker.runOptions = '-u $(id -u):$(id -g) -e DXFUSE_ENABLED=false --mount type=bind,source=' + System.getenv('HOST_DIR') + ',target=' + System.getenv('HOST_DIR') + ',readonly'
EOF

NXF_VER=24.10.4 nextflow -c kneaddata-docker.config run . -profile local,form_docker \
  --readsdir "$READS_DIR" \
  --outdir "$PWD/kneaddata-results" \
  --host_genome "$HOST_DIR" \
  --run_qc true \
  --run_taxonomic_profiling false \
  --run_functional_profiling false \
  --run_viral_profiling false \
  --run_strain_profiling false \
  --run_medi false \
  --run_vis false \
  --run_stats false
```

### 4. Open the results

Find the cleaned reads and per-sample logs in `kneaddata-results/kneaddata/`.
Nextflow runs `kneaddata_read_count_table` and writes a TSV. Check its header
and first two rows:

```bash
head -n 3 kneaddata-results/kneaddata/merged/kneaddata_read_count_table.tsv
```

Expect a `Sample` column and one row per sample. For the human-reference
alignment count and percentage, see
[Find the host-read count and fraction](docs/stages/02-kneaddata.md#find-the-host-read-count-and-fraction).

The Nextflow run log must show these two lines:

```text
Version check: kneaddata 0.12.0 >= 0.12 (...)
Version check: bowtie2 2.5.5 >= 2.5.5 (...)
```

Use `local,form_docker` for the locked FORM versions. The `harvard_rc`,
`tufts_hpc`, and `amazon` profiles are inherited bioBakery site profiles. They
select different tools or databases and are not the canonical FORM runtime.

#### What `form_docker` sets

- It pins the KneadData, MetaPhlAn, and HUMAnN images by digest.
- It sets `DXFUSE_ENABLED=false`. The images try to mount DNAnexus storage
  when they start. Without this setting, every task fails with
  `DNAnexus references: set DX_REFERENCE_PROJECT or forward DX_PROJECT_CONTEXT_ID`.
- It runs each container as your user (`-u $(id -u):$(id -g)`).
- It gives each KneadData task 8 CPUs and sets `kneaddata_options` to
  `--threads 8 --processes 1`. This gives Bowtie2 and Trimmomatic the task's
  threads without multiplying the allocation across eight internal processes.

`form_docker` does not supply the visualization report tools. Add
`--run_vis false`, or supply those tools through the site profile.

## Download the MGX databases

Run this block from the repository root. It uses direct, range-tested download
URLs instead of the tool installers. Keep at least 220 GB of disk space free for
the archives and extracted databases.

```bash
set -euo pipefail

DB="$(pwd -P)/databases"
DOWNLOADS="$DB/downloads"
MPA="mpa_vOct22_CHOCOPhlAnSGB_202403"
mkdir -p "$DOWNLOADS" "$DB/metaphlan" \
  "$DB/humann/chocophlan" "$DB/humann/uniref" "$DB/humann/utility_mapping"

MPA_URL="https://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases"

wget -c -P "$DOWNLOADS" \
  "$MPA_URL/$MPA.tar" "$MPA_URL/$MPA.md5" \
  "$MPA_URL/bowtie2_indexes/${MPA}_bt2.tar" "$MPA_URL/bowtie2_indexes/${MPA}_bt2.md5" \
  "https://huttenhower.sph.harvard.edu/humann_data/chocophlan/chocophlan.v4_alpha.tar.gz" \
  "https://huttenhower.sph.harvard.edu/humann_data/uniprot/uniref_ec_filtered/uniref90_annotated_v4_alpha_ec_filtered.tar.gz" \
  "https://huttenhower.sph.harvard.edu/humann_data/full_mapping_v4_alpha.tar.gz"

(cd "$DOWNLOADS" && md5sum --check "$MPA.md5" && md5sum --check "${MPA}_bt2.md5")
gzip -t "$DOWNLOADS/chocophlan.v4_alpha.tar.gz"
gzip -t "$DOWNLOADS/uniref90_annotated_v4_alpha_ec_filtered.tar.gz"
gzip -t "$DOWNLOADS/full_mapping_v4_alpha.tar.gz"

tar -xf "$DOWNLOADS/$MPA.tar" -C "$DB/metaphlan"
tar -xf "$DOWNLOADS/${MPA}_bt2.tar" -C "$DB/metaphlan"
tar -xzf "$DOWNLOADS/chocophlan.v4_alpha.tar.gz" -C "$DB/humann/chocophlan"
tar -xzf "$DOWNLOADS/uniref90_annotated_v4_alpha_ec_filtered.tar.gz" -C "$DB/humann/uniref"
tar -xzf "$DOWNLOADS/full_mapping_v4_alpha.tar.gz" -C "$DB/humann/utility_mapping"

test -f "$DB/metaphlan/$MPA.pkl"
test -n "$(find "$DB/metaphlan" -name "${MPA}*.bt2l" -print -quit)"
```

MetaPhlAn needs **two** archives for one index: the `.tar` holds the marker
metadata (`.pkl`, marker FASTA) and `bowtie2_indexes/..._bt2.tar` holds the
Bowtie2 index. Both have a distributor MD5 file. These are the same URLs the
MetaPhlAn database installer uses. The HUMAnN source server does not publish
checksum sidecars for the three v4-alpha archives; `gzip -t` detects incomplete
downloads but does not establish provenance. The
[database inventory](docs/reference/databases.md) keeps their SHA256 status
pending until verified hashes are available.

Run the locked MGX pipeline with Docker:

```bash
nextflow run . -profile local,form_docker \
  --readsdir "$PWD/fastqs" \
  --outdir "$PWD/results" \
  --host_genome "$PWD/databases/kneaddata/hg39T2T" \
  --metaphlan_db "$PWD/databases/metaphlan" \
  --humann_db "$PWD/databases/humann" \
  --run_medi false --run_vis false
```

This route uses MetaPhlAn 4.2.5 with
`mpa_vOct22_CHOCOPhlAnSGB_202403` and HUMAnN 4.0.0a2.

## Full FORM pipeline with MEDI

The repository does not yet provide an accessible, versioned MEDI database
bundle or both tested x86 MEDI images. The current default MEDI images are ARM.
Do not present the MEDI branch as copy-and-run on an x86 workstation or Harvard
FASRC until those artifacts are published and verified.

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

FORM changes the generic bioBakery defaults to `--workflow mgx`,
`--humann_version humann_v4a`, and MetaPhlAn index
`mpa_vOct22_CHOCOPhlAnSGB_202403`. The inherited `tufts_hpc` profile selects
HUMAnN 3.7 and a different MetaPhlAn index, so it is not a FORM-locked profile.

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
tests/check_links.sh                   # bioBakery links are complete
python3 tests/check_form_version_lock.py # config and docs match the FORM lock
tests/run_guards.sh                    # bad parameter combinations stop the run
nextflow run tests/medi_stub.nf -stub-run -c tests/stub.config --outdir /tmp/medi-stub
```

CI (`.github/workflows/ci.yml`) runs these, plus a `-preview` of the full
MGX + MEDI graph in both input modes and a real `--check_inputs_only` run.
