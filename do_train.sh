#!/usr/bin/env bash
# Train Popper on 1D-ARC (relational decomposition).
set -euo pipefail

tasks_1d=(
  1d_denoising_1c 1d_fill 1d_hollow 1d_move_1p 1d_move_2p_dp 1d_move_dp
  1d_pcopy_1c 1d_recolor_cmp 1d_recolor_oe 1d_denoising_mc 1d_flip 1d_mirror
  1d_move_2p 1d_move_3p 1d_padded_fill 1d_pcopy_mc 1d_recolor_cnt 1d_scale_dp
)

# Parallel jobs: default to number of CPUs (override with JOBS=N).
JOBS="${JOBS:-$(nproc)}"
TIMEOUT="${TIMEOUT:-600}"
trials=(0 1 2)
systems=(popper)
representation=relational

echo "Training 1D-ARC: TIMEOUT=${TIMEOUT}s JOBS=${JOBS} trials=${trials[*]}"

parallel --jobs "$JOBS" \
  python train.py "$TIMEOUT" {1} {2} 1d {3} "$representation" \
  ::: "${trials[@]}" ::: "${systems[@]}" ::: "${tasks_1d[@]}"
