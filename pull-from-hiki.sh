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
run git merge master               # swap?
run git pull --no-ff sf.jp master  # swap?
run git checkout master
run git merge hiki
run git svn dcommit
