#!/usr/bin/env python3

import sys

try:
    import pytoml as toml
except Exception:
    sys.exit(1)
try:
    with open("pyproject.toml", "r") as pyproject:
        p = toml.load(pyproject)
        print(p["tool"]["poetry"]["version"])
except Exception:
    sys.exit(1)
