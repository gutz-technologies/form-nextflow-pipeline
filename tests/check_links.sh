#!/usr/bin/env bash
# bioBakery modules find their scripts and assets through ${projectDir}, which
# is this repo's root once bioBakery is a submodule. FORM makes those paths
# resolve with symlinks instead of editing bioBakery: assets/ links to
# biobakery/assets, and bin/ (a real folder, so FORM's own scripts can sit in
# it) holds one link per top-level entry of biobakery/bin.
#
#   tests/check_links.sh         fail if a link is missing or dangling
#   tests/check_links.sh --fix   create the missing links (after a submodule bump)
set -euo pipefail
cd "$(dirname "$0")/.."

fix=false
[[ "${1:-}" == "--fix" ]] && fix=true
status=0

[[ -d biobakery/bin ]] || { echo "biobakery/ is empty: run git submodule update --init"; exit 1; }

for src in biobakery/bin/*; do
    name=$(basename "$src")
    link="bin/$name"
    if [[ -L "$link" ]]; then
        continue
    elif [[ -e "$link" ]]; then
        echo "bin/$name is a FORM file, but bioBakery also has bin/$name"
        status=1
    elif $fix; then
        ln -s "../$src" "$link"
        echo "linked $link -> ../$src"
    else
        echo "missing link: $link -> ../$src"
        status=1
    fi
done

for link in assets bin/*; do
    if [[ -L "$link" && ! -e "$link" ]]; then
        echo "dangling link: $link -> $(readlink "$link")"
        status=1
    fi
done

[[ -L assets ]] || { echo "assets should link to biobakery/assets"; status=1; }

if [[ $status -ne 0 && $fix == false ]]; then
    echo "Run tests/check_links.sh --fix"
fi
exit $status
