#!/bin/bash
# Runs `npm install` whenever `package.json` changes.
# NOTE: We assume `npm install` runs `bower install`.
# Runs `bower install` whenever `bower.json` changes
set -e

unset GIT_WORK_TREE

# Install all dependencies
# $1 is the name of the JSON file containing dependencies
updateDependencies () {
	if [ $1 == "package.json" ]; then
		PACKAGE_MANAGER=npm
	elif [ $1 == "bower.json" ]; then
		PACKAGE_MANAGER=./node_modules/bower/bin/bower
	fi
	cd "$(git rev-parse --show-toplevel)"
	echo "$1 has changed. Running $PACKAGE_MANAGER install..."
	$PACKAGE_MANAGER install
}

# Check if the JSON containing dependencies has been updated or not
isJsonChanged () {
	git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD | grep --quiet "$1"
}

# Run script

if isJsonChanged 'package.json' ; then
	updateDependencies package.json
else
	if isJsonChanged 'bower.json' ;	then
		updateDependencies bower.json
	fi
fi
