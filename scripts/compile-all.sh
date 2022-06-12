#!/bin/bash

cd "${0%/*}"

for i in compile/*.sh; do
    [ -f "$i" ] || break
    echo "Compiling $i"
    $i
done
