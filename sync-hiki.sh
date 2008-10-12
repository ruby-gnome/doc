#!/bin/sh

run()
{
    $@
    if test $? -ne 0; then
	echo "Failed $@"
	exit 1
    fi
}

run ./pull-from-hiki.sh
run ./push-to-hiki.sh
