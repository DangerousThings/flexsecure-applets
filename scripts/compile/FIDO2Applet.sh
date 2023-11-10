#!/bin/bash

mkdir -p /app/src/bin
cd /app/src/applets/FIDO2Applet
JC_HOME=/app/sdks/jc304_kit ./gradlew buildJavaCard classes
cp /app/src/applets/FIDO2Applet/build/javacard/*.cap /app/src/bin/
