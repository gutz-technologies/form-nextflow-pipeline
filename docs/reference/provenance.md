# Provenance and verification

The inventory distinguishes four identities: workflow source, installed
software, reference data, and run-specific inputs. A reproducible FORM release
needs all four.

## Evidence in this baseline

| Evidence | What was captured | Limit |
| --- | --- | --- |
| FORM source | Manifest version and bioBakery gitlink | Upstream changes and DNAnexus integration are still pending |
| Candidate images | Local image IDs, registry digests where available, platform, Conda metadata, and Python distribution versions | These are locally inspected candidates, not proof of a deployed FORM run |
| Neighboring source files | SHA256 of helper and container recipe snapshots | Some recipes are local/untracked work; the checkout HEAD alone does not identify them |
| BAQLaVa annotations | SHA256 of installed `utility_files/` assets in the inspected image | Full nucleotide/protein search references still need hashes |
| GBM reference | Downloaded payloads matched to pinned Git LFS SHA256 and size | Production representation has not yet been selected |
| hg39T2T host reference | Program selection, assembly accession, download URL, and six owner-provided expected file SHA256 values | File sizes, archive SHA256, index-builder version, and deployment-byte verification remain unrecorded |
| omixer-rpm JAR | Downloaded 1.1 release matched the image's JAR | No registry digest was available for the local image tag |

Download the [software inventory](software-inventory.json) and
[database inventory](database-inventory.json) to inspect the complete evidence.
`null` checksums and **Pending** entries are deliberate gaps, not verified values.
The status `user-provided` records an expected checksum supplied by the program
owner, separately from `measured` checksums obtained during inspection. It does
not assert that the deployment files have passed verification. The
[hg39T2T record](kneaddata-host.md) and its downloadable manifest use this status.

## Record source and image identity

From a populated FORM checkout, record the wrapper commit and the submodule
commit independently:

```bash
git rev-parse HEAD
git submodule status
git status --short
```

For an image already available locally, without pulling a new tag:

```bash
docker image inspect IMAGE --format '{{json .RepoDigests}}'
docker image inspect IMAGE --format '{{.Id}} {{.Os}}/{{.Architecture}}'
```

For Conda-based images, collect package metadata and Python distribution
metadata separately. An example for a locally available image is:

```bash
docker run --rm --network none --read-only --pull never \
  --entrypoint /opt/conda/bin/python IMAGE -c '
import importlib.metadata, json, pathlib
packages = [json.loads(p.read_text()) for p in pathlib.Path("/opt/conda/conda-meta").glob("*.json")]
print(json.dumps([{k: p.get(k) for k in ["name", "version", "build"]} for p in packages], indent=2))
for name in ["humann", "metaphlan", "baqlava"]:
    try:
        print(name, importlib.metadata.version(name))
    except importlib.metadata.PackageNotFoundError:
        pass
'
```

Also capture the flagship program's version command where available. Store
environment-specific patches and reference build commands with the image recipe.

## Hash an exact file or archive

Run these commands in the directory containing the artifact:

```bash
sha256sum reference.tar.gz > reference.tar.gz.sha256
sha256sum --check reference.tar.gz.sha256
```

For large project references, checksum the actual stored artifact or use an
existing checksum sidecar whose provenance you can verify. Avoid downloading
hundreds of gigabytes merely to fill a documentation table if a trusted
manifest is already available. A DNAnexus file ID or storage-provider ETag
does not substitute for a SHA256 content checksum.

Record the original source URL, release/accession, retrieval date, archive
filename, byte size, SHA256, and any extraction/index-build transformations.
An archive checksum identifies the compressed archive bytes. It does not by
itself verify a subsequently edited extracted tree.

## Hash a deployed directory

Use a sorted file manifest when references are stored as extracted indexes:

```bash
cd /path/to/reference
LC_ALL=C find . -type f -print0 | LC_ALL=C sort -z | \
  xargs -0 -r sha256sum > /tmp/reference.files.sha256
sha256sum /tmp/reference.files.sha256
sha256sum --check /tmp/reference.files.sha256
```

Keep the manifest outside the directory while generating it so it cannot hash
itself. This procedure records regular-file contents and relative filenames;
it does not capture permissions, empty directories, or symlink semantics.
Resolve symlinked references into a defined reference tree, or record their
targets explicitly. Archive the manifest with the release and record its own
checksum in the catalog.

## Git LFS references

A small file beginning `version https://git-lfs.github.com/spec/v1` is a pointer,
not the reference payload. For the GBM snapshot, the documented download URLs
use `media.githubusercontent.com` to retrieve actual payloads. Verify both their
SHA256 and byte size against the pinned source pointer. Never report the hash
of the 129-byte pointer as the hash of the 4685-byte GBM database.

Line endings matter: the local GBM text uses CRLF while the pinned upstream
payload uses LF. Both are measured in the catalog. Any conversion creates a
new artifact that needs its own checksum and transformation record.

## Complete a deployment record

Before calling a release reproducible, resolve each pending entry used by that
release and preserve the chosen YAML, generated samplesheet checksum, read file
references/checksums, FORM and bioBakery commits, applet ID, engine version,
container digests, and reference manifest. Record which branches ran and any
optional StrainPhlAn genomes or alternative MetaPhlAn databases.

The documentation build validates rendering and internal links. It does not
download reference databases, verify their contents, or execute the biological
pipeline. A successful site build is not a reference-integrity or analysis test.
