# Cloud Agent base for 1D-ARC / Popper (IJCAI 2025 relational decomposition).
# System packages only — repo is checked out by Cursor after the image builds.
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    OMP_NUM_THREADS=1 \
    OPENBLAS_NUM_THREADS=1 \
    MKL_NUM_THREADS=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    parallel \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    swi-prolog \
    && rm -rf /var/lib/apt/lists/*

# Ensure ubuntu user exists (Ubuntu 24.04 images include it).
RUN id ubuntu >/dev/null 2>&1 || useradd -m -s /bin/bash ubuntu

USER ubuntu
WORKDIR /home/ubuntu

# Verify toolchain at build time (fails early if packages are broken).
RUN swipl --version && parallel --version | head -1 && python3 --version
