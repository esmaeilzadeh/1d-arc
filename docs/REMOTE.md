# Remote machine setup (1D-ARC / Popper)

Popper + Clingo jobs are **CPU- and RAM-bound**, mostly single-threaded per job.
Throughput comes from running many tasks in parallel (`JOBS`), not from GPU.

## 1. Provision the host

Recommended:
- Linux x86_64
- ≥ 16 CPU cores (32+ ideal for 54 jobs)
- ≥ 32 GB RAM (64 GB safer at `TIMEOUT=3600`)
- Fast local SSD for `programs/` writes

Clone and setup:

```bash
git clone git@github.com:<USER>/1d-arc.git
cd 1d-arc
bash scripts/setup_remote.sh
```

## 2. Performance tuning (done by `setup_remote.sh`)

| Knob | Why |
|------|-----|
| CPU governor `performance` | Avoid frequency scaling mid-search |
| `vm.swappiness=10` | Prefer RAM over swap during long Clingo searches |
| `ulimit -n 65535` | Many parallel SWI/Clingo processes open files |
| `OMP_NUM_THREADS=1` (and OpenBLAS/MKL=1) | Prevent BLAS/OpenMP oversubscription when `JOBS≈nproc` |
| `JOBS=nproc-2` | Leave headroom for OS / I/O |

Do **not** raise Clingo threads per job while also setting high `JOBS`; oversubscription slows every trial.

## 3. Run evaluation

```bash
source .venv/bin/activate
export TIMEOUT=600
export JOBS=$(($(nproc)-2))
bash scripts/run_remote_eval.sh
```

Wall-clock estimate (rough): `ceil(54 / JOBS) * TIMEOUT` plus parse/test overhead.
Example: 32 cores → ~2×600s ≈ 20–30 minutes for the 10-min setting.

For the paper’s best 1D number (69±6%):

```bash
TIMEOUT=3600 JOBS=$(($(nproc)-2)) bash scripts/run_remote_eval.sh
```

## 4. Detached / resilient runs

```bash
tmux new -s arc1d
source .venv/bin/activate
TIMEOUT=600 JOBS=$(($(nproc)-2)) bash scripts/run_remote_eval.sh
# Ctrl-b d to detach
```

Or:

```bash
nohup env TIMEOUT=600 JOBS=30 bash scripts/run_remote_eval.sh > eval600.log 2>&1 &
```

## 5. Collect results

```bash
python results.py
# compare to paper 63±7 at TIMEOUT=600
tar czf programs-600.tgz programs/relational/600
```

## 6. Optional: all 50 instances

Paper scripts use trials `{0,1,2}` only. To parse every instance:

```bash
PARSE_MAX_TRIAL=49 python parse_data.py
```
