# 4. HUMAnN

HUMAnN profiles gene families and pathways from cleaned reads using MetaPhlAn's
taxonomic profile. KO regrouping supplies the proposed Gut-Brain Module stage.
Its retained **nucleotide-unaligned** reads supply FORM's default MEDI branch.

**State:** imported through bioBakery; the optional read-export interface is
being updated upstream.

## Software and major dependencies

| Component | Installed version | Role |
| --- | --- | --- |
| HUMAnN | **4.0.0a2** | Python distribution installed over the Conda package |
| HUMAnN source | `9cb1a8253e11a0a8ed8f58f85f53e04a690e40a6` | Pinned experimental checkout in the candidate image recipe |
| Python | 3.12.16 | Runtime |
| Bowtie2 | 2.5.5 | Nucleotide search |
| DIAMOND | 2.2.8 | Translated protein search |
| MetaPhlAn inside this image | 4.0.6 | HUMAnN dependency; separate from the profiling image's 4.2.5 |
| GLPK | 4.57 | Pathway optimization support |
| NumPy / pandas | 2.5.4 / 3.1.0 | Numerical operations and tables |
| SciPy / Biopython | 1.18.1 / 1.88 | Scientific computing and sequence handling |

Inspected image:
`public.ecr.aws/j5i5h1i5/humann:4.0.0-experimental-nodb-dnanexus-r1`.
The image tag says `4.0.0`, and Conda metadata still records `4.0.0a1`;
Python distribution metadata records the replacement as `4.0.0a2`. The
[software inventory](../reference/software-inventory.json) preserves both.

## Databases and sources

| Reference | Identity or source | SHA256 |
| --- | --- | --- |
| Deployment bundle | Locally packaged `chocophlan-v4-201901.tar.gz` | **Pending** — `humann-bundle` |
| ChocoPhlAn nucleotide database | Bundle member `chocophlan/`; exact upstream artifact selection still needs confirmation | **Pending** — `humann-chocophlan` |
| UniRef90 annotated DIAMOND database | Bundle member `uniref90_annotated/`; exact upstream release still needs confirmation | **Pending** — `humann-uniref90` |
| Utility mappings | Bundle member `full_mapping/` | **Pending** — `humann-mappings` |

See the full [HUMAnN database catalog](../reference/databases.md#humann).
The pinned upstream downloader lists v4 alpha ChocoPhlAn, EC-filtered UniRef90,
and full-mapping URLs. These are discovery leads; they have not been proven to
be the exact inputs used to construct the local deployment bundle.

The selected mapping set also needs byte-level provenance, especially
`map_ko_uniref90.txt.gz` for GBMs. The neighboring configuration additionally uses
EC and Pfam regrouping/name tables. Hash the deployed mapping tree rather than
identifying it only by a folder name.

## MEDI handoff

The required reads are the Bowtie2 nucleotide-search leftovers, before the
translated search. They are not the final reads left after all HUMAnN searches.
Retain the temporary read artifact and expose it as a declared workflow output.
The default MEDI mode requires the nucleotide search and must not remove its
temporary output before the consumer can stage it.

## Sources

- [Pinned HUMAnN source](https://github.com/biobakery/humann/tree/9cb1a8253e11a0a8ed8f58f85f53e04a690e40a6).
- [Pinned database downloader](https://github.com/biobakery/humann/blob/9cb1a8253e11a0a8ed8f58f85f53e04a690e40a6/humann/tools/humann_databases.py).
- [Measured image and recipe evidence](../reference/software-inventory.json).
