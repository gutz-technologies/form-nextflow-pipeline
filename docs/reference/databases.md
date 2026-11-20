# Databases and SHA256 checksums

This catalog records the reference identity separately from the software
version and container digest. **Pending** means the exact artifact has not been
hashed or its original provenance has not been established. It never means an
empty database or a successful integrity check.

The full catalog, including sources, byte counts, checksum scope, and evidence,
is downloadable as [database-inventory.json](database-inventory.json). Observed
image identities are in [software-inventory.json](software-inventory.json).
Expected checksums with status `user-provided` retain their supplied provenance;
`measured` records were hashed during inspection.
The software inventory was recorded on **2026-11-19**. The database inventory
was updated on **2026-11-20** after the host archive verification and download
link audit. Every direct resource link on this page returned HTTP 200 or 206 in
a ranged GET during that audit. They describe the candidate deployment, not a
validated FORM release.

Checksums for directories must cover their contents using a defined file
manifest or an exact packaged archive. A hash of a path string, image tag,
Git commit, or Git LFS pointer is not a database content checksum. See
[verification procedures](provenance.md) before filling a pending value.

## Samplesheet building

No external reference database. Hash the generated CSV for each run; it is
not a reusable release artifact. The helper source checksum is recorded on the
[samplesheet stage page](../stages/01-samplesheet.md).


## KneadData

**Program-selected reference: hg39T2T**, assembly **GCA_009914755.4 /
T2T-CHM13v2.0**, Huttenhower Lab Bowtie2 index bundle **v0.2**. See the
[host-reference record](kneaddata-host.md) for the original NCBI source, index
prefix, runtime placement, and verification instructions.

