#!/bin/bash

# Run prettier on the files in the diff.
#
# Tests if prettier exists

formatter=${PRETTIER_BIN:-./node_modules/.bin/prettier}

if [ ! -f "$formatter" ]; then
    return 0
fi

STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM -- '*.js' '*.scss' | sed 's| |\\ |g')

CHANGED_UNSTAGED_FILES=$(git diff --name-only)

if [ ! -z "$STAGED_FILES" ]; then
    if [ ! -z "$CHANGED_UNSTAGED_FILES" ]; then
        # if there's changed stuff that isn't staged, we dont want to format the unstaged stuff too
        git stash --keep-index
    fi

    # Format all selected files
    echo "$STAGED_FILES" | xargs "$formatter" --write

    # Check for the exit code
    if [ $? -ne 0 ]; then
        exit 1
    fi

    # Add back the modified/prettified files to staging
    echo "$STAGED_FILES" | xargs git add -u


    if [ ! -z "$CHANGED_UNSTAGED_FILES" ]; then
        # put everything back in its place, hopefully without any merge conflicts...
        git stash pop
    fi
fi
