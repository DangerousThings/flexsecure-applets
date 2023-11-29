#!/usr/bin/env bash

cd "${0%/*}"

FAIL=0

for i in compile/*.sh; do
    [ -f "$i" ] || break
    if [[ "$i" != *"apex-fido2"* && "$i" != *"apex-tesla"* && "$i" != *"apex-ndef"* && "$i" != *"apex-spark"* ]] || [[ "$1" == "private" ]]; then
        echo "Compiling $i"
        $i
    else
        echo "Skipping $i"
    fi
    if [ "$?" != 0 ]; then
        FAIL=1
    fi
done

if [ "$FAIL" == 0 ]; then
    echo "All binaries compiled successfully."
    exit 0
else
    echo "One or more binaries failed to compile."
    exit 1
fi
