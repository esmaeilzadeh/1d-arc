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

## Cursor Cloud Agents (Pro)

There is **no free Cursor machine**. Cloud Agents (Pro+) can clone this repo on a Cursor-hosted Ubuntu VM.

1. Create an API key: https://cursor.com/dashboard/api
2. Connect GitHub to Cursor and ensure `esmaeilzadeh/1d-arc` is accessible
3. Launch from https://cursor.com/agents or:

```bash
curl -u "$CURSOR_API_KEY:" -H 'Content-Type: application/json' \
  https://api.cursor.com/v1/agents \
  -d '{
    "prompt": {"text": "Install nothing beyond environment. Run: bash scripts/setup_remote.sh if needed, then TIMEOUT=60 JOBS=2 bash scripts/run_remote_eval.sh for a smoke/short run. Default Cloud VMs are too small for TIMEOUT=600 x 54 jobs; prefer TIMEOUT=60 or a few tasks. Report results.py output."},
    "repos": [{"url": "https://github.com/esmaeilzadeh/1d-arc", "startingRef": "main"}],
    "autoCreatePR": false
  }'
```

`.cursor/environment.json` + `.cursor/Dockerfile` configure the VM for SWI-Prolog / Clingo / parallel.
