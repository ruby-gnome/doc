#!/bin/sh

run()
{
    $@
    if test $? -ne 0; then
	echo "Failed $@"
	exit 1
    fi
}

run git checkout master
run git svn rebase
run git checkout hiki
run git merge master
run git push --verbose sf.jp hiki:master
run git checkout master