- [Download the prebuilt index archive](https://huttenhower.sph.harvard.edu/kneadData_databases/Homo_sapiens_hg39_T2T_Bowtie2_v0.2.tar.gz).
- [Original genome assembly](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_009914755.4/).
- [Download the SHA256 manifest](checksums/kneaddata-hg39-t2t-v0.2.sha256).

The following SHA256 values were supplied by the program owner on 2026-11-19.
On 2026-11-20 each extracted file was independently rehashed and matched its
supplied value. The downloaded archive had SHA256
`183b4a28a1fe87b1f93f9fdd8c4b9381e89b8c928e6c610c8c295fb818d93b63`, and all
six extracted files matched the manifest. The index-builder software version
remains unrecorded; a Bowtie2 index does not store it.

| Extracted file | Expected SHA256 |
| --- | --- |
| `GCA_009914755.4_T2T.1.bt2` | `31e72a1d368f8bbc29a0cc1359db2e62d2b624a9371d7b1e75fc8d72dbb295af` |
| `GCA_009914755.4_T2T.2.bt2` | `d3962bc9e65a7a80fd3af9f883914cb2bad804192bb1a0e448bae218cbfa00d3` |
| `GCA_009914755.4_T2T.3.bt2` | `5cf938e8402a908b5cd5be380c7a3850a5630ee5a3f33d0a50abbf6793e3bc30` |
| `GCA_009914755.4_T2T.4.bt2` | `aeaba4a2c9cf171e152e5e21e9679f931ffab6a110bffd85fffd396b18cd03e6` |
| `GCA_009914755.4_T2T.rev.1.bt2` | `789f9666a2934a141ea2ea631a543c6572a25528b6e1cc159c13c665c7ac59d6` |
| `GCA_009914755.4_T2T.rev.2.bt2` | `d531e13fa16aa719884513f71b660f99788d40fb3c0040d74e55fa27910291b5` |

The archive is `kneaddata-host` in the JSON inventory; each named file has a
separate measured child artifact. Older `hg37dec` settings in neighboring
recipes are legacy configuration, not the FORM reference.

## MetaPhlAn

| Artifact ID | Reference / version | Source | SHA256 |
| --- | --- | --- | --- |
| `metaphlan-markers` | MetaPhlAn marker metadata — `mpa_vOct22_CHOCOPhlAnSGB_202403.tar` (contains the `.pkl`) | [Download](https://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/mpa_vOct22_CHOCOPhlAnSGB_202403.tar) · [MD5](https://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/mpa_vOct22_CHOCOPhlAnSGB_202403.md5) | **Pending SHA256**; distributor MD5 `91d57912faab6bfd3526a49d9e83da8c` |
| `metaphlan-bowtie2-index` | MetaPhlAn Bowtie2 index — `mpa_vOct22_CHOCOPhlAnSGB_202403_bt2.tar` (contains `.1.bt2l`) | [Download](https://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/bowtie2_indexes/mpa_vOct22_CHOCOPhlAnSGB_202403_bt2.tar) · [MD5](https://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/bowtie2_indexes/mpa_vOct22_CHOCOPhlAnSGB_202403_bt2.md5) | **Pending SHA256**; distributor MD5 `6618ecfbed7f2964b9185b0c6f090020` |

## HUMAnN

| Artifact ID | Reference / version | Direct download | SHA256 |
| --- | --- | --- | --- |
| `humann-bundle` | Neighboring packaged bundle — chocophlan-v4-201901 packaging label | Local packaging; equality to the portable archives is unresolved | **Pending** |
| `humann-chocophlan` | ChocoPhlAn nucleotide tree — selected v4-alpha archive | [Download](https://huttenhower.sph.harvard.edu/humann_data/chocophlan/chocophlan.v4_alpha.tar.gz) | **Pending; no publisher sidecar** |
| `humann-uniref90` | Annotated UniRef90 DIAMOND tree — selected v4-alpha EC-filtered archive | [Download](https://huttenhower.sph.harvard.edu/humann_data/uniprot/uniref_ec_filtered/uniref90_annotated_v4_alpha_ec_filtered.tar.gz) | **Pending; no publisher sidecar** |
| `humann-mappings` | HUMAnN utility mappings including UniRef90-to-KO — selected v4-alpha full mapping | [Download](https://huttenhower.sph.harvard.edu/humann_data/full_mapping_v4_alpha.tar.gz) | **Pending; no publisher sidecar** |

## BAQLaVa

| Artifact ID | Reference / version | Direct download | SHA256 |
| --- | --- | --- | --- |
| `humann-bundle` | Neighboring packaged bundle — chocophlan-v4-201901 packaging label | Local packaging; equality to the portable archives is unresolved | **Pending** |
| `humann-chocophlan` | ChocoPhlAn nucleotide tree — selected v4-alpha archive | [Download](https://huttenhower.sph.harvard.edu/humann_data/chocophlan/chocophlan.v4_alpha.tar.gz) | **Pending; no publisher sidecar** |
| `humann-uniref90` | Annotated UniRef90 DIAMOND tree — selected v4-alpha EC-filtered archive | [Download](https://huttenhower.sph.harvard.edu/humann_data/uniprot/uniref_ec_filtered/uniref90_annotated_v4_alpha_ec_filtered.tar.gz) | **Pending; no publisher sidecar** |
| `humann-mappings` | HUMAnN utility mappings including UniRef90-to-KO — selected v4-alpha full mapping | [Download](https://huttenhower.sph.harvard.edu/humann_data/full_mapping_v4_alpha.tar.gz) | **Pending; no publisher sidecar** |
| `baqlava-nucleotide` | BAQLaVa nucleotide search database — V0.5 | [Source](https://huttenhower.sph.harvard.edu/baqlava-db/databases.V0.5.tar.gz) | **Pending** |
| `baqlava-protein` | BAQLaVa protein search database — V0.5 | [Source](https://huttenhower.sph.harvard.edu/baqlava-db/databases.V0.5.tar.gz) | **Pending** |
| `baqlava-baqlava-metadata-orfs` | BAQLaVa_metadata_ORFs.txt.gz — 629c744a553eb534be457050ca8b7b33f177e0da | [Source](https://raw.githubusercontent.com/biobakery/baqlava/629c744a553eb534be457050ca8b7b33f177e0da/baqlava/utility_files/BAQLaVa_metadata_ORFs.txt.gz) | `96d079ba765281493c640d74cc08e1f8be963bfd4367b934a2587a464281dc73` |
| `baqlava-baqlava-metadata-genomes` | BAQLaVa_metadata_genomes.txt.gz — 629c744a553eb534be457050ca8b7b33f177e0da | [Source](https://raw.githubusercontent.com/biobakery/baqlava/629c744a553eb534be457050ca8b7b33f177e0da/baqlava/utility_files/BAQLaVa_metadata_genomes.txt.gz) | `ba7d54f467b5213cfbe86f4a889834d11eb3e3624102bfc8d16a86b87e934570` |
| `baqlava-mgx-plasmid-vgbs` | MGX_plasmid_VGBs.txt — 629c744a553eb534be457050ca8b7b33f177e0da | [Source](https://raw.githubusercontent.com/biobakery/baqlava/629c744a553eb534be457050ca8b7b33f177e0da/baqlava/utility_files/MGX_plasmid_VGBs.txt) | `4e83492235aeaf83047ae5df2f2567eef6e9480647e68763cf269495fe9ddba6` |
| `baqlava-mtx-plasmid-vgbs` | MTX_plasmid_VGBs.txt — 629c744a553eb534be457050ca8b7b33f177e0da | [Source](https://raw.githubusercontent.com/biobakery/baqlava/629c744a553eb534be457050ca8b7b33f177e0da/baqlava/utility_files/MTX_plasmid_VGBs.txt) | `6b2b2bd5733a94ede10d25c2eb2fa89b5fd7d1f36d76c1c3b2b546d28164d32d` |
| `baqlava-vgb-taxonomy` | VGB_taxonomy.txt — 629c744a553eb534be457050ca8b7b33f177e0da | [Source](https://raw.githubusercontent.com/biobakery/baqlava/629c744a553eb534be457050ca8b7b33f177e0da/baqlava/utility_files/VGB_taxonomy.txt) | `e29f6d2b3fb3af9040bff4b5308a1d6d348db076734fab566e2db3baf83c68fc` |
| `baqlava-idmap-nucleotide-conservative` | idmap_nucleotide_conservative.txt — 629c744a553eb534be457050ca8b7b33f177e0da | [Source](https://raw.githubusercontent.com/biobakery/baqlava/629c744a553eb534be457050ca8b7b33f177e0da/baqlava/utility_files/idmap_nucleotide_conservative.txt) | `3618f936b9260a1dfcf8a558483b1df30c24efa2ef6b31f8fd501d0d33f40b80` |
| `baqlava-idmap-nucleotide-default` | idmap_nucleotide_default.txt — 629c744a553eb534be457050ca8b7b33f177e0da | [Source](https://raw.githubusercontent.com/biobakery/baqlava/629c744a553eb534be457050ca8b7b33f177e0da/baqlava/utility_files/idmap_nucleotide_default.txt) | `075c226a1d012cd8b6512892ab33618432436c004efa0aad928c74b1ce6a6479` |
| `baqlava-idmap-nucleotide-nofilter` | idmap_nucleotide_nofilter.txt — 629c744a553eb534be457050ca8b7b33f177e0da | [Source](https://raw.githubusercontent.com/biobakery/baqlava/629c744a553eb534be457050ca8b7b33f177e0da/baqlava/utility_files/idmap_nucleotide_nofilter.txt) | `f9a84cc3d179111f0a004cb7467ed7e45e17ea2ff8def5cd1e42ea2d7c6900f8` |
| `baqlava-idmap-protein-conservative` | idmap_protein_conservative.txt — 629c744a553eb534be457050ca8b7b33f177e0da | [Source](https://raw.githubusercontent.com/biobakery/baqlava/629c744a553eb534be457050ca8b7b33f177e0da/baqlava/utility_files/idmap_protein_conservative.txt) | `4d4b7bd3cfc112d426adc014b84b510a5dac67384e57de6763e28ad68b30a6ad` |
| `baqlava-idmap-protein-default` | idmap_protein_default.txt — 629c744a553eb534be457050ca8b7b33f177e0da | [Source](https://raw.githubusercontent.com/biobakery/baqlava/629c744a553eb534be457050ca8b7b33f177e0da/baqlava/utility_files/idmap_protein_default.txt) | `027f0dc03b4758d65a1ddad470cb00768f73960e36babfca0f6b3971a7c957ff` |
| `baqlava-idmap-protein-nofilter` | idmap_protein_nofilter.txt — 629c744a553eb534be457050ca8b7b33f177e0da | [Source](https://raw.githubusercontent.com/biobakery/baqlava/629c744a553eb534be457050ca8b7b33f177e0da/baqlava/utility_files/idmap_protein_nofilter.txt) | `12cdb9a45c3df8d03bc442cb52f83cf2822bc2347ac20eb81a850e89f40dc1ac` |
| `baqlava-nucleotide-marker-reference` | nucleotide_marker_reference.txt — 629c744a553eb534be457050ca8b7b33f177e0da | [Source](https://raw.githubusercontent.com/biobakery/baqlava/629c744a553eb534be457050ca8b7b33f177e0da/baqlava/utility_files/nucleotide_marker_reference.txt) | `259f3c81e01a994b09f0e6c2e94c7312bb4c8f00e1d540d0f71876d1ad2616a8` |
| `baqlava-translated-protein-reference` | translated_protein_reference.txt — 629c744a553eb534be457050ca8b7b33f177e0da | [Source](https://raw.githubusercontent.com/biobakery/baqlava/629c744a553eb534be457050ca8b7b33f177e0da/baqlava/utility_files/translated_protein_reference.txt) | `0611d16db6cca8a2c2bb04aa8ccfb5937c51092ce65f251fe266a818f4bd47b1` |

Annotation checksums were measured in the inspected BAQLaVa image. The full search
databases remain pending. Shared HUMAnN references appear here because bacterial
depletion also consumes them; their checksums must agree across consumers.

## StrainPhlAn

| Artifact ID | Reference / version | Source | SHA256 |
| --- | --- | --- | --- |
| `strainphlan-markers` | StrainPhlAn marker metadata `.pkl` — `mpa_vOct22_CHOCOPhlAnSGB_202403` | Same [marker archive](https://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/mpa_vOct22_CHOCOPhlAnSGB_202403.tar) as MetaPhlAn | **Pending SHA256** |

## MEDI

| Artifact ID | Reference / version | Source | SHA256 |
| --- | --- | --- | --- |
| `medi-kraken` | MEDI Kraken2/Bracken reference with taxonomy — Exact snapshot/build unresolved | [Source](https://github.com/Gibbons-Lab/medi/tree/c1166dc491e221dc3f182adecc16e2b1239affa7) | **Pending** |
| `medi-food-matches` | MEDI food-to-taxon matches CSV — Exact snapshot unresolved | [Source](https://github.com/Gibbons-Lab/medi/tree/c1166dc491e221dc3f182adecc16e2b1239affa7) | **Pending** |
| `medi-food-contents` | MEDI food contents CSV — Exact snapshot unresolved | [Source](https://github.com/Gibbons-Lab/medi/tree/c1166dc491e221dc3f182adecc16e2b1239affa7) | **Pending** |

## omixer-rpm (Gut-Brain Modules)

| Artifact ID | Reference / version | Source | SHA256 |
| --- | --- | --- | --- |
| `humann-mappings` | HUMAnN utility mappings including UniRef90-to-KO — selected v4-alpha full mapping | [Download](https://huttenhower.sph.harvard.edu/humann_data/full_mapping_v4_alpha.tar.gz) | **Pending; no publisher sidecar** |
| `gbm-archive` | GBMs.zip — 21a2875d39a1b85338b9b10b5fe21eefa634fc55 | [Source](https://media.githubusercontent.com/media/raeslab/GBMs/21a2875d39a1b85338b9b10b5fe21eefa634fc55/supplementary/GBMs.zip) | `d6af41d68fced6a1f3ec3fd0dd712612bcf0bf841d26801e4fe9f0d90c33091a` |
| `gbm-modules` | GBM.inputfile.txt — 21a2875d39a1b85338b9b10b5fe21eefa634fc55 | [Source](https://media.githubusercontent.com/media/raeslab/GBMs/21a2875d39a1b85338b9b10b5fe21eefa634fc55/supplementary/GBMs/GBM.inputfile.txt) | `50f808a781326c706a622e3e9a1da79bc6485a65f422bee171bc7743080fd232` |
| `gbm-supplement` | Supplementary.Data.S1.txt — 21a2875d39a1b85338b9b10b5fe21eefa634fc55 | [Source](https://media.githubusercontent.com/media/raeslab/GBMs/21a2875d39a1b85338b9b10b5fe21eefa634fc55/supplementary/GBMs/Supplementary.Data.S1.txt) | `4c80595ebe1cda28cc25e26e94a913d4a1d317d130cd87f0e7fac4df3baab92e` |
| `gbm-local-crlf` | GBM.inputfile.txt (local CRLF copy) — Local snapshot 2026-11-19 | Local copy; identical to pinned upstream after CRLF-to-LF normalization | `a73637f95df556af0322be5b32b549b2304e82120ebbbd5751cae58df71eb082` |

The upstream GBM files are Git LFS payloads. The local reference uses CRLF line
endings; the pinned upstream input uses LF. Their logical text agrees after
normalization, but their checksums correctly differ. Neither has yet been
selected as a FORM production default.

## Remaining provenance work

The hg39T2T archive checksum and deployment verification of the six provided
index checksums remain outstanding. The corrected MetaPhlAn tree, HUMAnN
deployment bundle, BAQLaVa full search databases, StrainPhlAn marker metadata,
and MEDI database/tables still need exact deployed checksums. Any run-selected optional
StrainPhlAn reference genomes or additional marker databases need new entries.
DNAnexus reference checksum sidecars could not be inspected because the local
authentication token had expired. No reference data were changed.
