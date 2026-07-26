#!/usr/bin/env python3
"""Aggregate predictive accuracy for 1D-ARC Popper runs."""

import re
import numpy as np
import scipy.stats as stats

TRIALS = [0, 1, 2]
TASKS = [
    "1d_denoising_1c",
    "1d_fill",
    "1d_hollow",
    "1d_move_1p",
    "1d_move_2p_dp",
    "1d_move_dp",
    "1d_pcopy_1c",
    "1d_recolor_cmp",
    "1d_recolor_oe",
    "1d_denoising_mc",
    "1d_flip",
    "1d_mirror",
    "1d_move_2p",
    "1d_move_3p",
    "1d_padded_fill",
    "1d_pcopy_mc",
    "1d_recolor_cnt",
    "1d_scale_dp",
]

PATH = "programs/relational"
DOMAIN = "1d"
TIMEOUT = 600
SYSTEM = "popper"

accuracy = []
missing = []
for task in TASKS:
    for trial in TRIALS:
        prog_path = f"{PATH}/{TIMEOUT}/{DOMAIN}/{task}/{SYSTEM}/{trial}/results.pl"
        try:
            with open(prog_path, "r") as f:
                lines = f.readlines()
        except FileNotFoundError:
            missing.append(prog_path)
            continue
        for line in lines:
            if line.startswith("% matrix:"):
                match = re.search(
                    r"% matrix: \[([^,]+),([^,]+),([^,]+),([^\]]+)\]", line
                )
                if match:
                    tp, fn, tn, fp = match.groups()
                    tp, fn, tn, fp = int(tp), int(fn), int(tn), int(fp)
                    if tp + fn + tn + fp:
                        accuracy.append((tp + tn) / (tp + fn + tn + fp))
                else:
                    raise AssertionError(f"Bad matrix line in {prog_path}: {line}")

if missing:
    print(f"missing {len(missing)} result files (showing up to 5):")
    for p in missing[:5]:
        print(f"  {p}")

if not accuracy:
    raise SystemExit("No accuracy values found")

print(
    f"accuracy for {DOMAIN} with timeout {TIMEOUT}: "
    f"{np.mean(accuracy)} \\pm {stats.sem(accuracy)}"
)
print(f"n={len(accuracy)} (expected {len(TASKS) * len(TRIALS)})")
