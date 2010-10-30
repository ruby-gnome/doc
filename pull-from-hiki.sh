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
run git pull --rebase
run git checkout hiki
run git merge master
run git pull
run git checkout master
run git merge hiki
