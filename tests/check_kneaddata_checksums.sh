#!/usr/bin/env bash
# Run the KneadData checksum workflow and check checksums.md5.
# The check uses the published file and the FASTQ files, as
# `cd kneaddata && md5sum -c checksums.md5` does.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cd "$root"

nextflow run tests/kneaddata_checksums.nf \
    -c tests/stub.config \
    -w "$tmp/work" \
    --outdir "$tmp/out" \
    -ansi-log false

published="$tmp/out/kneaddata/checksums.md5"
if [[ ! -s "$published" ]]; then
    echo "FAIL  missing $published"
    exit 1
fi

mapfile -t copies < <(find "$tmp/work" -type f -name checksums.md5 | sort)
if [[ ${#copies[@]} -ne 1 ]]; then
    echo "FAIL  expected one task checksums.md5, found ${#copies[@]}"
    printf '  %s\n' "${copies[@]:-}"
    exit 1
fi
taskdir="$(dirname "${copies[0]}")"

python3 - "$published" "$taskdir" <<'PY'
import pathlib, re, sys
published = pathlib.Path(sys.argv[1]).read_text()
taskdir = pathlib.Path(sys.argv[2])
if not published.endswith("\n"):
    sys.exit("checksums.md5 must end with a newline")
lines = published.splitlines()
expected = [
    "sampleA_kneaddata_paired_1.fastq.gz",
    "sampleA_kneaddata_paired_2.fastq.gz",
    "sampleA_kneaddata_unmatched_1.fastq.gz",
    "sampleA_kneaddata_unmatched_2.fastq.gz",
    "sampleB_kneaddata_paired_1.fastq.gz",
    "sampleB_kneaddata_paired_2.fastq.gz",
    "sampleB_kneaddata_unmatched_1.fastq.gz",
    "sampleB_kneaddata_unmatched_2.fastq.gz",
    "sampleC_kneaddata.fastq.gz",
    "sampleC_kneaddata_contam.fastq.gz",
]
pat = re.compile(r"^[0-9a-f]{32}  \S+\.fastq\.gz$")
bad = [ln for ln in lines if not pat.fullmatch(ln)]
if bad:
    sys.exit("bad checksum line:\n" + "\n".join(bad))
names = [ln.split("  ", 1)[1] for ln in lines]
if names != expected:
    sys.exit("names differ:\n got {}\n want {}".format(names, expected))
task_copy = (taskdir / "checksums.md5").read_text()
if task_copy != published:
    sys.exit("published checksums.md5 differs from the task file")
print("ok    {} checksum lines".format(len(lines)))
PY

stage="$(mktemp -d)"
find "$taskdir" -maxdepth 1 -name '*.fastq.gz' -exec cp -L {} "$stage/" \;
cp "$published" "$stage/checksums.md5"
(
    cd "$stage"
    md5sum -c checksums.md5
)
echo "ok    md5sum -c"
