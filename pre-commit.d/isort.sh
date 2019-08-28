#!/bin/bash

#
# Run isort on the files in the diff.
#
# 1. Virtualenv must be activated
# 2. isort must be installed in the virtualenv (and thus be available in your
#    path)
#
#

if  [ -z $VIRTUAL_ENV ]; then
    1>&2 echo "Ensure your virtualenv is activated."
    exit 1
fi

# The formatter to use
# default -> available in venv or $PATH
formatter=${ISORT_BIN:-isort}

# Check availability of the formatter
if [ -z "$formatter" ]
then
  1>&2 echo "$formatter not found. Pre-commit formatting will not be done."
  exit 1
fi

STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM -- '*.py' | sed 's| |\\ |g')

CHANGED_UNSTAGED_FILES=$(git diff --name-only)

if [ ! -z "$STAGED_FILES" ]; then
    if [ ! -z "$CHANGED_UNSTAGED_FILES" ]; then
        # if there's changed stuff that isn't staged, we dont want to format the unstaged stuff too
        git stash --keep-index
    fi

    # Format all selected files
    echo "$FILES" | xargs "$formatter"

    # Check for the exit code
    if [ $? -ne 0 ]; then
        exit 1
    fi

    # Add back the modified/prettified files to staging
    echo "$FILES" | xargs git add -u


    if [ ! -z "$CHANGED_UNSTAGED_FILES" ]; then
        # put everything back in its place, hopefully without any merge conflicts...
        git stash pop
    fi
fi
