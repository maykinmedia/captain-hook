#!/bin/bash
#
# Called by "git commit" with no arguments.  The hook should
# exit with non-zero status after issuing an appropriate message if
# it wants to stop the commit.
#
# Taken from https://gist.github.com/ralovely/9367737
#
# Requires the envvar VAULT_FILES to be set to a comma-separated list of
# files that are considered to be vault-encrypted:
#
# export VAULT_FILES=foo/bar.yml,foo/baz.yml
#

# Unset variables produce errors
set -u

if git rev-parse --verify HEAD >/dev/null 2>&1
then
    against=HEAD
else
    # Initial commit: diff against an empty tree object
    against=0000000000000000000000000000000000000000
fi

IFS=','; FILES=(${VAULT_FILES:-}); unset IFS;

# Redirect output to stderr.
exec 1>&2

# Check that all changed *.vault files are encrypted
# read: -r do not allow backslashes to escape characters; -d delimiter
while IFS= read -r -d $'\0' file; do
    # test if the file is considered an ansible-vault file
    [[ " ${FILES[*]} " != *"$file"* ]] && continue
    # cut gets symbols 1-2
    file_status=$(git status --porcelain -- "$file" 2>&1 | cut -c1-2)
    file_status_index=${file_status:0:1}
    file_status_worktree=${file_status:1:1}
    [[ "$file_status_worktree" != ' ' ]] && {
        echo "ERROR: vault file is modified in worktree but not added to the index: $file"
        echo "Can not check if it is properly encrypted. Use git add or git stash to fix this."
        exit 1
    }
    # check is neither required nor possible for deleted files
    [[ "$file_status_index" = 'D' ]] && continue
    head -1 "$file" | grep --quiet '^\$ANSIBLE_VAULT;' || {
        echo "ERROR: non-encrypted vault file: $file"
        exit 1
    }
done < <(git diff --cached --name-only -z "$against")
