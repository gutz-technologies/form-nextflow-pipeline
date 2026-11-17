#!/usr/bin/env bash
# Each bad combination of parameters must stop the run before any task starts,
# with its own message. Needs Nextflow only: no tools, databases or reads.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cd "$work"

base=(--readsdir "$root/biobakery/tests/data/rawfastq" --outdir out
      --medi_db /dummy --medi_food_matches /dummy --medi_food_contents /dummy)
status=0

expect() {
    local want="$1"; shift
    local out
    out=$(nextflow run "$root/main.nf" -preview -ansi-log false "$@" 2>&1)
    if [[ $? -ne 0 && "$out" == *"$want"* ]]; then
        echo "ok    $want"
    else
        echo "FAIL  expected '$want' for: $*"
        status=1
    fi
}

expect "FORM runs the mgx workflow only"          "${base[@]}" --workflow mtx
expect "--readsdir is required"                   --outdir out --medi_db /d --medi_food_matches /d --medi_food_contents /d
expect "--check_inputs_only true needs"           "${base[@]}" --check_inputs_only true --check_inputs false
expect "medi_input must be humann or kneaddata"   "${base[@]}" --medi_input bogus
expect "medi_input kneaddata requires run_qc"     "${base[@]}" --medi_input kneaddata --run_qc false
expect "medi_input humann requires run_functional_profiling" "${base[@]}" --run_functional_profiling false
expect "requires humann_version humann_v4a"       "${base[@]}" --humann_version humann_v37
expect "run_medi requires: --medi_db"             --readsdir "$root/biobakery/tests/data/rawfastq" --outdir out
expect "remove --remove-temp-output"              "${base[@]}" --humann_options=--remove-temp-output
expect "drop the nucleotide-search bypass"        "${base[@]}" --humann_bypass_nucleotide_search true
expect "drop the nucleotide-search bypass"        "${base[@]}" --humann_options=--bypass-nucleotide-search

exit $status
