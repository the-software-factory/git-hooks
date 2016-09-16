#!/bin/bash
# Perform pre-push checks. In particular, check that the commit message format
# is correct and that we are not pushing to protected branches
#
# For a complete documentation see https://git-scm.com/docs/githooks

PROTECTED_BRANCHES="^(master|devel)"
z40=0000000000000000000000000000000000000000
with_refs=0

check_commits() {
    range=$1
    commit=`git rev-list -n 1 --grep '^[A-Z]\{2,\}-[0-9]\+:' --invert-grep --since 2016-09-01 --no-merges "$range"`
    if [ -n "$commit" ]
    then
        echo >&2 "Found commit with wrong message format in $commit, not pushing."
        exit 1
    fi
}

# This script is based on the git hook pre-push.sample
while read local_ref local_sha remote_ref remote_sha
do
    with_refs=1
    if [ "$local_sha" != $z40 ]
    then
      if [ "$remote_sha" = $z40 ]
      then
        # New branch, examine all commits
        range="$local_sha"
      else
        # Update to existing branch, examine new commits
        range="$remote_sha..$local_sha"
      fi

      check_commits $range
    fi

    # Prevents pushing to master or devel (protected branches)
    # It returns to the variable only the remote branch name, without path
    REMOTE_BRANCH="${remote_ref##*/}"
    if [[ "$REMOTE_BRANCH" =~ $PROTECTED_BRANCHES ]]; then
        echo "Prevented push to protected branch \"$REMOTE_BRANCH\" by pre-push hook"
        exit 1
    fi
done

if [ $with_refs -eq 0 ]
then
    check_commits "HEAD"
fi
