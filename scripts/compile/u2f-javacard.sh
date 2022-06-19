#!/bin/bash

mkdir -p /app/src/bin /app/src/applets/u2f-javacard/target
cd /app/src/applets/u2f-javacard
cp /app/src/scripts/compile/res/u2f-javacard.build.xml .
JC_HOME=/app/sdks/jc304_kit ant -buildfile u2f-javacard.build.xml
cp /app/src/applets/u2f-javacard/target/*.cap /app/src/bin/
