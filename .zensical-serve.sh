#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
VENV="$ROOT/.venv-docs"

if [[ ! -x "$VENV/bin/zensical" ]]; then
    python3 -m venv "$VENV"
    "$VENV/bin/python" -m pip install -r "$ROOT/docs/requirements.txt"
fi

has_address=false
for arg in "$@"; do
    if [[ "$arg" == "--dev-addr" || "$arg" == --dev-addr=* ]]; then
        has_address=true
        break
    fi
done

cd "$ROOT"
if [[ "$has_address" == true ]]; then
    exec "$VENV/bin/zensical" serve "$@"
else
    exec "$VENV/bin/zensical" serve --dev-addr 127.0.0.1:8001 "$@"
fi
