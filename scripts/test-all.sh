#!/bin/bash

cd "${0%/*}"

for i in test/*.bats; do
    [ -f "$i" ] || break
    echo "Testing $i"
    $i
done
