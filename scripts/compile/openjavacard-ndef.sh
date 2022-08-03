#!/bin/bash

mkdir -p /app/src/bin
cd /app/src/applets/openjavacard-ndef
cp /app/src/scripts/compile/res/openjavacard-ndef.build.xml .
ant -DJAVACARD_HOME=/app/sdks/jc222_kit -buildfile openjavacard-ndef.build.xml build
cd /app/src/applets/openjavacard-ndef/build/javacard
cp *full.cap *tiny.cap /app/src/bin/
