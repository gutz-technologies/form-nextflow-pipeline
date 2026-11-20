# 5. BAQLaVa

BAQLaVa profiles viral sequences using cleaned reads and a microbial taxonomic
profile. Its bacterial-depletion phase also uses HUMAnN reference data.

**State:** available in the neighboring bioBakery deployment; inclusion in the
updated FORM pin and combined DNAnexus run is pending.

## Software and major dependencies

| Component | Installed version | Role |
| --- | --- | --- |
| BAQLaVa | **1.2.0.dev0** | Distribution metadata normalized by the image recipe |
| BAQLaVa source | `629c744a553eb534be457050ca8b7b33f177e0da` | Source pin in the candidate image recipe |
| Python | 3.12.16 | Runtime |
| AnADAMA2 | 0.10.0 | Internal workflow dependency |
| HUMAnN | 4.0.0a1 | Depletion/search support inside this image |
| MetaPhlAn | 4.2.5 | Installed dependency |
| Bowtie2 | 2.5.5 | Nucleotide alignment |
| DIAMOND | 2.2.8 | Translated search |
| SAMtools | 1.25 | Alignment handling |
| NumPy / pandas | 2.5.4 / 3.1.0 | Numerical operations and tables |

Inspected image: `public.ecr.aws/j5i5h1i5/baqlava:4.0.0-r1`.
**The image tag is not the BAQLaVa software version.** The catalogue's tag
uses the HUMAnN version; the installed BAQLaVa distribution reports `1.2.0.dev0`.
See the [software inventory](../reference/software-inventory.json) for image identity.

The inspected recipe normalizes package version metadata, replaces local `scp`
calls with `cp`, and patches HUMAnN's validation for the specific BAQLaVa protein
database filename. These modifications belong to the image provenance alongside
the upstream source commit.

## Databases and sources

| Reference | Selected identity | SHA256 |
| --- | --- | --- |
| Nucleotide search DB | `BAQLaVa.V0.5.nucleotide` | **Pending** — `baqlava-nucleotide` |
| Protein search DB | `BAQLaVa.V0.5.protein` | **Pending** — `baqlava-protein` |
| Bundled annotation/taxonomy tables | `baqlava/utility_files/` in the inspected image | See [BAQLaVa checksums](../reference/databases.md#baqlava) |
| Bacterial depletion references | HUMAnN nucleotide, protein, and mapping trees | Same pending identities as the [HUMAnN references](04-humann.md#databases-and-sources) |

The pinned BAQLaVa setup script names
`https://huttenhower.sph.harvard.edu/baqlava-db/databases.V0.5.tar.gz` as its full
database download. Confirm the project copy against the chosen upstream archive
before recording a deployment checksum. The small example databases shipped with
the source are not substitutes for the full references.

## Sources

- [Pinned BAQLaVa source](https://github.com/biobakery/baqlava/tree/629c744a553eb534be457050ca8b7b33f177e0da).
- [Pinned setup and database download definition](https://github.com/biobakery/baqlava/blob/629c744a553eb534be457050ca8b7b33f177e0da/setup.py).
- [Measured image and recipe evidence](../reference/software-inventory.json).
