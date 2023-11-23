#!/bin/bash

mkdir -p /app/src/bin
cd /app/src/applets/FIDO2Applet
JC_HOME=/app/sdks/jc304_kit ./gradlew -PPackageID='A0:00:00:06:47:2F:00:01' -PApplicationID='A0:00:00:06:47:2F:00:01:01' buildJavaCard classes
cp /app/src/applets/FIDO2Applet/build/javacard/*.cap /app/src/bin/
