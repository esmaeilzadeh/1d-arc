#!/usr/bin/env bash
# Install and tune a Linux host for 1D-ARC Popper evaluation.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "==> [1/5] System packages (needs sudo)"
if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y \
    build-essential curl git parallel \
    swi-prolog \
    python3 python3-pip python3-venv python3-dev
  # Prefer a newer clingo if available from potassco; fall back to apt.
  if ! command -v clingo >/dev/null 2>&1; then
    sudo apt-get install -y gringo || true
  fi
else
  echo "Non-apt system: install SWI-Prolog, GNU parallel, Python 3.10+ manually."
fi

echo "==> [2/5] Python venv + deps"
python3 -m venv .venv
# shellcheck disable=SC1091
source .venv/bin/activate
pip install --upgrade pip wheel
pip install -r requirements.txt
pip install -e ./popper || true

echo "==> [3/5] Verify toolchain"
swipl --version | head -1
python - <<'PY'
import clingo, janus_swi, pysat, bitarray
print("clingo", getattr(clingo, "__version__", "?"))
print("janus_swi/pysat/bitarray OK")
PY
parallel --version | head -1

echo "==> [4/5] Performance tuning for CPU-bound ILP (best-effort, needs sudo)"
# Popper+clingo are CPU / memory heavy; prefer performance governor and avoid swap thrash.
if [[ -d /sys/devices/system/cpu/cpu0/cpufreq ]]; then
  if command -v cpupower >/dev/null 2>&1; then
    sudo cpupower frequency-set -g performance || true
  else
    for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
      echo performance | sudo tee "$g" >/dev/null || true
    done
  fi
fi

# Milder swappiness helps long-running solver jobs stay in RAM.
if [[ -w /proc/sys/vm/swappiness ]] || sudo test -w /proc/sys/vm/swappiness; then
  echo 10 | sudo tee /proc/sys/vm/swappiness >/dev/null || true
fi

# Raise open files / stack for many parallel Prolog/clingo processes.
ulimit -n 65535 || true
ulimit -s unlimited || true

echo "==> [5/5] Recommended runtime knobs"
NPROC="$(nproc)"
# Leave 1-2 cores for OS if the machine is large.
if (( NPROC > 4 )); then
  SUGGESTED=$((NPROC - 2))
else
  SUGGESTED=$NPROC
fi
cat <<MSG
Setup complete.

Suggested env for this host (${NPROC} CPUs):
  export JOBS=${SUGGESTED}
  export TIMEOUT=600
  export OMP_NUM_THREADS=1
  export OPENBLAS_NUM_THREADS=1
  export MKL_NUM_THREADS=1
  export CLINGO_DEFAULT_THREADS=1

OMP/CLINGO threads=1 avoids oversubscription when JOBS≈nproc.
Then: bash scripts/run_remote_eval.sh
MSG
