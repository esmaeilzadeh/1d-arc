# Next steps: remote training

## 1. Clone on the remote host

```bash
git clone git@github.com:esmaeilzadeh/1d-arc.git
cd 1d-arc
```

## 2. Install + tune for Popper/Clingo throughput

```bash
bash scripts/setup_remote.sh
source .venv/bin/activate
```

This installs SWI-Prolog, GNU parallel, Python deps, and applies host tweaks:
- CPU governor → `performance`
- `vm.swappiness=10`
- higher `ulimit -n`
- prints suggested `JOBS=nproc-2`

## 3. Pin threads (critical when JOBS is high)

```bash
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1
export TIMEOUT=600
export JOBS=$(($(nproc)-2))
```

## 4. Run evaluation (parse → smoke → train → test → aggregate)

Prefer `tmux` so a disconnect does not kill the run:

```bash
tmux new -s arc1d
bash scripts/run_remote_eval.sh
# Ctrl-b d to detach
```

Expect ~`ceil(54/JOBS)*TIMEOUT` wall time for the 10-minute setting.

## 5. Compare to the paper

```bash
python results.py
# target ~ 63 ± 7% at TIMEOUT=600
```

Optional best-paper setting:

```bash
TIMEOUT=3600 JOBS=$(($(nproc)-2)) bash scripts/run_remote_eval.sh
# target ~ 69 ± 6%
```

## 6. Pull artifacts back (optional)

```bash
tar czf programs-600.tgz programs/relational/600
# scp programs-600.tgz laptop:
```
