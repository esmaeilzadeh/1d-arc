# Cloud Agent base for 1D-ARC / Popper evaluation
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential curl ca-certificates git parallel \
    python3 python3-pip python3-venv python3-dev \
    swi-prolog \
    && rm -rf /var/lib/apt/lists/*

# Clingo via pip (prefer >=5.6.2); system may also provide gringo later
RUN python3 -m pip install --break-system-packages --no-cache-dir \
    'clingo>=5.6.2' bitarray janus-swi python-sat multiprocess numpy scipy

WORKDIR /workspace
