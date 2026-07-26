# Cloud Agent base for 1D-ARC / Popper evaluation
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# System deps. Ubuntu's swi-prolog is 9.0.4, which lacks the janus bridge that
# janus-swi needs; the official PPA provides SWI-Prolog >= 9.2. python-is-python3
# is required because the helper scripts (do_train.sh/do_test.sh/smoke.sh) call
# `python`, not `python3`.
RUN apt-get update && apt-get install -y --no-install-recommends \
      software-properties-common ca-certificates curl git build-essential \
      parallel python3 python3-pip python3-dev python3-venv python3-setuptools \
      python-is-python3 \
    && add-apt-repository -y ppa:swi-prolog/stable \
    && apt-get update && apt-get install -y --no-install-recommends swi-prolog \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# Python deps installed system-wide. setuptools<81 keeps pkg_resources, which the
# vendored Popper (popper/popper/tester.py) imports. Do NOT `pip install -e ./popper`:
# the PEP 660 editable install shadows the vendored `popper.popper` import path.
COPY requirements.txt ./requirements.txt
RUN python3 -m pip install --break-system-packages --no-cache-dir \
      'setuptools<81' -r requirements.txt
