#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
[[ -f .venv/bin/activate ]] && source .venv/bin/activate
python train.py 60 0 popper 1d 1d_denoising_1c relational
python test.py 60 0 popper 1d 1d_denoising_1c relational
cat programs/relational/60/1d/1d_denoising_1c/popper/0/results.pl
