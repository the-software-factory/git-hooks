#!/bin/bash
# Perform pre-push checks. In particular, check that the commit message format
# is correct and that we are not pushing to protected branches
#
# For a complete documentation see https://git-scm.com/docs/githooks

PROTECTED_BRANCHES="^(master|devel)$"

# This script is based on the git hook pre-push.sample
while read local_ref local_sha remote_ref remote_sha
do
    # Prevents pushing to master or devel (protected branches)
    # It returns to the variable only the remote branch name, without path
    REMOTE_BRANCH="${remote_ref##*/}"
    if [[ "$REMOTE_BRANCH" =~ $PROTECTED_BRANCHES ]]; then
        echo "Prevented push to protected branch \"$REMOTE_BRANCH\" by pre-push hook"
        exit 1
    fi
done
