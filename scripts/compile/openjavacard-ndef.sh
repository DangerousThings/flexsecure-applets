#!/bin/bash

mkdir -p /app/src/bin
cd /app/src/applets/openjavacard-ndef
ant -DJAVACARD_HOME=/app/sdks/jc222_kit build
cd /app/src/applets/openjavacard-ndef/build/javacard
cp *full.cap *tiny.cap /app/src/bin/
