#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build openjavacard-ndef
patch_version $BUILD/applet-advanced/src/main/java/org/openjavacard/ndef/advanced/NdefApplet.java
patch_version $BUILD/applet-full/src/main/java/org/openjavacard/ndef/full/NdefApplet.java
patch_version $BUILD/applet-stub/src/main/java/org/openjavacard/ndef/stub/NdefApplet.java
patch_version $BUILD/applet-tiny/src/main/java/org/openjavacard/ndef/tiny/NdefApplet.java
cd $BUILD
cp -f /app/src/scripts/compile/res/openjavacard-ndef.build.xml build.xml
ant -DJAVACARD_HOME=/app/sdks/jc222_kit build
cd build/javacard
cp *full.cap *tiny.cap /app/src/bin/