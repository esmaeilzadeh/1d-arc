#!/usr/bin/env python3
"""Learn a Popper program for one 1D-ARC task/trial."""

import sys
import time
import pathlib

# Prefer vendored Popper in ./popper
_ROOT = pathlib.Path(__file__).resolve().parent
if str(_ROOT) not in sys.path:
    sys.path.insert(0, str(_ROOT))

from popper.popper.util import Settings
from popper.popper.loop import learn_solution


if __name__ == "__main__":
    timeout = int(sys.argv[1])
    trial = int(sys.argv[2])
    system = sys.argv[3].strip()
    domain = sys.argv[4].strip()
    task = sys.argv[5].strip()
    representation = sys.argv[6].strip()

    if domain != "1d":
        raise SystemExit(f"This repo only supports domain=1d, got {domain!r}")

    path = f"train/{representation}/{domain}/{task}/{trial}"
    prog_path = f"programs/{representation}/{timeout}/{domain}/{task}/{system}/{trial}"
    pathlib.Path(prog_path).mkdir(parents=True, exist_ok=True)

    ex_file = f"{path}/exs.pl"
    bk_file = f"{path}/bk.pl"
    bias_file = f"{path}/bias.pl"

    print(f"python train.py {timeout=} {trial} {system} {domain} {task} {path} -> {prog_path}")

    SOLVER = "rc2"
    if system != "popper":
        raise SystemExit(f"Unsupported system: {system}")

    settings = Settings(
        cmd_line=False,
        quiet=False,
        solver=SOLVER,
        ex_file=ex_file,
        bk_file=bk_file,
        bias_file=bias_file,
        timeout=timeout,
    )

    t1 = time.time()
    prog, terminated_by_timeout = learn_solution(settings)
    t2 = time.time()
    duration = t2 - t1

    if prog is not None:
        print(prog, duration)

    with open(prog_path + "/program.pl", "w+") as f:
        if prog is not None:
            f.write(prog + "\n")
        f.write(f"% learning time: {duration}\n")
        f.write(f"% terminated: {not terminated_by_timeout}\n")
