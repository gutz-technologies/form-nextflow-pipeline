#!/usr/bin/env bash
# Preview the FORM documentation with the pinned Zensical.
#
# Zensical 0.1.2 needs Python 3.11 or later; the documentation CI uses 3.12.
# The helper uses $PYTHON if set, otherwise python3.12, otherwise python3,
# and stops with a clear message if that interpreter is too old.
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
VENV="$ROOT/.venv-docs"

# A usable interpreter is Python 3.11+ that can create a virtual environment
# (Debian/Ubuntu ship python3.12 without ensurepip unless python3.12-venv is
# installed).
usable() {
    command -v "$1" >/dev/null 2>&1 &&
        "$1" -c 'import sys, venv, ensurepip; sys.exit(sys.version_info < (3, 11))' 2>/dev/null
}

if [[ -n "${PYTHON:-}" ]]; then
    candidates=("$PYTHON")
else
    candidates=(python3.12 python3.13 python3.11 python3)
fi

py=""
for candidate in "${candidates[@]}"; do
    if usable "$candidate"; then
        py="$candidate"
        break
    fi
done

if [[ -z "$py" ]]; then
    echo "error: no usable Python found (tried: ${candidates[*]})." >&2
    echo "Zensical needs Python 3.11 or later with the venv module; CI uses 3.12." >&2
    echo "Install Python 3.12 (on Debian/Ubuntu also python3.12-venv)," >&2
    echo "or set PYTHON=/path/to/python3.12." >&2
    exit 1
fi

# Rebuild the environment if Zensical is missing or the environment was made
# with a Python older than 3.11, for example by an earlier failed run.
if [[ ! -x "$VENV/bin/zensical" ]] ||
   ! "$VENV/bin/python" -c 'import sys; sys.exit(sys.version_info < (3, 11))' 2>/dev/null; then
    rm -rf -- "$VENV"
    "$py" -m venv "$VENV"
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
