#!/usr/bin/env bash
# Idempotent Cloud Agent install — runs after repo checkout.
set -euo pipefail

cd "$(dirname "$0")/.."

python3 -m venv .venv
# shellcheck disable=SC1091
source .venv/bin/activate
python -m pip install --upgrade pip wheel
python -m pip install -r requirements.txt
python -m pip install -e ./popper

python - <<'PY'
import clingo, janus_swi, pysat, bitarray
print("clingo", getattr(clingo, "__version__", "?"))
print("cloud-agent deps ok")
PY

# Parse paper trials 0..2 if missing
if [[ ! -f train/relational/1d/1d_denoising_1c/1/exs.pl ]]; then
  PARSE_MAX_TRIAL=2 python parse_data.py
fi

echo "Cloud Agent install complete."
echo "Smoke: python train.py 60 0 popper 1d 1d_denoising_1c relational"
echo "Full:  TIMEOUT=600 JOBS=\$((\$(nproc)-1)) bash scripts/run_remote_eval.sh"
