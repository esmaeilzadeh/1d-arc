# 1d-arc

Reproduce the **1D-ARC** evaluation from
[Relational Decomposition for Program Synthesis](https://arxiv.org/pdf/2408.12212)
(Hocquette & Cropper, IJCAI 2025) using Popper with a relational pixel decomposition.

This repository is **1D-only** (no ARC / strings / lists domains, no `sources/` tree).

## Paper targets (Decom / 1D-ARC)

| Max learning time | Predictive accuracy |
|-------------------|---------------------|
| 1 min (`TIMEOUT=60`) | 59 ± 7% |
| 10 min (`TIMEOUT=600`) | 63 ± 7% |
| 60 min (`TIMEOUT=3600`) | 69 ± 6% |

Setup: 18 task types × trials `{0,1,2}` = 54 jobs.

## Requirements

- SWI-Prolog ≥ 9.2
- Clingo ≥ 5.6.2 (Python package `clingo` recommended)
- GNU `parallel`
- Python 3.10+ packages in `requirements.txt`

## Quick start (local)

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
pip install -e ./popper   # optional; train.py imports vendored package path

# Parse JSON -> train/relational/1d/{task}/{trial}/ (trials 0..2 by default)
python parse_data.py

# Smoke test
python train.py 60 0 popper 1d 1d_denoising_1c relational
python test.py 60 0 popper 1d 1d_denoising_1c relational

# Full 10-minute evaluation
TIMEOUT=600 JOBS=$(nproc) bash do_train.sh
TIMEOUT=600 JOBS=$(nproc) bash do_test.sh
python results.py
```

Outputs land in:

`programs/relational/{TIMEOUT}/1d/{task}/popper/{trial}/{program,results}.pl`

## Remote machine

See [docs/REMOTE.md](docs/REMOTE.md) and:

```bash
bash scripts/setup_remote.sh        # install deps + tune host for ILP workloads
bash scripts/run_remote_eval.sh     # parse + smoke + full TIMEOUT=600 run
```

## Layout

```
train.py / test.py / results.py   # learning, testing, aggregation (timeout in path)
do_train.sh / do_test.sh          # GNU parallel drivers for 18×3
parse_data.py                     # 1D relational decomposition parser
raw_data/onedarcraw/              # upstream 1D-ARC JSON + decompo_parser.py
popper/                           # vendored Popper ILP system
train/relational/1d/              # generated (and bootstrapped) Popper inputs
scripts/                          # remote setup & evaluation helpers
```

## Citation

```
@inproceedings{hocquette2025relational,
  title={Relational Decomposition for Program Synthesis},
  author={Hocquette, C{\'e}line and Cropper, Andrew},
  booktitle={IJCAI},
  year={2025}
}
```

Upstream experiment code: https://github.com/celinehocquette/ijcai25-relational-decomposition
