#!/bin/bash

cd /app/src/applets/openjavacard-ndef
ant -DJAVACARD_HOME=/app/sdks/jc222_kit build
cp /app/src/applets/openjavacard-ndef/build/javacard/*.cap /app/src/bin/
