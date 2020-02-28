#!/usr/bin/env python

import os
import subprocess
import sys

from shutil import which

homedir = os.path.expanduser("~")
tag_dir = os.path.join(homedir, ".tags")
tag_file = "<name-your-tags-here>.tags"
options = ["-f", f"{tag_dir}/{tag_file}", "-R", os.getcwd()]

if not os.getenv("CREATE_TAGS"):
    sys.exit(0)

if not which("ctags"):
    sys.exit("ctags binary is not executable or not present!")

if not os.path.exists(tag_dir):
    os.mkdir(tag_dir)

try:
    output = subprocess.check_output(
        ["ctags", *options], universal_newlines=True, stderr=subprocess.STDOUT
    )
except subprocess.CalledProcessError as e:
    sys.exit(e.stdout)
