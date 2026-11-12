# form-nextflow-pipeline

Bioinformatics pipeline for FORM: the [bioBakery](https://github.com/biobakery/biobakery-nextflow)
MGX workflow (KneadData → MetaPhlAn → HUMAnN 4), followed by
[MEDI](https://github.com/Gibbons-Lab/medi) food DNA quantification.

bioBakery is a git submodule (`biobakery/`) pinned to an upstream commit and
used unmodified. Design and rationale: [docs/specs/0001-biobakery-dependency-and-medi.md](docs/specs/0001-biobakery-dependency-and-medi.md).

## Getting it

```bash
git clone --recurse-submodules https://github.com/gutz-technologies/form-nextflow-pipeline.git
# or, in an existing clone:
git submodule update --init
```

`nextflow run gutz-technologies/form-nextflow-pipeline` fetches the submodule
too (`manifest.recurseSubmodules`).

## Running

Everything bioBakery's MGX workflow takes works the same way (see
`biobakery/README.md`): profiles, `--readsdir`, database params, `-params-file`.
FORM adds MEDI, on by default:

```bash
nextflow run . -profile harvard_rc --readsdir /path/to/fastqs --outdir results \
  --medi_db /path/to/medi-db \
  --medi_food_matches /path/to/food_matches.csv \
  --medi_food_contents /path/to/food_contents.csv \
  --max_memory 450.GB
```

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
