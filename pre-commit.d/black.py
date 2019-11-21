#!/usr/bin/env python

import os
import subprocess
import sys

from shutil import which

if not os.getenv("VIRTUAL_ENV"):
    sys.exit("Ensure your virtualenv is activated.")

file_extensions = (".py",)
line_length = os.getenv("BLACK_LINE_LENGTH", 88)
black = os.getenv("BLACK_BIN", "black")
options = ["-l", str(line_length),]

if not which(black):
    sys.exit("Black binary not found")

diff = subprocess.check_output(
    ["git", "diff", "--cached", "--name-only", "--diff-filter", "ACM"],
    universal_newlines=True
)

python_files = [
    item for item in diff.splitlines() if item.endswith(file_extensions)
]

if not python_files:
    sys.exit(0)

try:
    output = subprocess.check_output(
        [black, *options, *python_files], universal_newlines=True, stderr=subprocess.STDOUT
    )
except subprocess.CalledProcessError as e:
    print("Formatting was unsuccessful:")
    sys.exit(e.stdout)

subprocess.run(["git", "add", "-u", *python_files])
sys.exit(0)
