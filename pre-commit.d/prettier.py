#!/usr/bin/env python

import os
import subprocess
import sys

from shutil import which

if not os.getenv("VIRTUAL_ENV"):
    sys.exit("Ensure your virtualenv is activated.")

file_extensions = (".js", ".jsx",)
prettier = os.getenv("PRETTIER_BIN", "./node_modules/.bin/prettier")
options = ["--write"]

if not which(prettier):
    sys.exit("Prettier binary not found")

diff = subprocess.check_output(
    ["git", "diff", "--cached", "--name-only", "--diff-filter", "ACM"],
    universal_newlines=True
)

javascript_files = [
    item for item in diff.splitlines() if item.endswith(file_extensions)
]

if not javascript_files:
    sys.exit(0)

try:
    output = subprocess.check_output(
        [prettier, *options, *javascript_files],
        universal_newlines=True,
        stderr=subprocess.STDOUT
    )
except subprocess.CalledProcessError as e:
    print("Formatting was unsuccessful:")
    sys.exit(e.stdout)

subprocess.run(["git", "add", "-u", *javascript_files])
sys.exit(0)
