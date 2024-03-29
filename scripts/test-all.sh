#!/usr/bin/env bash

cd "${0%/*}"

FAIL=0

for i in test/*.bats; do
    [ -f "$i" ] || break
    if [[ "$i" != *"apex-fido2"* && "$i" != *"apex-tesla"* && "$i" != *"apex-ndef"* && "$i" != *"apex-spark"* ]] || [[ "$1" == "private" ]]; then
        echo "Testing $i"
        $i
    else
        echo "Skipping $i"
    fi
    if [ "$?" != 0 ]; then
        echo "Failed to test $i"
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
