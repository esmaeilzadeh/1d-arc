#!/usr/bin/env python3
"""Parse raw 1D-ARC JSON into Popper relational train/test files."""

from raw_data.onedarcraw.decompo_parser import parse1d


if __name__ == "__main__":
    parse1d()
