#!/usr/bin/env bash
# Parse data, smoke-test, then full 1D-ARC train/test at TIMEOUT (default 600).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ -f .venv/bin/activate ]]; then
  # shellcheck disable=SC1091
  source .venv/bin/activate
fi

export TIMEOUT="${TIMEOUT:-600}"
export JOBS="${JOBS:-$(nproc)}"
export OMP_NUM_THREADS="${OMP_NUM_THREADS:-1}"
export OPENBLAS_NUM_THREADS="${OPENBLAS_NUM_THREADS:-1}"
export MKL_NUM_THREADS="${MKL_NUM_THREADS:-1}"
export PARSE_MAX_TRIAL="${PARSE_MAX_TRIAL:-2}"

echo "==> Parsing 1D relational data (trials 0..${PARSE_MAX_TRIAL})"
python parse_data.py

echo "==> Smoke train/test (60s, 1d_denoising_1c trial 0)"
python train.py 60 0 popper 1d 1d_denoising_1c relational
python test.py 60 0 popper 1d 1d_denoising_1c relational
ls -la programs/relational/60/1d/1d_denoising_1c/popper/0/

echo "==> Full train TIMEOUT=${TIMEOUT}s JOBS=${JOBS}"
bash do_train.sh

echo "==> Full test"
bash do_test.sh

echo "==> Aggregate"
python results.py
