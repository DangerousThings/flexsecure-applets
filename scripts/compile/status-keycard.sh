#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build status-keycard
cd $BUILD
JC_HOME=/app/sdks/jc304_kit ./gradlew convertJavacard
cp $BUILD/build/javacard/im/status/keycard/javacard/*.cap /app/src/bin/
