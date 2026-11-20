# 8. omixer-rpm (Gut-Brain Modules)

omixer-rpm maps ortholog abundances to module abundance and coverage. For FORM,
the intended input is the HUMAnN KO profile and the reference is the curated
Gut-Brain Modules (GBMs) database.

**State:** a local container and reference file exist; the FORM workflow module
and its HUMAnN table adapter are still planned.

## Software and major dependencies

| Component | Version or identity | Evidence |
| --- | --- | --- |
| omixer-rpm | **1.1** | Downloaded release JAR matches the JAR in the inspected image |
| Java | **OpenJDK 21.0.13**, Temurin `21.0.13+9` | Measured in the local image |
| HUMAnN KO regrouping | See [HUMAnN](04-humann.md) | Supplies ortholog abundances; its mapping release must be recorded |

Inspected image: `omixer-rpm:1.1-r1`, platform `linux/amd64`.
The [software inventory](../reference/software-inventory.json) records its local
image ID; a registry digest was not available for that local tag.

SHA256 of `omixer-rpm-1.1.jar`, independently downloaded and matched against
`/opt/omixer/omixer-rpm.jar` in the image:

```text
7a1355e34d7f982003971228de2a7014b2161b8ee9413d9ee5933c02c30dd39f
```

## Databases and sources

The source is the [Raes Lab GBM collection](https://code.raeslab.org/GBMs/),
associated with [Valles-Colomer et al. (2019)](https://doi.org/10.1038/s41564-018-0337-x).
The reference snapshot is pinned to commit
`21a2875d39a1b85338b9b10b5fe21eefa634fc55` of `raeslab/GBMs`.

| Artifact | Bytes | SHA256 |
| --- | ---: | --- |
| `GBMs.zip` | 6005 | `d6af41d68fced6a1f3ec3fd0dd712612bcf0bf841d26801e4fe9f0d90c33091a` |
| `GBM.inputfile.txt` | 4685 | `50f808a781326c706a622e3e9a1da79bc6485a65f422bee171bc7743080fd232` |
| `Supplementary.Data.S1.txt` | 11375 | `4c80595ebe1cda28cc25e26e94a913d4a1d317d130cd87f0e7fac4df3baab92e` |

These are checksums of the actual Git LFS payloads, independently matched to
their upstream LFS object identifiers. Pinned download URLs are in the
[GBM database catalog](../reference/databases.md#omixer-rpm-gut-brain-modules).

The existing local `/Databases/omixer-rpm/GBM.inputfile.txt` is **4914 bytes**, with
SHA256 `a73637f95df556af0322be5b32b549b2304e82120ebbbd5751cae58df71eb082`.
It matches the upstream file after CRLF-to-LF normalization, but its exact bytes
differ. The production reference must explicitly select one representation and
record that representation's checksum.

## Integration decisions

The module needs a defined HUMAnN-to-KO matrix adapter, treatment of stratified
rows, abundance normalization, coverage threshold, and scoring estimator.
Preserve those choices in the YAML and run provenance. GBMs and the related
Gut Metabolic Modules (GMMs) are different reference sets; select the GBM input
file for this stage.

## Sources

- [omixer-rpm 1.1 release](https://github.com/raeslab/omixer-rpm/releases/tag/1.1).
- [omixer-rpm input and module formats](https://github.com/raeslab/omixer-rpm).
- [Pinned GBM source](https://github.com/raeslab/GBMs/tree/21a2875d39a1b85338b9b10b5fe21eefa634fc55).
