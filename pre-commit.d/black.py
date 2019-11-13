#!/usr/bin/env python

import os
import subprocess
import sys

file_extensions = (".py",)

user_dir = os.path.expanduser("~")
formatter_path = os.path.join(user_dir, ".")

if not os.getenv("VIRTUAL_ENV"):
    exit("Ensure your virtualenv is activated.", 1)

line_length = os.getenv("BLACK_LINE_LENGTH", 88)

formatter = os.getenv("BLACK_BIN", "black")
options = f"-l {line_length}"

if not os.path.isfile(formatter):
    exit(f"Formatter not found in {formatter}", 1)

files = subprocess.check_output(
    ["git", "diff", "--cached", "--name-only", "--diff-filter", "ACM", "-- '*.py'"],
)

if not files:
    sys.exit("No files left to format", 0)

try
    output = subprocess.check_output(["formatter", *files])
except CalledProcessError as e:
    print(f"Formatting was unsuccessful")
    sys.exit(output.stdout, 1)

subprocess.run(["git", "add", "-u", *files])
sys.exit("Black ran successfully", 0)
