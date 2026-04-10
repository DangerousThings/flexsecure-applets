#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build status-keycard
patch_version $BUILD/src/main/java/im/status/keycard/CashApplet.java
patch_version $BUILD/src/main/java/im/status/keycard/IdentApplet.java
patch_version $BUILD/src/main/java/im/status/keycard/KeycardApplet.java
patch_version $BUILD/src/main/java/im/status/keycard/NDEFApplet.java
rm -rf $BUILD/buildSrc
sed -i \
  -e '/im\.status\.keycard\.build\./d' \
  -e '/if (testTarget == .card.)/,/^}/d' \
  $BUILD/build.gradle
cd $BUILD
./gradlew convertJavacard
cp $BUILD/build/javacard/im/status/keycard/javacard/*.cap /app/src/bin/
