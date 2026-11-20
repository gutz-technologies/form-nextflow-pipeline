# DNAnexus interface

FORM will use **one `dnanexus` profile** for the entire pipeline, extending the
existing bioBakery deployment settings with the resources, containers, and
reference access required by FORM-owned modules.

## Launch inputs

| Input | Meaning |
| --- | --- |
| `readsdir` | Folder containing the reads, such as `dx://project-id:/inputs/reads` |
| Run YAML | File supplied through the platform's built-in `nextflow_params_file` input |

FORM's root `nextflow_schema.json` exposes only `readsdir`. The YAML input is
provided by DNAnexus itself; it is not a duplicate pipeline parameter in the
schema. Tool switches, database selection, containers, and resource overrides
belong in the YAML or bundled defaults. The schema does not expose a samplesheet
input. DNAnexus may also present its own execution controls, such as cache/resume
and destination settings.

The [samplesheet builder](../stages/01-samplesheet.md) is the planned first FORM
module. It will turn the folder into explicit read assignments before bioBakery
starts. That handoff still requires the upstream workflow input interface.

## Packaging and reference access

Build the FORM source tree with its populated, pinned `biobakery/` dependency.
The applet must contain every imported workflow, included config, helper script,
and linked asset. A Git submodule declaration alone is not the dependency's
source payload.

Database URIs and container-visible paths are different things. The profile
must stage the selected references on the workers and expose the paths expected
by each tool. In particular, MEDI currently reads its database directly from
`medi_db`; a project URI in the YAML alone does not implement that staging.

The program-selected KneadData host reference is
[hg39T2T / GCA_009914755.4, Bowtie2 bundle v0.2](kneaddata-host.md).
The single FORM site configuration must point to that verified index directory;
legacy `hg37dec` settings in the neighboring deployment are not the selected
FORM reference. Changing the documentation alone does not update an applet.

## Current state

The minimal schema is present. The single-profile FORM configuration, packaging,
samplesheet module, updated bioBakery pin, and combined deployment validation
remain implementation work. The [version inventory](versions.md) and
[database catalog](databases.md) document available evidence and gaps while that
work proceeds; they do not claim a successful platform execution.

See DNAnexus's [Nextflow build and run guide](https://documentation.dnanexus.com/user/running-apps-and-workflows/running-nextflow-pipelines)
for the platform's parameter-file input, source-folder requirements, and native
execution controls.
