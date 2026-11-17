# Spec 0001: bioBakery as a dependency, plus MEDI

- **Status:** In progress (FORM PR + upstream bioBakery PR drafted 2026-11-12)
- **Date:** 2026-11-12
- **Supersedes:** gutz-technologies/biobakery-nextflow#1 (Colin Brislawn, `feature/medi`)
- **Upstream:** biobakery/biobakery-nextflow (Sagun's PR #33 merged 2026-11-02, head `576718d`)

## 1. Goal

`form-nextflow-pipeline` becomes the FORM pipeline: the bioBakery MGX workflow
(KneadData → MetaPhlAn → HUMAnN 4 → reports), used unmodified as a pinned
dependency, followed by MEDI food DNA quantification as an extra stage owned by
this repo.

Colin's MEDI work in biobakery-nextflow#1 moves here. The
`gutz-technologies/biobakery-nextflow` fork is retired: FORM depends on upstream
`biobakery/biobakery-nextflow` directly, and **bioBakery's files are not
rewired**. Syncing with bioBakery means bumping the submodule commit.

### Non-goals

- Changing bioBakery's profiling logic or defaults.
- MTX / MGX+MTX / 16S / assembly in FORM. They stay reachable through the
  submodule but FORM neither wires nor tests them.
- The human reference (T2T) pin. That stays a separate bioBakery PR
  (`feature/pin-t2t-host`).

## 2. Current state

| Repo | State |
|---|---|
| `form-nextflow-pipeline` | Empty: `README.md`, `LICENSE`, `.gitignore` (commit `2034fff`). |
| `biobakery/biobakery-nextflow` `main` | Includes PR #33 (standard bioBakery workflow). |
| `gutz-technologies/biobakery-nextflow` | Fork, 50 commits behind upstream `main`. **To be archived** once PR #1 is ported. |
| `gutz-technologies/biobakery-nextflow` `feature/medi` (PR #1) | 8 commits on `8489d04` (PR #33 mid-review). A rebase on upstream `main` conflicts in `main.nf` only. All Bugbot findings fixed (`25637ad`, `6891fc0`). Stub runs pass; 16 SRP662258 samples ran on AWS Batch in both input modes. |

### What PR #1 changes, by destination

| PR #1 path | Kind | Destination |
|---|---|---|
| `modules/medi/**` (9 modules) | MEDI | **FORM** `modules/medi/**` |
| `subworkflows/medi.nf` | MEDI | **FORM** `subworkflows/medi.nf` |
| `bin/medi_csv_to_biom.py` | MEDI | **FORM** `bin/` |
| `conf/params.config` MEDI block | MEDI | **FORM** `conf/params.config` |
| `conf/base.config` `medi_kraken` / `medi_low` labels | MEDI | **FORM** `conf/base.config` |
| `main.nf` MEDI guards | MEDI | **FORM** `main.nf` |
| `workflows/mgx.nf` MEDI block | MEDI wiring | **FORM** `workflows/form.nf`, fed from `MGX.out` (section 5.2) |
| `modules/{kneaddata,metaphlan,humann,utils/humann_*}` `stub:` blocks (`8dd2ddc`) | Generic | **Upstream** PR U3 (optional) |
| `modules/humann` `unaligned_reads` output + `FUNCTIONAL_PROFILING` emit (`58649e8`) | Generic | **Upstream** PR U1 |
| `README.md`, `HISTORY.md`, `docs/**`, `tests/README.md` MEDI parts | Docs | **FORM** `README.md`, `docs/`, `tests/` |
| `bin/make_diagrams.py`, `docs/diagrams/*.mmd` | Diagrams | Not ported. FORM draws its own diagram later (optional). |

## 3. Dependency mechanism

**Decision: a git submodule at `biobakery/` → `https://github.com/biobakery/biobakery-nextflow.git`, pinned to an exact upstream commit. No fork.**

```
form-nextflow-pipeline/
├── biobakery/            submodule → biobakery/biobakery-nextflow @ <sha>
├── main.nf
├── nextflow.config
├── workflows/form.nf
├── subworkflows/medi.nf
├── modules/medi/...
├── bin/                  real dir: FORM scripts + symlinks into biobakery/bin/* (5.4)
├── assets -> biobakery/assets      symlink (5.4)
├── conf/
│   ├── params.config     FORM params (MEDI) and FORM overrides of bioBakery defaults
│   ├── base.config       MEDI resource labels
│   └── profiles/         FORM additions only, e.g. AWS MEDI DB paths
├── tests/
└── docs/
```

Nextflow resolves `include { X } from './biobakery/...'` relative to the
including file, so FORM can import bioBakery workflows and subworkflows
directly. With `manifest.recurseSubmodules = true`, `nextflow run
gutz-technologies/form-nextflow-pipeline -r <tag>` clones the submodule too.

Alternatives considered:

| Option | Why not |
|---|---|
| Vendor (copy) bioBakery into FORM | Drifts at once, and upstream fixes have to be re-copied by hand. |
| nf-core `modules.json` / `nf-core modules install` | bioBakery is not an nf-core module repo. |
| Run bioBakery and FORM as two pipelines chained through `outdir` | Two launches, no shared `-resume`, MEDI can't use HUMAnN's temp reads without publishing them, and twice the config. |
| Merge MEDI into the bioBakery fork (PR #1 as is) | Keeps a fork alive. FORM work ends up in a repo FORM doesn't own. |
| Pin the submodule to the gutz fork | Fork is being retired. Every sync becomes a fork rebase. |

**Syncing with bioBakery:** `git -C biobakery fetch && git -C biobakery checkout <new upstream sha>`,
commit the bump, CI runs. Nothing else to touch unless upstream adds a new
top-level entry under `bin/` (CI catches that, 5.4).

## 4. Changes needed in bioBakery (upstream PRs)

**No path rewiring.** `${projectDir}` stays as is in bioBakery; FORM makes those
paths resolve with symlinks (5.4).

What FORM still needs from upstream is two small changes, both
behaviour-neutral for standalone bioBakery runs. They go to
`biobakery/biobakery-nextflow` as **one PR**, whose branch is pushed to the
gutz fork. The fork is only the vehicle for that PR, since we can't push to
upstream, and it is archived afterwards.

### U1. HUMAnN's nucleotide-unaligned reads (required for `medi_input humann`)
Colin's commit `58649e8`: an optional `unaligned_reads` output on the `humann`
process and an `unaligned_reads` emit on `FUNCTIONAL_PROFILING`. About 3 lines.
There is no way to get these reads from outside the module: they are an
undeclared file in HUMAnN's temp folder.

### U2. `emit:` block on `workflows/mgx.nf` (required)
Today `MGX` emits nothing, so FORM can't reach its channels. Add:

```nextflow
emit:
cleaned           = cleaned                                   // [meta, reads]
read_counts       = params.run_qc ? QUALITY_CONTROL.out.read_counts : Channel.empty()
taxonomic_profile = params.run_taxonomic_profiling ? TAXONOMIC_PROFILING.out.profile : Channel.empty()
unaligned_reads   = params.run_functional_profiling ? FUNCTIONAL_PROFILING.out.unaligned_reads : Channel.empty()
```

The `--check_inputs_only` early `return` has to go. Tested on Nextflow
24.10: a workflow with an `emit:` block that returns early fails with `Missing
workflow output parameter`, even when the caller never reads `.out`. So
bioBakery's own `--check_inputs_only` run would break. The fix is to default
the emits to `Channel.empty()` and wrap the profiling steps in
`if (!params.check_inputs_only) { ... }`. Apart from that it's an indentation
change (`git diff -w` shows 24 lines).

### U3. Stub blocks for MGX modules (optional, for CI)
Colin's commit `8dd2ddc`: adds `stub:` sections only. Without it, FORM CI can
do `-preview` (DAG only) but not `-stub-run` through MGX.

### Fallback if upstream is slow to merge
- Without U2: FORM keeps its own `FORM_MGX` workflow that composes the upstream
  subworkflows (`read_input`, `CHECK_INPUTS`, `QUALITY_CONTROL`,
  `TAXONOMIC_PROFILING`, `FUNCTIONAL_PROFILING`, `REPORTING`): about 100 lines
  copied from `mgx.nf`. It's a sync cost, so delete it once U2 lands.
- Without U1: only `medi_input kneaddata` is available.

### Not upstreamed: parameter validation
bioBakery's guards live inline in its `main.nf` `workflow {}` block and can't be
imported. FORM re-implements the few MGX guards it needs (`--readsdir`
required, `check_inputs_only` consistency) next to the MEDI guards.

## 5. FORM pipeline design

### 5.1 Config layering (`nextflow.config`)

```groovy
manifest {
    name              = 'form-nextflow-pipeline'
    mainScript        = 'main.nf'
    nextflowVersion   = '>=24.04.0'   // match bioBakery
    recurseSubmodules = true
}

// 1-3: bioBakery defaults, unmodified
includeConfig 'biobakery/conf/params.config'
includeConfig 'biobakery/conf/base.config'
includeConfig 'biobakery/conf/reports.config'

// 4: FORM defaults and overrides (MEDI params)
includeConfig 'conf/params.config'
includeConfig 'conf/base.config'

profiles {
    local      { includeConfig 'biobakery/conf/profiles/local.config' }
    harvard_rc { includeConfig 'biobakery/conf/profiles/harvard_rc.config'
                 includeConfig 'biobakery/conf/databases/harvard_rc.config' }
    tufts_hpc  { includeConfig 'biobakery/conf/profiles/tufts_hpc.config'
                 includeConfig 'biobakery/conf/databases/tufts.config' }
    amazon     { includeConfig 'biobakery/conf/profiles/aws.config'
                 includeConfig 'conf/profiles/aws.config' }   // MEDI DB, arm64 images
}
```

Precedence stays as bioBakery documents it: params file and then CLI override
everything.

### 5.2 Workflow (`workflows/form.nf`)

```nextflow
include { MGX  } from '../biobakery/workflows/mgx.nf'
include { MEDI } from '../subworkflows/medi.nf'

workflow FORM {
    MGX()
    if (params.run_medi) {
        medi_reads = params.medi_input == 'kneaddata'
            ? MGX.out.cleaned.map { meta, r -> tuple(meta.id, r) }
            : MGX.out.unaligned_reads
        MEDI(medi_reads, '')
    }
}
```

`main.nf` holds the guards (the MGX guards from "Not upstreamed" in section 4, plus PR #1's MEDI guards
unchanged: `medi_input` ∈ {humann, kneaddata}, `humann_v4a` required for the
humann input, no `--remove-temp-output`, no nucleotide-search bypass, required
`medi_db` / `medi_food_matches` / `medi_food_contents`), then calls `FORM()`.
`--workflow` is fixed to `mgx`. Any other value is an error.

### 5.3 Defaults that differ from bioBakery

| Param | bioBakery | FORM | Why |
|---|---|---|---|
| `run_medi` | n/a | `true` | MEDI is the reason this pipeline exists. |
| `medi_input` | n/a | `humann` | Same food calls as `kneaddata`. Kraken2 runs about 3× faster on HUMAnN's leftover reads (PR #1 AWS run). |
| `humann_version` | site default | `humann_v4a` | Required by `medi_input humann`. |

### 5.4 Resolving bioBakery's `projectDir` paths with symlinks
With bioBakery as a submodule, `projectDir` is the FORM root. bioBakery uses it
in three ways, and FORM's layout satisfies all three without editing bioBakery:

| bioBakery expects | Used for | FORM provides |
|---|---|---|
| `${projectDir}/assets/NO_FILE` | Placeholder input in `workflows/*.nf`, `version_log`, MEDI stubs | `assets -> biobakery/assets` |
| `${projectDir}/bin/scripts/*.py`, `bin/Rscripts/*.R`, `bin/lib/` | ~20 vis/stats/assembly modules | `bin/scripts -> ../biobakery/bin/scripts`, same for `Rscripts`, `lib` |
| Bare `check_fastq_inputs.py` on the task PATH | `check_reads` | `bin/check_fastq_inputs.py -> ../biobakery/bin/check_fastq_inputs.py` |

`bin/` stays a real directory so FORM's own scripts (`medi_csv_to_biom.py`)
sit beside the symlinks. All links are relative, so they work wherever the
repo is cloned.

**Verified on 2026-11-12** (Nextflow 24.10.0, upstream `576718d`, local
executor): a FORM-layout prototype ran upstream `read_input` + `CHECK_INPUTS`
unmodified on `biobakery/tests/data/rawfastq` (both samples passed the check).
A process in the same run executed a FORM-owned `bin/` script, ran
`${projectDir}/bin/scripts/transpose_table.py`, and found
`${projectDir}/assets/NO_FILE`.

**Still to verify:**
- `nextflow run gutz-technologies/form-nextflow-pipeline` (remote clone via JGit)
  keeps the symlinks and submodule. Do this in the scaffold PR's CI.
- AWS Batch: Nextflow uploads `bin/` for cloud executors. Check that it follows
  the symlinks. bioBakery's absolute `${projectDir}/bin/scripts/...` calls
  (vis/stats) already need the pipeline dir on workers there, so that part
  of the AWS gap isn't new. The MGX + MEDI path only needs `bin/` on PATH.

**Sync guard (CI):** a check that every top-level entry in `biobakery/bin/`
has a matching symlink in `bin/`, and that no symlink dangles. A short script
`tests/check_links.sh` regenerates the links after a submodule bump.

## 6. Porting Colin's work

Keep authorship with `git format-patch` limited to the MEDI paths. PR #1 uses
the same paths in both repos, so the patches apply without rewriting:

```bash
# in biobakery-nextflow, on feature/medi
git format-patch 8489d04..6891fc0 -o /tmp/medi-patches -- \
    modules/medi subworkflows/medi.nf bin/medi_csv_to_biom.py

# in form-nextflow-pipeline
git am /tmp/medi-patches/*.patch
```

Commits that also touched shared files (`conf/*.config`, `main.nf`,
`workflows/mgx.nf`, docs) are ported by hand in one follow-up commit with
`Co-authored-by: Colin J. Brislawn`. Keep Colin's eight commit messages
in the PR description for history.

Once FORM has the port, close gutz biobakery-nextflow#1 with a link to the FORM
PR and the upstream U1/U2 PRs, then archive the gutz fork. First check that its
other branches (`feature/pin-t2t-host`, `feature/nexus-aws-addons`,
`feature/HVP-workflow`, `feature/sra`, ...) are upstreamed or deliberately
dropped.

## 7. Delivery plan

| # | Repo | PR | Contents | Done when |
|---|---|---|---|---|
| 1 | upstream biobakery-nextflow (branch on gutz fork) | U1+U2 | HUMAnN unaligned output, `MGX` emit. U3 stubs deferred. | Upstream CI passes; standalone MGX and `--check_inputs_only` unchanged. |
| 2+3 | FORM (one PR) | Scaffold + MEDI port | Submodule pinned to the upstream PR head, symlinks, config, `main.nf`, `workflows/form.nf`, Colin's MEDI commits, guards, tests, CI. `run_medi = true`. No `FORM_MGX` copy: the pin already has U2. | CI green: links, profiles, `-preview` in both MEDI modes, real `--check_inputs_only`, 11 guard cases, MEDI stub run. |
| 4 | FORM | Validation | Re-run the 16 SRP662258 samples on AWS Batch. | Food CSVs and BIOMs match the PR #1 run. Symlinked `bin/` works on Batch. |
| 5 | FORM | Re-pin | Submodule to the merged upstream commit with U1/U2. | Pin is on upstream `main`. |
| 6 | gutz fork | Archive | Close PR #1, archive the repo. | Nothing references it. |

Steps 1 and 2+3 go in parallel. The FORM PR stays draft until the upstream
PR merges and the submodule is re-pinned to the merged commit (step 5).

### CI (FORM)
GitHub Actions with `actions/checkout` `submodules: recursive`,
`nf-core/setup-nextflow@v2`, then:
- `nextflow config -profile <p>` for each profile
- `nextflow run . -stub-run` for both `medi_input` modes, using the bioBakery test
  fixtures (`biobakery/tests/data/rawfastq`)
- a guard matrix: each invalid params combination must exit non-zero with the
  expected message
- a check that the submodule SHA is reachable on upstream
- the symlink sync guard (5.4)

## 8. Open questions

1. **Containers.** `colinbrislawn/medi:1.0.1` and `colinbrislawn/metaphlan:4.2.4`
   are arm64-only. Upstream `cdiener/medi:1.0.1` is amd64. Build multi-arch
   images under a gutz org namespace, or pick the image per profile?
2. **MEDI DB on AWS.** `medi_db` is read in place (about 415 GB RAM for
   Kraken2) and must exist on every node. Should it be an EFS/FSx mount in the
   AWS profile, or a pre-baked AMI?
3. **Upstream turnaround.** How fast will Sagun's team review U1/U2? Until
   they merge, FORM is pinned to an unmerged PR commit.
4. ~~Default `run_medi`~~: decided `true`.
5. **Placement.** Keep both `medi_input` modes, or drop `kneaddata` to shrink
   the guard surface? Colin's data shows the same food calls in both modes.
6. **Release coupling.** Should a FORM tag record the bioBakery version in
   `manifest.version` metadata (e.g. `1.0.0+bb0.0.4`)?
