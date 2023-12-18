#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build openjavacard-ndef
cd $BUILD
cp /app/src/scripts/compile/res/openjavacard-ndef.build.xml .
ant -DJAVACARD_HOME=/app/sdks/jc222_kit -buildfile openjavacard-ndef.build.xml build
cd build/javacard
cp *full.cap *tiny.cap /app/src/bin/