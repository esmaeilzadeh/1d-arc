#!/usr/bin/env bash
# Test learned 1D-ARC programs.
set -euo pipefail

tasks_1d=(
  1d_denoising_1c 1d_fill 1d_hollow 1d_move_1p 1d_move_2p_dp 1d_move_dp
  1d_pcopy_1c 1d_recolor_cmp 1d_recolor_oe 1d_denoising_mc 1d_flip 1d_mirror
  1d_move_2p 1d_move_3p 1d_padded_fill 1d_pcopy_mc 1d_recolor_cnt 1d_scale_dp
)

JOBS="${JOBS:-$(nproc)}"
TIMEOUT="${TIMEOUT:-600}"
TEST_TIMEOUT="${TEST_TIMEOUT:-600}"
trials=(0 1 2)
systems=(popper)
representation=relational

echo "Testing 1D-ARC: TIMEOUT=${TIMEOUT}s JOBS=${JOBS} trials=${trials[*]}"

parallel --timeout="$TEST_TIMEOUT" --jobs "$JOBS" \
  python test.py "$TIMEOUT" {1} {2} 1d {3} "$representation" \
  ::: "${trials[@]}" ::: "${systems[@]}" ::: "${tasks_1d[@]}"
