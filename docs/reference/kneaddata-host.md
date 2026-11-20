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
The distributor also publishes an
[MD5 file for the archive](https://huttenhower.sph.harvard.edu/kneadData_databases/Homo_sapiens_hg39_T2T_Bowtie2_v0.2.tar.gz.md5).
The original genome source is the
[NCBI GenBank assembly GCA_009914755.4](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_009914755.4/).
Assembly identity was also checked using the
[NCBI Datasets assembly report](https://api.ncbi.nlm.nih.gov/datasets/v2/genome/accession/GCA_009914755.4/dataset_report).
The prebuilt index, source assembly, and runtime aligner are recorded separately
so a later software upgrade does not silently redefine the host reference.

## SHA256 manifest

These six expected checksums were **provided by the program owner on
2026-11-19**. They identify extracted index members. On **2026-11-20** the
archive was downloaded from the link above. It matched the distributor's MD5
(`b0323c21fa64d8c56eb390155b3987f1`), and all six extracted files matched
(`OK`). The archive is 3,882,451,903 bytes with SHA256:

```text
183b4a28a1fe87b1f93f9fdd8c4b9381e89b8c928e6c610c8c295fb818d93b63  Homo_sapiens_hg39_T2T_Bowtie2_v0.2.tar.gz
```

`bowtie2-inspect -n` lists 25 sequences: `CP068255.2`–`CP068277.2`
(chromosomes 1–22 and X), `CP086569.2` (Y) and `CP068254.1` (mitochondrion).
These are the T2T-CHM13v2.0 sequences of GCA_009914755.4. A Bowtie2 index does
not record the Bowtie2 release that built it.

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

Run this block from the root of a FORM pipeline checkout. It creates one known
location for the index:

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

The MD5 check verifies the downloaded archive against the distributor's MD5
file. All six SHA256 checks must also report `OK`.

Use this directory as the pipeline parameter:

```bash
--host_genome "$PWD/databases/kneaddata/hg39T2T"
```

Pass the directory that directly contains the six `.bt2` files. Do not pass the
`.tar.gz` archive or one index file. Every worker must see this absolute path.
A cluster installation should put the same verified directory on shared storage.

Older neighboring deployment recipes and the current `harvard_rc` default still
select hg38. They do not define the FORM program reference. Always override that
default with the hg39T2T path.

FORM stops the run before any task if a local `--host_genome` does not contain
the six `GCA_009914755.4_T2T.*.bt2` files (`form_host_check`). This is a
file-name check; it does not run the SHA256 manifest, so run the block above
when you stage the index. See
[KneadData runtime flags](../stages/02-kneaddata.md#runtime-flags-and-precedence)
for the command-line and tool defaults.
