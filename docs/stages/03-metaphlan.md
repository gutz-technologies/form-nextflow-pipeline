# 3. MetaPhlAn

MetaPhlAn estimates microbial taxonomic abundances and produces marker alignments.
Its taxonomic profile feeds HUMAnN and BAQLaVa; its marker outputs feed StrainPhlAn.

**State:** imported through bioBakery. The version inventory describes the
candidate DNAnexus image; the updated FORM deployment still needs validation.

## Software and major dependencies

| Component | Installed version | Role |
| --- | --- | --- |
| MetaPhlAn | **4.2.5** | Taxonomic profiling |
| Python | 3.8.20 | Runtime |
| Bowtie2 | 2.5.5 | Marker alignment |
| SAMtools | 1.25 | Alignment handling |
| NumPy | 1.24.4 | Numerical operations |
| pandas | 2.0.3 | Tables |
| SciPy | 1.10.1 | Scientific computing |
| Biopython | 1.83 | Sequence handling |

Inspected image:
`public.ecr.aws/j5i5h1i5/metaphlan:4.2.5-nodb-dnanexus-r1`.
See its registry digest and package build identifiers in the
[software inventory](../reference/software-inventory.json).

## Databases and sources

| Reference | Selected identity | SHA256 |
| --- | --- | --- |
| Marker/index bundle | `mpa_vOct22_CHOCOPhlAnSGB_202403`, packaged under `mpa_vOct22_202403` | **Pending** — `metaphlan-markers` in the [database catalog](../reference/databases.md#metaphlan) |

The neighboring deployment uses corrected extracted indexes in its project
reference folder. A checksum for an older archive would not verify those
corrected files. Capture a manifest of the actual index files and the associated
`.pkl`, or package that exact directory and hash the new archive.

MetaPhlAn's software version, its database release, and the workflow's
`metaphlan_version` CLI compatibility setting are different identifiers. Record
all three when validating a run. If multiple databases are selected, each needs
its own provenance and checksum entries.

## Sources

- [MetaPhlAn source and database installation](https://github.com/biobakery/MetaPhlAn).
- [Container environment recipe snapshot](https://github.com/Hugemiler/biobakery-containers/blob/a8d779ba245722b9806bc9431391b1c59141f279/packages/metaphlan/4.2.5/nodb/environment.yaml).
- [Measured image evidence](../reference/software-inventory.json).
