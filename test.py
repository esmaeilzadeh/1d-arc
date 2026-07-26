#!/usr/bin/env python3
"""Evaluate a learned program on held-out 1D-ARC test facts."""

import sys
import os
from janus_swi import query_once, consult


def do_test(program_file, task_path):
    consult("test.pl")
    consult(os.path.join(task_path, "test.pl"))
    print(program_file)
    try:
        consult(program_file)
        res = query_once("do_test_ex(TP,FN,TN,FP)")
        tp, fn, tn, fp = res["TP"], res["FN"], res["TN"], res["FP"]
        return [tp, fn, tn, fp]
    except Exception:
        num_pos = query_once("num_pos(P)")["P"]
        num_neg = query_once("num_neg(N)")["N"]
        return [0, num_pos, num_neg, 0]


if __name__ == "__main__":
    timeout = int(sys.argv[1])
    trial = int(sys.argv[2])
    system = sys.argv[3].strip()
    domain = sys.argv[4].strip()
    task = sys.argv[5].strip()
    representation = sys.argv[6].strip()

    if domain != "1d":
        raise SystemExit(f"This repo only supports domain=1d, got {domain!r}")

    path = f"train/{representation}/{domain}/{task}/{trial}/"
    prog_dir = f"programs/{representation}/{timeout}/{domain}/{task}/{system}/{trial}"
    prog_path = f"{prog_dir}/program.pl"

    os.makedirs(prog_dir, exist_ok=True)
    matrix = do_test(prog_path, path)

    with open(f"{prog_dir}/results.pl", "w+") as f:
        f.write(f"% matrix: {matrix}\n")
        if matrix[1] == 0 and matrix[3] == 0:
            f.write("% solved: True\n")
        else:
            f.write("% solved: False\n")
