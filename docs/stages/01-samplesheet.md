# 1. Samplesheet building

The first FORM module will discover reads from the supplied folder, pair mates,
validate assignments, and emit a samplesheet for bioBakery. Users supply the
reads folder and run YAML; the generated CSV is an output of the workflow.

**State:** the helper exists in the neighboring bioBakery checkout. Its conversion
to a FORM process and the bioBakery channel-input handoff are still pending.

## Software and major dependencies

| Component | Version or identity | Evidence |
| --- | --- | --- |
| `build_samplesheet.py` | Source snapshot SHA256 below | Inspected bioBakery helper; no independent package release |
| Python | Exact production version pending | Standard-library CSV, JSON, regex, pathlib, and subprocess modules |
| DNAnexus `dx` CLI | Exact worker version pending | Required for project-folder discovery; not required for local folder discovery |
| Nextflow | See [shared runtime](../reference/versions.md#shared-runtime) | FORM will own the process wrapper |

Helper SHA256, measured on 2026-11-19:

```text
5d4f71cb8555ad27f87399c249b2028353d0997fff23ffffa4adb1f5d6f8a411
```

The source snapshot came from `biobakery-nextflow/bin/build_samplesheet.py` in
the neighboring checkout at HEAD `88144cda85ce4a191681299b37bbfa07dcb3282d`.
The [source inventory](../reference/software-inventory.json) records the file
digest so a future port can be compared with this baseline.

## Inputs and outputs

The existing helper recognizes compressed `.fastq.gz` and `.fq.gz` files and
`_R1`/`_R2` mate names, optionally followed by `_001`. It supports alternate
pairing expressions, single-end libraries, and recursive discovery. The FORM
wrapper will keep those controls in the YAML rather than exposing extra launch
fields.

The CSV columns are `sample,assay,read_1,read_2`; single-end rows leave `read_2`
empty. Missing mates, duplicate sample IDs, unsafe IDs, and repeated read
assignments must stop the workflow before profiling starts.

## Databases and checksums

**External reference database: not applicable.** The generated samplesheet is
run-specific. Record its SHA256 alongside the run YAML and the resolved read
references. Read content checksums, when available, belong in the run provenance;
they are separate from the samplesheet checksum.

## Integration handoff

The generated manifest must feed a workflow input channel. Changing a global
parameter after a task completes is not a reliable handoff. bioBakery needs an
importable workflow accepting explicit reads or a samplesheet channel before
FORM can use this module as its entry stage.
