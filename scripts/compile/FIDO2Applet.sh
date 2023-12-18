#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build FIDO2Applet
cd $BUILD
JC_HOME=/app/sdks/jc304_kit ./gradlew -PPackageID=A0000006472F0001 -PApplicationID=A0000006472F000101 buildJavaCard classes
cp $BUILD/build/javacard/*.cap /app/src/bin/
