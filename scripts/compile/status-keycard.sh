#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build status-keycard
patch_version $BUILD/src/main/java/im/status/keycard/CashApplet.java
patch_version $BUILD/src/main/java/im/status/keycard/IdentApplet.java
patch_version $BUILD/src/main/java/im/status/keycard/KeycardApplet.java
patch_version $BUILD/src/main/java/im/status/keycard/NDEFApplet.java
cd $BUILD
JC_HOME=/app/sdks/jc304_kit ./gradlew convertJavacard
cp $BUILD/build/javacard/im/status/keycard/javacard/*.cap /app/src/bin/
