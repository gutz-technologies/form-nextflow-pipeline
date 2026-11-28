#!/usr/bin/env bash
# Write checksums.md5 for every .fastq.gz in the task directory.
# Lines use the md5sum text format: "<hash>  <filename>", sorted by name.
set -euo pipefail
shopt -s nullglob
files=( *.fastq.gz )
if [ ${#files[@]} -eq 0 ]; then
    : > checksums.md5
else
    printf '%s\0' "${files[@]}" \
        | xargs -0 md5sum -- \
        | LC_ALL=C sort -k 2 \
        > checksums.md5
fi
