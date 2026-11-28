# Software versions

This is the **2026-11-19 documentation baseline**. It combines the checked-in
FORM settings, neighboring container recipes, and direct inspection of locally
available candidate images. It is not yet a release lockfile for a validated
FORM applet.

**Selection precedence:** use the versions supplied in the Hugemiler container
set when a generic bioBakery default or site profile differs. Commit
`a8d779ba245722b9806bc9431391b1c59141f279` is the tracked recipe baseline;
immutable image digests identify the supplied local DNAnexus variants. In particular, FORM uses MetaPhlAn **4.2.5**
with **`mpa_vOct22_CHOCOPhlAnSGB_202403`**. It does not use the generic vJun23
index. The machine-readable [FORM version lock](form-version-lock.json) records
this decision and the immutable image references.

## Flagship software

| Order | Component | Version / identity | Evidence level |
| --- | --- | --- | --- |
| 1 | [Samplesheet building](../stages/01-samplesheet.md) | Helper source snapshot `5d4f71cb…f6f8a411` | Source file hashed; FORM wrapper pending |
| 2 | [KneadData](../stages/02-kneaddata.md) | **0.12.1** Conda package; CLI **v0.12.0** | Both package and executable observations recorded |
| 3 | [MetaPhlAn](../stages/03-metaphlan.md) | **4.2.5** with **`mpa_vOct22_CHOCOPhlAnSGB_202403`** | Hugemiler recipe, installed distribution, Conda metadata, and selected database agree |
| 4 | [HUMAnN](../stages/04-humann.md) | **4.0.0a2**, source `9cb1a8253e11a0a8ed8f58f85f53e04a690e40a6` in recipe | Installed distribution; source recipe pin |
| 5 | [BAQLaVa](../stages/05-baqlava.md) | **1.2.0.dev0**, source `629c744a553eb534be457050ca8b7b33f177e0da` in recipe | Installed distribution; source recipe pin |
| 6 | [StrainPhlAn](../stages/06-strainphlan.md) | **4.2.5** | `strainphlan --version` in MetaPhlAn image |
| 7 | [MEDI](../stages/07-medi.md) | **1.0.1** image tag | FORM default; installed contents still need inspection |
| 8 | [omixer-rpm](../stages/08-omixer-rpm.md) | **1.1** | Release JAR and local-image JAR SHA256 agree |

Full image IDs, available registry digests, Conda builds, Python distribution
versions, source snapshot hashes, and inspection scope are in
[software-inventory.json](software-inventory.json). Each stage page lists its
major dependencies. [Database releases and SHA256 values](databases.md) are
maintained separately from software versions.

The KneadData image contains **Trimmomatic 0.40**, **TRF 4.10.0rc2**, and
**Bowtie2 2.5.5**. The program-selected host reference is
[hg39T2T / GCA_009914755.4, index bundle v0.2](kneaddata-host.md).
See the [KneadData stage](../stages/02-kneaddata.md#runtime-flags-and-precedence)
for the generated flags, nested-tool defaults, and DNAnexus resource settings.

The KneadData `0.12.1` package / `v0.12.0` CLI mismatch is **document-only**;
no software correction is requested. Its public ECR tag and immutable SHA256
reference are recorded under [Public runtime image and checksum](../stages/02-kneaddata.md#public-runtime-image-and-checksum).

## Shared runtime

| Component | Recorded version | Meaning |
| --- | --- | --- |
| FORM | `0.1.0` | Current `manifest.version` |
| bioBakery dependency | `4466d89aeb5131dd5a99e077d61d0020028377f4` | Gitlink currently recorded by FORM; re-pin is pending |
| Nextflow minimum | `>=25.04.0` | Topic channels without the preview flag; 25.10 rejects `nextflow.preview.topic` |
| Nextflow CI | `25.10.4` | Existing pipeline CI configuration |
| Java CI | `21` | Existing pipeline CI configuration |
| DNAnexus Nextflow build | `25.10` (`dx build --nextflow-version 25.10`) | DNAnexus offers 24.10 (deprecated) and 25.10 |
| DNAnexus dx-toolkit | Not recorded | Capture the build client and worker CLI versions during deployment |
| Zensical | **0.1.2** | Exact documentation dependency in `docs/requirements.txt` |
| Documentation Python | **3.12** series | GitHub Actions runtime; distinct from tool-image Python versions |

## Interpreting version evidence

A Docker tag is a label that can be moved. Use a registry digest to identify
the selected image and record the platform. A local Docker image ID identifies
the inspected local image configuration; it is not an interchangeable registry
manifest digest or a database checksum.

Conda package metadata can remain after a pip installation replaces the actual
Python distribution. This occurs in the inspected HUMAnN image: Conda reports
`4.0.0a1`, while the installed distribution reports `4.0.0a2`. Retain both facts
and use the distribution/CLI result to describe the installed flagship tool.

Similarly, a source recipe's `ENV COMMIT` records build intent. Matching package
metadata does not by itself prove every installed file came from that source
commit. Preserve the built-image digest and recipe snapshot alongside the source
pin when making a release.

## Release updates

When changing the bioBakery pin, a container, or a database, update its stage
page and both relevant inventories together. Reinspect the chosen image rather
than copying a version from an older tag. Clear pending values only when their
byte-level evidence is available; see [verification](provenance.md).
