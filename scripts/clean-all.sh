#!/usr/bin/env bash

cd "${0%/*}"

for i in clean/*.sh; do
    [ -f "$i" ] || break
    echo "Cleaning $i"
    $i
done

echo "Cleaning binaries"
cd /app/src/bin && rm *.cap *.jar
