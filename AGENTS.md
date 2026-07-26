# AGENTS.md

## Cursor Cloud specific instructions

This repo reproduces the **1D-ARC** evaluation using the vendored **Popper** ILP
system (SWI-Prolog + Clingo). See `README.md` for the full workflow and paper
targets; the notes below only cover non-obvious setup/run caveats.

### Environment
- System deps come from `.cursor/Dockerfile` (source of truth): **SWI-Prolog >= 9.2
  via `ppa:swi-prolog/stable`**, GNU `parallel`, and `python-is-python3`. Ubuntu's
  default `swi-prolog` (9.0.4) is too old — it lacks the `janus` bridge that
  `janus-swi` needs, so the PPA is required.
- Python deps are installed **system-wide** (`pip install --break-system-packages
  -r requirements.txt`). No virtualenv is used by default.
- The startup update script only refreshes Python deps; it does not install system
  packages. If the Dockerfile changes are not merged, a fresh VM will be missing
  SWI-Prolog/parallel and `janus-swi` will fail to build — rebuild from the
  Dockerfile (or reinstall those system deps) in that case.

### Gotchas
- **Do NOT `pip install -e ./popper`.** The PEP 660 editable install registers a
  top-level `popper` package that shadows the vendored `popper.popper.*` import
  path and breaks `train.py`. The vendored code is used directly because
  `train.py`/`test.py` prepend the repo root to `sys.path`. The `-e ./popper` step
  mentioned in the README is optional and currently harmful.
- `setuptools<81` is required: newer setuptools removed `pkg_resources`, which the
  vendored `popper/popper/tester.py` imports.
- The helper scripts (`do_train.sh`, `do_test.sh`, `smoke.sh`, `run_remote_eval.sh`)
  and the README call `python` (not `python3`); `python-is-python3` provides it.

### Running
- Standard commands are in `README.md`. Quick smoke (no venv needed):
  `python parse_data.py` then `python train.py 60 0 popper 1d 1d_denoising_1c relational`
  and `python test.py 60 0 popper 1d 1d_denoising_1c relational`. A solved run writes
  `% solved: True` to `programs/relational/60/1d/.../results.pl`.
- Full eval: `TIMEOUT=<s> JOBS=$(nproc) bash do_train.sh` then `do_test.sh`. This is
  54 CPU-heavy jobs (18 tasks x 3 trials); on small VMs use a short `TIMEOUT` for
  smoke tests. `results.py` aggregates and is hardcoded to `TIMEOUT=600`, so it only
  reports for runs done at that timeout.
- There is no linter config and no automated (pytest) suite in this repo; the
  train/test ILP pipeline is the effective test.

### Generated files (not committed)
- `programs/` is gitignored. `parse_data.py` regenerates `train/relational/1d/<task>/<trial>/`
  inputs (only trial `0` is committed; trials `1`/`2` are regenerated).
