# KneadData host reference: hg39T2T

**Program decision:** FORM uses the human **hg39T2T** reference for KneadData
host depletion. The selected prebuilt Bowtie2 index is the Huttenhower Lab
**v0.2** bundle derived from GenBank assembly **GCA_009914755.4**.

## Reference identity

| Field | Selected value |
| --- | --- |
| Program reference label | `hg39T2T` |
| Organism | *Homo sapiens* |
| Original assembly accession | `GCA_009914755.4` |
| NCBI assembly name | `T2T-CHM13v2.0` |
| Index distributor | Huttenhower Lab, KneadData database collection |
| Distributed archive | `Homo_sapiens_hg39_T2T_Bowtie2_v0.2.tar.gz` |
| Index prefix | `GCA_009914755.4_T2T` |
| Index format | Six-file Bowtie2 `.bt2` index |
| Index-builder software version | Not supplied with the checksum record; separate from the runtime Bowtie2 version |
| Runtime Bowtie2 in inspected image | **2.5.5** |

Download the [prebuilt Bowtie2 index archive](https://huttenhower.sph.harvard.edu/kneadData_databases/Homo_sapiens_hg39_T2T_Bowtie2_v0.2.tar.gz).
The original genome source is the
[NCBI GenBank assembly GCA_009914755.4](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_009914755.4/).
Assembly identity was also checked using the
[NCBI Datasets assembly report](https://api.ncbi.nlm.nih.gov/datasets/v2/genome/accession/GCA_009914755.4/dataset_report).
The prebuilt index, source assembly, and runtime aligner are recorded separately
so a later software upgrade does not silently redefine the host reference.

## SHA256 manifest

These six expected checksums were **provided by the program owner on
2026-11-19**. They identify extracted index members. They have not been
independently checked against the deployment files during this documentation
update. An SHA256 for the compressed archive was not supplied.

Download the ready-to-use
[SHA256 manifest](checksums/kneaddata-hg39-t2t-v0.2.sha256).

| Extracted file | Expected SHA256 |
| --- | --- |
| `GCA_009914755.4_T2T.1.bt2` | `31e72a1d368f8bbc29a0cc1359db2e62d2b624a9371d7b1e75fc8d72dbb295af` |
| `GCA_009914755.4_T2T.2.bt2` | `d3962bc9e65a7a80fd3af9f883914cb2bad804192bb1a0e448bae218cbfa00d3` |
| `GCA_009914755.4_T2T.3.bt2` | `5cf938e8402a908b5cd5be380c7a3850a5630ee5a3f33d0a50abbf6793e3bc30` |
| `GCA_009914755.4_T2T.4.bt2` | `aeaba4a2c9cf171e152e5e21e9679f931ffab6a110bffd85fffd396b18cd03e6` |
| `GCA_009914755.4_T2T.rev.1.bt2` | `789f9666a2934a141ea2ea631a543c6572a25528b6e1cc159c13c665c7ac59d6` |
| `GCA_009914755.4_T2T.rev.2.bt2` | `d531e13fa16aa719884513f71b660f99788d40fb3c0040d74e55fa27910291b5` |

After extracting the archive, change to the directory containing all six files
and run, using the absolute path to a FORM checkout:

```bash
sha256sum --check /path/to/form-nextflow-pipeline/docs/reference/checksums/kneaddata-hg39-t2t-v0.2.sha256
```

All six lines must report `OK`. This checks the named files; it does not reject
extra files in the directory. Keep this host index in its own directory so
KneadData does not discover additional complete host indexes there. Record the
verification result alongside the DNAnexus reference artifact and run provenance.

## Runtime placement

The site configuration supplies the directory containing the verified index.
For example, a dedicated container-visible path could be:

```yaml
host_genome: /Databases/kneaddata/hg39T2T
kneaddata_db_location: container
kneaddata_database_identity: hg39T2T / GCA_009914755.4 / Bowtie2 v0.2 bundle
```

This path is illustrative; the production site must stage the selected bundle
at its configured path. With `kneaddata_db_location: host`, Nextflow instead
stages the configured directory as a normal process input. `container` means
the path is already visible inside the task, whether supplied by a read-only
worker bind or included in an image.

Older neighboring deployment recipes/configurations still mention `hg37dec`.
Those are legacy settings and do not define the FORM program reference. Updating
this documentation does not replace their data or reconfigure an existing applet.
The FORM site configuration must select hg39T2T when the deployment is completed.

The inspected workflow checks reference-path availability but does not yet run
this SHA256 manifest automatically. `kneaddata_database_identity` is a log label,
not an integrity check. See [KneadData runtime flags](../stages/02-kneaddata.md#runtime-flags-and-precedence)
for the actual command-line and tool defaults.
