#!/bin/bash

cd "${0%/*}"

FAIL=0

for i in test/*.bats; do
    [ -f "$i" ] || break
    $i
    if [ "$?" != 0 ]; then
        FAIL=1
    fi
done

if [ "$FAIL" == 0 ]; then
    echo "All tests passed."
    exit 0
else
    echo "One or more tests failed."
    exit 1
fi
