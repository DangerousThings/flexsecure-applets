#!/bin/bash

mkdir -p /app/src/bin
cd /app/src/applets/FIDO2Applet
JC_HOME=/app/sdks/jc304_kit ./gradlew -PPackageID=A0000006472F0001 -PApplicationID=A0000006472F000101 buildJavaCard classes
cp /app/src/applets/FIDO2Applet/build/javacard/*.cap /app/src/bin/
