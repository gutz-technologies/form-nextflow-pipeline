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

| Reference | Selected identity | Download | SHA256 |
| --- | --- | --- | --- |
| Marker metadata | `mpa_vOct22_CHOCOPhlAnSGB_202403.tar` — contains the `.pkl` and marker FASTA | [Archive](https://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/mpa_vOct22_CHOCOPhlAnSGB_202403.tar) · [MD5](https://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/mpa_vOct22_CHOCOPhlAnSGB_202403.md5) | **Pending SHA256**; distributor MD5 `91d57912faab6bfd3526a49d9e83da8c` |
| Bowtie2 index | `mpa_vOct22_CHOCOPhlAnSGB_202403_bt2.tar` — contains the `.bt2l` files | [Archive](https://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/bowtie2_indexes/mpa_vOct22_CHOCOPhlAnSGB_202403_bt2.tar) · [MD5](https://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/bowtie2_indexes/mpa_vOct22_CHOCOPhlAnSGB_202403_bt2.md5) | **Pending SHA256**; distributor MD5 `6618ecfbed7f2964b9185b0c6f090020` |

One MetaPhlAn index needs **both** archives, extracted into the same directory:
the marker `.tar` provides the `.pkl`, and `bowtie2_indexes/..._bt2.tar` provides
the `.bt2l` index. These are the URLs the MetaPhlAn database installer uses. All
four public URLs returned successful ranged downloads on 2026-11-20. The
neighboring deployment uses corrected extracted indexes in its project reference
folder; the public MD5 files do not verify that project copy. Capture a manifest
of the files actually used by the run.

MetaPhlAn's software version, its database release, and the workflow's
`metaphlan_version` CLI compatibility setting are different identifiers. FORM
locks them to MetaPhlAn 4.2.5, `mpa_vOct22_CHOCOPhlAnSGB_202403`, and
`metaphlan_v4`. The run refuses another MetaPhlAn index unless the explicit FORM
index check is disabled. Record all three when validating a run.

## Sources

- [MetaPhlAn source and database installation](https://github.com/biobakery/MetaPhlAn).
- [Container environment recipe snapshot](https://github.com/Hugemiler/biobakery-containers/blob/a8d779ba245722b9806bc9431391b1c59141f279/packages/metaphlan/4.2.5/nodb/environment.yaml).
- [Measured image evidence](../reference/software-inventory.json).
